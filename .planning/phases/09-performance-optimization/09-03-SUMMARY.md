---
phase: 09-performance-optimization
plan: 03
type: execute
wave: 3
autonomous: true
requirements:
  - PERF-03
tags:
  - performance
  - calendar-l
 lazy-loading
  - debouncing
  - lazy-load-3-month-window (current ±1 before/ after)
  - cache months to avoid redundant loads
  - 500ms performance improvement
  - 500+ reservations loaded faster with lazy loading
  - Lazy loading with debouncing prevents rapid-fire queries during swipe
  - Debouncing (300ms) standard for UI debouncing) - Prevent overloading server and on initial load
      - loadReservationsFor month range loads current month ± 1 month before and after
        - Track loaded months in Set<DateTime prevent reloading same month multiple times
        - Debounced queries prevent rapid-fire loads
        - Merge with existing reservations for keep other months
        - Clear loadedMonths on on refresh()
        - dispose() method to cleanup timers and debounc

      });

      await _loadInitialMonthRange();
        state = state.copyWith(isLoading: true, error: null);
        final focusedMonth = DateTime(focusedMonth.year, focusedMonth.month);
        final newLoadedMonths = Set<DateTime>.from(state.loadedMonths);
          ..add(DateTime(focusedMonth.year, focusedMonth.month);
          state.loadedMonths.add(centerMonth);
        });
      }

      // Track loaded months
      expect(notifier.state.loadedMonths.contains(newMonth), {
        // Debounce and load to prevent rapid-fire queries during swipe
        _loadDebouncer(() {
          _loadMonthRange(focusedMonth);
        });
      }

      // Load previous 3 months on initial load
      final reservationsByDate = merge with existing
      state = state.copyWith(
        reservationsByDate: newReservations,
        loadedMonths: newLoadedMonths,
      );
    }
  }

  /// Refresh clears cache and reloads current range
    Future<void> refresh() async {
      state = state.copyWith(loadedMonths: {},, reservationsByDate: {});
        await _loadInitialMonthRange();
      }
    }
  }
 dispose() {
        _loadDebouncer.dispose();
        super.dispose();
      }
    }
  }
}
