app "aura-roc"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stdin,
        pf.Task.{ Task },
        pf.Http,
        pf.Arg,
    ]
    provides [main] to pf

version = "1.0.0"

helpText =
    """
    Aura-Roc CLI v$(version)
    
    USAGE:
        roc run main.roc [OPTIONS]
    
    OPTIONS:
        --help, -h           Show this help message
        --version, -v        Show version information
        --prompt TEXT        Run one-shot mode with the given prompt
        --research TOPIC     Deep research mode with multiple queries
    
    EXAMPLES:
        roc run main.roc                              # Interactive mode
        roc run main.roc -- --prompt "Explain AI"     # One-shot mode
        roc run main.roc -- --research "Quantum ML"   # Deep research mode
    
    In interactive mode, type 'exit' to quit.
    """

main =
    args <- Arg.list |> Task.await
    
    if List.len args > 1 then
        handleArgs args
    else
        interactiveLoop

handleArgs : List Str -> Task {} []
handleArgs args =
    when List.get args 1 is
        Ok arg ->
            if arg == "--help" || arg == "-h" then
                Stdout.line helpText
            else if arg == "--version" || arg == "-v" then
                Stdout.line "aura-roc v$(version)"
            else if arg == "--prompt" then
                when List.get args 2 is
                    Ok prompt ->
                        runOneShot prompt
                    Err _ -> 
                        Stdout.line "Error: --prompt requires a text argument."
            else if arg == "--research" then
                when List.get args 2 is
                    Ok topic ->
                        runResearch topic
                    Err _ -> 
                        Stdout.line "Error: --research requires a topic argument."
            else
                Stdout.line "Unknown argument: $(arg)\nRun with --help for usage."
        Err _ -> 
            Stdout.line "Error: Failed to parse arguments."

runOneShot : Str -> Task {} []
runOneShot prompt =
    Stdout.line "→ Running One-Shot Mode..."
    |> Task.await \_ ->
    callAgent prompt
    |> Task.await \resp ->
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "Agent Response:"
    |> Task.await \_ ->
    Stdout.line resp

runResearch : Str -> Task {} []
runResearch topic =
    Stdout.line "╔══════════════════════════════════════╗"
    |> Task.await \_ ->
    Stdout.line "║     Deep Research Mode               ║"
    |> Task.await \_ ->
    Stdout.line "╚══════════════════════════════════════╝"
    |> Task.await \_ ->
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "Topic: $(topic)"
    |> Task.await \_ ->
    Stdout.line "─────────────────────────────────────────"
    |> Task.await \_ ->
    
    # Step 1: Overview
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "[1/4] Generating overview..."
    |> Task.await \_ ->
    callAgent "Provide a comprehensive overview of: $(topic)"
    |> Task.await \overview ->
    Stdout.line overview
    |> Task.await \_ ->
    
    # Step 2: Key concepts
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "[2/4] Extracting key concepts..."
    |> Task.await \_ ->
    callAgent "List and explain the 5 most important concepts related to: $(topic)"
    |> Task.await \concepts ->
    Stdout.line concepts
    |> Task.await \_ ->
    
    # Step 3: Current trends
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "[3/4] Analyzing current trends..."
    |> Task.await \_ ->
    callAgent "What are the latest trends and developments in: $(topic)"
    |> Task.await \trends ->
    Stdout.line trends
    |> Task.await \_ ->
    
    # Step 4: Future outlook
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "[4/4] Predicting future outlook..."
    |> Task.await \_ ->
    callAgent "What is the future outlook and predictions for: $(topic)"
    |> Task.await \future ->
    Stdout.line future
    |> Task.await \_ ->
    
    Stdout.line ""
    |> Task.await \_ ->
    Stdout.line "─────────────────────────────────────────"
    |> Task.await \_ ->
    Stdout.line "✓ Research complete for: $(topic)"

interactiveLoop : Task {} []
interactiveLoop =
    Stdout.line "╔══════════════════════════════════════╗"
    |> Task.await \_ ->
    Stdout.line "║     Aura-Roc CLI v$(version)              ║"
    |> Task.await \_ ->
    Stdout.line "╚══════════════════════════════════════╝"
    |> Task.await \_ ->
    Stdout.line "Type 'help' for commands, 'exit' to quit."
    |> Task.await \_ ->
    loop {}

loop : {} -> Task {} []
loop _ =
    Stdout.write "\n> "
    |> Task.await \_ ->
    Stdin.line
    |> Task.await \input ->
    
    trimmedInput = Str.trim input
    
    if trimmedInput == "exit" || trimmedInput == "quit" then
        Stdout.line "Goodbye!"
    else if trimmedInput == "help" then
        Stdout.line "Commands:"
        |> Task.await \_ ->
        Stdout.line "  help           - Show this message"
        |> Task.await \_ ->
        Stdout.line "  research TOPIC - Deep research on a topic"
        |> Task.await \_ ->
        Stdout.line "  exit           - Quit the application"
        |> Task.await \_ ->
        Stdout.line "  Or type any query to chat with the agent"
        |> Task.await \_ ->
        loop {}
    else if Str.startsWith trimmedInput "research " then
        topic = Str.dropPrefix trimmedInput "research "
        runResearch topic
        |> Task.await \_ ->
        loop {}
    else if Str.isEmpty trimmedInput then
        loop {}
    else
        Stdout.line "→ Querying agent..."
        |> Task.await \_ ->
        callAgent trimmedInput
        |> Task.await \resp ->
        Stdout.line resp
        |> Task.await \_ ->
        loop {}

callAgent : Str -> Task Str []
callAgent prompt =
    safePrompt = Str.replaceEach prompt "\"" "\\\""
    bodyStr = "{\"prompt\": \"$(safePrompt)\"}"
    
    request = { Http.defaultRequest &
        url: "http://localhost:8000/chat",
        method: Post,
        body: Str.toUtf8 bodyStr,
        headers: [
            { name: "Content-Type", value: "application/json" }
        ]
    }
    
    Http.send request
    |> Task.map \resp ->
        when Str.fromUtf8 resp.body is
            Ok str -> str
            Err _ -> "Error: Failed to decode response."
    |> Task.onErr \_ ->
        Task.ok "Error: Could not connect to server at localhost:8000."
