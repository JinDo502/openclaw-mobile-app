import 'package:flutter/material.dart';

import '../api/client.dart';

class RunDetailScreen extends StatefulWidget {
  const RunDetailScreen({super.key, required this.api, required this.runId});
  final ApiClient api;
  final String runId;

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    return widget.api.getOkData<Map<String, dynamic>>(
      '/run.get',
      queryParameters: {'runId': widget.runId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Run ${widget.runId}')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Load failed: ${snapshot.error}'));
          }
          final run = snapshot.data!;
          final steps = (run['steps'] is List) ? (run['steps'] as List) : const [];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _kv('name', run['name']),
              _kv('status', run['status']),
              _kv('startedAt', run['startedAt']),
              _kv('durationMs', run['durationMs']),
              _kv('updatedAt', run['updatedAt']),
              const SizedBox(height: 12),
              const Text('summary', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${run['summary'] ?? ''}'),
              const SizedBox(height: 12),
              Text('steps (${steps.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...steps.map((s) => ListTile(title: Text(s.toString()))),
            ],
          );
        },
      ),
    );
  }

  Widget _kv(String k, dynamic v) {
    return ListTile(
      dense: true,
      title: Text(k),
      subtitle: Text(v?.toString() ?? ''),
    );
  }
}
