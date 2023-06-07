import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/api/timeline.dart';
import 'package:wechat_moments/pages/index.dart';

import 'package:wechat_moments/utils/index.dart';
import 'package:wechat_moments/widgets/index.dart';

import '../entity/index.dart';
import '../entity/timeline/result.dart';


class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  //用户资料模型
  UserModel? _user;

//  动态数据列表
  List<Result> _items = [];

//  载入数据
  _loadData() async {
    Map<String, dynamic> data = Map();
    data["pages"] = 15;
    List<Result> result = await TimelineApi.getPageList(data: data);
    // 等待界面上的组件树绘制完成再将数据更新
    if (mounted) {
      setState(() {
        _items = result;
      });
    }
  }

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
    if (mounted) {
      setState(() {});
    }

    // 载入数据
    _loadData();
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
                    InkWell(
                      onTap: () async {
                        Map<String, dynamic> data = Map();
                        data["pages"] = 1;
                        List<Result> list =
                            await TimelineApi.getPageList(data: data);
                        // Response res =await WxHttpUtil().post(apiMoments,data: data);
                        print(list.length);
                        // print(res.data);
                      },
                      child: ClipRRect(
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
                    ),
                  ],
                ),
              )
            ],
          );
  }

  //列表
  SliverList _buildList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        var item = _items[index];
        return _buildListItem(item);
      },
      childCount: _items.length,
    ));
  }

//  列表项
  Widget _buildListItem(Result item) {
    // 获取图片数
    int imgCount = item.images.length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //头像
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Image.network(
              item.user.avator,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          // 右侧
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称
                Text(
                  item.user.nickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SpaceVerticalWidget(
                  space: 5,
                ),
                // 正文
                Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                // 九宫格图片-如果有图片
                ///方案一-GridView.builder---------------------------------------
                // if(item.images.isNotEmpty)
                //   GridView.builder(
                //     itemCount: item.images.length,
                //     physics: const NeverScrollableScrollPhysics(),
                //     shrinkWrap: true,
                //     gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: 3,
                //       crossAxisSpacing: 4,
                //       mainAxisSpacing: 4,
                //     ),
                //     itemBuilder: (BuildContext context, int index) {
                //       return Image.network(
                //         item.images[index],
                //         fit: BoxFit.cover,
                //       );
                //     },
                //   ),
                // 方案二-Warp------------------------------------------------------
                LayoutBuilder(
                  builder: (layoutBuilderContext, constraints) {
                    double imgWidth = imgCount == 1
                        ? (constraints.maxWidth * 0.7)
                        : (constraints.maxWidth - spacing * 2) / 3;
                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.images.map((e) {
                        return Image.network(
                          e,
                          width: imgWidth,
                          height: imgWidth,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SpaceVerticalWidget(),
                // 位置
                Text(
                  item.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SpaceVerticalWidget(),
                // 发布时间
                Text(
                  item.publishDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SpaceVerticalWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  //主视图
  Widget _mainView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: spacing)),
        _buildList(),
      ],
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
