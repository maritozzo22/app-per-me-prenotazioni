import 'package:flutter/material.dart';

/// Utility for making screen reader announcements.
///
/// Provides methods for announcing state changes, errors, and other
/// important information to screen reader users.
class AccessibilityAnnouncer {
  /// Announce a message to screen reader users.
  ///
  /// Uses SemanticsService.announce to make an announcement.
  /// This is useful for informing users about state changes that
  /// don't have a visible UI element to focus on.
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce a loading state change.
  static void announceLoading(BuildContext context, bool isLoading) {
    if (isLoading) {
      announce(context, 'Caricamento in corso');
    }
  }

  /// Announce a successful operation.
  static void announceSuccess(BuildContext context, String operation) {
    announce(context, '$operation completato con successo');
  }

  /// Announce an error.
  static void announceError(BuildContext context, String errorMessage) {
    announce(context, 'Errore: $errorMessage');
  }

  /// Announce that a list has been updated.
  static void announceListUpdate(BuildContext context, int count, String itemType) {
    announce(context, '$itemType aggiornati: $count elementi');
  }

  /// Announce page navigation.
  static void announcePageChange(BuildContext context, String pageName) {
    announce(context, 'Pagina $pageName');
  }

  /// Announce tab change.
  static void announceTabChange(BuildContext context, String tabName) {
    announce(context, 'Tab $tabName');
  }

  /// Announce form validation error.
  static void announceValidationError(BuildContext context, String fieldName) {
    announce(context, 'Errore di validazione nel campo $fieldName');
  }
}

/// Widget that announces state changes to screen readers.
///
/// Wrap widgets that have important state changes with this to
/// ensure screen readers are notified.
class LiveRegion extends StatefulWidget {
  final Widget child;
  final String message;
  final bool assertive;

  const LiveRegion({
    super.key,
    required this.child,
    required this.message,
    this.assertive = false,
  });

  @override
  State<LiveRegion> createState() => _LiveRegionState();
}

class _LiveRegionState extends State<LiveRegion> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: widget.message,
      child: widget.child,
    );
  }
}

/// Widget that shows a live region for loading states.
class LoadingAnnouncer extends StatelessWidget {
  final bool isLoading;
  final String loadingMessage;
  final Widget child;

  const LoadingAnnouncer({
    super.key,
    required this.isLoading,
    required this.loadingMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: isLoading ? loadingMessage : '',
      child: child,
    );
  }
}

/// Extension methods for accessibility
extension AccessibilityExtensions on BuildContext {
  /// Announce a message to screen readers.
  void announce(String message) {
    AccessibilityAnnouncer.announce(this, message);
  }

  /// Announce a success message.
  void announceSuccess(String operation) {
    AccessibilityAnnouncer.announceSuccess(this, operation);
  }

  /// Announce an error message.
  void announceError(String errorMessage) {
    AccessibilityAnnouncer.announceError(this, errorMessage);
  }
}
