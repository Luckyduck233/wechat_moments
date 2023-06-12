import 'package:flutter/material.dart';

///Apifox
///请求朋友圈列表数据接口
const String apiBaseUrl = "https://mock.apifox.cn/m1/2837307-0-default/";
///朋友圈列表数据
const String apiMoments = "/moments/news";
const String requestToken = "45DLJcRNodsbpykbih3EHT7sDI80ufUU";

///间距 default=10
const double spacing = 10.0;

///图片选取数量
const int maxAssets = 9;

///强调色
const Color accentColor = Colors.yellowAccent;

///文字辅助色
const Color secondaryTextColor = Colors.lightBlueAccent;

///文字强调色
const Color textEmphasizeColor = Color.fromRGBO(23, 75, 115, 1);

///图片border
const double imageBorder = 3.0;

/// 视频录制最大时间 秒
const int maxVideoDuration = 30;

///页面 padding
const double pagePadding = 12;

///appbar 朋友圈滚动时appbar颜色
const Color appbarColorIsScroll = Color(0xFFEDEDED);
