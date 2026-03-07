// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_revenue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyRevenueImpl _$$MonthlyRevenueImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyRevenueImpl(
      month: json['month'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      bookingCount: (json['bookingCount'] as num).toInt(),
    );

Map<String, dynamic> _$$MonthlyRevenueImplToJson(
  _$MonthlyRevenueImpl instance,
) => <String, dynamic>{
  'month': instance.month,
  'revenue': instance.revenue,
  'bookingCount': instance.bookingCount,
};
