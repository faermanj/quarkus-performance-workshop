# make_requests.py
import requests

print("Warming up")

for i in range(1, 43):
    print(f"Sending request {i}")
    try:
        # Replace the URLs with your actual endpoints
        requests.get("http://your_service:9999/members/333/balance")
        requests.post("http://your_service:9999/members/333/transactions",
                      json={"amount": 0, "kind": "d", "description": "warmup"})
    except requests.RequestException as e:
        print(f"Request {i} failed: {e}")

print("Warmup done")
