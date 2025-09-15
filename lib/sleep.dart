import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'run.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  String _currentImage = 'assets/images/sleep1.png';
  Timer? _timer;
  int _frame = 0; // 0 or 1
  late final DateTime _startAt;
  StreamSubscription<Position>? _posSub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _startAt = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() {
        _frame = (_frame + 1) % 2;
        _currentImage = _frame == 0
            ? 'assets/images/sleep1.png'
            : 'assets/images/sleep2.png';
      });
    });

    _startMovementDetection();
  }

  Future<void> _startMovementDetection() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return;
      }

      const settings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      );

      _posSub = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
        if (_navigated) return;
        final v = pos.speed; // m/s
        if (v.isFinite && v > 1.0) {
          _navigated = true;
          _posSub?.cancel();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RunScreen()),
            );
          }
        }
      });
    } catch (_) {
      // ignore errors
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
  _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double baseWidthFactor = 0.6; // 60%
    final bool isSleep1 = _frame == 0; // sleep1만 80% 축소
    final double widthFactor = isSleep1 ? baseWidthFactor * 0.8 : baseWidthFactor;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: widthFactor,
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
                      top: 150,
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
                                final h = elapsed.inHours;
                                final m = elapsed.inMinutes % 60;
                                return Text(
                                  '$h시간 $m분째 숙면중',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // zzZ overlay
                    const Positioned(
                      right: -4,
                      top: 230,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            'zzZ',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.indigo,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
                              ],
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
