import 'package:flutter/material.dart';
import 'dart:async';

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
      home: const MyHomePage(title: '테스트 화면'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 현재 보여줄 이미지 경로
  String _currentImage = 'assets/images/run1.png';
  // 애니메이션 타이머
  Timer? _timer;
  // 현재 프레임 인덱스 (0 또는 1)
  int _frame = 0;
  // 현재 모드: 'run' 또는 'sleep'
  String _mode = 'run';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation(String mode) {
    // 모드가 변경되면 프레임 초기화
    _mode = mode;
    _frame = 0;
    _updateImage();

    _timer?.cancel();
  _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() {
        _frame = (_frame + 1) % 2; // 0,1 반복
        _updateImage();
      });
    });
  }

  void _updateImage() {
    if (_mode == 'run') {
      _currentImage = _frame == 0
          ? 'assets/images/run1.png'
          : 'assets/images/run2.png';
    } else {
      _currentImage = _frame == 0
          ? 'assets/images/sleep1.png'
          : 'assets/images/sleep2.png';
    }
  }

  @override
  Widget build(BuildContext context) {
  // 기본 이미지 폭: 화면 가로의 60%, sleep2는 80%로 더 축소(= 0.48)
  const double baseWidthFactor = 0.6;
  final bool isSleep2 = (_mode == 'sleep' && _frame == 1);
  final double widthFactor = isSleep2 ? baseWidthFactor * 0.8 : baseWidthFactor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: widthFactor, // 기본 60%, sleep2는 48%
                child: Image.asset(
                  _currentImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startAnimation('run'),
                      icon: const Icon(Icons.directions_run),
                      label: const Text('달리기'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _startAnimation('sleep'),
                      icon: const Icon(Icons.bedtime),
                      label: const Text('잠자기'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 플로팅 버튼 제거
    );
  }
}
