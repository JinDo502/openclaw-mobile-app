import 'package:flutter/material.dart';

import '../api/client.dart';
import '../api/models.dart';

class NodeDetailScreen extends StatefulWidget {
  const NodeDetailScreen({super.key, required this.api, required this.node});
  final ApiClient api;
  final NodeInfo node;

  @override
  State<NodeDetailScreen> createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends State<NodeDetailScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await widget.api.getOkData<Map<String, dynamic>>(
      '/node.stats',
      queryParameters: {'nodeId': widget.node.nodeId, 'preset': '1h'},
    );
    final points = (data['points'] as List).cast<Map<String, dynamic>>();
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.node.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(title: const Text('status'), subtitle: Text(widget.node.status)),
          ListTile(title: const Text('version'), subtitle: Text(widget.node.version)),
          ListTile(title: const Text('lastHeartbeatAt'), subtitle: Text('${widget.node.lastHeartbeatAt}')),
          const Divider(),
          const Text('stats (points)', style: TextStyle(fontWeight: FontWeight.bold)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Load stats failed: ${snapshot.error}'),
                );
              }
              final points = snapshot.data!;
              return Column(
                children: [
                  for (final p in points.take(20))
                    ListTile(
                      dense: true,
                      title: Text('ts=${p['ts']} cpu=${p['cpuPct']} mem=${p['memPct']}'),
                      subtitle: Text('disk=${p['diskPct']} netIn=${p['netIn']} netOut=${p['netOut']}'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
