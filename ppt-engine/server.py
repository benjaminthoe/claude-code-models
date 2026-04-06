#!/usr/bin/env python3
"""
Keynote PPT Generator - Live Preview Server
Serves generated presentations from the output directory.
"""
import http.server
import socketserver
import os
import sys
import json
import signal

PORT = 3847
BASE = os.path.dirname(os.path.abspath(__file__))
OUTPUT = os.path.join(BASE, "output")


class PresentationHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=OUTPUT, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def log_message(self, format, *args):
        sys.stdout.write(f"[PPT-Preview] {args[0]}\n")
        sys.stdout.flush()


def main():
    os.makedirs(OUTPUT, exist_ok=True)

    # Write a default index if none exists
    index = os.path.join(OUTPUT, "index.html")
    if not os.path.exists(index):
        with open(index, "w") as f:
            f.write("<html><body style='background:#0b0b1a;color:#f1f5f9;font-family:Inter,sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0'><h1>Waiting for presentation...</h1></body></html>")

    handler = PresentationHandler
    with socketserver.TCPServer(("", PORT), handler) as httpd:
        print(f"[PPT-Preview] Serving presentations at http://localhost:{PORT}")
        sys.stdout.flush()
        signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))
        httpd.serve_forever()


if __name__ == "__main__":
    main()
