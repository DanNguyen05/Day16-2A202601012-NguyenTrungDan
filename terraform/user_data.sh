#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting CPU fallback OpenAI-compatible API"

dnf install -y python3

cat > /opt/cpu_api.py << 'PY'
import json
import time
import uuid
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self._send_json(200, {"status": "ok"})
            return
        self._send_json(404, {"error": "not found"})

    def do_POST(self):
        if self.path != "/v1/chat/completions":
            self._send_json(404, {"error": "not found"})
            return

        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            request = json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError:
            request = {}

        model = request.get("model", "cpu-fallback-lightgbm-api")
        messages = request.get("messages", [])
        user_message = ""
        for message in reversed(messages):
            if message.get("role") == "user":
                user_message = message.get("content", "")
                break

        content = (
            "Bastion Host trong AWS là một máy chủ trung gian nằm ở public subnet. "
            "Người dùng SSH vào Bastion trước, sau đó từ Bastion mới truy cập các máy "
            "trong private subnet như CPU/GPU node. Cách này giúp không phải mở public IP "
            "cho máy xử lý chính, giảm bề mặt tấn công và kiểm soát truy cập tốt hơn."
        )
        if user_message:
            content += f" Câu hỏi đã nhận: {user_message}"

        response = {
            "id": f"chatcmpl-{uuid.uuid4().hex[:12]}",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": model,
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": content,
                    },
                    "finish_reason": "stop",
                }
            ],
            "usage": {
                "prompt_tokens": 0,
                "completion_tokens": len(content.split()),
                "total_tokens": len(content.split()),
            },
        }
        self._send_json(200, response)

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8000), Handler)
    server.serve_forever()
PY

nohup python3 /opt/cpu_api.py > /var/log/cpu-api.log 2>&1 &

echo "CPU fallback API started on port 8000"
