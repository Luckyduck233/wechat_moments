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

class _TimeLinePageState extends State<TimeLinePage>
    with SingleTickerProviderStateMixin {
  //用户资料模型
  UserModel? _user;

  // overlay遮罩显示
  /// overlay 浮动层管理
  OverlayState? _overlayState;

  /// overlay 阴影遮罩层
  OverlayEntry? _shadowOverlayEntry;

//  动态数据列表
  List<Result> _items = [];

//  获取更多组件的 offset
  Offset _btnMoreOffset = Offset.zero;

//  动画控制器
  late AnimationController _animationController;

//  动画Tween
  late Animation<double> _sizeTween;

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
    _onLoadData();

    // 初始化overlay
    _overlayState = Overlay.of(context);

    // 初始化动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // 设置动画取值范围
    _sizeTween = Tween(begin: 0.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  //  载入数据
  _onLoadData() async {
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

  //获取组件的位置的方法
  void _onGetWidgetOffset(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      _btnMoreOffset = offset;
    });
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

  //显示遮罩
  void _onShowOverlay({Function()? onTap}) {
    _shadowOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          // 接收关闭遮罩层的方法
          onTap: onTap,
          child: Stack(children: [
            // 遮罩层
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              color: Colors.black.withOpacity(.2),
              width: double.infinity,
              height: double.infinity,
            ),
            AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget? child) {
                  return Positioned(
                    left: _btnMoreOffset.dx - _sizeTween.value - 10,
                    top: _btnMoreOffset.dy,
                    child: SizedBox(
                      width: _sizeTween.value,
                      height: 40,
                      child: _buildIsLikeMenu(),
                    ),
                  );
                }),
          ]),
        );
      },
    );
    _overlayState?.insert(_shadowOverlayEntry!);

    // 延迟显示更多菜单
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  //关闭遮罩和关闭更多窗口
  void _onCloseOverlay() async {
    if (_shadowOverlayEntry != null &&
        _animationController.status == AnimationStatus.completed) {
      await _animationController.reverse();
      _shadowOverlayEntry!.remove();
      _shadowOverlayEntry!.dispose();
    }
  }

  //点赞菜单
  Widget _buildIsLikeMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 喜欢
            // 这个约束尺寸是跟随弹出动画的值而变化的
            // 而这个约束来源于父组件的动态宽高
            if (constraints.maxWidth > 95)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_border_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "点赞",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            //评论
            if (constraints.maxWidth > 180)
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "评论",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      }),
    );
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

    // 更多按钮的key
    GlobalKey _btnMoreKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //头像
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.user.avator,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          // 右侧
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称
                  Text(
                    item.user.nickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(23, 75, 115, 1),
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
                      color: Colors.black,
                    ),
                  ),
                  const SpaceVerticalWidget(),
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
                  // 发布时间 和 点击弹出(点赞评论弹窗)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item.publishDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          // 获取更多按钮位置
                          _onGetWidgetOffset(_btnMoreKey);
                          // 点击弹出遮罩层，并将关闭遮罩层的方法传入
                          _onShowOverlay(onTap: _onCloseOverlay);
                        },
                        child: Container(
                          key: _btnMoreKey,
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.more_horiz_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SpaceVerticalWidget(),
                ],
              ),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
