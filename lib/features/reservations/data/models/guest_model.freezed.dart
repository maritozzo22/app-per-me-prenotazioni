// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GuestModel _$GuestModelFromJson(Map<String, dynamic> json) {
  return _GuestModel.fromJson(json);
}

/// @nodoc
mixin _$GuestModel {
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  /// Serializes this GuestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GuestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GuestModelCopyWith<GuestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuestModelCopyWith<$Res> {
  factory $GuestModelCopyWith(
    GuestModel value,
    $Res Function(GuestModel) then,
  ) = _$GuestModelCopyWithImpl<$Res, GuestModel>;
  @useResult
  $Res call({String name, String? phone});
}

/// @nodoc
class _$GuestModelCopyWithImpl<$Res, $Val extends GuestModel>
    implements $GuestModelCopyWith<$Res> {
  _$GuestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? phone = freezed}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GuestModelImplCopyWith<$Res>
    implements $GuestModelCopyWith<$Res> {
  factory _$$GuestModelImplCopyWith(
    _$GuestModelImpl value,
    $Res Function(_$GuestModelImpl) then,
  ) = __$$GuestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? phone});
}

/// @nodoc
class __$$GuestModelImplCopyWithImpl<$Res>
    extends _$GuestModelCopyWithImpl<$Res, _$GuestModelImpl>
    implements _$$GuestModelImplCopyWith<$Res> {
  __$$GuestModelImplCopyWithImpl(
    _$GuestModelImpl _value,
    $Res Function(_$GuestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? phone = freezed}) {
    return _then(
      _$GuestModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GuestModelImpl implements _GuestModel {
  const _$GuestModelImpl({required this.name, this.phone});

  factory _$GuestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GuestModelImplFromJson(json);

  @override
  final String name;
  @override
  final String? phone;

  @override
  String toString() {
    return 'GuestModel(name: $name, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuestModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, phone);

  /// Create a copy of GuestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuestModelImplCopyWith<_$GuestModelImpl> get copyWith =>
      __$$GuestModelImplCopyWithImpl<_$GuestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GuestModelImplToJson(this);
  }
}

abstract class _GuestModel implements GuestModel {
  const factory _GuestModel({required final String name, final String? phone}) =
      _$GuestModelImpl;

  factory _GuestModel.fromJson(Map<String, dynamic> json) =
      _$GuestModelImpl.fromJson;

  @override
  String get name;
  @override
  String? get phone;

  /// Create a copy of GuestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuestModelImplCopyWith<_$GuestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
