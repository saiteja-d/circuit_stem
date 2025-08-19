import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_manager_state.freezed.dart';

@freezed
class AssetState with _$AssetState {
  const factory AssetState({
    @Default({}) Map<String, Image> imageCache,
    @Default({}) Map<String, Image> svgImageCache,
  }) = _AssetState;
}