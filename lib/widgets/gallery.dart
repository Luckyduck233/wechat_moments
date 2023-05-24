import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/widgets/appbar.dart';

/// 图像浏览器
class GalleryWidget extends StatefulWidget {
  const GalleryWidget({
    Key? key,
    required this.initialIndex,
    required this.items,
    this.isBarVisible,
  }) : super(key: key);

//  初始图片的位置
  final int initialIndex;

//  图片列表
  final List<AssetEntity> items;

//  是否显示 bar
  final bool? isBarVisible;

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget>
    with SingleTickerProviderStateMixin {
  bool visible = true;

//  动画控制器
  late final AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    visible = widget.isBarVisible ?? true;
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 400,
      ),
     );
  }

  /// 图片视图
  Widget _buildImageView() {
    return ExtendedImageGesturePageView.builder(
      controller: ExtendedPageController(
        // 传入图片初始位置
        initialPage: widget.initialIndex,
      ),
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        final AssetEntity item = widget.items[index];
        return ExtendedImage(
          image: AssetEntityImageProvider(
            item,
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

  /// 主视图
  Widget _mainView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Navigator.pop(context);
        setState(() {
          visible=!visible;
        });
      },
      child: Scaffold(
        // 是否占用appbar的空间 appbar仍然存在
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: SlideAppbarWidget(
          controller: controller,
          visible: visible,
          child: AppBar(
            backgroundColor: Colors.grey,
            elevation: 0,
          ),
        ),
        body: _buildImageView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
