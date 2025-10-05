import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:run_tungtung/run.dart';
import 'package:run_tungtung/sleep.dart';
import 'package:run_tungtung/fat.dart';

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
  double _fullness = 0.7; // 0.0 ~ 1.0 포만감 (임시 고정 값)

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
                title: const Text('Run Mode'),
                onTap: () {
                  Navigator.of(context).pop(); // close drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RunScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Sleep Mode'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.fastfood),
                title: const Text('Pig Mode'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FatScreen()),
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
                  child: SizedBox(
                    width: 260,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 캐릭터 이미지 (프레임 애니메이션)
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Image.asset(
                              _sitFrames[_frame],
                              key: ValueKey(_frame),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // 귀여운 경고/주의 배지 (살짝 점프하는 효과)
                        Positioned(
                          top: -8,
                          left: 0,
                          right: 0,
                          child: LayoutBuilder(
                            builder: (context, _) {
                              final scale = _frame == 0 ? 1.0 : 1.07; // 기존 프레임 토글에 맞춰 살짝 점프
                              return Transform.scale(
                                scale: scale,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFE5EC), Color(0xFFFFD1DC)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: const Color(0xFFFFB7C5), width: 1.5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text('🐷', style: TextStyle(fontSize: 20)),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              '운동이 필요해요!\n2일 뒤에 뚱뚱한 돼지가 될지도 몰라요 💦',
                                              style: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                                height: 1.25,
                                                letterSpacing: 0.3,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text('😭', style: TextStyle(fontSize: 20)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 포만감 게이지
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: SizedBox(
                  height: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final fillW = w * _fullness.clamp(0.0, 1.0);
                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      width: fillW,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFFD54F), Color(0xFFF57C00)],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Center(
                                      child: Text(
                                        '포만감 ${(100 * _fullness).round()}%',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
