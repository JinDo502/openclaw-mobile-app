import 'package:flutter/material.dart';

import '../api/client.dart';
import '../api/models.dart';

class RunsScreen extends StatefulWidget {
  const RunsScreen({super.key, required this.api});
  final ApiClient api;

  @override
  State<RunsScreen> createState() => _RunsScreenState();
}

class _RunsScreenState extends State<RunsScreen> {
  late Future<List<RunListItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RunListItem>> _load() async {
    final data = await widget.api.getOkData<Map<String, dynamic>>(
      '/run.list',
      queryParameters: {
        'status': 'failed',
        'limit': 50,
        'offset': 0,
      },
    );
    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    return items.map(RunListItem.fromJson).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RunListItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Load failed: ${snapshot.error}'));
        }
        final items = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final run = items[index];
            return ListTile(
              title: Text(run.name),
              subtitle: Text('${run.status}${run.failReason != null ? ' · ${run.failReason}' : ''}'),
              trailing: Text(run.runId),
            );
          },
        );
      },
    );
  }
}
