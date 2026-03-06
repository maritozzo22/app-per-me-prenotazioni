import 'package:flutter/material.dart';

/// Centralized test keys for integration testing.
/// These keys are used to find widgets during integration tests.
class TestKeys {
  // Calendar
  static const Key calendarView = Key('calendar_view');
  static const Key calendarFab = Key('calendar_fab');
  static const Key monthNext = Key('month_next');
  static const Key monthPrev = Key('month_prev');
  static const Key calendarTitle = Key('calendar_title');

  // Dashboard
  static const Key dashboardView = Key('dashboard_view');
  static const Key occupancyGrid = Key('occupancy_grid');
  static const Key incomeCard = Key('income_card');
  static const Key checkInsCard = Key('check_ins_card');
  static const Key checkOutsCard = Key('check_outs_card');
  static const Key calendarAccessCard = Key('calendar_access_card');

  // Form
  static const Key guestNameField = Key('guest_name_field');
  static const Key phoneField = Key('phone_field');
  static const Key checkInField = Key('check_in_field');
  static const Key checkOutField = Key('check_out_field');
  static const Key platformField = Key('platform_field');
  static const Key roomField = Key('room_field');
  static const Key paymentStatusField = Key('payment_status_field');
  static const Key priceField = Key('price_field');
  static const Key notesField = Key('notes_field');
  static const Key saveButton = Key('save_button');
  static const Key cancelButton = Key('cancel_button');
  static const Key reservationForm = Key('reservation_form');

  // List
  static const Key reservationsList = Key('reservations_list');
  static const Key searchButton = Key('search_button');
  static const Key searchField = Key('search_field');
  static const Key reservationListTile = Key('reservation_list_tile');

  // Navigation
  static const Key bottomNav = Key('bottom_nav');
  static const Key dashboardTab = Key('dashboard_tab');
  static const Key calendarTab = Key('calendar_tab');
  static const Key reservationsTab = Key('reservations_tab');
  static const Key platformsTab = Key('platforms_tab');

  // Platforms
  static const Key platformsList = Key('platforms_list');
  static const Key platformFab = Key('platform_fab');

  // Settings (if exists)
  static const Key settingsView = Key('settings_view');
  static const Key themeToggle = Key('theme_toggle');

  // Empty states
  static const Key emptyState = Key('empty_state');
  static const Key emptyStateAction = Key('empty_state_action');

  // Error states
  static const Key errorState = Key('error_state');
  static const Key retryButton = Key('retry_button');

  // Loading states
  static const Key loadingIndicator = Key('loading_indicator');
}
