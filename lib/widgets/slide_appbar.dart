import 'package:flutter/material.dart';

class SlideAppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const SlideAppbarWidget({
    Key? key,
    required this.child,
    required this.controller,
    required this.visible,
  }) : super(key: key);

  final PreferredSizeWidget child;
  final AnimationController controller;
  final bool visible;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0, -1),
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: child,
    );
  }
}
