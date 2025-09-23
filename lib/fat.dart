import 'dart:async';
import 'package:flutter/material.dart';

class FatScreen extends StatefulWidget {
	const FatScreen({super.key});

	@override
	State<FatScreen> createState() => _FatScreenState();
}

class _FatScreenState extends State<FatScreen> {
	static const _frames = [
		'assets/images/fat1.png',
		'assets/images/fat2.png',
	];

	int _frame = 0; // 0 or 1
	Timer? _timer;

	@override
	void initState() {
		super.initState();
		_timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
			if (!mounted) return;
			setState(() {
				_frame = 1 - _frame; // toggle
			});
		});
	}

	@override
	void dispose() {
		_timer?.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Fat 퉁퉁이'),
			),
			body: Center(
				child: AnimatedSwitcher(
					duration: const Duration(milliseconds: 250),
					child: Image.asset(
						_frames[_frame],
						key: ValueKey(_frame),
						width: 280,
						fit: BoxFit.contain,
					),
				),
			),
		);
	}
}

