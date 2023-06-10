import 'package:flutter/material.dart';

import '../utils/config.dart';

class TextMaxLinesWidget extends StatefulWidget {
  const TextMaxLinesWidget({Key? key, required this.content, this.maxLines})
      : super(key: key);

  final String content;
  final int? maxLines;

  @override
  State<TextMaxLinesWidget> createState() => _TextMaxLinesWidgetState();
}

class _TextMaxLinesWidgetState extends State<TextMaxLinesWidget> {
  //内容
  late final String _content;

  //最大行数
  late final int _maxLines;

//  是否展开
  bool _isExpansion = false;

  @override
  void initState() {
    super.initState();
    _content = widget.content;
    _maxLines = widget.maxLines ?? 3;
  }

  void _doExpansion() {
    setState(() {
      _isExpansion = !_isExpansion;
    });
  }

  Widget _mainView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 将 TextSpan树 绘制到 Canvas中的对象
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: _content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          maxLines: _maxLines,
          textDirection: TextDirection.ltr,
        )..layout(
            maxWidth: constraints.maxWidth,
          );

        // 1. 不展开
        if (_isExpansion == false) {
          List<Widget> ws = [];
          // 1.1 检查是否超出高度，didExceedMaxLines 是否超出最大行数
          if (textPainter.didExceedMaxLines && _isExpansion == false) {
            ws.add(
              Text(
                _content,
                maxLines: _maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            );
            ws.add(
              GestureDetector(
                onTap: () {
                  _doExpansion();
                },
                child: const Text(
                  "展开全文",
                  style: TextStyle(
                    fontSize: 18,
                    color: textEmphasizeColor,
                  ),
                ),
              ),
            );
          }
          // 1.2 不超出则显示全部
          else {
            ws.add(
              Text(
                _content,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ws,
          );
        }
        // 2. 展开显示全部
        else {
          List<Widget> ws = [];
          ws.add(
            Text(
              _content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          );
          ws.add(
            GestureDetector(
              onTap: () {
                _doExpansion();
              },
              child: const Text(
                "收缩",
                style: TextStyle(
                  fontSize: 18,
                  color: textEmphasizeColor,
                ),
              ),
            ),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ws,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }
}
