// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aggregate_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AggregateStatistics _$AggregateStatisticsFromJson(Map<String, dynamic> json) {
  return _AggregateStatistics.fromJson(json);
}

/// @nodoc
mixin _$AggregateStatistics {
  double get totalRevenue => throw _privateConstructorUsedError;
  double get occupancyRate => throw _privateConstructorUsedError;
  double get averageStayDuration => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  int get totalGuests => throw _privateConstructorUsedError;
  List<PlatformRevenue> get platformBreakdown =>
      throw _privateConstructorUsedError;
  List<MonthlyRevenue> get monthlyTrend => throw _privateConstructorUsedError;
  YearOverYearComparison? get yearOverYear =>
      throw _privateConstructorUsedError;

  /// Serializes this AggregateStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AggregateStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AggregateStatisticsCopyWith<AggregateStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AggregateStatisticsCopyWith<$Res> {
  factory $AggregateStatisticsCopyWith(
    AggregateStatistics value,
    $Res Function(AggregateStatistics) then,
  ) = _$AggregateStatisticsCopyWithImpl<$Res, AggregateStatistics>;
  @useResult
  $Res call({
    double totalRevenue,
    double occupancyRate,
    double averageStayDuration,
    int totalBookings,
    int totalGuests,
    List<PlatformRevenue> platformBreakdown,
    List<MonthlyRevenue> monthlyTrend,
    YearOverYearComparison? yearOverYear,
  });

  $YearOverYearComparisonCopyWith<$Res>? get yearOverYear;
}

/// @nodoc
class _$AggregateStatisticsCopyWithImpl<$Res, $Val extends AggregateStatistics>
    implements $AggregateStatisticsCopyWith<$Res> {
  _$AggregateStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AggregateStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? occupancyRate = null,
    Object? averageStayDuration = null,
    Object? totalBookings = null,
    Object? totalGuests = null,
    Object? platformBreakdown = null,
    Object? monthlyTrend = null,
    Object? yearOverYear = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            occupancyRate: null == occupancyRate
                ? _value.occupancyRate
                : occupancyRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageStayDuration: null == averageStayDuration
                ? _value.averageStayDuration
                : averageStayDuration // ignore: cast_nullable_to_non_nullable
                      as double,
            totalBookings: null == totalBookings
                ? _value.totalBookings
                : totalBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            totalGuests: null == totalGuests
                ? _value.totalGuests
                : totalGuests // ignore: cast_nullable_to_non_nullable
                      as int,
            platformBreakdown: null == platformBreakdown
                ? _value.platformBreakdown
                : platformBreakdown // ignore: cast_nullable_to_non_nullable
                      as List<PlatformRevenue>,
            monthlyTrend: null == monthlyTrend
                ? _value.monthlyTrend
                : monthlyTrend // ignore: cast_nullable_to_non_nullable
                      as List<MonthlyRevenue>,
            yearOverYear: freezed == yearOverYear
                ? _value.yearOverYear
                : yearOverYear // ignore: cast_nullable_to_non_nullable
                      as YearOverYearComparison?,
          )
          as $Val,
    );
  }

  /// Create a copy of AggregateStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $YearOverYearComparisonCopyWith<$Res>? get yearOverYear {
    if (_value.yearOverYear == null) {
      return null;
    }

    return $YearOverYearComparisonCopyWith<$Res>(_value.yearOverYear!, (value) {
      return _then(_value.copyWith(yearOverYear: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AggregateStatisticsImplCopyWith<$Res>
    implements $AggregateStatisticsCopyWith<$Res> {
  factory _$$AggregateStatisticsImplCopyWith(
    _$AggregateStatisticsImpl value,
    $Res Function(_$AggregateStatisticsImpl) then,
  ) = __$$AggregateStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double totalRevenue,
    double occupancyRate,
    double averageStayDuration,
    int totalBookings,
    int totalGuests,
    List<PlatformRevenue> platformBreakdown,
    List<MonthlyRevenue> monthlyTrend,
    YearOverYearComparison? yearOverYear,
  });

  @override
  $YearOverYearComparisonCopyWith<$Res>? get yearOverYear;
}

/// @nodoc
class __$$AggregateStatisticsImplCopyWithImpl<$Res>
    extends _$AggregateStatisticsCopyWithImpl<$Res, _$AggregateStatisticsImpl>
    implements _$$AggregateStatisticsImplCopyWith<$Res> {
  __$$AggregateStatisticsImplCopyWithImpl(
    _$AggregateStatisticsImpl _value,
    $Res Function(_$AggregateStatisticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AggregateStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? occupancyRate = null,
    Object? averageStayDuration = null,
    Object? totalBookings = null,
    Object? totalGuests = null,
    Object? platformBreakdown = null,
    Object? monthlyTrend = null,
    Object? yearOverYear = freezed,
  }) {
    return _then(
      _$AggregateStatisticsImpl(
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        occupancyRate: null == occupancyRate
            ? _value.occupancyRate
            : occupancyRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageStayDuration: null == averageStayDuration
            ? _value.averageStayDuration
            : averageStayDuration // ignore: cast_nullable_to_non_nullable
                  as double,
        totalBookings: null == totalBookings
            ? _value.totalBookings
            : totalBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        totalGuests: null == totalGuests
            ? _value.totalGuests
            : totalGuests // ignore: cast_nullable_to_non_nullable
                  as int,
        platformBreakdown: null == platformBreakdown
            ? _value._platformBreakdown
            : platformBreakdown // ignore: cast_nullable_to_non_nullable
                  as List<PlatformRevenue>,
        monthlyTrend: null == monthlyTrend
            ? _value._monthlyTrend
            : monthlyTrend // ignore: cast_nullable_to_non_nullable
                  as List<MonthlyRevenue>,
        yearOverYear: freezed == yearOverYear
            ? _value.yearOverYear
            : yearOverYear // ignore: cast_nullable_to_non_nullable
                  as YearOverYearComparison?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AggregateStatisticsImpl implements _AggregateStatistics {
  const _$AggregateStatisticsImpl({
    required this.totalRevenue,
    required this.occupancyRate,
    required this.averageStayDuration,
    required this.totalBookings,
    required this.totalGuests,
    required final List<PlatformRevenue> platformBreakdown,
    required final List<MonthlyRevenue> monthlyTrend,
    required this.yearOverYear,
  }) : _platformBreakdown = platformBreakdown,
       _monthlyTrend = monthlyTrend;

  factory _$AggregateStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AggregateStatisticsImplFromJson(json);

  @override
  final double totalRevenue;
  @override
  final double occupancyRate;
  @override
  final double averageStayDuration;
  @override
  final int totalBookings;
  @override
  final int totalGuests;
  final List<PlatformRevenue> _platformBreakdown;
  @override
  List<PlatformRevenue> get platformBreakdown {
    if (_platformBreakdown is EqualUnmodifiableListView)
      return _platformBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_platformBreakdown);
  }

  final List<MonthlyRevenue> _monthlyTrend;
  @override
  List<MonthlyRevenue> get monthlyTrend {
    if (_monthlyTrend is EqualUnmodifiableListView) return _monthlyTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyTrend);
  }

  @override
  final YearOverYearComparison? yearOverYear;

  @override
  String toString() {
    return 'AggregateStatistics(totalRevenue: $totalRevenue, occupancyRate: $occupancyRate, averageStayDuration: $averageStayDuration, totalBookings: $totalBookings, totalGuests: $totalGuests, platformBreakdown: $platformBreakdown, monthlyTrend: $monthlyTrend, yearOverYear: $yearOverYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AggregateStatisticsImpl &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.occupancyRate, occupancyRate) ||
                other.occupancyRate == occupancyRate) &&
            (identical(other.averageStayDuration, averageStayDuration) ||
                other.averageStayDuration == averageStayDuration) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.totalGuests, totalGuests) ||
                other.totalGuests == totalGuests) &&
            const DeepCollectionEquality().equals(
              other._platformBreakdown,
              _platformBreakdown,
            ) &&
            const DeepCollectionEquality().equals(
              other._monthlyTrend,
              _monthlyTrend,
            ) &&
            (identical(other.yearOverYear, yearOverYear) ||
                other.yearOverYear == yearOverYear));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalRevenue,
    occupancyRate,
    averageStayDuration,
    totalBookings,
    totalGuests,
    const DeepCollectionEquality().hash(_platformBreakdown),
    const DeepCollectionEquality().hash(_monthlyTrend),
    yearOverYear,
  );

  /// Create a copy of AggregateStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AggregateStatisticsImplCopyWith<_$AggregateStatisticsImpl> get copyWith =>
      __$$AggregateStatisticsImplCopyWithImpl<_$AggregateStatisticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AggregateStatisticsImplToJson(this);
  }
}

abstract class _AggregateStatistics implements AggregateStatistics {
  const factory _AggregateStatistics({
    required final double totalRevenue,
    required final double occupancyRate,
    required final double averageStayDuration,
    required final int totalBookings,
    required final int totalGuests,
    required final List<PlatformRevenue> platformBreakdown,
    required final List<MonthlyRevenue> monthlyTrend,
    required final YearOverYearComparison? yearOverYear,
  }) = _$AggregateStatisticsImpl;

  factory _AggregateStatistics.fromJson(Map<String, dynamic> json) =
      _$AggregateStatisticsImpl.fromJson;

  @override
  double get totalRevenue;
  @override
  double get occupancyRate;
  @override
  double get averageStayDuration;
  @override
  int get totalBookings;
  @override
  int get totalGuests;
  @override
  List<PlatformRevenue> get platformBreakdown;
  @override
  List<MonthlyRevenue> get monthlyTrend;
  @override
  YearOverYearComparison? get yearOverYear;

  /// Create a copy of AggregateStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AggregateStatisticsImplCopyWith<_$AggregateStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
