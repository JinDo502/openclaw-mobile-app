class NodeInfo {
  NodeInfo({
    required this.nodeId,
    required this.name,
    required this.status,
    required this.lastHeartbeatAt,
    required this.version,
  });

  final String nodeId;
  final String name;
  final String status;
  final int lastHeartbeatAt;
  final String version;

  factory NodeInfo.fromJson(Map<String, dynamic> json) => NodeInfo(
        nodeId: (json['nodeId'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        lastHeartbeatAt: (json['lastHeartbeatAt'] ?? 0) as int,
        version: (json['version'] ?? '').toString(),
      );
}

class RunListItem {
  RunListItem({
    required this.runId,
    required this.name,
    required this.status,
    required this.startedAt,
    required this.durationMs,
    required this.updatedAt,
    this.failReason,
  });

  final String runId;
  final String name;
  final String status;
  final int startedAt;
  final int durationMs;
  final int updatedAt;
  final String? failReason;

  factory RunListItem.fromJson(Map<String, dynamic> json) => RunListItem(
        runId: (json['runId'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        startedAt: (json['startedAt'] ?? 0) as int,
        durationMs: (json['durationMs'] ?? 0) as int,
        updatedAt: (json['updatedAt'] ?? 0) as int,
        failReason: json['failReason']?.toString(),
      );
}
