import 'dart:async';

import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  const Countdown({
    Key? key,
    required this.time,
    required this.callback,
  }) : super(key: key);

  final Duration? time;
  final Function callback;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Duration _currentTime;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    print("6666666");
    _currentTime = widget.time!;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final newTime = _currentTime - Duration(seconds: 1);
      if (newTime == Duration.zero) {
        widget.callback();
        _timer.cancel();
      } else {
        setState(() {
          _currentTime = newTime;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${_currentTime.inSeconds}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
      ),
    );
  }
}
