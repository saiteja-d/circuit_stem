// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LevelGoal {
  String get type => throw _privateConstructorUsedError;
  int? get r => throw _privateConstructorUsedError;
  int? get c => throw _privateConstructorUsedError;

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelGoalCopyWith<LevelGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelGoalCopyWith<$Res> {
  factory $LevelGoalCopyWith(LevelGoal value, $Res Function(LevelGoal) then) =
      _$LevelGoalCopyWithImpl<$Res, LevelGoal>;
  @useResult
  $Res call({String type, int? r, int? c});
}

/// @nodoc
class _$LevelGoalCopyWithImpl<$Res, $Val extends LevelGoal>
    implements $LevelGoalCopyWith<$Res> {
  _$LevelGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? r = freezed,
    Object? c = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      r: freezed == r
          ? _value.r
          : r // ignore: cast_nullable_to_non_nullable
              as int?,
      c: freezed == c
          ? _value.c
          : c // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelGoalImplCopyWith<$Res>
    implements $LevelGoalCopyWith<$Res> {
  factory _$$LevelGoalImplCopyWith(
          _$LevelGoalImpl value, $Res Function(_$LevelGoalImpl) then) =
      __$$LevelGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, int? r, int? c});
}

/// @nodoc
class __$$LevelGoalImplCopyWithImpl<$Res>
    extends _$LevelGoalCopyWithImpl<$Res, _$LevelGoalImpl>
    implements _$$LevelGoalImplCopyWith<$Res> {
  __$$LevelGoalImplCopyWithImpl(
      _$LevelGoalImpl _value, $Res Function(_$LevelGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? r = freezed,
    Object? c = freezed,
  }) {
    return _then(_$LevelGoalImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      r: freezed == r
          ? _value.r
          : r // ignore: cast_nullable_to_non_nullable
              as int?,
      c: freezed == c
          ? _value.c
          : c // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$LevelGoalImpl with DiagnosticableTreeMixin implements _LevelGoal {
  const _$LevelGoalImpl({required this.type, this.r, this.c});

  @override
  final String type;
  @override
  final int? r;
  @override
  final int? c;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LevelGoal(type: $type, r: $r, c: $c)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LevelGoal'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('r', r))
      ..add(DiagnosticsProperty('c', c));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelGoalImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.r, r) || other.r == r) &&
            (identical(other.c, c) || other.c == c));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, r, c);

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelGoalImplCopyWith<_$LevelGoalImpl> get copyWith =>
      __$$LevelGoalImplCopyWithImpl<_$LevelGoalImpl>(this, _$identity);
}

abstract class _LevelGoal implements LevelGoal {
  const factory _LevelGoal(
      {required final String type,
      final int? r,
      final int? c}) = _$LevelGoalImpl;

  @override
  String get type;
  @override
  int? get r;
  @override
  int? get c;

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelGoalImplCopyWith<_$LevelGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
