import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, this.colors, this.elevation, this.leading, this.actions});

  ///appbar的背景颜色
  final Color? colors;
  ///appbar的海拔阴影
  final double? elevation;
  /// 在[title]之前的小组件
  final Widget? leading;
  /// 在[title]之后的小组件
  final List<Widget>? actions;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(30);

  Widget _mainView(){
    return AppBar(
      backgroundColor: colors ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading:leading,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

}