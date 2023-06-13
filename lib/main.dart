import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_moments/pages/index.dart';
import 'package:wechat_moments/widgets/global.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色为透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        Global.routeObserver
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const TimeLinePage(),
    );
  }
}
