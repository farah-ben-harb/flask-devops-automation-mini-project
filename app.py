import os
import time

from flask import Flask, Response, g, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest


REQUEST_COUNT = Counter(
    "flask_http_requests_total",
    "Total number of HTTP requests handled by the Flask application.",
    ["method", "endpoint", "status_code"],
)

REQUEST_LATENCY = Histogram(
    "flask_http_request_duration_seconds",
    "HTTP request latency in seconds.",
    ["method", "endpoint"],
)


def create_app():
    app = Flask(__name__)

    @app.before_request
    def start_request_timer():
        g.request_start_time = time.perf_counter()

    @app.after_request
    def record_request_metrics(response):
        endpoint = request.url_rule.rule if request.url_rule else request.path
        duration = time.perf_counter() - getattr(g, "request_start_time", time.perf_counter())

        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=endpoint,
            status_code=response.status_code,
        ).inc()
        REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=endpoint,
        ).observe(duration)

        return response

    @app.get("/")
    def home():
        return jsonify(
            {
                "message": "Hello from CI/CD Demo!",
                "status": "running",
            }
        )

    @app.get("/health")
    def health():
        return jsonify({"status": "ok"}), 200

    @app.get("/metrics")
    def metrics():
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

    return app


app = create_app()


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    debug = os.getenv("FLASK_DEBUG", "0") == "1"
    app.run(host="0.0.0.0", port=port, debug=debug)
