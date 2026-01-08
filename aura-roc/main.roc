app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

import pf.Stdout
import pf.Stdin
import pf.Http
import pf.Arg exposing [Arg]

main! : List Arg => Result {} _
main! = |args|
    if List.len(args) > 1 then
        handle_args!(args)
    else
        interactive_loop!({})

handle_args! : List Arg => Result {} _
handle_args! = |args|
    when List.get(args, 1) is
        Ok(arg) ->
            arg_str = Arg.display(arg)
            if arg_str == "--help" || arg_str == "-h" then
                show_help!({})
            else if arg_str == "--version" || arg_str == "-v" then
                Stdout.line!("aura-cms v1.0.0")
            else if arg_str == "--prompt" then
                when List.get(args, 2) is
                    Ok(prompt_arg) ->
                        prompt = Arg.display(prompt_arg)
                        run_one_shot!(prompt)
                    Err(_) -> 
                        Stdout.line!("Error: --prompt requires a text argument.")
            else if arg_str == "--research" then
                when List.get(args, 2) is
                    Ok(topic_arg) ->
                        topic = Arg.display(topic_arg)
                        run_research!(topic)
                    Err(_) -> 
                        Stdout.line!("Error: --research requires a topic argument.")
            else
                Stdout.line!(Str.concat("Unknown argument: ", arg_str))
        Err(_) -> 
            Stdout.line!("Error: Failed to parse arguments.")

show_help! : {} => Result {} _
show_help! = |_|
    Stdout.line!("Aura CMS CLI v1.0.0")?
    Stdout.line!("")?
    Stdout.line!("USAGE: roc main.roc [OPTIONS]")?
    Stdout.line!("")?
    Stdout.line!("OPTIONS:")?
    Stdout.line!("  -h, --help        Show this help")?
    Stdout.line!("  -v, --version     Show version")?
    Stdout.line!("  --prompt TEXT     One-shot query")?
    Stdout.line!("  --research TOPIC  Deep research mode")

run_one_shot! : Str => Result {} _
run_one_shot! = |prompt|
    Stdout.line!("-> Running One-Shot Mode...")?
    resp = call_agent!(prompt)?
    Stdout.line!("")?
    Stdout.line!("Agent Response:")?
    Stdout.line!(resp)

run_research! : Str => Result {} _
run_research! = |topic|
    Stdout.line!("========================================")?
    Stdout.line!("     Deep Research Mode")?
    Stdout.line!("========================================")?
    Stdout.line!("")?
    Stdout.line!(Str.concat("Topic: ", topic))?
    Stdout.line!("----------------------------------------")?
    
    Stdout.line!("")?
    Stdout.line!("[1/4] Generating overview...")?
    overview = call_agent!(Str.concat("Provide a comprehensive overview of: ", topic))?
    Stdout.line!(overview)?
    
    Stdout.line!("")?
    Stdout.line!("[2/4] Extracting key concepts...")?
    concepts = call_agent!(Str.concat("List the 5 most important concepts related to: ", topic))?
    Stdout.line!(concepts)?
    
    Stdout.line!("")?
    Stdout.line!("[3/4] Analyzing current trends...")?
    trends = call_agent!(Str.concat("What are the latest trends in: ", topic))?
    Stdout.line!(trends)?
    
    Stdout.line!("")?
    Stdout.line!("[4/4] Future outlook...")?
    future = call_agent!(Str.concat("Future predictions for: ", topic))?
    Stdout.line!(future)?
    
    Stdout.line!("")?
    Stdout.line!("----------------------------------------")?
    Stdout.line!(Str.concat("Research complete: ", topic))

interactive_loop! : {} => Result {} _
interactive_loop! = |_|
    Stdout.line!("========================================")?
    Stdout.line!("     Aura CMS CLI v1.0.0")?
    Stdout.line!("========================================")?
    Stdout.line!("Type 'help' for commands, 'exit' to quit.")?
    loop!({})

loop! : {} => Result {} _
loop! = |_|
    Stdout.write!("> ")?
    input = Stdin.line!({})?
    trimmed = Str.trim(input)
    
    if trimmed == "exit" || trimmed == "quit" then
        Stdout.line!("Goodbye!")
    else if trimmed == "help" then
        Stdout.line!("Commands: help, exit, research TOPIC")?
        loop!({})
    else if Str.starts_with(trimmed, "research ") then
        topic = Str.replace_first(trimmed, "research ", "")
        run_research!(topic)?
        loop!({})
    else if Str.is_empty(trimmed) then
        loop!({})
    else
        Stdout.line!("-> Querying agent...")?
        resp = call_agent!(trimmed)?
        Stdout.line!(resp)?
        loop!({})

call_agent! : Str => Result Str _
call_agent! = |prompt|
    safe_prompt = Str.replace_each(prompt, "\"", "\\\"")
    body_str = Str.concat(Str.concat("{\"prompt\": \"", safe_prompt), "\"}")
    
    request = { Http.default_request &
        method: POST,
        headers: [Http.header(("Content-Type", "application/json"))],
        uri: "http://localhost:8000/chat",
        body: Str.to_utf8(body_str),
        timeout_ms: TimeoutMilliseconds(30000),
    }
    
    result = Http.send!(request)
    when result is
        Ok(response) ->
            when Str.from_utf8(response.body) is
                Ok(str) -> Ok(str)
                Err(_) -> Ok("Error: Failed to decode response.")
        Err(_) ->
            Ok("Error: Could not connect to server at localhost:8000.")
