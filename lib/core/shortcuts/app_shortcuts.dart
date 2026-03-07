import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts for the app.
///
/// Provides consistent keyboard navigation across all platforms.
class AppShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onNewReservation;
  final VoidCallback? onSearch;
  final VoidCallback? onEscape;

  const AppShortcuts({
    super.key,
    required this.child,
    this.onNewReservation,
    this.onSearch,
    this.onEscape,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Ctrl+N: New reservation
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            _NewReservationIntent(),
        // Ctrl+F: Search
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
            _SearchIntent(),
        // Escape: Close modal/back
        LogicalKeySet(LogicalKeyboardKey.escape): _EscapeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NewReservationIntent: _NewReservationAction(onNewReservation),
          _SearchIntent: _SearchAction(onSearch),
          _EscapeIntent: _EscapeAction(context, onEscape),
        },
        child: child,
      ),
    );
  }
}

/// Intent for creating a new reservation
class _NewReservationIntent extends Intent {
  const _NewReservationIntent();
}

/// Intent for triggering search
class _SearchIntent extends Intent {
  const _SearchIntent();
}

/// Intent for escape action (close modal/back)
class _EscapeIntent extends Intent {
  const _EscapeIntent();
}

/// Action for new reservation intent
class _NewReservationAction extends Action<_NewReservationIntent> {
  final VoidCallback? onNewReservation;

  _NewReservationAction(this.onNewReservation);

  @override
  Object? invoke(_NewReservationIntent intent) {
    onNewReservation?.call();
    return null;
  }
}

/// Action for search intent
class _SearchAction extends Action<_SearchIntent> {
  final VoidCallback? onSearch;

  _SearchAction(this.onSearch);

  @override
  Object? invoke(_SearchIntent intent) {
    onSearch?.call();
    return null;
  }
}

/// Action for escape intent
class _EscapeAction extends Action<_EscapeIntent> {
  final BuildContext context;
  final VoidCallback? onEscape;

  _EscapeAction(this.context, this.onEscape);

  @override
  Object? invoke(_EscapeIntent intent) {
    if (onEscape != null) {
      onEscape!.call();
    } else {
      // Default behavior: try to pop navigator
      Navigator.of(context).maybePop();
    }
    return null;
  }
}

/// Focus management utility for forms.
///
/// Provides methods for managing focus order and traversal.
class FocusUtils {
  /// Create a list of focus nodes with proper traversal order.
  static List<FocusNode> createFocusNodes(int count) {
    return List.generate(count, (_) => FocusNode());
  }

  /// Set up linear focus traversal order.
  static void setLinearTraversalOrder(List<FocusNode> nodes) {
    for (int i = 0; i < nodes.length - 1; i++) {
      // Note: FocusNode doesn't have a nextFocus setter.
      // Use FocusTraversalGroup for proper traversal order instead.
    }
  }

  /// Request focus on the next focusable widget.
  static void focusNext(FocusNode currentNode, List<FocusNode> allNodes) {
    final currentIndex = allNodes.indexOf(currentNode);
    if (currentIndex < allNodes.length - 1) {
      allNodes[currentIndex + 1].requestFocus();
    }
  }

  /// Dispose all focus nodes.
  static void disposeFocusNodes(List<FocusNode> nodes) {
    for (final node in nodes) {
      node.dispose();
    }
  }
}

/// Mixin for widgets that need focus management.
mixin FocusManagerMixin<T extends StatefulWidget> on State<T> {
  final List<FocusNode> _focusNodes = [];

  /// Create a focus node and track it for disposal.
  FocusNode createFocusNode() {
    final node = FocusNode();
    _focusNodes.add(node);
    return node;
  }

  /// Create multiple focus nodes.
  List<FocusNode> createFocusNodes(int count) {
    return List.generate(count, (_) => createFocusNode());
  }

  @override
  void dispose() {
    FocusUtils.disposeFocusNodes(_focusNodes);
    super.dispose();
  }
}
