#!/usr/bin/env python3
"""PPT Studio — Backend Server with Higgsfield AI integration."""
import http.server
import socketserver
import os
import sys
import json
import signal
import urllib.request
import urllib.parse
import threading

PORT = 3848
BASE = os.path.dirname(os.path.abspath(__file__))

# Higgsfield API
HF_BASE = "https://platform.higgsfield.ai"
HF_KEYS = [
    "3b4d1846-57ca-4510-a2e4-99bf892f14c6:9ae8f8f61824f431bd7e202fe76d303e6f04fa12a1f1c70860b205c10c5420ec",
    "32c86517-b17d-4702-ab36-47d86edd9b88:9fb20f6bd83b82304c97bf044e35e0c974899b93740faa664addba49335d60f7",
]
HF_KEY = HF_KEYS[0]


def hf_request(path, data=None):
    """Make a Higgsfield API request."""
    url = f"{HF_BASE}/{path}"
    headers = {
        "Authorization": f"Key {HF_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method="POST" if data else "GET")
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        return {"error": str(e)}


class StudioHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length > 0 else {}

        if self.path == "/api/save-tony-photo":
            import base64
            fname = body.get("filename", "tony.jpg")
            data = body.get("data", "")
            # Strip data URI prefix
            if "," in data:
                data = data.split(",", 1)[1]
            raw = base64.b64decode(data)
            tony_dir = os.path.join(BASE, "assets", "tony")
            os.makedirs(tony_dir, exist_ok=True)
            fpath = os.path.join(tony_dir, fname)
            with open(fpath, "wb") as f:
                f.write(raw)
            self._json_response({"saved": fpath, "size": len(raw)})

        elif self.path == "/api/higgsfield/image":
            result = hf_request(body.get("model", "higgsfield-ai/soul/standard"), {
                "prompt": body.get("prompt", ""),
                "aspect_ratio": body.get("aspect_ratio", "16:9"),
                "resolution": body.get("resolution", "720p"),
            })
            self._json_response(result)

        elif self.path == "/api/higgsfield/video":
            params = {
                "image_url": body.get("image_url", ""),
                "prompt": body.get("prompt", ""),
            }
            if body.get("tail_image_url"):
                params["tail_image_url"] = body["tail_image_url"]
            if body.get("duration"):
                params["duration"] = body["duration"]
            result = hf_request(body.get("model", "kling-video/v2.1/pro/image-to-video"), params)
            self._json_response(result)

        elif self.path == "/api/higgsfield/status":
            rid = body.get("request_id", "")
            result = hf_request(f"requests/{rid}/status")
            self._json_response(result)

        elif self.path == "/api/save-presentation":
            fname = body.get("filename", "presentation.html")
            content = body.get("content", "")
            outpath = os.path.join(BASE, "output", fname)
            with open(outpath, "w") as f:
                f.write(content)
            self._json_response({"saved": outpath})

        else:
            self._json_response({"error": "unknown endpoint"}, 404)

    def _json_response(self, data, code=200):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, fmt, *args):
        pass  # Silent


def main():
    os.makedirs(os.path.join(BASE, "output"), exist_ok=True)
    os.makedirs(os.path.join(BASE, "assets"), exist_ok=True)
    with socketserver.TCPServer(("", PORT), StudioHandler) as httpd:
        httpd.allow_reuse_address = True
        print(f"PPT Studio running at http://localhost:{PORT}")
        sys.stdout.flush()
        signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))
        signal.signal(signal.SIGTERM, lambda s, f: sys.exit(0))
        httpd.serve_forever()


if __name__ == "__main__":
    main()
