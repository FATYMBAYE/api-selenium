from fastapi.testclient import TestClient
from app.api import app

client = TestClient(app)

def test_add():
    response = client.get("/add?a=2&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 5}

def test_subtract():
    response = client.get("/subtract?a=5&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 2}

def test_multiply():
    response = client.get("/multiply?a=4&b=3")
    assert response.status_code == 200
    assert response.json() == {"result": 12}

def test_divide():
    response = client.get("/divide?a=10&b=2")
    assert response.status_code == 200
    assert response.json() == {"result": 5.0}

def test_divide_by_zero():
    response = client.get("/divide?a=10&b=0")
    assert response.status_code == 400
    assert response.json()["detail"] == "Division by zero is not allowed"
