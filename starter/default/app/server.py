"""__MODULE__ — bee starter 골격. 앱 본체로 교체하라."""
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8080


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({
            "module": "__MODULE__",
            "env": os.environ.get("BEE_ENV", "unknown"),
            "host": socket.gethostname(),
            "path": self.path,
        }).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f"{self.address_string()} {fmt % args}")


if __name__ == "__main__":
    print(f"__MODULE__ listening :{PORT}")
    HTTPServer(("", PORT), Handler).serve_forever()
