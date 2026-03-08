import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/widgets/app_shell.dart';
import 'package:app_prenotazioni/core/theme/app_theme.dart';
import 'package:app_prenotazioni/core/providers/theme_provider.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_initializer.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';
import 'package:app_prenotazioni/features/reservations/presentation/pages/edit_reservation_page.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global navigation key for notification tap navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for web support
  SharedPreferences prefs;
  if (PlatformService.isWeb) {
    // Web requires SharedPreferencesAsync to be registered
    SharedPreferences.setPrefix('app_prenotazioni_');
    prefs = await SharedPreferences.getInstance();
  } else {
    prefs = await SharedPreferences.getInstance();
  }

  // Initialize locale data for Italian
  await initializeDateFormatting('it_IT');

  // Initialize notifications (only on Android)
  if (!PlatformService.isWeb) {
    final notificationService = createNotificationService();
    final databaseHelper = DatabaseHelper();
    final notificationDatasource = NotificationDatasource(databaseHelper);
    final notificationRepository = NotificationRepositoryImpl(notificationDatasource);

    await initializeNotifications(notificationService, notificationRepository);

    // Store the initialized service globally for use in providers/pages
    setNotificationServiceInstance(notificationService);

    // Set up notification navigation handler
    _setupNotificationNavigation();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

/// Set up navigation handler for notification taps
void _setupNotificationNavigation() {
  setNotificationNavigationHandler((reservationId) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('No navigation context available for notification tap');
      return;
    }

    try {
      // We need to get the repository from a provider, but we're not in a widget context yet
      // So we'll navigate to a page that will load the reservation
      if (navigatorKey.currentState != null) {
        await navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => _ReservationLoaderPage(reservationId: reservationId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la navigazione: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  });
}

/// Page that loads a reservation and navigates to edit page
class _ReservationLoaderPage extends ConsumerStatefulWidget {
  final String reservationId;

  const _ReservationLoaderPage({required this.reservationId});

  @override
  ConsumerState<_ReservationLoaderPage> createState() => _ReservationLoaderPageState();
}

class _ReservationLoaderPageState extends ConsumerState<_ReservationLoaderPage> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    try {
      final repository = ref.read(reservationRepositoryProvider);
      final reservation = await repository.getReservationById(widget.reservationId);

      if (mounted && reservation != null) {
        // Replace this loader page with the edit page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditReservationPage(reservation: reservation),
          ),
        );
      } else if (mounted) {
        // Reservation not found, show error and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prenotazione non trovata'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MyApp extends ConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'App Prenotazioni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      home: const AppShell(),
    );
  }
}
