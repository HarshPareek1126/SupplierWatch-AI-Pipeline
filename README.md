# SupplierWatch

Know your supplier is in trouble before they tell you.

A free, self-hosted early-warning system for supply-chain risk. It watches public news for chosen suppliers, classifies each headline with an LLM, scores the risk, and sends Telegram alerts and a daily digest.

## How it works
Google News RSS -> normalize and hash -> skip already-seen -> relevance filter -> LLM classification -> risk score -> Supabase -> Telegram alert (score >= 45) + daily digest (8:00)

## Workflows (workflows/)
- 01 Ingest and Score: every 3 hours
- 02 Daily Digest: every day at 8:00, AI summary of medium-risk events (score 20 to 44)
- 03 Error Handler: Telegram alert when a workflow fails
- 04 Evaluation: manual run on hand-labeled headlines, reports precision and recall

## Stack
n8n (self-hosted), Ollama (qwen2.5:1.5b), Supabase (PostgreSQL), Telegram bot, a small FastAPI service (normalize-service/)

## Repository layout
- workflows/ exported n8n workflows
- sql/schema.sql database tables
- normalize-service/ FastAPI service used by workflow 01
- docs/classifier-prompt.md the LLM classification prompt

## Setup
1. Create a Supabase project and run sql/schema.sql in the SQL Editor.
2. Create a Telegram bot with BotFather and find your chat ID.
3. Install n8n and Ollama, and pull qwen2.5:1.5b.
4. Start the normalize service (see normalize-service/README.md). It must run on http://127.0.0.1:8000.
5. In n8n, create credentials for Supabase, Telegram and Ollama.
6. Import each file from workflows/ (workflow menu -> Import from file) and select your credentials.
7. Replace YOUR_TELEGRAM_CHAT_ID in the Telegram nodes with your chat ID.
8. Publish workflows 01, 02 and 03. Keep 04 unpublished and run it manually.
9. On Windows, if Telegram times out, start n8n with NODE_OPTIONS=--dns-result-order=ipv4first.

## Results
[Add after running workflow 04: number of labeled headlines, precision, recall.]

## Limitations
- Runs locally, so it only works while the machine, n8n, Ollama and the normalize service are running.
- Evaluation set is small, so results are indicative.
- Some analyst commentary may still be classified as events.
- Only Google News RSS is used as a data source.