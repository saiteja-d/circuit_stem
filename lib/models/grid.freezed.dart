// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Grid {
  int get rows => throw _privateConstructorUsedError;
  int get cols => throw _privateConstructorUsedError;
  Map<String, ComponentModel> get componentsById =>
      throw _privateConstructorUsedError;

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GridCopyWith<Grid> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GridCopyWith<$Res> {
  factory $GridCopyWith(Grid value, $Res Function(Grid) then) =
      _$GridCopyWithImpl<$Res, Grid>;
  @useResult
  $Res call({int rows, int cols, Map<String, ComponentModel> componentsById});
}

/// @nodoc
class _$GridCopyWithImpl<$Res, $Val extends Grid>
    implements $GridCopyWith<$Res> {
  _$GridCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? cols = null,
    Object? componentsById = null,
  }) {
    return _then(_value.copyWith(
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as int,
      cols: null == cols
          ? _value.cols
          : cols // ignore: cast_nullable_to_non_nullable
              as int,
      componentsById: null == componentsById
          ? _value.componentsById
          : componentsById // ignore: cast_nullable_to_non_nullable
              as Map<String, ComponentModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GridImplCopyWith<$Res> implements $GridCopyWith<$Res> {
  factory _$$GridImplCopyWith(
          _$GridImpl value, $Res Function(_$GridImpl) then) =
      __$$GridImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rows, int cols, Map<String, ComponentModel> componentsById});
}

/// @nodoc
class __$$GridImplCopyWithImpl<$Res>
    extends _$GridCopyWithImpl<$Res, _$GridImpl>
    implements _$$GridImplCopyWith<$Res> {
  __$$GridImplCopyWithImpl(_$GridImpl _value, $Res Function(_$GridImpl) _then)
      : super(_value, _then);

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? cols = null,
    Object? componentsById = null,
  }) {
    return _then(_$GridImpl(
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as int,
      cols: null == cols
          ? _value.cols
          : cols // ignore: cast_nullable_to_non_nullable
              as int,
      componentsById: null == componentsById
          ? _value._componentsById
          : componentsById // ignore: cast_nullable_to_non_nullable
              as Map<String, ComponentModel>,
    ));
  }
}

/// @nodoc

class _$GridImpl extends _Grid {
  const _$GridImpl(
      {required this.rows,
      required this.cols,
      final Map<String, ComponentModel> componentsById = const {}})
      : _componentsById = componentsById,
        super._();

  @override
  final int rows;
  @override
  final int cols;
  final Map<String, ComponentModel> _componentsById;
  @override
  @JsonKey()
  Map<String, ComponentModel> get componentsById {
    if (_componentsById is EqualUnmodifiableMapView) return _componentsById;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_componentsById);
  }

  @override
  String toString() {
    return 'Grid(rows: $rows, cols: $cols, componentsById: $componentsById)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridImpl &&
            (identical(other.rows, rows) || other.rows == rows) &&
            (identical(other.cols, cols) || other.cols == cols) &&
            const DeepCollectionEquality()
                .equals(other._componentsById, _componentsById));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rows, cols,
      const DeepCollectionEquality().hash(_componentsById));

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridImplCopyWith<_$GridImpl> get copyWith =>
      __$$GridImplCopyWithImpl<_$GridImpl>(this, _$identity);
}

abstract class _Grid extends Grid {
  const factory _Grid(
      {required final int rows,
      required final int cols,
      final Map<String, ComponentModel> componentsById}) = _$GridImpl;
  const _Grid._() : super._();

  @override
  int get rows;
  @override
  int get cols;
  @override
  Map<String, ComponentModel> get componentsById;

  /// Create a copy of Grid
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridImplCopyWith<_$GridImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
