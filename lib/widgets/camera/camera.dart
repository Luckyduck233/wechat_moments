import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_moments/widgets/camera/widget/take_photo.dart';
import 'package:wechat_moments/widgets/camera/widget/take_video.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({
    Key? key,
    this.captureMode = CaptureMode.photo,
    this.maxVideoDuration,
  }) : super(key: key);

//  拍照、视频
  final CaptureMode captureMode;

//  视频最大时长
  final Duration? maxVideoDuration;

//  生成文件路径
  Future<String> _buildFilePath() async {
    // 获取临时文件路径，获取的就是app安装后里的cache目录
    final extDir = await getTemporaryDirectory();
    // 文件类型扩展名
    final extendName = captureMode == CaptureMode.photo ? "jpg" : "mp4";
    final finalPath = "${extDir.path}/${Uuid().v4()}.${extendName}";
    print("文件路径:${finalPath}");
    return finalPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
        saveConfig: captureMode == CaptureMode.photo
            ? SaveConfig.photo(pathBuilder: _buildFilePath)
            : SaveConfig.video(pathBuilder: _buildFilePath),
        builder: (
          CameraState state,
          PreviewSize previewSize,
          Rect previewRect,
        ) {
          return state.when(
//            拍照
            onPhotoMode: (PhotoCameraState state) {
              return TakePhotoPage(
                cameraState: state,
              );
            },
//              拍视频
            onVideoMode: (VideoCameraState state) {
              return TakeVideoPage(
                cameraState: state,
              );
            },
//            拍摄中
            onVideoRecordingMode: (VideoRecordingCameraState state) {
              return TakeVideoPage(
                cameraState: state,
              );
            },
//            启动摄像头
            onPreparingCamera: (PreparingCameraState state) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
        // 图像生成的配置信息
        imageAnalysisConfig:
            AnalysisConfig(outputFormat: InputAnalysisImageFormat.jpeg),
      ),
    );
  }
}
