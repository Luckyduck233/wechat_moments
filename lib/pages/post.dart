import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:wechat_moments/utils/asset_picker.dart';
import 'package:wechat_moments/utils/config.dart';
import 'package:wechat_moments/widgets/gallery.dart';
import 'package:wechat_moments/widgets/player.dart';

import '../utils/compress.dart';

enum PostType {
  image,
  video,
}

class PostEditPage extends StatefulWidget {
  const PostEditPage({Key? key}) : super(key: key);

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
//  发布类型
  PostType? postType;

//  已选中图片列表
  List<AssetEntity> selectedAssets = [];

//  是否开始拖拽
  bool isDragNow = false;

//  是否将要删除
  bool isWillRemove = false;

//  是否将要拖拽
  bool isWillOrder = false;

//  被拖拽的id
  late String targetAssetId;

//  已压缩的视频文件
  CompressMediaFile? videoCompressMediaFile;

//  图片列表
  Widget _buildPhotosList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
        builder: (context, constraints) {
          //(获取最大约束的值 减去 图片之间间隙的总数)/每行图片数量
          final double imageSize =
              (constraints.maxWidth - spacing * 2 - imageBorder * (2 * 3)) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final asset in selectedAssets)
                _buildPhotoItem(asset, imageSize),
              //加入图片末尾的按钮
              if (selectedAssets.length < maxAssets)
                _buildAddImageButton(context, imageSize),
              _buildTakeImageButton(context, imageSize)
            ],
          );
        },
      ),
    );
  }

  /// 缩略图末尾添加按钮
  Widget _buildAddImageButton(BuildContext context, double imageSize) {
    return GestureDetector(
      onTap: (){
        // // 这里是读取了图片的一些信息例如图片大小时间经纬度之类的
        // List<AssetEntity>? result = await AssetPicker.pickAssets(
        //   context,
        //   pickerConfig: AssetPickerConfig(
        //     // 这里将 已获取的图片列表 传入AssetPickerConfig，它会自动识别 已获取的图片列表 并自动勾选
        //     selectedAssets: selectedAssets,
        //     maxAssets: maxAssets,
        //   ),
        // );
        // print("${result}");
        // // if (result == null) {
        // //   return;
        // // }
        // if (result != null) {
        //   setState(
        //     () {
        //       selectedAssets = result;
        //     },
        //   );
        // }

        // List<AssetEntity>? asset = await MyAssetPicker.getAsset(
        //   context: context,
        //   selectedAssets: selectedAssets,
        // );
        //
        // if (asset != null) {
        //   print(asset);
        // } else {
        //   return;
        // }
        //
        // setState(() {
        //   selectedAssets = asset;
        // });
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('拍照'),
                  onTap: () async {
                    AssetEntity? asset =await MyAssetPicker.takePhoto(context);
                    if(asset==null)return;
                    setState(() {
                      postType=PostType.image;
                      selectedAssets.add(asset);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('摄像'),
                  onTap: () async{
                    AssetEntity? asset =await MyAssetPicker.takeVideo(context);
                    if(asset==null)return;
                    setState(() {
                      postType=PostType.video;
                      selectedAssets.clear();
                      selectedAssets.add(asset);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
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

  /// 缩略图末尾拍摄按钮
  Widget _buildTakeImageButton(BuildContext context, double imageSize) {
    return GestureDetector(
      onTap: () async {
        final AssetEntity? result = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: const CameraPickerConfig(
            // 选择器是否可以录像
            enableRecording: true,
          ),
        );

        if (result != null) {
          print("${result.relativePath}");
          setState(() {
            selectedAssets.add(result);
          });
        }
      },
      child: Container(
        width: imageSize,
        height: imageSize,
        color: Colors.black12,
        child: Icon(
          Icons.photo_camera,
          size: 45,
          color: Colors.black38,
        ),
      ),
    );
  }

  ///  图片缩略图的Item
  Widget _buildPhotoItem(AssetEntity asset, double imageSize) {
    // 图片缩略图代码抽取
    Widget _photoItem(double? opacity) => Container(
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
            opacity: opacity != null ? AlwaysStoppedAnimation(opacity) : null,
          ),
        );

    return Draggable<AssetEntity>(
      data: asset,
//      开始拖拽时
      onDragStarted: () {
        print("onDragStarted-${asset.id}");
        setState(() {
          isDragNow = true;
        });
      },
//      拖拽结束时
      onDragEnd: (DraggableDetails details) {
        print("onDragStarted-${asset.id}");
        setState(() {
          isDragNow = false;
          isWillOrder = false;
        });
      },
      // 当draggable被拖放并被DragTarget接受时调用
      onDragCompleted: () {
        print("onDragStarted-${asset.id}");
      },
      // 当拖放对象未被DragTarget接受而被拖放时调用
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        setState(() {
          isDragNow = false;
        });
      },
      // 拖拽时的样式
      feedback: _photoItem(null),
      // 拖拽后原本位置的样式
      childWhenDragging: _photoItem(0.3),
      // 不拖拽时的样式
      child: DragTarget<AssetEntity>(
        onWillAccept: (data) {
          print("onWillAccept-${data?.id}");

          setState(() {
            isWillOrder = true;
            targetAssetId = asset.id;
          });
          return true;
        },
        onAccept: (data) {
          print("onAccept-${data.id}");
          // // 从队列中删除拖拽对象

          // final int index = selectedAssets.indexOf(data);
          // print("从队列中删除拖拽对象的index-${index}");
          //
          // selectedAssets.removeAt(index);
          // //
          // int targetIndex = selectedAssets.indexOf(asset);
          // print("目标需要插入的index-${targetIndex}");
          // print("${selectedAssets.length}");
          // // if(targetAssetId==selectedAssets.length-1){
          // //   targetIndex++;
          // // }
          // selectedAssets.insert(targetIndex, data);

          // 0 当前元素位置
          int targetIndex = selectedAssets.indexWhere((element) {
            return element.id == asset.id;
          });

          // 1 删除原来的
          selectedAssets.removeWhere((element) {
            return element.id == data.id;
          });

          // 2 插入到目标前面
          selectedAssets.insert(targetIndex, data);

          setState(() {
            isWillOrder = false;
            targetAssetId = "";
          });
        },
        onLeave: (data) {
          print("onLeave-${data?.id}");
          setState(() {
            isWillOrder = false;
            targetAssetId = "";
          });
        },
        builder: (BuildContext context, List<AssetEntity?> candidateData,
            List<dynamic> rejectedData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return GalleryWidget(
                      initialIndex: selectedAssets.indexOf(asset),
                      items: selectedAssets,
                    );
                  },
                ),
              );
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: (isWillOrder && targetAssetId == asset.id)
                    ? Border.all(
                        color: accentColor,
                        width: imageBorder,
                      )
                    : null,
              ),
              child: AssetEntityImage(
                asset,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                // 这里设置不需要原图显示，缩略图无需原图，非常消耗资源和性能，造成卡顿
                isOriginal: false,
              ),
            ),
          );
        },
      ),
    );
  }

//  删除的bar
  Widget _buildRemoveBar() {
    return DragTarget<AssetEntity>(
      builder: (BuildContext context, List<Object?> candidateData,
          List<dynamic> rejectedData) {
        return Container(
          width: double.infinity,
          height: 100,
          color: isWillRemove ? Colors.red[600] : Colors.red[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text(
                "拖拽到这里删除",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
      //   调用以确定此小部件是否允许接收在此拖动目标上拖动的给定数据块。当一段数据进入目标时调用。
      //   如果数据被拖放，接下来是onAccept和onAcceptWithDetails方法，如果拖放离开目标，接下来是onLeave方法
      onWillAccept: (data) {
        print("onWillAccept");
        setState(() {
          isWillRemove = true;
        });
        return true;
      },
      // 当被允许接收的数据块被拖放到此拖动目标上时调用
      onAccept: (AssetEntity data) {
        print("onAccept：drag target image is ${data}");
        setState(() {
          selectedAssets.remove(data);
          isWillRemove = false;
        });
      },

      onLeave: (data) {
        print("leave");
        setState(() {
          isWillRemove = false;
        });
      },
    );
  }

  //  主视图
  Widget _mainView() {
    return Column(
      children: [
        // 相册列表
        if (postType == PostType.image) _buildPhotosList(),

        // 视频播放器
        if (postType == PostType.video)
          VideoPlayerWidget(
            initAsset: selectedAssets.first,
            onCompleted: (value) => videoCompressMediaFile = value,
          ),

        // 添加按钮
        if (postType == null && selectedAssets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(spacing),
            child: _buildAddImageButton(context, 100),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (selectedAssets.length > 0) {
                for (int i = 0; i < selectedAssets.length; i++) {
                  print("${selectedAssets[i].id}");
                }
              }
            },
            icon: Icon(Icons.ads_click),
          ),
        ],
      ),
      body: _mainView(),
      bottomSheet: isDragNow ? _buildRemoveBar() : null,
    );
  }
}
