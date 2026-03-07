// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aggregate_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AggregateStatisticsImpl _$$AggregateStatisticsImplFromJson(
  Map<String, dynamic> json,
) => _$AggregateStatisticsImpl(
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  occupancyRate: (json['occupancyRate'] as num).toDouble(),
  averageStayDuration: (json['averageStayDuration'] as num).toDouble(),
  totalBookings: (json['totalBookings'] as num).toInt(),
  totalGuests: (json['totalGuests'] as num).toInt(),
  platformBreakdown: (json['platformBreakdown'] as List<dynamic>)
      .map((e) => PlatformRevenue.fromJson(e as Map<String, dynamic>))
      .toList(),
  monthlyTrend: (json['monthlyTrend'] as List<dynamic>)
      .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
      .toList(),
  yearOverYear: json['yearOverYear'] == null
      ? null
      : YearOverYearComparison.fromJson(
          json['yearOverYear'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$AggregateStatisticsImplToJson(
  _$AggregateStatisticsImpl instance,
) => <String, dynamic>{
  'totalRevenue': instance.totalRevenue,
  'occupancyRate': instance.occupancyRate,
  'averageStayDuration': instance.averageStayDuration,
  'totalBookings': instance.totalBookings,
  'totalGuests': instance.totalGuests,
  'platformBreakdown': instance.platformBreakdown,
  'monthlyTrend': instance.monthlyTrend,
  'yearOverYear': instance.yearOverYear,
};
