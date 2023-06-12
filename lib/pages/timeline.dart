import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/api/timeline.dart';
import 'package:wechat_moments/pages/index.dart';

import 'package:wechat_moments/utils/index.dart';
import 'package:wechat_moments/widgets/index.dart';
import 'package:wechat_moments/widgets/text.dart';

import '../entity/index.dart';
import '../entity/timeline_likesAndcomments/result.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage>
    with TickerProviderStateMixin {
  //用户资料模型
  UserModel? _user;

  // overlay遮罩显示-------------------------------------------------------------
  /// overlay 浮动层管理
  OverlayState? _overlayState;

  /// overlay 阴影遮罩层
  OverlayEntry? _shadowOverlayEntry;

  //----------------------------------------------------------------------------

//  动态数据列表
  List<Result> _items = [];

//  获取更多组件的 offset
  Offset _btnMoreOffset = Offset.zero;

  // 控制点击更多按钮弹出窗口的动画
  //----------------------------------------------------------------------------
//  动画控制器
  late AnimationController _animationController;

//  动画Tween
  late Animation<double> _sizeTween;

  //----------------------------------------------------------------------------

//  滚动控制器
  final ScrollController _scrollController = ScrollController();

  // appbar 背景颜色透明度
  double? _appBarBgOpacity = 0.0;

  //----------------------------------------------------------------------------
//  控制弹出输入框的变量

//  是否显示评论输入框
  bool _isShowInput = false;

//  是否展开表情列表
  bool _isShowEmoji = false;

//  是否输入内容
  bool _isInputContent = false;

//  键盘高度
  final double _keyboardHeight = 200;

//  评论输入控制器
  final TextEditingController _textCommentEditingController =
      TextEditingController();

//  输入框焦点
  final FocusNode _focusNodeInput = FocusNode();

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

    // 设置动画取值范围-弹出点赞评论菜单的尺寸
    _sizeTween = Tween(begin: 0.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels > 200) {
    //     double opacity = (_scrollController.position.pixels - 200) / 100;
    //
    //     opacity = opacity.clamp(0, 1); // 将透明度限制在0到1之间
    //
    //     setState(() {
    //       _appBarOpacity=opacity;
    //     });
    //   } else {
    //     setState(() {
    //       _appBarOpacity=0.0;
    //     });
    //   }
    // });
    // 监听滚动事件
    _scrollController.addListener(_scrollListener);

    // 监听文本控制器
    _textCommentEditingController.addListener(() {
      setState(() {
        _isInputContent = _textCommentEditingController.text.isNotEmpty;
      });
    });
  }

  //  载入数据
  _onLoadData() async {
    Map<String, dynamic> data = Map();
    data["pages"] = 15;
    Response res = await WxHttpUtil().post(apiMoments, data: data);
    List<Result> result = await TimelineApi.getData(response: res);
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

//   被滚动组件监听的方法
  void _scrollListener() {
    _updateAppbarBgOpacity();
  }

//  更新appbar的背景颜色
  void _updateAppbarBgOpacity() {
    double opacity = (_scrollController.offset - 200) / 100;
    opacity = opacity.clamp(0, 1);
    // print("${opacity}");
    if (_appBarBgOpacity != opacity) {
      setState(() {
        _appBarBgOpacity = opacity;
      });
    }
    if (_appBarBgOpacity! >= 1.0) {
      return;
    }
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

  //切换评论输入栏
  void _onSwitchCommentBar() {
    setState(() {
      _isShowInput = !_isShowInput;
      if (_isShowInput) {
        _focusNodeInput.requestFocus();
      } else {
        _focusNodeInput.unfocus();
      }
      _textCommentEditingController.text = "";
    });
  }

//  评论操作
  void _onComment() {
    _onSwitchCommentBar();
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
                onPressed: () {
                  _onCloseOverlay();
                  _onComment();
                },
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
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          // 主要内容
          _buildMainContent(item),
          // 点赞的用户
          _buildLikeList(item),
          // 评论的用户及评论
          if (item.comments.isNotEmpty) _buildCommentList(item),
        ],
      ),
    );
  }

//  帖子主要内容
  Widget _buildMainContent(Result item) {
    // 获取图片数
    int imgCount = item.images.length;

    // 更多按钮的key
    GlobalKey _btnMoreKey = GlobalKey();

    return Row(
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
                    color: textEmphasizeColor,
                  ),
                ),
                const SpaceVerticalWidget(
                  space: 5,
                ),
                // 正文
                // Text(
                //   item.content,
                //   style: const TextStyle(
                //     fontSize: 16,
                //     color: Colors.black,
                //   ),
                // ),
                TextMaxLinesWidget(
                  content: item.content,
                  maxLines: 2,
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
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                        child: const Icon(
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
    );
  }

//  点赞的用户列表

  Widget _buildLikeList(Result item) {
    return Container(
      padding: const EdgeInsets.all(spacing),
      color: Colors.grey[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 前置图标-喜欢图标
          const Padding(
            padding: EdgeInsets.only(right: spacing),
            child: Icon(
              Icons.favorite_border_outlined,
              color: textEmphasizeColor,
              size: 20,
            ),
          ),
//          点赞用户的头像
          Expanded(
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (User item in item.likes)
                  Image.network(
                    item.avator,
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 评论的用户及评论
  Widget _buildCommentList(Result item) {
    return Container(
      padding: const EdgeInsets.all(spacing),
      color: Colors.grey[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 前置图标-评论图标
          const Padding(
            padding: EdgeInsets.only(right: spacing),
            child: Icon(
              Icons.chat_bubble_outline,
              color: textEmphasizeColor,
              size: 20,
            ),
          ),
          // 右侧评论列表
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (Comment comment in item.comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: spacing),
                          child: Image.network(
                            comment.user.avator,
                            height: 30,
                            width: 30,
                          ),
                        ),
                        //昵称、时间、内容
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 昵称和日期
                              Row(
                                children: [
                                  //名称
                                  Text(
                                    comment.user.nickname,
                                    style: const TextStyle(
                                      color: textEmphasizeColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  // 评论的日期
                                  Text(
                                    "${comment.publishDate.year}-${comment.publishDate.month}-${comment.publishDate.day} ${comment.publishDate.hour}:${comment.publishDate.minute}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                              const SpaceVerticalWidget(space: 3),
                              // 评论内容
                              Text(
                                comment.content,
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
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
                        // 默认的请求数据
                        Map<String, dynamic> defaultPostData = Map();
                        defaultPostData["pages"] = 1;

                        Response response = await WxHttpUtil()
                            .post(apiMoments, data: defaultPostData);

                        List<dynamic> result =
                            await TimelineApi.getData(response: response);
                        // Response res =await WxHttpUtil().post(apiMoments,data: data);
                        print(result);
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

  //底部弹出评论栏
  Widget _buildCommentBar() {
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(spacing),
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacing),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCommentEditingController,
                        decoration: InputDecoration(
                          hintText: "评论",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SpaceHorizontalWidget(),
                    // 键盘及表情图标
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isShowEmoji = !_isShowEmoji;
                        });
                        if(_isShowEmoji){
                          _focusNodeInput.unfocus();
                        }else {
                          _focusNodeInput.requestFocus();
                        }
                      },
                      child: Icon(
                        _isShowEmoji
                            ? Icons.keyboard_alt_outlined
                            : Icons.mood_outlined,
                        size: 36,
                        color: Colors.black87,
                      ),
                    ),
                    const SpaceHorizontalWidget(),
                    ElevatedButton(
                      style: const ButtonStyle(
                        elevation: MaterialStatePropertyAll(0),
                      ),
                      onPressed: _isInputContent ? _onComment : null,
                      child: const Text(
                        "发送",
                      ),
                    ),
                  ],
                ),
              ),
              //                表情列表
              if (_isShowEmoji)
                Container(
                  padding: const EdgeInsets.all(spacing),
                  height: _keyboardHeight,
                  child: GridView.builder(
                    itemCount: 50,
                    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                      // 横轴上的组件数量
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        color: Colors.grey[200],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //主视图
  Widget _mainView() {
    return GestureDetector(
      onTap: () {
        if (_isShowInput) {
          _onSwitchCommentBar();
        }
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: spacing)),
          _buildList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color startColor = Colors.white; // 起始颜色（白色）
    Color endColor = Colors.black; // 结束颜色（黑色）

    // 根据opacity而渐变颜色
    Color? interpolatedColor = ColorTween(begin: startColor, end: endColor)
        .transform(_appBarBgOpacity!);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        title: AnimatedOpacity(
          opacity: _appBarBgOpacity!,
          duration: const Duration(microseconds: 1),
          child: const Text(
            "朋友圈",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        backgroundColor: appbarColorIsScroll.withOpacity(_appBarBgOpacity!),
        leading: Icon(
          Icons.arrow_back_ios,
          color: interpolatedColor,
        ),
        actions: [
          IconButton(
            onPressed: () {
              _onPublishPage();
            },
            icon: Icon(Icons.camera_alt_outlined, color: interpolatedColor),
          )
        ],
        centerTitle: true,
      ),
      body: _mainView(),
      bottomNavigationBar: _isShowInput ? _buildCommentBar() : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    _overlayState!.dispose();
    _shadowOverlayEntry!.dispose();
    _textCommentEditingController.dispose();
    _focusNodeInput.dispose();
  }
}
