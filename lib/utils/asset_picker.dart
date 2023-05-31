

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/widgets/camera/camera.dart';


import 'config.dart';

class MyAssetPicker {
  ///相册
  static Future<List<AssetEntity>?> getAsset({
    required BuildContext context,
    List<AssetEntity>? selectedAssets,
    int maxAssets = maxAssets,
    RequestType requestType = RequestType.image,
  }) async {
    List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        selectedAssets: selectedAssets,
        requestType: requestType,
        maxAssets: maxAssets,
      ),
    );
    return result;
  }

  /// 拍摄照片
  static Future<AssetEntity?> takePhoto(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (bc) {
          return CameraPage();
        },
      ),
    );
    return result;
  }

  ///拍摄视频
  static Future<AssetEntity?> takeVideo(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (bc) {
          return const CameraPage(
            captureMode: CaptureMode.video,
            maxVideoDuration: Duration(seconds: maxVideoDuration),
          );
        },
      ),
    );
    return result;
  }
}
