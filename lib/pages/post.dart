import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_moments/utils/config.dart';

class PostEditPage extends StatefulWidget {
  const PostEditPage({Key? key}) : super(key: key);

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
//  已选中图片列表
  List<AssetEntity> selectedAssets = [];

//  图片列表
  Widget _buildPhotosList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
        builder: (context, constraints) {
          //(获取最大约束的值 减去 图片之间间隙的总数)/每行图片数量
          final double imageSize = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final asset in selectedAssets)
                _buildPhotoItem(asset, imageSize),
              //加入图片末尾的按钮
              if (selectedAssets.length < maxAssets)
                _buildAddImageButton(context, imageSize)
            ],
          );
        },
      ),
    );
  }

  /// 缩略图末尾添加按钮
  Widget _buildAddImageButton(BuildContext context, double imageSize) {
    return GestureDetector(
      onTap: () async {
        // 这里将 已获取的图片列表 传入AssetPickerConfig，它会自动识别 已获取的图片列表 并自动勾选
        List<AssetEntity>? result = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            selectedAssets: selectedAssets,
            maxAssets: maxAssets,
          ),
        );
        setState(() {
          selectedAssets = result ?? [];
        });
      },
      child: Container(
        width: imageSize,
        height: imageSize,
        color: Colors.black12,
        child: Icon(
          Icons.add,
          size: 45,
          color: Colors.black38,
        ),
      ),
    );
  }

  ///  图片缩略图的Item
  Widget _buildPhotoItem(AssetEntity asset, double imageSize) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: AssetEntityImage(
        asset,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        // 这里设置不需要原图显示，缩略图无需原图，非常消耗资源和性能，造成卡顿
        isOriginal: false,
      ),
    );
  }

  //  主视图
  Widget _mainView() {
    return Column(
      children: [
        // 选取图片的按钮
        ElevatedButton(
          onPressed: () async {
            // 这里是读取了图片的一些信息例如图片大小时间经纬度之类的
            List<AssetEntity>? result = await AssetPicker.pickAssets(context);
            print("${result?.length}");
            setState(() {
              selectedAssets = result ?? [];
            });
          },
          child: Text("选取图片"),
        ),
        _buildPhotosList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _mainView(),
    );
  }
}
