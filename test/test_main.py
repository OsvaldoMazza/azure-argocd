from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_greetings():
    response = client.post("/greetings", json={"name": "John"})
    assert response.status_code == 200
    assert response.json() == {"message": "Hello John!"}

def test_movies():
    response = client.get("/movies")
    assert response.status_code == 200
    assert response.json() == {
        "movies": [
            {"title": "Titanic", "year": 1997, "type": "Drama"},
            {"title": "Rambo", "year": 1982, "type": "Action"},
            {"title": "Scarface", "year": 1983, "type": "Crime"}
        ]
    }

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}