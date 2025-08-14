// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LevelMetadata _$LevelMetadataFromJson(Map<String, dynamic> json) {
  return _LevelMetadata.fromJson(json);
}

/// @nodoc
mixin _$LevelMetadata {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get levelNumber => throw _privateConstructorUsedError;
  bool get unlocked => throw _privateConstructorUsedError;

  /// Serializes this LevelMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelMetadataCopyWith<LevelMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelMetadataCopyWith<$Res> {
  factory $LevelMetadataCopyWith(
          LevelMetadata value, $Res Function(LevelMetadata) then) =
      _$LevelMetadataCopyWithImpl<$Res, LevelMetadata>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int levelNumber,
      bool unlocked});
}

/// @nodoc
class _$LevelMetadataCopyWithImpl<$Res, $Val extends LevelMetadata>
    implements $LevelMetadataCopyWith<$Res> {
  _$LevelMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? levelNumber = null,
    Object? unlocked = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      levelNumber: null == levelNumber
          ? _value.levelNumber
          : levelNumber // ignore: cast_nullable_to_non_nullable
              as int,
      unlocked: null == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelMetadataImplCopyWith<$Res>
    implements $LevelMetadataCopyWith<$Res> {
  factory _$$LevelMetadataImplCopyWith(
          _$LevelMetadataImpl value, $Res Function(_$LevelMetadataImpl) then) =
      __$$LevelMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int levelNumber,
      bool unlocked});
}

/// @nodoc
class __$$LevelMetadataImplCopyWithImpl<$Res>
    extends _$LevelMetadataCopyWithImpl<$Res, _$LevelMetadataImpl>
    implements _$$LevelMetadataImplCopyWith<$Res> {
  __$$LevelMetadataImplCopyWithImpl(
      _$LevelMetadataImpl _value, $Res Function(_$LevelMetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? levelNumber = null,
    Object? unlocked = null,
  }) {
    return _then(_$LevelMetadataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      levelNumber: null == levelNumber
          ? _value.levelNumber
          : levelNumber // ignore: cast_nullable_to_non_nullable
              as int,
      unlocked: null == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelMetadataImpl implements _LevelMetadata {
  const _$LevelMetadataImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.levelNumber,
      this.unlocked = false});

  factory _$LevelMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelMetadataImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final int levelNumber;
  @override
  @JsonKey()
  final bool unlocked;

  @override
  String toString() {
    return 'LevelMetadata(id: $id, title: $title, description: $description, levelNumber: $levelNumber, unlocked: $unlocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelMetadataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.levelNumber, levelNumber) ||
                other.levelNumber == levelNumber) &&
            (identical(other.unlocked, unlocked) ||
                other.unlocked == unlocked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, levelNumber, unlocked);

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelMetadataImplCopyWith<_$LevelMetadataImpl> get copyWith =>
      __$$LevelMetadataImplCopyWithImpl<_$LevelMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelMetadataImplToJson(
      this,
    );
  }
}

abstract class _LevelMetadata implements LevelMetadata {
  const factory _LevelMetadata(
      {required final String id,
      required final String title,
      required final String description,
      required final int levelNumber,
      final bool unlocked}) = _$LevelMetadataImpl;

  factory _LevelMetadata.fromJson(Map<String, dynamic> json) =
      _$LevelMetadataImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  int get levelNumber;
  @override
  bool get unlocked;

  /// Create a copy of LevelMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelMetadataImplCopyWith<_$LevelMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
