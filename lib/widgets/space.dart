import 'package:flutter/material.dart';

///横向间距
class SpaceHorizontalWidget extends StatelessWidget {
  const SpaceHorizontalWidget({super.key, this.space});

  final double? space;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: space ?? 10);
  }
}

///垂直间距
class SpaceVerticalWidget extends StatelessWidget {
  const SpaceVerticalWidget({super.key, this.space});

  final double? space;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: space ?? 10);
  }
}
