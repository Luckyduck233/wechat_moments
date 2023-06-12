import 'package:dio/dio.dart';
// import 'package:wechat_moments/entity/timeline/result.dart';

import '../entity/timeline_likesAndcomments/time_line_like_comments_entity.dart';
import '../entity/timeline_likesAndcomments/result.dart';

///朋友圈api
class TimelineApi {
//  翻页列表
//   static Future<List<Result>> getPageList({Map<String, dynamic>? data}) async {
//     // 默认的请求数据
//     Map<String, dynamic> defaultPostData = Map();
//     defaultPostData["pages"] = 5;
//
//     Response res =
//         await WxHttpUtil().post(apiMoments, data: data ??= defaultPostData);
//
//
//     var timeLineEntity = timeLineEntityFromJson(res.toString());
//
//     List<Result> items = [];
//
//     for (var item in timeLineEntity.result) {
//       items.add(item);
//     }
//
//     return items;
//   }

//  获取res的数据
  static Future<List<Result>> getData({required Response response}) async{

    TimeLineLikesCommentsEntity entity = timeLineLikesCommentsEntityFromJson(response.toString());

    List<Result> items = [];

    for(var item in entity.result){
      items.add(item);
    }

    return items;
  }
}
