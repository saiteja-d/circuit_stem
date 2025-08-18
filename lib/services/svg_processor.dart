import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'svg_processor_base.dart';

class SvgProcessor implements SvgProcessorBase {
  @override
  Future<Map<String, ui.Image>> processSvgs(List<String> assetPaths) async {
    final imageFutures = assetPaths.map((path) async {
      try {
        final svgString = await rootBundle.loadString(path);
        final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
        final image = await pictureInfo.picture.toImage(64, 64); // Assuming a default size
        pictureInfo.picture.dispose();
        return MapEntry(path, image);
      } catch (e) {
        debugPrint('Failed to process SVG $path: $e. Skipping.');
        return null; // Gracefully handle individual asset failure
      }
    }).where((future) => future != null);

    final results = await Future.wait(imageFutures.cast());
    return Map.fromEntries(results.where((entry) => entry != null).cast());
  }
}
