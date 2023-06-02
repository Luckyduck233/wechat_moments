import 'dart:io';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/utils/compress.dart';

class TakePhotoPage extends StatefulWidget {
  const TakePhotoPage({
    Key? key,
    required this.cameraState,
  }) : super(key: key);

  final CameraState cameraState;

  @override
  State<TakePhotoPage> createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  ///  未压缩图片的代码
  // @override
  // void initState() {
  //   super.initState();
  //   // 监听cameraState
  //   widget.cameraState.captureState$.listen((event) async {
  //     if (event != null && event.status == MediaCaptureStatus.success) {
  //       String filePath = event.filePath;
  //       String fileTitle = filePath.split("/").last;
  //
  //       File file = File(filePath);
  //
  //       // 转换为AssetEntity
  //       final AssetEntity? asset = await PhotoManager.editor.saveImage(
  //         file.readAsBytesSync(),
  //         title: fileTitle,
  //       );
  //
  //       // 删除临时文件
  //       await file.delete();
  //
  //       Navigator.of(context).pop(asset);
  //     }
  //   });
  // }
  ///已压缩图片的代码
  @override
  void initState() {
    super.initState();

    widget.cameraState.captureState$.listen((event) async {
      if (event != null && event.status == MediaCaptureStatus.success) {
        String filePath = event.filePath;
        String fileTitle = filePath.split("/").last;

        Uint8List unCompressU8l = File(filePath).readAsBytesSync();

        // 压缩图片
        Uint8List compressList =await DuCompress.compressWithList(unCompressU8l);

        File newFile =await saveImage(compressList);
        
        if (newFile == null) return;

        final AssetEntity? asset = await PhotoManager.editor
            .saveImage(File(newFile.path).readAsBytesSync(), title: fileTitle);

        await File(filePath).delete();
        await newFile.delete();

        Navigator.of(context).pop(asset);
      }
    });
  }

  Future<File> saveImage(Uint8List imageByte) async {
    //获取临时目录
    var tempDir = await getTemporaryDirectory();
    //生成file文件格式
    var file = await File('${tempDir.path}/image_${DateTime.now().millisecond}.jpg').create();
    print("file path${file.path}");
    //转成file文件
    file.writeAsBytesSync(imageByte);
    return file;
  }

  Widget _mainView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black54,
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 切换摄像头
            AwesomeCameraSwitchButton(state: widget.cameraState),
            //拍摄按钮
            AwesomeCaptureButton(state: widget.cameraState),
            //右侧区域
            const SizedBox(
              width: 32 + 20 * 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
