import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgCapture extends StatefulWidget {
  final List<String> svgStrings;
  final Function(Map<String, ui.Image>) onImagesCaptured;

  const SvgCapture({
    Key? key,
    required this.svgStrings,
    required this.onImagesCaptured,
  }) : super(key: key);

  @override
  _SvgCaptureState createState() => _SvgCaptureState();
}

class _SvgCaptureState extends State<SvgCapture> {
  final Map<String, GlobalKey> _keys = {};
  final Map<String, ui.Image> _images = {};

  @override
  void initState() {
    super.initState();
    for (final svgString in widget.svgStrings) {
      _keys[svgString] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureWidgets());
  }

  Future<void> _captureWidgets() async {
    for (final svgString in widget.svgStrings) {
      final image = await _captureWidget(svgString);
      if (image != null) {
        _images[svgString] = image;
      }
    }
    widget.onImagesCaptured(_images);
  }

  Future<ui.Image?> _captureWidget(String svgString) async {
    try {
      final key = _keys[svgString]!;
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      return image;
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.0,
      child: Stack(
        children: widget.svgStrings.map((svgString) {
          return RepaintBoundary(
            key: _keys[svgString],
            child: SvgPicture.string(
              svgString,
              width: 64,
              height: 64,
            ),
          );
        }).toList(),
      ),
    );
  }
}
