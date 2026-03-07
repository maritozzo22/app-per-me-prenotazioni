// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_revenue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyRevenue _$MonthlyRevenueFromJson(Map<String, dynamic> json) {
  return _MonthlyRevenue.fromJson(json);
}

/// @nodoc
mixin _$MonthlyRevenue {
  String get month =>
      throw _privateConstructorUsedError; // Format: YYYY-MM (e.g., "2025-01")
  double get revenue => throw _privateConstructorUsedError;
  int get bookingCount => throw _privateConstructorUsedError;

  /// Serializes this MonthlyRevenue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyRevenueCopyWith<MonthlyRevenue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyRevenueCopyWith<$Res> {
  factory $MonthlyRevenueCopyWith(
    MonthlyRevenue value,
    $Res Function(MonthlyRevenue) then,
  ) = _$MonthlyRevenueCopyWithImpl<$Res, MonthlyRevenue>;
  @useResult
  $Res call({String month, double revenue, int bookingCount});
}

/// @nodoc
class _$MonthlyRevenueCopyWithImpl<$Res, $Val extends MonthlyRevenue>
    implements $MonthlyRevenueCopyWith<$Res> {
  _$MonthlyRevenueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? revenue = null,
    Object? bookingCount = null,
  }) {
    return _then(
      _value.copyWith(
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            bookingCount: null == bookingCount
                ? _value.bookingCount
                : bookingCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyRevenueImplCopyWith<$Res>
    implements $MonthlyRevenueCopyWith<$Res> {
  factory _$$MonthlyRevenueImplCopyWith(
    _$MonthlyRevenueImpl value,
    $Res Function(_$MonthlyRevenueImpl) then,
  ) = __$$MonthlyRevenueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, double revenue, int bookingCount});
}

/// @nodoc
class __$$MonthlyRevenueImplCopyWithImpl<$Res>
    extends _$MonthlyRevenueCopyWithImpl<$Res, _$MonthlyRevenueImpl>
    implements _$$MonthlyRevenueImplCopyWith<$Res> {
  __$$MonthlyRevenueImplCopyWithImpl(
    _$MonthlyRevenueImpl _value,
    $Res Function(_$MonthlyRevenueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? revenue = null,
    Object? bookingCount = null,
  }) {
    return _then(
      _$MonthlyRevenueImpl(
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        bookingCount: null == bookingCount
            ? _value.bookingCount
            : bookingCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyRevenueImpl implements _MonthlyRevenue {
  const _$MonthlyRevenueImpl({
    required this.month,
    required this.revenue,
    required this.bookingCount,
  });

  factory _$MonthlyRevenueImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyRevenueImplFromJson(json);

  @override
  final String month;
  // Format: YYYY-MM (e.g., "2025-01")
  @override
  final double revenue;
  @override
  final int bookingCount;

  @override
  String toString() {
    return 'MonthlyRevenue(month: $month, revenue: $revenue, bookingCount: $bookingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyRevenueImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.bookingCount, bookingCount) ||
                other.bookingCount == bookingCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, revenue, bookingCount);

  /// Create a copy of MonthlyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyRevenueImplCopyWith<_$MonthlyRevenueImpl> get copyWith =>
      __$$MonthlyRevenueImplCopyWithImpl<_$MonthlyRevenueImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyRevenueImplToJson(this);
  }
}

abstract class _MonthlyRevenue implements MonthlyRevenue {
  const factory _MonthlyRevenue({
    required final String month,
    required final double revenue,
    required final int bookingCount,
  }) = _$MonthlyRevenueImpl;

  factory _MonthlyRevenue.fromJson(Map<String, dynamic> json) =
      _$MonthlyRevenueImpl.fromJson;

  @override
  String get month; // Format: YYYY-MM (e.g., "2025-01")
  @override
  double get revenue;
  @override
  int get bookingCount;

  /// Create a copy of MonthlyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyRevenueImplCopyWith<_$MonthlyRevenueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
