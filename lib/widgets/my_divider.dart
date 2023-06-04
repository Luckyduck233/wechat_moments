import 'package:flutter/material.dart';

class MyDividerWidget extends StatelessWidget {
  const MyDividerWidget({Key? key, this.height}) : super(key: key);

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1,
      color: Colors.grey[200],
    );
  }
}
