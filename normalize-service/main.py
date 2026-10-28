
from fastapi import FastAPI
from hashlib import sha256
from datetime import datetime, timezone
from urllib.parse import urlsplit, urlunsplit, parse_qsl, urlencode

app = FastAPI(title="SupplierWatch API")


@app.get("/")
def health_check():
    return {
        "status": "running",
        "service": "SupplierWatch Python API"
    }


@app.post("/normalize")
def normalize_articles(payload: dict):
    articles = payload.get("articles", [])
    normalized = []

    tracking_keys = {"oc", "ved", "usg", "hl"}

    for article in articles:
        supplier = str(article.get("supplier", "")).strip()
        title = str(article.get("title", "")).strip()
        raw_url = str(
            article.get("link") or article.get("url") or ""
        ).strip()

        canonical_url = raw_url

        try:
            parts = urlsplit(raw_url)
            query = [
                (key, value)
                for key, value in parse_qsl(parts.query)
                if not key.lower().startswith("utm_")
                and key.lower() not in tracking_keys
            ]

            canonical_url = urlunsplit((
                parts.scheme,
                parts.netloc,
                parts.path,
                urlencode(query),
                ""
            ))
        except ValueError:
            pass

        hash_input = (
            canonical_url
            if canonical_url
            else supplier.lower() + "|" + title.lower()
        )

        normalized.append({
            "supplier": supplier,
            "title": title,
            "url": canonical_url,
            "published_at": (
                article.get("isoDate")
                or article.get("pubDate")
            ),
            "summary": str(
                article.get("contentSnippet")
                or article.get("content")
                or ""
            ).strip(),
            "source_hash": sha256(
                hash_input.encode("utf-8")
            ).hexdigest(),
            "processed_at": datetime.now(
                timezone.utc
            ).isoformat()
        })

    return {
        "count": len(normalized),
        "articles": normalized
    }
