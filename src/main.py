import logging
from azure.monitor.opentelemetry import configure_azure_monitor
from fastapi import FastAPI
from pydantic import BaseModel

configure_azure_monitor() # Only for Biceps or Terraform (Not K8s)

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("app_logger")

app = FastAPI()

# Model for /greetings endpoint
class GreetingRequest(BaseModel):
    name: str

@app.post("/greetings")
async def greetings(request: GreetingRequest):
    logger.info("Greetings endpoint was called with name: %s", request.name)
    return {"message": f"Hello {request.name}!"}

@app.get("/movies")
async def movies():
    logger.info("Movies endpoint was called")
    return {
        "movies": [
            {"title": "Titanic", "year": 1997, "type": "Drama"},
            {"title": "Rambo", "year": 1982, "type": "War"},
            {"title": "Scarface", "year": 1983, "type": "Crime"}
        ]
    }

@app.get("/health")
async def health():
    logger.info("Health check endpoint was called")
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

@app.get("/error")
async def cause_error():
    # this endpoint is designed to cause an error for testing purposes
    try:
        1 / 0
    except ZeroDivisionError:
        logger.exception("an error occurred dividing by zero")
        return {"error": "Oops!"}