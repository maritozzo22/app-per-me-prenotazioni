// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_movement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InventoryMovementModel _$InventoryMovementModelFromJson(
  Map<String, dynamic> json,
) {
  return _InventoryMovementModel.fromJson(json);
}

/// @nodoc
mixin _$InventoryMovementModel {
  String get id => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  int get delta => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // ISO8601 string
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this InventoryMovementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryMovementModelCopyWith<InventoryMovementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryMovementModelCopyWith<$Res> {
  factory $InventoryMovementModelCopyWith(
    InventoryMovementModel value,
    $Res Function(InventoryMovementModel) then,
  ) = _$InventoryMovementModelCopyWithImpl<$Res, InventoryMovementModel>;
  @useResult
  $Res call({
    String id,
    String itemId,
    int delta,
    String date,
    String createdAt,
  });
}

/// @nodoc
class _$InventoryMovementModelCopyWithImpl<
  $Res,
  $Val extends InventoryMovementModel
>
    implements $InventoryMovementModelCopyWith<$Res> {
  _$InventoryMovementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? delta = null,
    Object? date = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            delta: null == delta
                ? _value.delta
                : delta // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryMovementModelImplCopyWith<$Res>
    implements $InventoryMovementModelCopyWith<$Res> {
  factory _$$InventoryMovementModelImplCopyWith(
    _$InventoryMovementModelImpl value,
    $Res Function(_$InventoryMovementModelImpl) then,
  ) = __$$InventoryMovementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String itemId,
    int delta,
    String date,
    String createdAt,
  });
}

/// @nodoc
class __$$InventoryMovementModelImplCopyWithImpl<$Res>
    extends
        _$InventoryMovementModelCopyWithImpl<$Res, _$InventoryMovementModelImpl>
    implements _$$InventoryMovementModelImplCopyWith<$Res> {
  __$$InventoryMovementModelImplCopyWithImpl(
    _$InventoryMovementModelImpl _value,
    $Res Function(_$InventoryMovementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? delta = null,
    Object? date = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$InventoryMovementModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        delta: null == delta
            ? _value.delta
            : delta // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryMovementModelImpl extends _InventoryMovementModel {
  const _$InventoryMovementModelImpl({
    required this.id,
    required this.itemId,
    required this.delta,
    required this.date,
    required this.createdAt,
  }) : super._();

  factory _$InventoryMovementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryMovementModelImplFromJson(json);

  @override
  final String id;
  @override
  final String itemId;
  @override
  final int delta;
  @override
  final String date;
  // ISO8601 string
  @override
  final String createdAt;

  @override
  String toString() {
    return 'InventoryMovementModel(id: $id, itemId: $itemId, delta: $delta, date: $date, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryMovementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, itemId, delta, date, createdAt);

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryMovementModelImplCopyWith<_$InventoryMovementModelImpl>
  get copyWith =>
      __$$InventoryMovementModelImplCopyWithImpl<_$InventoryMovementModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryMovementModelImplToJson(this);
  }
}

abstract class _InventoryMovementModel extends InventoryMovementModel {
  const factory _InventoryMovementModel({
    required final String id,
    required final String itemId,
    required final int delta,
    required final String date,
    required final String createdAt,
  }) = _$InventoryMovementModelImpl;
  const _InventoryMovementModel._() : super._();

  factory _InventoryMovementModel.fromJson(Map<String, dynamic> json) =
      _$InventoryMovementModelImpl.fromJson;

  @override
  String get id;
  @override
  String get itemId;
  @override
  int get delta;
  @override
  String get date; // ISO8601 string
  @override
  String get createdAt;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryMovementModelImplCopyWith<_$InventoryMovementModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
