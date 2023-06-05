import 'package:flutter/material.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:wechat_moments/utils/index.dart';
import 'package:wechat_moments/widgets/index.dart';

import '../entity/index.dart';

enum PostType {
  image,
  video,
}

class PostEditPage extends StatefulWidget {
  const PostEditPage({Key? key, this.postType, this.selectedAssets})
      : super(key: key);

//  发布类型
  final PostType? postType;

//  已选中的图片列表
  final List<AssetEntity>? selectedAssets;

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
//  发布类型
  PostType? _postType;

//  已选中图片列表
  List<AssetEntity> _selectedAssets = [];

//  是否开始拖拽
  bool _isDragNow = false;

//  是否将要删除
  bool _isWillRemove = false;

//  是否将要拖拽
  bool _isWillOrder = false;

//  被拖拽的id
  late String _targetAssetId;

//  内容输入控制器
  final TextEditingController _contentController = TextEditingController();

//  菜单列表
  List<MenuItemModel> _menus = [];

//  已压缩的视频文件
  // ignore: unused_field
  CompressMediaFile? _videoCompressMediaFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postType = widget.postType;
    _selectedAssets = widget.selectedAssets ?? [];

    _menus = [
      MenuItemModel(icon: Icons.location_on_outlined, title: "所在位置"),
      MenuItemModel(icon: Icons.alternate_email_outlined, title: "提醒谁看"),
      MenuItemModel(
          icon: Icons.person_outline_outlined,
          title: "谁可以看",
          rightText: "公开",
          onTap: () {}),
    ];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _contentController.dispose();
  }

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
              for (final asset in _selectedAssets)
                _buildPhotoItem(asset, imageSize),
              //加入图片末尾的按钮
              if (_selectedAssets.length < maxAssets)
                _buildAddImageButton(context, imageSize),
              // _buildAddImageButton(context, imageSize)
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
        print("${widget.selectedAssets}");
        final result =
            await MyBottomSheet(selectedAssets: widget.selectedAssets)
                .wxPicker<List<AssetEntity>>(context: context);

        if (result == null || result.isEmpty) return;

        // 视频
        if (result.length == 1 && result.first.type == AssetType.video) {
          setState(() {
            _postType = PostType.video;
            _selectedAssets = result;
          });
        }
        // 图片
        else {
          setState(() {
            _postType = PostType.image;
            _selectedAssets = result;
          });
        }

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

        //3
        // showModalBottomSheet(
        //   context: context,
        //   useSafeArea: true,
        //   builder: (BuildContext context) {
        //     return Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         ListTile(
        //           leading: Icon(Icons.camera_alt),
        //           title: Text('拍照'),
        //           onTap: () async {
        //             AssetEntity? asset =await MyAssetPicker.takePhoto(context);
        //             if(asset==null)return;
        //             setState(() {
        //               _postType=PostType.image;
        //               _selectedAssets.add(asset);
        //             });
        //             Navigator.pop(context);
        //           },
        //         ),
        //         ListTile(
        //           leading: Icon(Icons.videocam),
        //           title: Text('摄像'),
        //           onTap: () async{
        //             AssetEntity? asset =await MyAssetPicker.takeVideo(context);
        //             if(asset==null)return;
        //             setState(() {
        //               _postType=PostType.video;
        //               _selectedAssets.clear();
        //               _selectedAssets.add(asset);
        //             });
        //             Navigator.pop(context);
        //           },
        //         ),
        //         ListTile(
        //           leading: Icon(Icons.photo),
        //           title: Text("选取图片"),
        //           onTap: ()async{
        //             List<AssetEntity>? asset = await MyAssetPicker.getAsset(context: context,selectedAssets: _selectedAssets);
        //             if(asset==null)return;
        //             setState(() {
        //               _postType=PostType.image;
        //               _postType=null;
        //               _selectedAssets=asset;
        //             });
        //             Navigator.pop(context);
        //           },
        //         )
        //       ],
        //     );
        //   },
        // );
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
            _selectedAssets.add(result);
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
          _isDragNow = true;
        });
      },
//      拖拽结束时
      onDragEnd: (DraggableDetails details) {
        print("onDragStarted-${asset.id}");
        setState(() {
          _isDragNow = false;
          _isWillOrder = false;
        });
      },
      // 当draggable被拖放并被DragTarget接受时调用
      onDragCompleted: () {
        print("onDragStarted-${asset.id}");
      },
      // 当拖放对象未被DragTarget接受而被拖放时调用
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        setState(() {
          _isDragNow = false;
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
            _isWillOrder = true;
            _targetAssetId = asset.id;
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
          int targetIndex = _selectedAssets.indexWhere((element) {
            return element.id == asset.id;
          });

          // 1 删除原来的
          _selectedAssets.removeWhere((element) {
            return element.id == data.id;
          });

          // 2 插入到目标前面
          _selectedAssets.insert(targetIndex, data);

          setState(() {
            _isWillOrder = false;
            _targetAssetId = "";
          });
        },
        onLeave: (data) {
          print("onLeave-${data?.id}");
          setState(() {
            _isWillOrder = false;
            _targetAssetId = "";
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
                      initialIndex: _selectedAssets.indexOf(asset),
                      items: _selectedAssets,
                    );
                  },
                ),
              );
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: (_isWillOrder && _targetAssetId == asset.id)
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

  ///  删除的bar
  Widget _buildRemoveBar() {
    return DragTarget<AssetEntity>(
      builder: (BuildContext context, List<Object?> candidateData,
          List<dynamic> rejectedData) {
        return Container(
          width: double.infinity,
          height: 100,
          color: _isWillRemove ? Colors.red[600] : Colors.red[300],
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
          _isWillRemove = true;
        });
        return true;
      },
      // 当被允许接收的数据块被拖放到此拖动目标上时调用
      onAccept: (AssetEntity data) {
        print("onAccept：drag target image is ${data}");
        setState(() {
          _selectedAssets.remove(data);
          _isWillRemove = false;
        });
      },

      onLeave: (data) {
        print("leave");
        setState(() {
          _isWillRemove = false;
        });
      },
    );
  }

  ///内容输入框
  Widget _buildContentInput() {
    return LimitedBox(
      maxHeight: 180,
      child: TextField(
        maxLines: null,
        maxLength: 20,
        controller: _contentController,
        decoration: InputDecoration(
          hintText: "这一刻的想法...",
          hintStyle: const TextStyle(
            color: Colors.black12,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          // 显示输入框右下角当前字数和最大可输入字数
          counterText: _contentController.text.isEmpty ? "" : null,
        ),
        // 当文字输入控制器发生变化时会发生一次回调
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  ///菜单项
  Widget _buildMenus() {
    List<Widget> ws = [];
    for (int i = 0; i < _menus.length; i++) {
      var menu = _menus[i];
      
      if(i==0){
        ws.add(MyDividerWidget());
      }
      ws.add(
        ListTile(
          leading: Icon(menu.icon),
          title: Text(menu.title!),
          trailing: Text(menu.rightText ?? ""),
          onTap: menu.onTap,
        ),
      );
      ws.add(MyDividerWidget());
    }
    return Padding(
      padding: const EdgeInsets.only(top: 200),
      child: Column(
        children: ws,
      ),
    );
  }

  //  主视图
  Widget _mainView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(pagePadding),
          child: Column(
            children: [
              // 内容输入区域
              _buildContentInput(),
              // 相册列表
              if (_postType == PostType.image) _buildPhotosList(),
              // 视频播放器
              if (_postType == PostType.video)
                VideoPlayerWidget(
                  initAsset: _selectedAssets.first,
                  onCompleted: (value) => _videoCompressMediaFile = value,
                ),

              // 添加按钮
              if (_postType == null && _selectedAssets.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(spacing),
                  child: _buildAddImageButton(context, 100),
                ),
              _buildMenus(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        // 左侧返回
        leading: Padding(
          padding: const EdgeInsets.only(left: pagePadding),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.grey,
            ),
          ),
        ),
        //右侧发布
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: pagePadding),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("发布"),
            ),
          ),
        ],
      ),
      body: _mainView(),
      bottomSheet: _isDragNow ? _buildRemoveBar() : null,
    );
  }
}
