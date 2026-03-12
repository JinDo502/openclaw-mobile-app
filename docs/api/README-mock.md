# OpenClaw Mobile Mock Server (P0)

## Quick start

```bash
cd mock-server
npm run dev
```

Default:
- BaseURL: `http://localhost:8787`
- Auth: **not required**

Require auth (optional):

```bash
MOCK_REQUIRE_AUTH=1 npm run dev
```

Then requests must include:
- `Authorization: Bearer atk_mock`

## Endpoints

- `GET /health`

Nodes
- `GET /node.get?nodeId=n1`
- `GET /node.stats?nodeId=n1&preset=1h`

Runs
- `GET /run.list?status=failed&limit=50&offset=0`
- `GET /run.get?runId=r1`

Logs
- `GET /logs.query?runId=r1&level=error&keyword=timeout&limit=100&offset=0`
  - rule: `runId` or `nodeId` required

Alerts
- `GET /alerts.list?status=open&severity=high&limit=50&offset=0`
- `GET /alerts.get?alertId=a1`
- `POST /alerts.ack` body: `{ "alertId": "a1", "note": "ack" }`
- `POST /alerts.resolve` body: `{ "alertId": "a1", "note": "resolve" }`

## cURL examples

```bash
curl -sS 'http://localhost:8787/health'
curl -sS 'http://localhost:8787/node.get?nodeId=n1'
curl -sS 'http://localhost:8787/node.stats?nodeId=n1&preset=1h'
curl -sS 'http://localhost:8787/run.list?status=failed&limit=50&offset=0'
curl -sS 'http://localhost:8787/run.get?runId=r1'
curl -sS 'http://localhost:8787/logs.query?runId=r1&limit=10&offset=0'
curl -sS 'http://localhost:8787/alerts.list?limit=10&offset=0'
curl -sS 'http://localhost:8787/alerts.get?alertId=a1'
curl -sS -X POST 'http://localhost:8787/alerts.ack' -H 'content-type: application/json' -d '{"alertId":"a1","note":"ack"}'
```

## Contract docs

- `docs/api/openclaw-mobile.md`
- `docs/api/openclaw-mobile.openapi.yaml`
