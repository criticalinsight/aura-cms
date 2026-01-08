interface Db
    exposes [
        query,
        saveResearch,
        cacheGet,
        cacheSet,
        initDb,
    ]
    imports [
        pf.Task.{ Task },
        pf.Process,
        pf.File,
        pf.Path,
    ]

# Database file path
dbPath = "local_research.db"

# Initialize database with required tables
initDb : Task Str []
initDb =
    # Create tables if not exist
    createResearchTable = """
        CREATE TABLE IF NOT EXISTS research (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT NOT NULL,
            findings TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    """
    createCacheTable = """
        CREATE TABLE IF NOT EXISTS cache (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            expires_at INTEGER NOT NULL
        );
    """
    query createResearchTable
    |> Task.await \_ ->
    query createCacheTable

# Execute SQL query
query : Str -> Task Str []
query sql =
    Process.exec "duckdb" [dbPath, sql]
    |> Task.map \_ -> "Query executed."
    |> Task.onErr \_ -> Task.ok "Query failed."

# Save research results
saveResearch : Str, Str -> Task Str []
saveResearch topic content =
    safeContent = Str.replaceEach content "'" "''"
    safeTopic = Str.replaceEach topic "'" "''"
    sql = "INSERT INTO research (topic, findings) VALUES ('$(safeTopic)', '$(safeContent)')"
    query sql

# Cache: Get value by key (returns empty string if not found or expired)
cacheGet : Str -> Task Str []
cacheGet key =
    safeKey = Str.replaceEach key "'" "''"
    # Get value if not expired (expires_at > current unix timestamp)
    sql = "SELECT value FROM cache WHERE key = '$(safeKey)' AND expires_at > strftime('%s', 'now') LIMIT 1;"
    Process.exec "duckdb" [dbPath, "-csv", "-noheader", sql]
    |> Task.map \output -> 
        when Str.fromUtf8 output is
            Ok s -> Str.trim s
            Err _ -> ""
    |> Task.onErr \_ -> Task.ok ""

# Cache: Set value with TTL in seconds
cacheSet : Str, Str, U64 -> Task Str []
cacheSet key value ttlSeconds =
    safeKey = Str.replaceEach key "'" "''"
    safeValue = Str.replaceEach value "'" "''"
    # Use INSERT OR REPLACE for upsert behavior
    sql = """
        INSERT OR REPLACE INTO cache (key, value, expires_at) 
        VALUES ('$(safeKey)', '$(safeValue)', strftime('%s', 'now') + $(Num.toStr ttlSeconds));
    """
    query sql
