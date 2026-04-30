// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackupDataModel _$BackupDataModelFromJson(Map<String, dynamic> json) {
  return _BackupDataModel.fromJson(json);
}

/// @nodoc
mixin _$BackupDataModel {
  String get version => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get reservations =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get platforms =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get rooms => throw _privateConstructorUsedError;
  String get backupType => throw _privateConstructorUsedError;

  /// Serializes this BackupDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupDataModelCopyWith<BackupDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupDataModelCopyWith<$Res> {
  factory $BackupDataModelCopyWith(
    BackupDataModel value,
    $Res Function(BackupDataModel) then,
  ) = _$BackupDataModelCopyWithImpl<$Res, BackupDataModel>;
  @useResult
  $Res call({
    String version,
    DateTime timestamp,
    List<Map<String, dynamic>> reservations,
    List<Map<String, dynamic>> platforms,
    List<Map<String, dynamic>> rooms,
    String backupType,
  });
}

/// @nodoc
class _$BackupDataModelCopyWithImpl<$Res, $Val extends BackupDataModel>
    implements $BackupDataModelCopyWith<$Res> {
  _$BackupDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? timestamp = null,
    Object? reservations = null,
    Object? platforms = null,
    Object? rooms = null,
    Object? backupType = null,
  }) {
    return _then(
      _value.copyWith(
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reservations: null == reservations
                ? _value.reservations
                : reservations // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            platforms: null == platforms
                ? _value.platforms
                : platforms // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            rooms: null == rooms
                ? _value.rooms
                : rooms // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            backupType: null == backupType
                ? _value.backupType
                : backupType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupDataModelImplCopyWith<$Res>
    implements $BackupDataModelCopyWith<$Res> {
  factory _$$BackupDataModelImplCopyWith(
    _$BackupDataModelImpl value,
    $Res Function(_$BackupDataModelImpl) then,
  ) = __$$BackupDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String version,
    DateTime timestamp,
    List<Map<String, dynamic>> reservations,
    List<Map<String, dynamic>> platforms,
    List<Map<String, dynamic>> rooms,
    String backupType,
  });
}

/// @nodoc
class __$$BackupDataModelImplCopyWithImpl<$Res>
    extends _$BackupDataModelCopyWithImpl<$Res, _$BackupDataModelImpl>
    implements _$$BackupDataModelImplCopyWith<$Res> {
  __$$BackupDataModelImplCopyWithImpl(
    _$BackupDataModelImpl _value,
    $Res Function(_$BackupDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? timestamp = null,
    Object? reservations = null,
    Object? platforms = null,
    Object? rooms = null,
    Object? backupType = null,
  }) {
    return _then(
      _$BackupDataModelImpl(
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reservations: null == reservations
            ? _value._reservations
            : reservations // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        platforms: null == platforms
            ? _value._platforms
            : platforms // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        rooms: null == rooms
            ? _value._rooms
            : rooms // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        backupType: null == backupType
            ? _value.backupType
            : backupType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupDataModelImpl implements _BackupDataModel {
  const _$BackupDataModelImpl({
    required this.version,
    required this.timestamp,
    required final List<Map<String, dynamic>> reservations,
    required final List<Map<String, dynamic>> platforms,
    required final List<Map<String, dynamic>> rooms,
    this.backupType = 'manual',
  }) : _reservations = reservations,
       _platforms = platforms,
       _rooms = rooms;

  factory _$BackupDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupDataModelImplFromJson(json);

  @override
  final String version;
  @override
  final DateTime timestamp;
  final List<Map<String, dynamic>> _reservations;
  @override
  List<Map<String, dynamic>> get reservations {
    if (_reservations is EqualUnmodifiableListView) return _reservations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reservations);
  }

  final List<Map<String, dynamic>> _platforms;
  @override
  List<Map<String, dynamic>> get platforms {
    if (_platforms is EqualUnmodifiableListView) return _platforms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_platforms);
  }

  final List<Map<String, dynamic>> _rooms;
  @override
  List<Map<String, dynamic>> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @override
  @JsonKey()
  final String backupType;

  @override
  String toString() {
    return 'BackupDataModel(version: $version, timestamp: $timestamp, reservations: $reservations, platforms: $platforms, rooms: $rooms, backupType: $backupType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupDataModelImpl &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(
              other._reservations,
              _reservations,
            ) &&
            const DeepCollectionEquality().equals(
              other._platforms,
              _platforms,
            ) &&
            const DeepCollectionEquality().equals(other._rooms, _rooms) &&
            (identical(other.backupType, backupType) ||
                other.backupType == backupType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    timestamp,
    const DeepCollectionEquality().hash(_reservations),
    const DeepCollectionEquality().hash(_platforms),
    const DeepCollectionEquality().hash(_rooms),
    backupType,
  );

  /// Create a copy of BackupDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupDataModelImplCopyWith<_$BackupDataModelImpl> get copyWith =>
      __$$BackupDataModelImplCopyWithImpl<_$BackupDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupDataModelImplToJson(this);
  }
}

abstract class _BackupDataModel implements BackupDataModel {
  const factory _BackupDataModel({
    required final String version,
    required final DateTime timestamp,
    required final List<Map<String, dynamic>> reservations,
    required final List<Map<String, dynamic>> platforms,
    required final List<Map<String, dynamic>> rooms,
    final String backupType,
  }) = _$BackupDataModelImpl;

  factory _BackupDataModel.fromJson(Map<String, dynamic> json) =
      _$BackupDataModelImpl.fromJson;

  @override
  String get version;
  @override
  DateTime get timestamp;
  @override
  List<Map<String, dynamic>> get reservations;
  @override
  List<Map<String, dynamic>> get platforms;
  @override
  List<Map<String, dynamic>> get rooms;
  @override
  String get backupType;

  /// Create a copy of BackupDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupDataModelImplCopyWith<_$BackupDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
