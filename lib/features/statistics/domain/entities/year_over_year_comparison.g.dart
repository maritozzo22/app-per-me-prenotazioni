// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_over_year_comparison.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$YearOverYearComparisonImpl _$$YearOverYearComparisonImplFromJson(
  Map<String, dynamic> json,
) => _$YearOverYearComparisonImpl(
  year1: (json['year1'] as num).toInt(),
  year2: (json['year2'] as num).toInt(),
  year1Monthly: (json['year1Monthly'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  year2Monthly: (json['year2Monthly'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$$YearOverYearComparisonImplToJson(
  _$YearOverYearComparisonImpl instance,
) => <String, dynamic>{
  'year1': instance.year1,
  'year2': instance.year2,
  'year1Monthly': instance.year1Monthly,
  'year2Monthly': instance.year2Monthly,
};
