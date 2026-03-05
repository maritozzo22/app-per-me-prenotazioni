// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReservationModel _$ReservationModelFromJson(Map<String, dynamic> json) {
  return _ReservationModel.fromJson(json);
}

/// @nodoc
mixin _$ReservationModel {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get platformId => throw _privateConstructorUsedError;
  GuestModel get guest => throw _privateConstructorUsedError;
  DateTime get checkIn => throw _privateConstructorUsedError;
  DateTime get checkOut => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReservationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReservationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationModelCopyWith<ReservationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationModelCopyWith<$Res> {
  factory $ReservationModelCopyWith(
    ReservationModel value,
    $Res Function(ReservationModel) then,
  ) = _$ReservationModelCopyWithImpl<$Res, ReservationModel>;
  @useResult
  $Res call({
    String id,
    String roomId,
    String platformId,
    GuestModel guest,
    DateTime checkIn,
    DateTime checkOut,
    double? amount,
    PaymentStatus paymentStatus,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $GuestModelCopyWith<$Res> get guest;
}

/// @nodoc
class _$ReservationModelCopyWithImpl<$Res, $Val extends ReservationModel>
    implements $ReservationModelCopyWith<$Res> {
  _$ReservationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? platformId = null,
    Object? guest = null,
    Object? checkIn = null,
    Object? checkOut = null,
    Object? amount = freezed,
    Object? paymentStatus = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            platformId: null == platformId
                ? _value.platformId
                : platformId // ignore: cast_nullable_to_non_nullable
                      as String,
            guest: null == guest
                ? _value.guest
                : guest // ignore: cast_nullable_to_non_nullable
                      as GuestModel,
            checkIn: null == checkIn
                ? _value.checkIn
                : checkIn // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            checkOut: null == checkOut
                ? _value.checkOut
                : checkOut // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            amount: freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double?,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as PaymentStatus,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of ReservationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GuestModelCopyWith<$Res> get guest {
    return $GuestModelCopyWith<$Res>(_value.guest, (value) {
      return _then(_value.copyWith(guest: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReservationModelImplCopyWith<$Res>
    implements $ReservationModelCopyWith<$Res> {
  factory _$$ReservationModelImplCopyWith(
    _$ReservationModelImpl value,
    $Res Function(_$ReservationModelImpl) then,
  ) = __$$ReservationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String roomId,
    String platformId,
    GuestModel guest,
    DateTime checkIn,
    DateTime checkOut,
    double? amount,
    PaymentStatus paymentStatus,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $GuestModelCopyWith<$Res> get guest;
}

/// @nodoc
class __$$ReservationModelImplCopyWithImpl<$Res>
    extends _$ReservationModelCopyWithImpl<$Res, _$ReservationModelImpl>
    implements _$$ReservationModelImplCopyWith<$Res> {
  __$$ReservationModelImplCopyWithImpl(
    _$ReservationModelImpl _value,
    $Res Function(_$ReservationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReservationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? platformId = null,
    Object? guest = null,
    Object? checkIn = null,
    Object? checkOut = null,
    Object? amount = freezed,
    Object? paymentStatus = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ReservationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        platformId: null == platformId
            ? _value.platformId
            : platformId // ignore: cast_nullable_to_non_nullable
                  as String,
        guest: null == guest
            ? _value.guest
            : guest // ignore: cast_nullable_to_non_nullable
                  as GuestModel,
        checkIn: null == checkIn
            ? _value.checkIn
            : checkIn // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        checkOut: null == checkOut
            ? _value.checkOut
            : checkOut // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        amount: freezed == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double?,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as PaymentStatus,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, converters: [PaymentStatusConverter()])
class _$ReservationModelImpl implements _ReservationModel {
  const _$ReservationModelImpl({
    required this.id,
    required this.roomId,
    required this.platformId,
    required this.guest,
    required this.checkIn,
    required this.checkOut,
    this.amount,
    this.paymentStatus = PaymentStatus.pending,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ReservationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String roomId;
  @override
  final String platformId;
  @override
  final GuestModel guest;
  @override
  final DateTime checkIn;
  @override
  final DateTime checkOut;
  @override
  final double? amount;
  @override
  @JsonKey()
  final PaymentStatus paymentStatus;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ReservationModel(id: $id, roomId: $roomId, platformId: $platformId, guest: $guest, checkIn: $checkIn, checkOut: $checkOut, amount: $amount, paymentStatus: $paymentStatus, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.platformId, platformId) ||
                other.platformId == platformId) &&
            (identical(other.guest, guest) || other.guest == guest) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
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
    roomId,
    platformId,
    guest,
    checkIn,
    checkOut,
    amount,
    paymentStatus,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ReservationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationModelImplCopyWith<_$ReservationModelImpl> get copyWith =>
      __$$ReservationModelImplCopyWithImpl<_$ReservationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationModelImplToJson(this);
  }
}

abstract class _ReservationModel implements ReservationModel {
  const factory _ReservationModel({
    required final String id,
    required final String roomId,
    required final String platformId,
    required final GuestModel guest,
    required final DateTime checkIn,
    required final DateTime checkOut,
    final double? amount,
    final PaymentStatus paymentStatus,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ReservationModelImpl;

  factory _ReservationModel.fromJson(Map<String, dynamic> json) =
      _$ReservationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get roomId;
  @override
  String get platformId;
  @override
  GuestModel get guest;
  @override
  DateTime get checkIn;
  @override
  DateTime get checkOut;
  @override
  double? get amount;
  @override
  PaymentStatus get paymentStatus;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ReservationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationModelImplCopyWith<_$ReservationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
