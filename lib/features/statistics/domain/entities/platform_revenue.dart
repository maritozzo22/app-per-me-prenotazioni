import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_revenue.freezed.dart';
part 'platform_revenue.g.dart';

/// Revenue breakdown by booking platform.
@freezed
class PlatformRevenue with _$PlatformRevenue {
  const factory PlatformRevenue({
    required String platformId,
    required String platformName,
    required int color, // ARGB color value (from BookingPlatform.color)
    required double totalRevenue,
    required int bookingCount,
    required double percentage,
  }) = _PlatformRevenue;

  factory PlatformRevenue.fromJson(Map<String, dynamic> json) =>
      _$PlatformRevenueFromJson(json);
}
