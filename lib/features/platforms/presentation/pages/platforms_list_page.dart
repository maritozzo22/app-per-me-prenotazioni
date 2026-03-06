import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/platforms/presentation/widgets/platform_list_tile.dart';
import 'package:app_prenotazioni/features/platforms/presentation/pages/platform_form_page.dart';
import 'package:app_prenotazioni/features/platforms/presentation/providers/platform_provider.dart';
import 'package:app_prenotazioni/core/presentation/widgets/error_display_widget.dart';
import 'package:app_prenotazioni/core/presentation/widgets/empty_state_widget.dart';
import 'package:app_prenotazioni/core/presentation/error/error_snackbar.dart';
import 'package:app_prenotazioni/core/widgets/animations.dart';

/// Page for managing platforms
class PlatformsListPage extends ConsumerStatefulWidget {
  const PlatformsListPage({super.key});

  @override
  ConsumerState<PlatformsListPage> createState() => _PlatformsListPageState();
}

class _PlatformsListPageState extends ConsumerState<PlatformsListPage> {
  @override
  Widget build(BuildContext context) {
    final platformState = ref.watch(platformProvider);
    final platforms = platformState.platforms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Piattaforme'),
      ),
      body: platformState.isLoading && platforms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : platformState.error != null && platforms.isEmpty
              ? ErrorDisplayWidget(
                  error: platformState.error!,
                  onRetry: () => ref.read(platformProvider.notifier).loadPlatforms(),
                )
              : platforms.isEmpty
                  ? EmptyStates.noPlatforms(
                      onAction: () => _navigateToForm(context, null),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(platformProvider.notifier).loadPlatforms();
                      },
                      child: ListView.builder(
                        itemCount: platforms.length,
                        itemBuilder: (context, index) {
                          final platform = platforms[index];
                          return FadeIn(
                            slide: SlideDirection.left,
                            delay: Duration(milliseconds: 50 * index),
                            child: PlatformListTile(
                              platform: platform,
                              onTap: () {
                                _showPlatformDetails(context, platform);
                              },
                              onEdit: () {
                                _navigateToForm(context, platform);
                              },
                              onDelete: platform.isSystem
                                  ? null
                                  : () {
                                      _confirmDelete(context, platform);
                                    },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToForm(context, null);
        },
        label: const Text('Nuova Piattaforma'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showPlatformDetails(BuildContext context, BookingPlatform platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(platform.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (platform.isSystem)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Chip(
                  label: Text('System'),
                  avatar: Icon(Icons.star, size: 16),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Colore: '),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: platform.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getColorName(platform.color),
                  style: TextStyle(
                    color: platform.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToForm(context, platform);
            },
            child: const Text('Modifica'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, BookingPlatform? platform) async {
    final result = await Navigator.push<BookingPlatform>(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformFormPage(platform: platform),
      ),
    );

    if (result != null && mounted) {
      // Integrate with PlatformProvider to save/update
      if (platform == null) {
        // Adding new platform
        await ref.read(platformProvider.notifier).addPlatform(result);
        if (mounted) {
          ErrorSnackbar.showSuccess(
            context,
            'Piattaforma "${result.name}" creata con successo',
          );
        }
      } else {
        // Updating existing platform
        await ref.read(platformProvider.notifier).updatePlatform(result);
        if (mounted) {
          ErrorSnackbar.showSuccess(
            context,
            'Piattaforma "${result.name}" aggiornata con successo',
          );
        }
      }
    }
  }

  void _confirmDelete(BuildContext context, BookingPlatform platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare la piattaforma "${platform.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete the platform
              await ref.read(platformProvider.notifier).deletePlatform(platform.id);
              if (mounted) {
                ErrorSnackbar.showSuccess(
                  context,
                  'Piattaforma "${platform.name}" eliminata',
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    if (color.value == Color(0xFF2196F3).value) return 'Blu';
    if (color.value == Color(0xFFE91E63).value) return 'Rosa';
    if (color.value == Color(0xFF4CAF50).value) return 'Verde';
    if (color.value == Color(0xFF9C27B0).value) return 'Viola';
    if (color.value == Color(0xFF212121).value) return 'Nero';
    return 'Personalizzato';
  }
}
