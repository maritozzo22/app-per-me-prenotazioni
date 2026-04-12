// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InventoryItemModel _$InventoryItemModelFromJson(Map<String, dynamic> json) {
  return _InventoryItemModel.fromJson(json);
}

/// @nodoc
mixin _$InventoryItemModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // Stored as string enum value
  int get quantity => throw _privateConstructorUsedError;
  String? get expiryDate =>
      throw _privateConstructorUsedError; // ISO8601 string or null
  String? get notes => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this InventoryItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryItemModelCopyWith<InventoryItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemModelCopyWith<$Res> {
  factory $InventoryItemModelCopyWith(
    InventoryItemModel value,
    $Res Function(InventoryItemModel) then,
  ) = _$InventoryItemModelCopyWithImpl<$Res, InventoryItemModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    int quantity,
    String? expiryDate,
    String? notes,
    String createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class _$InventoryItemModelCopyWithImpl<$Res, $Val extends InventoryItemModel>
    implements $InventoryItemModelCopyWith<$Res> {
  _$InventoryItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? quantity = null,
    Object? expiryDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryItemModelImplCopyWith<$Res>
    implements $InventoryItemModelCopyWith<$Res> {
  factory _$$InventoryItemModelImplCopyWith(
    _$InventoryItemModelImpl value,
    $Res Function(_$InventoryItemModelImpl) then,
  ) = __$$InventoryItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    int quantity,
    String? expiryDate,
    String? notes,
    String createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class __$$InventoryItemModelImplCopyWithImpl<$Res>
    extends _$InventoryItemModelCopyWithImpl<$Res, _$InventoryItemModelImpl>
    implements _$$InventoryItemModelImplCopyWith<$Res> {
  __$$InventoryItemModelImplCopyWithImpl(
    _$InventoryItemModelImpl _value,
    $Res Function(_$InventoryItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? quantity = null,
    Object? expiryDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$InventoryItemModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryItemModelImpl extends _InventoryItemModel {
  const _$InventoryItemModelImpl({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.expiryDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$InventoryItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  // Stored as string enum value
  @override
  final int quantity;
  @override
  final String? expiryDate;
  // ISO8601 string or null
  @override
  final String? notes;
  @override
  final String createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'InventoryItemModel(id: $id, name: $name, category: $category, quantity: $quantity, expiryDate: $expiryDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    quantity,
    expiryDate,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemModelImplCopyWith<_$InventoryItemModelImpl> get copyWith =>
      __$$InventoryItemModelImplCopyWithImpl<_$InventoryItemModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryItemModelImplToJson(this);
  }
}

abstract class _InventoryItemModel extends InventoryItemModel {
  const factory _InventoryItemModel({
    required final String id,
    required final String name,
    required final String category,
    required final int quantity,
    final String? expiryDate,
    final String? notes,
    required final String createdAt,
    final String? updatedAt,
  }) = _$InventoryItemModelImpl;
  const _InventoryItemModel._() : super._();

  factory _InventoryItemModel.fromJson(Map<String, dynamic> json) =
      _$InventoryItemModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category; // Stored as string enum value
  @override
  int get quantity;
  @override
  String? get expiryDate; // ISO8601 string or null
  @override
  String? get notes;
  @override
  String get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryItemModelImplCopyWith<_$InventoryItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
