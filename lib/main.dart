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
  int _frame = 0; // 0 or 1 for sit1 / sit2
  Timer? _sitAnimTimer;

  static const _sitFrames = [
    'assets/images/sit1.png',
    'assets/images/sit2.png',
  ];

  @override
  void initState() {
    super.initState();
    _startMovementDetection();
  _startSitAnimation();
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
    _sitAnimTimer?.cancel();
    super.dispose();
  }

  void _startSitAnimation() {
    _sitAnimTimer?.cancel();
    _sitAnimTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        _frame = 1 - _frame; // toggle 0 <-> 1
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '메뉴',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.directions_run),
                title: const Text('달리기'),
                onTap: () {
                  Navigator.of(context).pop(); // close drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RunScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('잠자기'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Image.asset(
                      _sitFrames[_frame],
                      key: ValueKey(_frame),
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '왼쪽 상단 햄버거 메뉴를 열어 기능을 선택하세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
