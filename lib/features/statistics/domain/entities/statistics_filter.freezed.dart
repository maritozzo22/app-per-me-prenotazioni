// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StatisticsFilter _$StatisticsFilterFromJson(Map<String, dynamic> json) {
  return _StatisticsFilter.fromJson(json);
}

/// @nodoc
mixin _$StatisticsFilter {
  PeriodFilter get period => throw _privateConstructorUsedError;
  DateTime? get customStartDate => throw _privateConstructorUsedError;
  DateTime? get customEndDate => throw _privateConstructorUsedError;
  bool get includePending => throw _privateConstructorUsedError;

  /// Serializes this StatisticsFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatisticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatisticsFilterCopyWith<StatisticsFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatisticsFilterCopyWith<$Res> {
  factory $StatisticsFilterCopyWith(
    StatisticsFilter value,
    $Res Function(StatisticsFilter) then,
  ) = _$StatisticsFilterCopyWithImpl<$Res, StatisticsFilter>;
  @useResult
  $Res call({
    PeriodFilter period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool includePending,
  });
}

/// @nodoc
class _$StatisticsFilterCopyWithImpl<$Res, $Val extends StatisticsFilter>
    implements $StatisticsFilterCopyWith<$Res> {
  _$StatisticsFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatisticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? customStartDate = freezed,
    Object? customEndDate = freezed,
    Object? includePending = null,
  }) {
    return _then(
      _value.copyWith(
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as PeriodFilter,
            customStartDate: freezed == customStartDate
                ? _value.customStartDate
                : customStartDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            customEndDate: freezed == customEndDate
                ? _value.customEndDate
                : customEndDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            includePending: null == includePending
                ? _value.includePending
                : includePending // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatisticsFilterImplCopyWith<$Res>
    implements $StatisticsFilterCopyWith<$Res> {
  factory _$$StatisticsFilterImplCopyWith(
    _$StatisticsFilterImpl value,
    $Res Function(_$StatisticsFilterImpl) then,
  ) = __$$StatisticsFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PeriodFilter period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool includePending,
  });
}

/// @nodoc
class __$$StatisticsFilterImplCopyWithImpl<$Res>
    extends _$StatisticsFilterCopyWithImpl<$Res, _$StatisticsFilterImpl>
    implements _$$StatisticsFilterImplCopyWith<$Res> {
  __$$StatisticsFilterImplCopyWithImpl(
    _$StatisticsFilterImpl _value,
    $Res Function(_$StatisticsFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatisticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? customStartDate = freezed,
    Object? customEndDate = freezed,
    Object? includePending = null,
  }) {
    return _then(
      _$StatisticsFilterImpl(
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as PeriodFilter,
        customStartDate: freezed == customStartDate
            ? _value.customStartDate
            : customStartDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        customEndDate: freezed == customEndDate
            ? _value.customEndDate
            : customEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        includePending: null == includePending
            ? _value.includePending
            : includePending // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatisticsFilterImpl implements _StatisticsFilter {
  const _$StatisticsFilterImpl({
    this.period = PeriodFilter.month,
    this.customStartDate,
    this.customEndDate,
    this.includePending = true,
  });

  factory _$StatisticsFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatisticsFilterImplFromJson(json);

  @override
  @JsonKey()
  final PeriodFilter period;
  @override
  final DateTime? customStartDate;
  @override
  final DateTime? customEndDate;
  @override
  @JsonKey()
  final bool includePending;

  @override
  String toString() {
    return 'StatisticsFilter(period: $period, customStartDate: $customStartDate, customEndDate: $customEndDate, includePending: $includePending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatisticsFilterImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.customStartDate, customStartDate) ||
                other.customStartDate == customStartDate) &&
            (identical(other.customEndDate, customEndDate) ||
                other.customEndDate == customEndDate) &&
            (identical(other.includePending, includePending) ||
                other.includePending == includePending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    period,
    customStartDate,
    customEndDate,
    includePending,
  );

  /// Create a copy of StatisticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatisticsFilterImplCopyWith<_$StatisticsFilterImpl> get copyWith =>
      __$$StatisticsFilterImplCopyWithImpl<_$StatisticsFilterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StatisticsFilterImplToJson(this);
  }
}

abstract class _StatisticsFilter implements StatisticsFilter {
  const factory _StatisticsFilter({
    final PeriodFilter period,
    final DateTime? customStartDate,
    final DateTime? customEndDate,
    final bool includePending,
  }) = _$StatisticsFilterImpl;

  factory _StatisticsFilter.fromJson(Map<String, dynamic> json) =
      _$StatisticsFilterImpl.fromJson;

  @override
  PeriodFilter get period;
  @override
  DateTime? get customStartDate;
  @override
  DateTime? get customEndDate;
  @override
  bool get includePending;

  /// Create a copy of StatisticsFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatisticsFilterImplCopyWith<_$StatisticsFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
