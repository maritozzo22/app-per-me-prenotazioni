// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatisticsFilterImpl _$$StatisticsFilterImplFromJson(
  Map<String, dynamic> json,
) => _$StatisticsFilterImpl(
  period:
      $enumDecodeNullable(_$PeriodFilterEnumMap, json['period']) ??
      PeriodFilter.month,
  customStartDate: json['customStartDate'] == null
      ? null
      : DateTime.parse(json['customStartDate'] as String),
  customEndDate: json['customEndDate'] == null
      ? null
      : DateTime.parse(json['customEndDate'] as String),
  includePending: json['includePending'] as bool? ?? true,
);

Map<String, dynamic> _$$StatisticsFilterImplToJson(
  _$StatisticsFilterImpl instance,
) => <String, dynamic>{
  'period': _$PeriodFilterEnumMap[instance.period]!,
  'customStartDate': instance.customStartDate?.toIso8601String(),
  'customEndDate': instance.customEndDate?.toIso8601String(),
  'includePending': instance.includePending,
};

const _$PeriodFilterEnumMap = {
  PeriodFilter.month: 'month',
  PeriodFilter.quarter: 'quarter',
  PeriodFilter.year: 'year',
  PeriodFilter.custom: 'custom',
};
