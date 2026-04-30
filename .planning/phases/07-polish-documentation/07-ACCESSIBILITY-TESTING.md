# Accessibility Testing Checklist

**Phase:** 07 - Polish & Documentation
**Wave:** 4 - Accessibility Enhancements
**Date:** 2026-03-07

## Overview

This checklist guides manual accessibility testing to ensure the app is usable by people with disabilities.

## Pre-Testing Setup

- [ ] Install Android Accessibility Scanner from Play Store
- [ ] Enable TalkBack on Android device (Settings > Accessibility > TalkBack)
- [ ] Enable VoiceOver on iOS device (Settings > Accessibility > VoiceOver)
- [ ] Prepare test device with various accessibility settings enabled

## Keyboard Navigation Tests (Web)

### Basic Navigation
- [ ] Tab key moves focus to next element in logical order
- [ ] Shift+Tab moves focus to previous element
- [ ] Enter activates buttons and submits forms
- [ ] Escape closes modals/dialogs
- [ ] Arrow keys navigate within lists and grids

### Shortcut Tests
- [ ] Ctrl+N opens new reservation form
- [ ] Ctrl+F focuses search field
- [ ] Tab order follows visual layout (top to bottom, left to right)

### Focus Indicators
- [ ] All interactive elements show visible focus indicator
- [ ] Focus indicator has high contrast (3:1 ratio)
- [ ] Focus moves smoothly between elements
- [ ] Focus is trapped in modals (can't tab out)

## Screen Reader Tests (TalkBack/VoiceOver)

### Navigation
- [ ] Can navigate to all tabs via bottom nav
- [ ] Can navigate into settings page
- [ ] Can navigate back from all pages
- [ ] Screen reader announces page titles when navigating

### Form Accessibility
- [ ] All form fields have descriptive labels
- [ ] Required fields are announced
- [ ] Invalid fields have error messages announced
- [ ] Can fill out entire form using only screen reader
- [ ] Field hints describe expected format

### List Accessibility
- [ ] List items announce key information (guest name, dates, room)
- [ ] Swipe actions are announced (edit, delete)
- [ ] Empty lists have appropriate message
- [ ] Loading states are announced

### Calendar Accessibility
- [ ] Calendar navigation buttons are announced
- [ ] Days with reservations announce guest information
- [ ] Multiple reservations per day are announced
- [ ] Current day is marked
- [ ] Month/year is announced when changing

### Dashboard Accessibility
- [ ] Room cards announce occupancy status
- [ ] Statistics are announced clearly
- [ ] Cards are identified as non-interactive (or interactive if clickable)

## Touch Target Tests

### Minimum Size
- [ ] All buttons are at least 48x48dp
- [ ] All icons are at least 48x48dp
- [ ] All list items are at least 48dp tall
- [ ] Touch targets don't overlap

### Spacing
- [ ] Adequate spacing between interactive elements
- [ ] No accidental taps due to crowded layout

## Color Contrast Tests

### Text Contrast
- [ ] Body text on background: ratio ≥ 4.5:1
- [ ] Large text on background: ratio ≥ 3:1
- [ ] UI elements on background: ratio ≥ 3:1

### Dark Mode
- [ ] All text remains readable in dark mode
- [ ] All UI elements remain visible in dark mode
- [ ] Platform colors remain distinguishable in dark mode

## Font Scaling Tests

### Large Fonts (200%)
- [ ] UI doesn't overflow or truncate text
- [ ] Forms remain usable
- [ ] Lists remain scrollable
- [ ] All information is still visible

### Extra Large Fonts (300%)
- [ ] Critical functionality still accessible
- [ ] Can still complete main user flows
- [ ] Text wraps instead of truncating where appropriate

## Reduce Motion Tests

### System Setting
- [ ] Enable "Reduce Motion" in system accessibility settings
- [ ] App respects the setting

### Behavior Verification
- [ ] Page transitions are instant (no animation)
- [ ] Lists appear immediately (no stagger)
- [ ] Loading indicators still show (essential animations)
- [ ] Micro-interactions are disabled
- [ ] App still functions normally

## High Contrast Mode Tests

### System Setting
- [ ] Enable "High Contrast Text" in system accessibility settings
- [ ] App respects the setting

### Verification
- [ ] All text remains readable
- [ ] Colors are adjusted appropriately
- [ ] Borders and UI elements are visible
- [ ] No information is lost

## Integration Tests

### Complete User Flows with Screen Reader
- [ ] Create new reservation with TalkBack
- [ ] Edit existing reservation with TalkBack
- [ ] Delete reservation with TalkBack
- [ ] Navigate calendar with TalkBack
- [ ] View dashboard statistics with TalkBack
- [ ] Search for reservation with TalkBack

### Complete User Flows with Keyboard (Web)
- [ ] Create new reservation with keyboard only
- [ ] Edit existing reservation with keyboard only
- [ ] Delete reservation with keyboard only
- [ ] Navigate between tabs with keyboard only
- [ ] Use search with keyboard only

## Platform-Specific Tests

### Android (TalkBack)
- [ ] TalkBack gestures work (explore by touch, linear navigation)
- [ ] Local context menu accessible
- [ ] Global context menu accessible
- [ ] Notifications are announced

### iOS (VoiceOver)
- [ ] VoiceOver gestures work (explore by touch, rotor navigation)
- [ ] Rotor navigation works for lists
- [ ] VoiceOver announcements are clear

## Automated Scanner Tests

### Android Accessibility Scanner
- [ ] Run scanner on dashboard page - no critical issues
- [ ] Run scanner on calendar page - no critical issues
- [ ] Run scanner on reservations list - no critical issues
- [ ] Run scanner on form - no critical issues
- [ ] Run scanner on platforms page - no critical issues

### iOS Accessibility Inspector (Xcode)
- [ ] Run audit on all major screens
- [ ] Check for missing accessibility labels
- [ ] Verify proper trait configurations

## Regression Testing

### After Enabling Accessibility
- [ ] App still functions normally with accessibility off
- [ ] No performance degradation with accessibility features
- [ ] App works correctly on different devices
- [ ] All features remain accessible

## Known Issues and Exceptions

Document any accessibility issues that cannot be fixed or are deferred:

### Issue Template
- **Issue**: [Description of accessibility limitation]
- **Impact**: [Who is affected and how]
- **Mitigation**: [Workaround or alternative approach]
- **Status**: [Deferred to future version / Cannot fix / Needs investigation]

## Test Results

| Test Category | Status | Notes |
|--------------|-------|-------|
| Keyboard Navigation | ⬜ Pass / ❌ Fail | |
| Screen Reader (TalkBack) | ⬜ Pass / ❌ Fail | |
| Touch Targets | ⬜ Pass / ❌ Fail | |
| Color Contrast | ⬜ Pass / ❌ Fail | |
| Font Scaling | ⬜ Pass / ❌ Fail | |
| Reduce Motion | ⬜ Pass / ❌ Fail | |
| High Contrast | ⬜ Pass / ❌ Fail | |

**Tester:** _______________
**Date:** _______________
**Device:** _______________
**Screen Reader:** _______________
