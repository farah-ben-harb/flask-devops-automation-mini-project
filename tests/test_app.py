from app import create_app


def test_home_route_returns_message():
    app = create_app()

    with app.test_client() as client:
        response = client.get("/")

    assert response.status_code == 200
    assert response.get_json() == {
        "message": "Hello from CI/CD Demo!",
        "status": "running",
    }


def test_health_route_returns_ok():
    app = create_app()

    with app.test_client() as client:
        response = client.get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_metrics_route_exposes_prometheus_format():
    app = create_app()

    with app.test_client() as client:
        client.get("/")
        client.get("/health")
        response = client.get("/metrics")

    assert response.status_code == 200
    assert response.mimetype == "text/plain"
    body = response.get_data(as_text=True)
    assert "flask_http_requests_total" in body
    assert "flask_http_request_duration_seconds_count" in body
