import 'package:flutter/material.dart';

/// Represents a booking platform with its associated color.
class BookingPlatform {
  final String id;
  final String name;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;

  const BookingPlatform({
    required this.id,
    required this.name,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  /// Default platforms with locked colors (PLAT-01 to PLAT-05).
  static final List<BookingPlatform> defaultPlatforms = [
    BookingPlatform(
      id: 'booking',
      name: 'Booking',
      color: Color(0xFF2196F3), // Blue (PLAT-01)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'airbnb',
      name: 'Airbnb',
      color: Color(0xFFE91E63), // Pink/Red (PLAT-02)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'whatsapp',
      name: 'WhatsApp',
      color: Color(0xFF4CAF50), // Green (PLAT-03)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'website',
      name: 'Sito Web',
      color: Color(0xFF9C27B0), // Purple (PLAT-04)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookingPlatform(
      id: 'tiktok',
      name: 'TikTok',
      color: Color(0xFF212121), // Black/Dark Gray (PLAT-05)
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
}
