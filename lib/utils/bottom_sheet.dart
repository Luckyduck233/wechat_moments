import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/utils/asset_picker.dart';
import 'package:wechat_moments/widgets/index.dart';

enum PickType { camera, asset }

///微信底部弹出框
class MyBottomSheet {
  MyBottomSheet({this.selectedAssets});

  List<AssetEntity>? selectedAssets;

  ///选择拍摄、资源
  Future<T?> wxPicker<T>(
      {required BuildContext context,
      Widget? firstWidget,
      Widget? secondWidget,
      Function()? onTapOnFirstWidget,
      Function()? onTapOnSecondWidget}) {
    return MyAssetPicker.showBottomSheet<T>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //拍摄
          _buildBtn(
            child: firstWidget ?? const Text("拍摄"),
            onTap: () {
              print("pppooo拍摄${selectedAssets}");
              showPhotoOrVideo(
                context: context,
                pickType: PickType.camera,
                selectedAssets: selectedAssets,
                firstWidget: const Text("图片"),
                secondWidget: const Text("视频"),
              );
            },
          ),
          const MyDividerWidget(height: 1),
          //相册
          _buildBtn(


    child: secondWidget ?? const Text("相册"),
            onTap: () {
              print("pppooo相册${selectedAssets}");
              showPhotoOrVideo(
                context: context,
                pickType: PickType.asset,
                selectedAssets: selectedAssets,
                firstWidget: const Text("图片"),
                secondWidget: const Text("视频"),
              );
            },
          ),
          const MyDividerWidget(height: 10),
          //取消
          _buildBtn(
            child: Text("取消"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  ///选择图片或视频
  ///选择拍摄、资源
  Future<dynamic> showPhotoOrVideo({
    required BuildContext context,
    required PickType pickType,
    required Widget firstWidget,
    required Widget secondWidget,
    List<AssetEntity>? selectedAssets,
  }) {
    return MyAssetPicker.showBottomSheet(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //拍摄
          _buildBtn(
            child: firstWidget,
            onTap: () async {
              print("pppooo拍摄2${selectedAssets}");
              List<AssetEntity>? result;
              if (pickType == PickType.asset) {
                result = await MyAssetPicker.getAsset(
                    context: context, selectedAssets: selectedAssets);
              } else if (pickType == PickType.camera) {
                final asset = await MyAssetPicker.takePhoto(context);
                if (asset == null) return;
                if (selectedAssets == null) {
                  result = [asset];
                } else {
                  result = [...selectedAssets, asset];
                }
              }
              _popRoute(context, result: result);
            },
          ),
          const MyDividerWidget(height: 1),
          //相册
          _buildBtn(
            child: secondWidget,
            onTap: () async {
              print("pppooo相册2${selectedAssets}");

              List<AssetEntity>? result;
              if (pickType == PickType.asset) {
                result = await MyAssetPicker.getAsset(
                  context: context,
                  requestType: RequestType.video,
                  selectedAssets: selectedAssets,
                  maxAssets: 1,
                );
              } else if (pickType == PickType.camera) {
                AssetEntity? asset = await MyAssetPicker.takeVideo(context);
                if (asset == null) return;
                result = [asset];
              }
              _popRoute(context,result: result);
            },
          ),
          const MyDividerWidget(height: 10),
          //取消
          _buildBtn(
            child: Text("取消"),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  InkWell _buildBtn({Widget? child, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 18, color: Colors.black),
        child: Container(
          alignment: Alignment.center,
          height: 55,
          child: child,
        ),
      ),
    );
  }

  ///  返回
  void _popRoute(BuildContext context, {result}) {
    Navigator.pop(context);
    Navigator.pop(context, result);
  }
}
