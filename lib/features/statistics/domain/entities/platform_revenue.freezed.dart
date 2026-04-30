// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_revenue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlatformRevenue _$PlatformRevenueFromJson(Map<String, dynamic> json) {
  return _PlatformRevenue.fromJson(json);
}

/// @nodoc
mixin _$PlatformRevenue {
  String get platformId => throw _privateConstructorUsedError;
  String get platformName => throw _privateConstructorUsedError;
  int get color =>
      throw _privateConstructorUsedError; // ARGB color value (from BookingPlatform.color)
  double get totalRevenue => throw _privateConstructorUsedError;
  int get bookingCount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this PlatformRevenue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlatformRevenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlatformRevenueCopyWith<PlatformRevenue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatformRevenueCopyWith<$Res> {
  factory $PlatformRevenueCopyWith(
    PlatformRevenue value,
    $Res Function(PlatformRevenue) then,
  ) = _$PlatformRevenueCopyWithImpl<$Res, PlatformRevenue>;
  @useResult
  $Res call({
    String platformId,
    String platformName,
    int color,
    double totalRevenue,
    int bookingCount,
    double percentage,
  });
}

/// @nodoc
class _$PlatformRevenueCopyWithImpl<$Res, $Val extends PlatformRevenue>
    implements $PlatformRevenueCopyWith<$Res> {
  _$PlatformRevenueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlatformRevenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platformId = null,
    Object? platformName = null,
    Object? color = null,
    Object? totalRevenue = null,
    Object? bookingCount = null,
    Object? percentage = null,
  }) {
    return _then(
      _value.copyWith(
            platformId: null == platformId
                ? _value.platformId
                : platformId // ignore: cast_nullable_to_non_nullable
                      as String,
            platformName: null == platformName
                ? _value.platformName
                : platformName // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            bookingCount: null == bookingCount
                ? _value.bookingCount
                : bookingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlatformRevenueImplCopyWith<$Res>
    implements $PlatformRevenueCopyWith<$Res> {
  factory _$$PlatformRevenueImplCopyWith(
    _$PlatformRevenueImpl value,
    $Res Function(_$PlatformRevenueImpl) then,
  ) = __$$PlatformRevenueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String platformId,
    String platformName,
    int color,
    double totalRevenue,
    int bookingCount,
    double percentage,
  });
}

/// @nodoc
class __$$PlatformRevenueImplCopyWithImpl<$Res>
    extends _$PlatformRevenueCopyWithImpl<$Res, _$PlatformRevenueImpl>
    implements _$$PlatformRevenueImplCopyWith<$Res> {
  __$$PlatformRevenueImplCopyWithImpl(
    _$PlatformRevenueImpl _value,
    $Res Function(_$PlatformRevenueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlatformRevenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? platformId = null,
    Object? platformName = null,
    Object? color = null,
    Object? totalRevenue = null,
    Object? bookingCount = null,
    Object? percentage = null,
  }) {
    return _then(
      _$PlatformRevenueImpl(
        platformId: null == platformId
            ? _value.platformId
            : platformId // ignore: cast_nullable_to_non_nullable
                  as String,
        platformName: null == platformName
            ? _value.platformName
            : platformName // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        bookingCount: null == bookingCount
            ? _value.bookingCount
            : bookingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlatformRevenueImpl implements _PlatformRevenue {
  const _$PlatformRevenueImpl({
    required this.platformId,
    required this.platformName,
    required this.color,
    required this.totalRevenue,
    required this.bookingCount,
    required this.percentage,
  });

  factory _$PlatformRevenueImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlatformRevenueImplFromJson(json);

  @override
  final String platformId;
  @override
  final String platformName;
  @override
  final int color;
  // ARGB color value (from BookingPlatform.color)
  @override
  final double totalRevenue;
  @override
  final int bookingCount;
  @override
  final double percentage;

  @override
  String toString() {
    return 'PlatformRevenue(platformId: $platformId, platformName: $platformName, color: $color, totalRevenue: $totalRevenue, bookingCount: $bookingCount, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatformRevenueImpl &&
            (identical(other.platformId, platformId) ||
                other.platformId == platformId) &&
            (identical(other.platformName, platformName) ||
                other.platformName == platformName) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.bookingCount, bookingCount) ||
                other.bookingCount == bookingCount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    platformId,
    platformName,
    color,
    totalRevenue,
    bookingCount,
    percentage,
  );

  /// Create a copy of PlatformRevenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatformRevenueImplCopyWith<_$PlatformRevenueImpl> get copyWith =>
      __$$PlatformRevenueImplCopyWithImpl<_$PlatformRevenueImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlatformRevenueImplToJson(this);
  }
}

abstract class _PlatformRevenue implements PlatformRevenue {
  const factory _PlatformRevenue({
    required final String platformId,
    required final String platformName,
    required final int color,
    required final double totalRevenue,
    required final int bookingCount,
    required final double percentage,
  }) = _$PlatformRevenueImpl;

  factory _PlatformRevenue.fromJson(Map<String, dynamic> json) =
      _$PlatformRevenueImpl.fromJson;

  @override
  String get platformId;
  @override
  String get platformName;
  @override
  int get color; // ARGB color value (from BookingPlatform.color)
  @override
  double get totalRevenue;
  @override
  int get bookingCount;
  @override
  double get percentage;

  /// Create a copy of PlatformRevenue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlatformRevenueImplCopyWith<_$PlatformRevenueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
