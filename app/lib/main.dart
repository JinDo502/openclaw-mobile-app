import 'package:flutter/material.dart';

import 'api/client.dart';
import 'screens/nodes_screen.dart';
import 'screens/runs_screen.dart';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8787');

void main() {
  runApp(const OpenClawApp());
}

class OpenClawApp extends StatelessWidget {
  const OpenClawApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient(baseUrl: apiBaseUrl);
    return MaterialApp(
      title: 'OpenClaw',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: HomePage(api: api),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api});
  final ApiClient api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      NodesScreen(api: widget.api),
      RunsScreen(api: widget.api),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('OpenClaw Mobile')),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.devices), label: 'Nodes'),
          NavigationDestination(icon: Icon(Icons.run_circle_outlined), label: 'Runs'),
        ],
      ),
    );
  }
}
