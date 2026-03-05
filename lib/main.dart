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
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for Italian
  await initializeDateFormatting('it_IT');

  // Initialize notifications (only on Android)
  if (!PlatformService.isWeb) {
    final notificationService = createNotificationService();
    final databaseHelper = DatabaseHelper();
    final notificationDatasource = NotificationDatasource(databaseHelper);
    final notificationRepository = NotificationRepositoryImpl(notificationDatasource);

    await initializeNotifications(notificationService, notificationRepository);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'App Prenotazioni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeMode,
      home: const AppShell(),
    );
  }
}
