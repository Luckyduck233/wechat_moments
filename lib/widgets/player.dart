import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_player/video_player.dart';


import '../utils/compress.dart';
import '../utils/config.dart';
import '../utils/toast.dart';

///视频播放器
///1 压缩视频，显示压缩进度
///2 播放压缩后的视频文件
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    Key? key,
    this.videoController,
    this.initAsset,
    this.onCompleted,
  }) : super(key: key);

  /// chewie 视频播放控制器
  final ChewieController? videoController;

  /// 视频资源
  final AssetEntity? initAsset;

  /// 完成视频压缩
  final Function(CompressMediaFile)? onCompleted;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  /// video 视频控制器
  VideoPlayerController? _videoController;

  /// chewie控制器
  ChewieController? _chewieController;

//  压缩消息订阅
  Subscription? _subscription;

//  资源asset
  AssetEntity? _asset;

//  是否载入中
   bool _isLoading =true;

//  是否错误
   bool _isError=false;

//  压缩进度
  double _progress =0;

  @override
  void initState() {
    super.initState();
    _asset = widget.initAsset;

    // 压缩进度订阅
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
      setState(() {
        _progress = progress;
      });
    });
    if (mounted) onLoad();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    if (widget.videoController == null){
      _chewieController?.dispose();
      _videoController?.dispose();
    }
    VideoCompress.cancelCompression();
    _subscription?.unsubscribe();
    _subscription = null;
    VideoCompress.deleteAllCache();
    super.dispose();
  }

  /// 文件 file
  Future<File> getFile() async {
    var file = await _asset?.file;
    if (file == null) throw 'No file';
    return file;
  }

  void onLoad() async {
    // 1. 初始界面状态
    setState(() {
      _isLoading = _asset != null;
      _isError = _asset == null;
    });

    // 2. 安全检查, 容错
    if (_asset == null) return;

    // 3. 清理资源，释放播放器对象
    _videoController?.dispose();

    //
    try {
      var file = await getFile();

      // 开始视频压缩
      var result = await DuCompress.video(file);

      // video_player 初始化
      _videoController = VideoPlayerController.file(result.video!.file!);
      await _videoController!.initialize();

      // chewie 初始化
      _chewieController = widget.videoController ??
          ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
            autoInitialize: true,
            showOptions: false,
            cupertinoProgressColors: ChewieProgressColors(
              playedColor: accentColor,
            ),
            materialProgressColors: ChewieProgressColors(
              playedColor: accentColor,
            ),
            allowPlaybackSpeedChanging: false,
            deviceOrientationsOnEnterFullScreen: [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
              DeviceOrientation.portraitUp,
            ],
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.portraitUp,
            ],
          );
      if (widget.onCompleted != null) widget.onCompleted!(result);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      MyToast.show('Video file error');
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _mainView() {
    // 默认空组件
    Widget ws = const SizedBox.shrink();

    // 正在载入
    if (_isLoading) {
      ws = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 进度状态 icon
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 10),
          // 进度状态文本
          Text(
            '${_progress.toStringAsFixed(2)}%',
            style: const TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      );
    }

    // 正确显示
    else {
      if (_chewieController != null && !_isError) {

        ws = Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Chewie(controller: _chewieController!),
        );
      } else {}
    }

    // 按比例组件包裹
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[100],
        child: ws,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
