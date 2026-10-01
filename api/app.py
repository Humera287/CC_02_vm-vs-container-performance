from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/compute")
def compute():
    total = 0
    for i in range(1000000):
        total += i
    return {"result": total}

@app.get("/memory")
def memory():
    data = [0] * 1000000
    return {"size": len(data)}
