import 'package:flutter/material.dart';

import '../api/client.dart';
import '../api/models.dart';
import 'node_detail_screen.dart';

class NodesScreen extends StatefulWidget {
  const NodesScreen({super.key, required this.api});
  final ApiClient api;

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  late Future<NodeInfo> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<NodeInfo> _load() async {
    final data = await widget.api.getOkData<Map<String, dynamic>>(
      '/node.get',
      queryParameters: {'nodeId': 'n1'},
    );
    return NodeInfo.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NodeInfo>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Load failed: ${snapshot.error}'),
          );
        }
        final node = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = _load());
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ListTile(
                title: Text(node.name),
                subtitle: Text('v${node.version} · heartbeat ${node.lastHeartbeatAt}'),
                trailing: _StatusChip(status: node.status),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NodeDetailScreen(api: widget.api, node: node),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'online' => (Colors.green.shade50, Colors.green.shade700),
      'offline' => (Colors.red.shade50, Colors.red.shade700),
      _ => (Colors.orange.shade50, Colors.orange.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}
