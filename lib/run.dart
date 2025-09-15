import 'dart:async';
import 'package:flutter/material.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> with SingleTickerProviderStateMixin {
  String _currentImage = 'assets/images/run1.png';
  Timer? _timer;
  int _frame = 0; // 0 or 1
  late final DateTime _startAt;

  // Wind animation
  late final AnimationController _windController;
  late final Animation<Offset> _windSlide1;
  late final Animation<Offset> _windSlide2;
  late final Animation<double> _windFade1;
  late final Animation<double> _windFade2;

  @override
  void initState() {
    super.initState();
    _startAt = DateTime.now();

    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() {
        _frame = (_frame + 1) % 2;
        _currentImage = _frame == 0
            ? 'assets/images/run1.png'
            : 'assets/images/run2.png';
      });
    });

    _windController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _windSlide1 = Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _windController, curve: Curves.easeInOut));
    _windSlide2 = Tween<Offset>(begin: const Offset(0.35, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _windController, curve: const Interval(0.2, 1.0, curve: Curves.easeInOut)));
    _windFade1 = CurvedAnimation(parent: _windController, curve: Curves.easeInOut);
    _windFade2 = CurvedAnimation(parent: _windController, curve: const Interval(0.2, 1.0, curve: Curves.easeInOut));
    _windController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double baseWidthFactor = 0.6; // 60%

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: baseWidthFactor,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        _currentImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Elapsed time badge (center-top)
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                            child: Builder(
                              builder: (context) {
                                final elapsed = DateTime.now().difference(_startAt);
                                final m = elapsed.inMinutes;
                                return const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                ).let((style) => Text('$m분째 런닝중', style: style));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Wind overlay on right-middle
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 64,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  SlideTransition(
                                    position: _windSlide1,
                                    child: FadeTransition(
                                      opacity: _windFade1,
                                      child: Icon(Icons.air, size: 30, color: Colors.blueGrey.withValues(alpha: 0.55)),
                                    ),
                                  ),
                                  SlideTransition(
                                    position: _windSlide2,
                                    child: FadeTransition(
                                      opacity: _windFade2,
                                      child: Icon(Icons.air, size: 22, color: Colors.blueGrey.withValues(alpha: 0.40)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SafeArea(child: SizedBox(height: 12)),
        ],
      ),
    );
  }
}

extension _TextStyleX on TextStyle {
  T let<T>(T Function(TextStyle) f) => f(this);
}
