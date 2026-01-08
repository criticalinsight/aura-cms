import http.client
import json

def run_test():
    conn = http.client.HTTPConnection("localhost", 8000)
    payload = {
        "message": "Research 'Zig 0.15.2 performance' and save the results to the research table. Use the research_topic tool."
    }
    headers = {'Content-Type': 'application/json'}
    conn.request("POST", "/chat", json.dumps(payload), headers)
    response = conn.getresponse()
    print(response.read().decode())

if __name__ == "__main__":
    run_test()
