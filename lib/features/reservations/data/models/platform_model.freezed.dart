// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlatformModel _$PlatformModelFromJson(Map<String, dynamic> json) {
  return _PlatformModel.fromJson(json);
}

/// @nodoc
mixin _$PlatformModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isSystem => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlatformModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlatformModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlatformModelCopyWith<PlatformModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatformModelCopyWith<$Res> {
  factory $PlatformModelCopyWith(
    PlatformModel value,
    $Res Function(PlatformModel) then,
  ) = _$PlatformModelCopyWithImpl<$Res, PlatformModel>;
  @useResult
  $Res call({
    String id,
    String name,
    int colorValue,
    bool isDefault,
    bool isSystem,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PlatformModelCopyWithImpl<$Res, $Val extends PlatformModel>
    implements $PlatformModelCopyWith<$Res> {
  _$PlatformModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlatformModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorValue = null,
    Object? isDefault = null,
    Object? isSystem = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            colorValue: null == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSystem: null == isSystem
                ? _value.isSystem
                : isSystem // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlatformModelImplCopyWith<$Res>
    implements $PlatformModelCopyWith<$Res> {
  factory _$$PlatformModelImplCopyWith(
    _$PlatformModelImpl value,
    $Res Function(_$PlatformModelImpl) then,
  ) = __$$PlatformModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int colorValue,
    bool isDefault,
    bool isSystem,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PlatformModelImplCopyWithImpl<$Res>
    extends _$PlatformModelCopyWithImpl<$Res, _$PlatformModelImpl>
    implements _$$PlatformModelImplCopyWith<$Res> {
  __$$PlatformModelImplCopyWithImpl(
    _$PlatformModelImpl _value,
    $Res Function(_$PlatformModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlatformModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorValue = null,
    Object? isDefault = null,
    Object? isSystem = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PlatformModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        colorValue: null == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSystem: null == isSystem
            ? _value.isSystem
            : isSystem // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlatformModelImpl implements _PlatformModel {
  const _$PlatformModelImpl({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isDefault = false,
    this.isSystem = false,
    required this.createdAt,
  });

  factory _$PlatformModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlatformModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int colorValue;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isSystem;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PlatformModel(id: $id, name: $name, colorValue: $colorValue, isDefault: $isDefault, isSystem: $isSystem, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatformModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    colorValue,
    isDefault,
    isSystem,
    createdAt,
  );

  /// Create a copy of PlatformModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatformModelImplCopyWith<_$PlatformModelImpl> get copyWith =>
      __$$PlatformModelImplCopyWithImpl<_$PlatformModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlatformModelImplToJson(this);
  }
}

abstract class _PlatformModel implements PlatformModel {
  const factory _PlatformModel({
    required final String id,
    required final String name,
    required final int colorValue,
    final bool isDefault,
    final bool isSystem,
    required final DateTime createdAt,
  }) = _$PlatformModelImpl;

  factory _PlatformModel.fromJson(Map<String, dynamic> json) =
      _$PlatformModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get colorValue;
  @override
  bool get isDefault;
  @override
  bool get isSystem;
  @override
  DateTime get createdAt;

  /// Create a copy of PlatformModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlatformModelImplCopyWith<_$PlatformModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
