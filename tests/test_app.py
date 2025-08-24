import pytest
from app import app
import json

@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    """Test the health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["status"] == "ok"

def test_root_endpoint(client):
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert "message" in data
    assert "Hello, CI/CD with Flask!" in data["message"]
    assert "version" in data
    assert "timestamp" in data

def test_root_endpoint_structure(client):
    """Test the structure of the root endpoint response."""
    response = client.get("/")
    data = json.loads(response.data)
    
    # Check all required fields are present
    required_fields = ["message", "version", "timestamp"]
    for field in required_fields:
        assert field in data, f"Missing field: {field}"
    
    # Check data types
    assert isinstance(data["message"], str)
    assert isinstance(data["version"], str)
    assert isinstance(data["timestamp"], str)

def test_404_endpoint(client):
    """Test that non-existent endpoints return 404."""
    response = client.get("/nonexistent")
    assert response.status_code == 404

def test_method_not_allowed(client):
    """Test that POST to GET endpoints returns 405."""
    response = client.post("/health")
    assert response.status_code == 405
