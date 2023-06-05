import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/pages/index.dart';

import 'package:wechat_moments/utils/index.dart';
import 'package:wechat_moments/widgets/index.dart';

import '../entity/index.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  //用户资料模型
  UserModel? _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 设置用户资料
    _user = UserModel(
      nickname: "可达鸭",
      // avatorUrl: "https://api.vvhan.com/api/acgimg",
      avatorUrl: "https://cravatar.cn/avatar/HASH",
      coverUrl: "https://t.mwm.moe/fj/",
    );
  }

  //压入发布界面的方法
  _onPublishPage() async {
    final result =
        await MyBottomSheet().wxPicker<List<AssetEntity>>(context: context);
    if (result == null || result.isEmpty) return;

    // 把数据压入发布界面
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (bc) {
            return PostEditPage(
              postType:
                  (result.length == 1 && result.first.type == AssetType.video)
                      ? PostType.video
                      : PostType.image,
              selectedAssets: result,
            );
          },
        ),
      );
    }
  }

  //头部
  Widget _buildHeader() {
    //获取屏幕宽度
    final double width = MediaQuery.of(context).size.width;

    return _user == null
        ? Center(child: const Text("loading"))
        : Stack(
            children: [
              // 背景
              Container(
                width: width,
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.network(
                  _user!.coverUrl ?? "",
                  height: width * 0.75,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
              // 昵称,头像
              Positioned(
                right: spacing,
                bottom: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        _user?.nickname ?? "昵称获取失败",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            height: 2.5),
                      ),
                    ),
                    // 头像
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 68,
                        height: 68,
                        child: Image.network(
                          _user?.avatorUrl ?? "",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
  }

  //主视图
  Widget _mainView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: spacing),
            child: IconButton(
              onPressed: () {
                _onPublishPage();
              },
              icon: Icon(
                Icons.camera_alt,
              ),
            ),
          )
        ],
      ),
      body: _mainView(),
    );
  }
}
