import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/pages/index.dart';

import 'package:wechat_moments/utils/index.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  Widget _mainView() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final result = await MyBottomSheet()
              .wxPicker<List<AssetEntity>>(context: context);
          if (result == null || result.isEmpty) return;

          // 把数据压入发布界面
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (bc) {
                  return PostEditPage(
                    postType: (result.length == 1 &&
                            result.first.type == AssetType.video)
                        ? PostType.video
                        : PostType.image,
                    selectedAssets: result,
                  );
                },
              ),
            );
          }

          // showModalBottomSheet(
          //   context: context,
          //   useSafeArea: true,
          //   builder: (BuildContext context) {
          //     return Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         ListTile(
          //           leading: Icon(Icons.camera_alt),
          //           title: Text('拍照'),
          //         ),
          //         ListTile(
          //           leading: Icon(Icons.videocam),
          //           title: Text('摄像'),
          //         ),
          //         ListTile(
          //           leading: Icon(Icons.photo),
          //           title: Text("选取图片"),
          //         )
          //       ],
          //     );
          //   },
          // );
        },
        child: Text("发布"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainView(),
    );
  }
}
