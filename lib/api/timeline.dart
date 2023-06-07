import 'package:dio/dio.dart';
import 'package:wechat_moments/entity/timeline/result.dart';
import 'package:wechat_moments/utils/index.dart';

import '../entity/timeline/time_line_entity.dart';

///朋友圈api
class TimelineApi {
//  翻页列表
  static Future<List<Result>> getPageList({Map<String, dynamic>? data}) async {
    // 默认的请求数据
    Map<String, dynamic> defaultPostData = Map();
    defaultPostData["pages"] = 5;

    Response res =
        await WxHttpUtil().post(apiMoments, data: data ??= defaultPostData);

    // print(res);

    var timeLineEntity = timeLineEntityFromJson(res.toString());

    List<Result> items = [];

    for (var item in timeLineEntity.result) {
      items.add(item);
    }

    return items;
  }
}
