from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="FastAPI Docker Optimized Demo")


class Item(BaseModel):
    id: int
    name: str
    price: float


@app.get("/healthz")
def health() -> dict:
    return {"status": "ok"}


@app.get("/")
def root() -> dict:
    return {"message": "Hello from a lean FastAPI Docker image!"}


@app.post("/items", response_model=Item)
def create_item(item: Item) -> Item:
    # Echo back as a stub; in real apps you'd persist to DB, etc.
    return item


# Allow local dev without gunicorn:
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
