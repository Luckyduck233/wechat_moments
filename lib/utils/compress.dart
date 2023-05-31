import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

///压缩返回类型
class CompressMediaFile {
  ///  缩略图
  final File? thumbnail;

  ///  媒体文件
  final MediaInfo? video;

  CompressMediaFile({this.thumbnail, this.video});
}

///压缩类
class DuCompress {
  /// 压缩图片
  static Future<XFile?> image(
    File file,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
  }) async {
    return await FlutterImageCompress.compressAndGetFile(
      // file 是一个 File 类型的参数，它表示要压缩的文件。你可以传入一个 File 对象，它指向你要压缩的图片文件。
      file.path,
      // targetPath 是一个字符串，它表示压缩后的文件的输出路径。你可以指定一个文件路径，压缩后的文件将会被保存在这个路径下。
      targetPath,

      minWidth: minWidth,
      minHeight: minHeight,
      // 压缩的质量
      quality: 80,
      // 转换的格式
      format: CompressFormat.jpeg,
    );
  }

  ///  压缩视频
  static Future<CompressMediaFile> video(File file) async {
    // 使用Future.wait()处理多个异步事件
    var result = await Future.wait([
      VideoCompress.compressVideo(file.path,
          quality: VideoQuality.Res640x480Quality,
          deleteOrigin: false,
          includeAudio: true,
          frameRate: 25),
      VideoCompress.getFileThumbnail(
        file.path,
        quality: 80,
        position: -1000,
      ),
    ]);
    return CompressMediaFile(
      video: result.first as MediaInfo,
      thumbnail: result.last as File,
    );
  }

  ///清理缓存
  static Future<bool?> clean() async {
    return await VideoCompress.deleteAllCache();
  }

  ///取消
  static Future<void> cancel() async {
    return await VideoCompress.cancelCompression();
  }
}
