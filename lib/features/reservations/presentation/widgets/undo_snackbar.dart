import 'package:flutter/material.dart';

/// Shows a snackbar with an undo action.
void showUndoSnackbar({
  required BuildContext context,
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: SnackBarAction(
        label: 'Annulla',
        onPressed: onUndo,
      ),
    ),
  );
}

/// Manages a pending deletion with undo capability.
class PendingDeletionManager<T> {
  T? _pendingItem;
  VoidCallback? _executeDeletion;
  bool _isPending = false;

  bool get isPending => _isPending;
  T? get pendingItem => _pendingItem;

  void scheduleDeletion({
    required T item,
    required VoidCallback executeDeletion,
  }) {
    _pendingItem = item;
    _executeDeletion = executeDeletion;
    _isPending = true;
  }

  void undo() {
    _pendingItem = null;
    _executeDeletion = null;
    _isPending = false;
  }

  void confirm() {
    if (_isPending && _executeDeletion != null) {
      _executeDeletion!();
    }
    _pendingItem = null;
    _executeDeletion = null;
    _isPending = false;
  }
}
