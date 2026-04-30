import 'package:flutter/material.dart';

/// Reusable empty state widget with optional call-to-action
///
/// Use when lists, searches, or pages have no content to display.
/// Provides clear visual feedback and optional next steps.
///
/// Example:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inbox_outlined,
///   title: 'Nessuna prenotazione',
///   message: 'Le prenotazioni appariranno qui',
///   actionLabel: 'Crea prenotazione',
///   onAction: () => navigateToForm(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  /// Empty state for no reservations
  static Widget noReservations({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'Nessuna prenotazione',
      message: 'Le prenotazioni appariranno qui',
      actionLabel: 'Crea prenotazione',
      onAction: onAction,
    );
  }

  /// Empty state for no search results
  static Widget noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Nessuna prenotazione trovata',
      message: 'Prova con altri termini di ricerca',
    );
  }

  /// Empty state for no platforms
  static Widget noPlatforms({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.hotel_outlined,
      title: 'Nessuna piattaforma configurata',
      message: 'Aggiungi le piattaforme che utilizzi',
      actionLabel: 'Aggiungi piattaforma',
      onAction: onAction,
    );
  }

  /// Empty state for no upcoming check-ins
  static Widget noUpcomingCheckIns() {
    return const EmptyStateWidget(
      icon: Icons.event_available_outlined,
      title: 'Nessun arrivo previsto',
      message: 'Non hai prossimi check-in',
    );
  }

  /// Empty state for no upcoming check-outs
  static Widget noUpcomingCheckOuts() {
    return const EmptyStateWidget(
      icon: Icons.event_busy_outlined,
      title: 'Nessuna partenza prevista',
      message: 'Non hai prossimi check-out',
    );
  }

  /// Empty state for calendar
  static Widget noCalendarEvents() {
    return const EmptyStateWidget(
      icon: Icons.calendar_today_outlined,
      title: 'Nessun evento',
      message: 'Non ci sono prenotazioni in questo periodo',
    );
  }

  /// Empty state for notifications
  static Widget noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'Nessuna notifica',
      message: 'Non hai notifiche',
    );
  }

  /// Empty state for settings
  static Widget noSettings() {
    return const EmptyStateWidget(
      icon: Icons.settings_outlined,
      title: 'Nessuna impostazione',
      message: 'Non ci sono impostazioni disponibili',
    );
  }

  /// Empty state for network error
  static Widget networkError({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Errore di connessione',
      message: 'Impossibile connettersi al server',
      actionLabel: 'Riprova',
      onAction: onRetry,
    );
  }

  /// Empty state for generic error
  static Widget error({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Si è verificato un errore',
      message: message ?? 'Impossibile completare l\'operazione',
      actionLabel: 'Riprova',
      onAction: onRetry,
    );
  }
}
