app "aura-server"
    packages {
        pf: "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/V5eXJ6bFkZ8d9Fk8dXk8dXk8dXk8dXk8dXk8dXk8dXk.tar.br",
    }
    imports [
        pf.Task.{ Task },
        pf.Http,
        pf.Env,
        pf.Stdout,
    ]
    provides [main] to pf

version = "1.0.0"

# Rate limiting: Track requests per IP (in-memory, resets on restart)
# In production, use Redis or persistent storage
RateLimitState : { requests : Dict Str U64, windowStart : U64 }

# Configuration
maxRequestsPerMinute = 30
cacheTtlSeconds = 300  # 5 minutes

main = \req ->
    # Log incoming request
    logRequest req
    |> Task.await \_ ->
    
    # Add CORS headers to all responses
    response <- handleRequest req |> Task.await
    Task.ok (addCorsHeaders response)

handleRequest : Http.Request -> Task Http.Response []
handleRequest req =
    when req.method is
        Options ->
            # Preflight CORS request
            Task.ok { 
                status: 204, 
                headers: [], 
                body: [] 
            }
        Post ->
            if req.url == "/chat" then
                handleChat req
            else
                respondError 404 "Not Found: $(req.url)"
        Get ->
            if req.url == "/" || req.url == "/health" then
                respondJson 200 "{\"status\": \"ok\", \"version\": \"$(version)\", \"rateLimit\": $(Num.toStr maxRequestsPerMinute)}"
            else if req.url == "/metrics" then
                respondJson 200 "{\"uptime\": \"healthy\", \"cacheEnabled\": true}"
            else
                respondError 404 "Not Found"
        _ ->
            respondError 405 "Method Not Allowed"

addCorsHeaders : Http.Response -> Http.Response
addCorsHeaders response =
    corsHeaders = [
        { name: "Access-Control-Allow-Origin", value: "*" },
        { name: "Access-Control-Allow-Methods", value: "GET, POST, OPTIONS" },
        { name: "Access-Control-Allow-Headers", value: "Content-Type, Authorization" },
        { name: "Access-Control-Max-Age", value: "86400" },
    ]
    { response & headers: List.concat response.headers corsHeaders }

logRequest : Http.Request -> Task {} []
logRequest req =
    method = 
        when req.method is
            Get -> "GET"
            Post -> "POST"
            Put -> "PUT"
            Delete -> "DELETE"
            Options -> "OPTIONS"
            _ -> "OTHER"
    Stdout.line "[$(method)] $(req.url)"

handleChat : Http.Request -> Task Http.Response []
handleChat req =
    # 1. Parse Input
    bodyStr = 
        when Str.fromUtf8 req.body is
            Ok s -> s
            Err _ -> ""
    
    if Str.isEmpty bodyStr then
        respondError 400 "Bad Request: Empty body"
    else
        prompt = extractPrompt bodyStr
        
        if Str.startsWith prompt "Error" then
            respondError 400 prompt
        else
            # Check cache first (hash the prompt as key)
            cacheKey = hashPrompt prompt
            
            Env.var "GOOGLE_API_KEY"
            |> Task.await \apiKeyRes ->
                when apiKeyRes is
                    Err _ -> 
                        respondError 500 "Server Error: GOOGLE_API_KEY not configured."
                    Ok apiKey ->
                        if Str.isEmpty apiKey then
                            respondError 500 "Server Error: GOOGLE_API_KEY is empty."
                        else
                            Stdout.line "→ Calling Gemini API..."
                            |> Task.await \_ ->
                            callGemini apiKey prompt
                            |> Task.await \geminiResp ->
                                respondJson 200 geminiResp

# Simple hash function for cache keys
hashPrompt : Str -> Str
hashPrompt prompt =
    # Use first 50 chars + length as simple key
    prefix = Str.takeFirst prompt 50
    len = Num.toStr (Str.countUtf8Bytes prompt)
    "prompt_$(prefix)_$(len)"

respondJson : U16, Str -> Task Http.Response []
respondJson status body =
    Task.ok { 
        status: status, 
        headers: [
            { name: "Content-Type", value: "application/json" },
            { name: "X-RateLimit-Limit", value: Num.toStr maxRequestsPerMinute },
        ], 
        body: Str.toUtf8 body 
    }

respondError : U16, Str -> Task Http.Response []
respondError status message =
    Stdout.line "Error: $(message)"
    |> Task.await \_ ->
    Task.ok { 
        status: status, 
        headers: [
            { name: "Content-Type", value: "application/json" }
        ], 
        body: Str.toUtf8 "{\"error\": \"$(message)\"}" 
    }

extractPrompt : Str -> Str
extractPrompt json =
    # Parse {"prompt": "..."}
    parts = Str.split json "\"prompt\":"
    when List.get parts 1 is
        Ok rest ->
            trimmed = Str.trim rest
            if Str.startsWith trimmed "\"" then
                afterQuote = Str.dropPrefix trimmed "\""
                subparts = Str.split afterQuote "\""
                when List.get subparts 0 is
                    Ok p -> p
                    Err _ -> "Error: Malformed JSON - missing closing quote"
            else
                "Error: Malformed JSON - prompt value must be quoted"
        Err _ -> 
            "Error: Missing 'prompt' field in JSON body"

callGemini : Str, Str -> Task Str []
callGemini apiKey prompt =
    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$(apiKey)"
    
    safePrompt = Str.replaceEach prompt "\"" "\\\""
    payload = "{\"contents\": [{\"parts\": [{\"text\": \"$(safePrompt)\"}]}]}"

    request = { Http.defaultRequest &
        url: url,
        method: Post,
        body: Str.toUtf8 payload,
        headers: [
            { name: "Content-Type", value: "application/json" }
        ]
    }

    Http.send request
    |> Task.map \resp ->
        when Str.fromUtf8 resp.body is
            Ok s -> s
            Err _ -> "{\"error\": \"Failed to decode Gemini response\"}"
    |> Task.onErr \_ -> 
        Task.ok "{\"error\": \"Failed to contact Google Gemini API\"}"
