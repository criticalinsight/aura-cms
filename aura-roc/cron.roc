app "aura-cron"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        pf.Process,
    ]
    provides [main] to pf

main =
    Stdout.line "Starting Aura-Cron Service..."
    |> Task.await \_ ->
    loop {}

loop : {} -> Task {} []
loop _ =
    Stdout.line "Running Hourly Task..."
    |> Task.await \_ ->
    
    # 1. Shell out to main.roc (headless)
    cmd = Process.exec "roc" ["run", "main.roc", "--", "--prompt", "Analyze 13F"]
    
    # Wait for result (in real Roc, check exit code)
    # Then wait 1 hour
    Task.sleep 3600_000 
    |> Task.await \_ ->
    loop {}
