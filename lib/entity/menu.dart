import 'package:flutter/material.dart';

///菜单项 数据模型
class MenuItemModel {
  MenuItemModel({
    this.icon,
    this.title,
    this.rightText,
    this.onTap,
  });

  ///图标
  final IconData? icon;

  ///标题
  final String? title;

  ///右侧文字
  final String? rightText;

  ///点击事件
  final Function()? onTap;
}
