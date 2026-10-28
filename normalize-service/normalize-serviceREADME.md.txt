# Normalize service

Small FastAPI service used by the SupplierWatch Workflow 01. It takes the articles fetched from Google News RSS and returns them in one clean format:
- strips tracking parameters (utm_*, oc, ved, usg, hl) from the URL
- builds a SHA-256 hash from the cleaned URL (or from supplier + title if there is no URL), used for dedupe
- returns supplier, title, url, published_at, summary, source_hash, processed_at

## Run (Windows)
cd normalize-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8000

Check it: open http://127.0.0.1:8000/ and you should see {"status":"running", ...}.
Interactive docs: http://127.0.0.1:8000/docs

## Endpoints
- GET /          health check
- POST /normalize   body: {"articles": [ ... ]}  ->  {"count": n, "articles": [ ... ]}