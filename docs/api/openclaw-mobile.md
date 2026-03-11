# OpenClaw Mobile App — API Contract (M1)

Status: **Draft for FE/QA integration**

## Conventions

- Auth header (when enabled): `Authorization: Bearer <accessToken>`
- Pagination: `limit` (1..200, default 50), `offset` (>=0, default 0)
- Time: **milliseconds** epoch
- Envelope:
  - success: `{ ok: true, data: ... }`
  - error: `{ ok: false, error: { code, message, details? } }`

### Error codes
- `INVALID_REQUEST` (validation)
- `NOT_FOUND`
- `AUTH_REQUIRED`
- `AUTH_UNAUTHORIZED`
- `AUTH_FORBIDDEN`

---

## Nodes

### GET /node.get
Query: `nodeId` (required)

Response `data`:
- `nodeId: string`
- `name: string`
- `status: online|offline|degraded|unknown`
- `lastHeartbeatAt: number(ms)`
- `version: string`
- `tags: string[]`
- `capabilities: string[]`
- `meta: { platform, arch, osVersion, clientVersion }`

### GET /node.stats
Query: `nodeId` (required), `preset` optional (`5m|1h|24h|7d`)

Response `data`:
- `nodeId: string`
- `points: Array<{ ts, cpuPct, memPct, diskPct, netIn, netOut }>`

---

## Runs

### GET /run.list
Query:
- `status` optional (`queued|running|paused|stopped|failed|success`)
- `limit`, `offset`

Response `data`:
- `total: number`
- `items: Array<{ runId,name,status,startedAt,durationMs,updatedAt,failReason? }>`

### GET /run.get
Query: `runId` (required)

Response `data`:
- `runId,name,status,summary,triggerSource`
- `startedAt,durationMs,updatedAt`
- `steps: Array<{ name,status,durationMs,startedAt,endedAt?,error? }>`
- `related: { nodeId?, sessionId? }`

---

## Logs

### GET /logs.query
Query:
- `runId` or `nodeId` (**one required**)
- `level` optional (`debug|info|warn|error`)
- `keyword` optional
- `limit`, `offset`

Response `data`:
- `total: number`
- `entries: Array<{ ts, level, msg, source, runId?, nodeId? }>`

---

## Alerts

### GET /alerts.list
Query:
- `status` optional (`open|ack|resolved`)
- `severity` optional (`low|medium|high|critical`)
- `limit`, `offset`

Response `data`:
- `total: number`
- `items: Array<{ alertId,severity,source,status,createdAt,related }>`

`related` schema (M1):
- `{ runId?: string, nodeId?: string, sessionId?: string }` (may include one or more keys)

### GET /alerts.get
Query: `alertId` (required)

Response `data`:
- `alertId,severity,source,status,createdAt,related,detail`

### POST /alerts.ack
Body: `{ alertId: string, note?: string }`

Response `data`:
- `{ ok: true, status: "ack" }`

**Idempotency**: repeated calls return **200** with the resulting status.

### POST /alerts.resolve
Body: `{ alertId: string, note?: string }`

Response `data`:
- `{ ok: true, status: "resolved" }`

**Idempotency**: repeated calls return **200** with the resulting status.
