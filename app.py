from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify(status="ok"), 200

@app.get("/")
def root():
    version = os.getenv("APP_VERSION", "1.0.0")
    return jsonify(
        message="Hello, CI/CD with Flask123!",
        version=version,
        timestamp=os.getenv("BUILD_TIMESTAMP", "unknown")
    ), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
# Updated at Sun Aug 24 01:47:18 EDT 2025
# Updated at Sun Aug 24 01:55:57 EDT 2025
# Updated at Sun Aug 24 02:10:34 EDT 2025
# Updated at Sun Aug 24 11:54:16 EDT 2025
# Auto-trigger test at Sun Aug 24 12:12:55 EDT 2025
