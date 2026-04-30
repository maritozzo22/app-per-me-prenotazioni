import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/core/utils/debouncer.dart';
import 'dart:async';

void main() {
  group('Debouncer', () {
    test('should delay function execution by specified duration', () async {
      // Arrange
      final debouncer = Debouncer(delay: Duration(milliseconds: 100));
      bool executed = false;

      // Act
      debouncer(() {
        executed = true;
      });

      // Assert - should not execute immediately
      expect(executed, false);

      // Wait for delay
      await Future.delayed(Duration(milliseconds: 150));

      // Assert - should have executed after delay
      expect(executed, true);

      // Cleanup
      debouncer.dispose();
    });

    test('should cancel previous call if new call arrives within delay', () async {
      // Arrange
      final debouncer = Debouncer(delay: Duration(milliseconds: 100));
      int callCount = 0;
      String? lastValue;

      // Act - call 3 times rapidly
      debouncer(() {
        callCount++;
        lastValue = 'first';
      });

      await Future.delayed(Duration(milliseconds: 50));

      debouncer(() {
        callCount++;
        lastValue = 'second';
      });

      await Future.delayed(Duration(milliseconds: 50));

      debouncer(() {
        callCount++;
        lastValue = 'third';
      });

      // Wait for delay to complete
      await Future.delayed(Duration(milliseconds: 150));

      // Assert - only the last call should have executed
      expect(callCount, 1);
      expect(lastValue, 'third');

      // Cleanup
      debouncer.dispose();
    });

    test('should cancel timer on dispose', () async {
      // Arrange
      final debouncer = Debouncer(delay: Duration(milliseconds: 100));
      bool executed = false;

      // Act
      debouncer(() {
        executed = true;
      });

      // Dispose immediately
      debouncer.dispose();

      // Wait for delay
      await Future.delayed(Duration(milliseconds: 150));

      // Assert - should not have executed after dispose
      expect(executed, false);
    });
  });
}
