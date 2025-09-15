import 'package:flutter/material.dart';
import 'package:run_tungtung/run.dart';
import 'package:run_tungtung/sleep.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunTungTung Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MyHomePage(title: '달리는 퉁퉁이'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RunScreen()),
                      ),
                      icon: const Icon(Icons.directions_run),
                      label: const Text('달리기'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SleepScreen()),
                      ),
                      icon: const Icon(Icons.bedtime),
                      label: const Text('잠자기'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
