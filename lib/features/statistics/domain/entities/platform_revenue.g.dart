// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_revenue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlatformRevenueImpl _$$PlatformRevenueImplFromJson(
  Map<String, dynamic> json,
) => _$PlatformRevenueImpl(
  platformId: json['platformId'] as String,
  platformName: json['platformName'] as String,
  color: (json['color'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  bookingCount: (json['bookingCount'] as num).toInt(),
  percentage: (json['percentage'] as num).toDouble(),
);

Map<String, dynamic> _$$PlatformRevenueImplToJson(
  _$PlatformRevenueImpl instance,
) => <String, dynamic>{
  'platformId': instance.platformId,
  'platformName': instance.platformName,
  'color': instance.color,
  'totalRevenue': instance.totalRevenue,
  'bookingCount': instance.bookingCount,
  'percentage': instance.percentage,
};
