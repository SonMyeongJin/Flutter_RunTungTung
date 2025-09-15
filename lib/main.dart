import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<Position>? _posSub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _startMovementDetection();
  }

  Future<void> _startMovementDetection() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        return; // 권한 거부 시 자동 전환 비활성
      }

      final settings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // 5m 이동마다 업데이트
      );

    _posSub = Geolocator.getPositionStream(locationSettings: settings)
      .listen((pos) {
        if (_navigated) return;
        // 속도(m/s)가 임계값 초과하면 달리기로 전환
        final v = pos.speed; // m/s
        if (v.isFinite && v > 1.0) { // 대략 3.6km/h 이상
          _navigated = true;
      _posSub?.cancel();
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RunScreen()),
            );
          }
        }
      });
    } catch (_) {
      // 무시: 센서/권한 오류 등
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

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
