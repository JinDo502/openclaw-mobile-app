import http from 'node:http';
import { URL } from 'node:url';

const PORT = process.env.PORT ? Number(process.env.PORT) : 8787;

function json(res, status, body) {
  const data = JSON.stringify(body);
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
    'access-control-allow-headers': 'content-type,authorization',
  });
  res.end(data);
}

function ok(data) {
  return { ok: true, data };
}

function err(code, message, details) {
  return { ok: false, error: { code, message, ...(details ? { details } : {}) } };
}

const now = Date.now();

const nodes = {
  n1: {
    nodeId: 'n1',
    name: 'mac-mini',
    status: 'online',
    lastHeartbeatAt: now - 5_000,
    version: '1.2.3',
    tags: ['prod'],
    capabilities: ['screen', 'camera', 'canvas'],
    meta: { platform: 'macos', arch: 'x64', osVersion: '21.6.0', clientVersion: 'openclaw-node/1.2.3' },
  },
  n2: {
    nodeId: 'n2',
    name: 'pi-node',
    status: 'offline',
    lastHeartbeatAt: now - 3_600_000,
    version: '1.1.0',
    tags: ['edge'],
    capabilities: ['camera'],
    meta: { platform: 'linux', arch: 'arm64', osVersion: '6.x', clientVersion: 'openclaw-node/1.1.0' },
  },
};

const runs = {
  r1: {
    runId: 'r1',
    name: 'Nightly Backup',
    status: 'failed',
    summary: 'timeout',
    triggerSource: 'cron:backup',
    startedAt: now - 900_000,
    durationMs: 450_000,
    updatedAt: now - 450_000,
    failReason: 'timeout',
    steps: [
      { name: 'prepare', status: 'success', durationMs: 30_000, startedAt: now - 900_000, endedAt: now - 870_000 },
      { name: 'sync', status: 'failed', durationMs: 300_000, startedAt: now - 870_000, endedAt: now - 570_000, error: 'timeout' },
    ],
    related: { nodeId: 'n1', sessionId: 's1' },
  },
  r2: {
    runId: 'r2',
    name: 'Sync Agents',
    status: 'failed',
    summary: 'auth_error',
    triggerSource: 'manual',
    startedAt: now - 2_000_000,
    durationMs: 120_000,
    updatedAt: now - 1_880_000,
    failReason: 'auth_error',
    steps: [
      { name: 'fetch', status: 'failed', durationMs: 5_000, startedAt: now - 2_000_000, endedAt: now - 1_995_000, error: '401' },
    ],
    related: { nodeId: 'n2', sessionId: 's2' },
  },
  r3: {
    runId: 'r3',
    name: 'Build Index',
    status: 'running',
    summary: 'running',
    triggerSource: 'cron:index',
    startedAt: now - 120_000,
    durationMs: 120_000,
    updatedAt: now - 5_000,
    steps: [{ name: 'index', status: 'running', durationMs: 120_000, startedAt: now - 120_000 }],
    related: { nodeId: 'n1', sessionId: 's3' },
  },
};

function requireAuth(req) {
  const h = req.headers['authorization'];
  if (!h) return { ok: false, res: err('AUTH_REQUIRED', 'missing Authorization header') };
  if (!String(h).startsWith('Bearer ')) return { ok: false, res: err('AUTH_UNAUTHORIZED', 'invalid Authorization header') };
  return { ok: true };
}

const server = http.createServer((req, res) => {
  if (!req.url) return json(res, 400, err('INVALID_REQUEST', 'missing url'));
  if (req.method === 'OPTIONS') return json(res, 204, {});

  const url = new URL(req.url, 'http://localhost');
  const path = url.pathname;

  if (path === '/' || path === '/health') return json(res, 200, ok({ status: 'ok' }));

  // auth optional: allow no-auth by env
  if (process.env.MOCK_REQUIRE_AUTH === '1') {
    const a = requireAuth(req);
    if (!a.ok) return json(res, 401, a.res);
  }

  if (path === '/node.get') {
    const nodeId = url.searchParams.get('nodeId');
    if (!nodeId) return json(res, 400, err('INVALID_REQUEST', 'nodeId required'));
    const node = nodes[nodeId];
    if (!node) return json(res, 404, err('NOT_FOUND', 'node not found'));
    return json(res, 200, ok(node));
  }

  if (path === '/node.stats') {
    const nodeId = url.searchParams.get('nodeId');
    if (!nodeId) return json(res, 400, err('INVALID_REQUEST', 'nodeId required'));
    const node = nodes[nodeId];
    if (!node) return json(res, 404, err('NOT_FOUND', 'node not found'));
    const points = [
      { ts: now - 3_600_000, cpuPct: 18, memPct: 61, diskPct: 40, netIn: 800, netOut: 420 },
      { ts: now - 1_800_000, cpuPct: 35, memPct: 68, diskPct: 40, netIn: 1200, netOut: 800 },
    ];
    return json(res, 200, ok({ nodeId, points }));
  }

  if (path === '/run.list') {
    const status = url.searchParams.get('status');
    const limit = Math.max(1, Math.min(200, Number(url.searchParams.get('limit') ?? '50') || 50));
    const offset = Math.max(0, Number(url.searchParams.get('offset') ?? '0') || 0);
    let items = Object.values(runs).map(r => ({
      runId: r.runId,
      name: r.name,
      status: r.status,
      startedAt: r.startedAt,
      durationMs: r.durationMs,
      updatedAt: r.updatedAt,
      ...(r.failReason ? { failReason: r.failReason } : {})
    }));
    if (status) items = items.filter(i => i.status === status);
    const total = items.length;
    items = items.slice(offset, offset + limit);
    return json(res, 200, ok({ total, items }));
  }

  if (path === '/run.get') {
    const runId = url.searchParams.get('runId');
    if (!runId) return json(res, 400, err('INVALID_REQUEST', 'runId required'));
    const run = runs[runId];
    if (!run) return json(res, 404, err('NOT_FOUND', 'run not found'));
    return json(res, 200, ok(run));
  }

  if (path === '/logs.query') {
    const runId = url.searchParams.get('runId');
    const nodeId = url.searchParams.get('nodeId');
    if (!runId && !nodeId) return json(res, 400, err('INVALID_REQUEST', 'runId or nodeId required'));
    const level = url.searchParams.get('level');
    const keyword = url.searchParams.get('keyword');
    const limit = Math.max(1, Math.min(200, Number(url.searchParams.get('limit') ?? '100') || 100));
    const offset = Math.max(0, Number(url.searchParams.get('offset') ?? '0') || 0);

    let entries = [
      { ts: now - 80_000, level: 'info', msg: 'start', source: 'runner', ...(runId ? { runId } : {}), ...(nodeId ? { nodeId } : {}) },
      { ts: now - 60_000, level: 'warn', msg: 'slow step: sync', source: 'runner', ...(runId ? { runId } : {}), ...(nodeId ? { nodeId } : {}) },
      { ts: now - 40_000, level: 'error', msg: 'timeout', source: 'runner', ...(runId ? { runId } : {}), ...(nodeId ? { nodeId } : {}) },
    ];
    if (level) entries = entries.filter(e => e.level === level);
    if (keyword) entries = entries.filter(e => e.msg.includes(keyword));
    const total = entries.length;
    entries = entries.slice(offset, offset + limit);
    return json(res, 200, ok({ total, entries }));
  }

  if (path === '/alerts.list') {
    const status = url.searchParams.get('status');
    const severity = url.searchParams.get('severity');
    const limit = Math.max(1, Math.min(200, Number(url.searchParams.get('limit') ?? '50') || 50));
    const offset = Math.max(0, Number(url.searchParams.get('offset') ?? '0') || 0);

    let items = [
      { alertId: 'a1', severity: 'high', source: 'run', status: 'open', createdAt: now - 30_000, related: { runId: 'r1' } },
      { alertId: 'a2', severity: 'medium', source: 'node', status: 'ack', createdAt: now - 3_600_000, related: { nodeId: 'n2' } },
    ];
    if (status) items = items.filter(i => i.status === status);
    if (severity) items = items.filter(i => i.severity === severity);
    const total = items.length;
    items = items.slice(offset, offset + limit);
    return json(res, 200, ok({ total, items }));
  }

  if (path === '/alerts.get') {
    const alertId = url.searchParams.get('alertId');
    if (!alertId) return json(res, 400, err('INVALID_REQUEST', 'alertId required'));
    const map = {
      a1: { alertId: 'a1', severity: 'high', source: 'run', status: 'open', createdAt: now - 30_000, related: { runId: 'r1' }, detail: 'run failed: timeout' },
      a2: { alertId: 'a2', severity: 'medium', source: 'node', status: 'ack', createdAt: now - 3_600_000, related: { nodeId: 'n2' }, detail: 'node offline' },
    };
    const item = map[alertId];
    if (!item) return json(res, 404, err('NOT_FOUND', 'alert not found'));
    return json(res, 200, ok(item));
  }

  // POST /alerts.ack  body: {alertId, note?}
  // POST /alerts.resolve body: {alertId, note?}
  if (path === '/alerts.ack' || path === '/alerts.resolve') {
    if (req.method !== 'POST') return json(res, 405, err('INVALID_REQUEST', 'method not allowed'));
    let raw = '';
    req.on('data', (c) => (raw += c));
    req.on('end', () => {
      let body;
      try {
        body = raw ? JSON.parse(raw) : {};
      } catch {
        return json(res, 400, err('INVALID_REQUEST', 'invalid json body'));
      }
      const alertId = typeof body.alertId === 'string' ? body.alertId : null;
      if (!alertId) return json(res, 400, err('INVALID_REQUEST', 'alertId required'));

      // idempotency semantics (mock): ack/resolve are idempotent; return 200 with resulting status
      const status = path === '/alerts.ack' ? 'ack' : 'resolved';
      return json(res, 200, ok({ ok: true, status }));
    });
    return;
  }

  return json(res, 404, err('NOT_FOUND', 'route not found'));
});

server.listen(PORT, () => {
  console.log(`openclaw-mobile mock server listening on http://localhost:${PORT}`);
  console.log(`routes: /health, /node.get, /node.stats, /run.list, /run.get`);
  console.log(`auth: ${process.env.MOCK_REQUIRE_AUTH === '1' ? 'required' : 'not required'} (set MOCK_REQUIRE_AUTH=1)`);
});
