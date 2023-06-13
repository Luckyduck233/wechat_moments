import 'package:chewie/chewie.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/entity/timeline_likesAndcomments/result.dart';
import 'package:wechat_moments/pages/index.dart';
import 'package:wechat_moments/utils/config.dart';
import 'package:wechat_moments/utils/index.dart';
import 'package:wechat_moments/widgets/global.dart';
import 'package:wechat_moments/widgets/index.dart';
import 'package:wechat_moments/widgets/slide_appbar.dart';

import '../entity/timeline_likesAndcomments/time_line_like_comments_entity.dart';
import '../pages/test.dart';

/// 图像浏览器
class GalleryWidget extends StatefulWidget {
  const GalleryWidget({
    Key? key,
    required this.initialIndex,
    this.items,
    this.isBarVisible,
    this.data,
  }) : super(key: key);

//  动态详情页的数据信息
  final Result? data;

//  初始图片的位置
  final int initialIndex;

//  图片列表
  final List<AssetEntity>? items;

//  是否显示 bar
  final bool? isBarVisible;

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

// 一个接口，对象知道自己当前的路由。这与RouteObserver一起使用，使小部件能够意识到Navigator会话历史记录的变化
//这样混入了一个[RouteAware]接口,这个接口可以让当前对象页面知道自己当前的路由,使组件能够知道Navigator
class _GalleryWidgetState extends State<GalleryWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
//  是否显示appbar
  bool visible = true;

//  是否显示appbar
  bool _isShowAppBar = true;

  // video控制器
  VideoPlayerController? _videoPlayerController;

  // chewie控制器
  ChewieController? _chewieController;

//  动画控制器
  late final AnimationController _animateAppBarController;

  @override
  void didPop() {
    super.didPop();
    print("didPop");
  }

  // 当C页面关闭返回到B页面后,B页面会调用该方法
  // 当顶部路由被弹出时调用，当前路由显示出来
  @override
  void didPopNext() {
    super.didPopNext();
    print("didPopNext");
    if (_videoPlayerController?.value.isInitialized != true) return;
    _chewieController!.play();
  }

  @override
  void didPush() {
    super.didPush();
    print("didPush");
  }

  // 当从B页面打开C页面时，该方法被调起。
  // 当新路由被推送，当前路由不再可见时调用
  @override
  void didPushNext() {

    super.didPushNext();
    print("didPushNext");
    if (_videoPlayerController?.value.isInitialized != true) return;
    _chewieController!.pause();
  }

  // 当程序退到后台暂停，恢复到前台时再播放
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("didChangeAppLifecycleState ${state}");

    if(_videoPlayerController?.value.isInitialized != true) return;

    // 应用程序是可见的，并响应用户输入
    if (state == AppLifecycleState.resumed) {
      print("应用程序是可见的，并响应用户输入");
      _chewieController!.play();
    }
    // 应用程序处于后台,不能响应用户输入
    if(state == AppLifecycleState.paused){
      print("应用程序处于后台,不能响应用户输入");
      _chewieController!.pause();
    }
  }

//  在此 State 对象的依赖项更改时调用
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 订阅路由
    Global.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    visible = widget.isBarVisible ?? true;
    _animateAppBarController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 400,
      ),
    );

    // 将给定对象注册为绑定观察者。捆绑 当各种应用程序事件发生时，观察者会收到通知，例如，当系统区域设置更改时
    WidgetsBinding.instance.addObserver(this);

    // 在下一帧之后调用回调。如果在帧绘制之前调用，则回调将在下一帧调用
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onLoadVideo();
    });
  }

//  初始加载视频
  _onLoadVideo() async {
    // 判断朋友圈的发布类型是否为视频
    if (widget.data?.postType != PostType.video.name) {
      return Future.value();
    }

    try {
      // video_player初始化
      _videoPlayerController =
          VideoPlayerController.network(widget.data?.video.url ?? "");

      // 尝试打开给定的 [dataSoure] 并加载有关视频的元数据
      await _videoPlayerController?.initialize();

      // chewie初始化
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        // 视频一显示就播放
        autoPlay: true,
        // 视频是否应该循环播放
        looping: false,
        // 在启动时初始化视频。这将为视频回放做准备
        autoInitialize: true,
        // 如果为false，则不会显示MaterialUI和MaterialDesktopUI中的选项按钮
        showOptions: false,
        // 在iOS上用于控件的颜色。默认情况下，iOS播放器使用从原始iOS 11设计中采样的颜色
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: accentColor,
        ),
        // material进度条使用的颜色。默认情况下，material播放器使用来自主题的颜色
        materialProgressColors: ChewieProgressColors(
          playedColor: accentColor,
        ),
        // 定义是否显示播放速度控制
        allowPlaybackSpeedChanging: false,
        // 定义进入全屏时允许的设备方向列表
        //  即定义可以以哪些全屏方向显示视频播放器
        deviceOrientationsOnEnterFullScreen: [
          // 从portraitUp顺时针90度的方向
          DeviceOrientation.landscapeLeft,
          // 从portraitUp逆时针90度的方向
          DeviceOrientation.landscapeRight,
          // 如果设备在纵向显示其引导徽标，则引导徽标将在纵向显示。否则，设备将横向显示其引导标志，该方向是将设备从其引导方向顺时针旋转90度获得的
          DeviceOrientation.portraitUp,
        ],
        // 定义退出全屏后可以 以什么方向显示
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        // 占位组件在视频初始化或播放之前显示在视频下方
        placeholder: _videoPlayerController?.value.isInitialized == false
            ? Image.network(widget.data?.video.cover ?? "")
            : null,
      );
    } catch (e) {
      MyToast.show("播放器出错，请检查网络连接或者视频链接");
    } finally {
      if (mounted) setState(() {});
    }
  }

  /// 图片视图
  Widget _buildImageView() {
    return ExtendedImageGesturePageView.builder(
      controller: ExtendedPageController(
        // 传入图片初始位置
        initialPage: widget.initialIndex,
      ),
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final AssetEntity? item = widget.items?[index];
        return ExtendedImage(
          image: AssetEntityImageProvider(
            item!,
            isOriginal: true,
          ),
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: ((ExtendedImageState state) {
            return GestureConfig(
              //	缩放最小值
              minScale: 0.8,
              maxScale: 5.0,
              //缩放拖拽速度，与用户操作成正比
              speed: 1.0,
              //是否缓存手势状态，可用于 ExtendedImageGesturePageView中
              // 保留状态，使用 clearGestureDetailsCache 方法清除
              cacheGesture: false,
              //拖拽惯性速度，与惯性速度成正比
              inertialSpeed: 100.0,
              initialScale: 1.0,
              //	是否使用 ExtendedImageGesturePageView 展示图片
              inPageView: true,
            );
          }),
        );
      },
    );
  }

  ///视频视图
  Widget _buildVideoView() {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          child: Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: _chewieController == null
                ? const Text(
                    "视频载入中...",
                    textAlign: TextAlign.center,
                  )
                : Chewie(controller: _chewieController!),
          ),
        ),
      ),
    );
  }

  ///底部动态信息栏
  // Widget _buildBottomDynamicInfoBar(){
  //   if(visible == false){
  //     return null;
  //   }else{
  //    
  //   }
  // }

  /// 主视图
  Widget _mainView() {
    // 默认加载中
    Widget body = const Text("loading");

    // 如果是图片
    if (widget.data?.postType == PostType.image.name) {
      body = _buildImageView();
    }

    // 如果是视频
    if (widget.data?.postType == PostType.video.name &&
        widget.data?.video.url != null) {
      body = _buildVideoView();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Navigator.pop(context);
        setState(() {
          visible = !visible;
        });
      },
      child: Scaffold(
        // 是否占用appbar的空间 appbar仍然存在-// 全屏, 高度将扩展为包括应用栏的高度
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        // appBar: SlideAppbarWidget(
        //   controller: _animateAppBarController,
        //   visible: visible,
        //   child: AppBar(
        //     backgroundColor: Colors.grey,
        //     elevation: 0,
        //   ),
        // ),
        appBar: MyAppBar(
          isAnimated: true,
          isShow: visible,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.white,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const TestPage()));
              },
              child: const Icon(
                Icons.more_horiz_outlined,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Global.routeObserver.unsubscribe(this);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
  }
}
