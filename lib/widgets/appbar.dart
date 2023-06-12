import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({super.key, this.backgroundColor, this.elevation, this.leading, this.actions, this.title, this.centerTitle});

  ///appbar的背景颜色
  final Color? backgroundColor;
  ///appbar的海拔阴影
  final double? elevation;
  /// 在[title]之前的小组件
  final Widget? leading;
  /// 在[title]之后的小组件
  final List<Widget>? actions;
  ///appbar 标题
  final Widget? title;

  final bool? centerTitle;

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(55);

  Widget _mainView(){
    return AppBar(
      title: title,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading:leading,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

}
