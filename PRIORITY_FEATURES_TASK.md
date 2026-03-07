# 🚀 Piano Sviluppo Feature Prioritarie
# App per Me Prenotazioni - Ottimizzazione e Espansione

> **Data creazione:** 7 Marzo 2026
> **Stato:** Planning - In attesa di approvazione
> **Approccio:** Sviluppo incrementale con commit atomici e test

---

## 📋 INDICE

1. [Fase 1: Ottimizzazioni Performance (CRITICO)](#fase-1-ottimizzazioni-performance-critico)
2. [Fase 2: Restructuring UI/UX](#fase-2-restructuring-uiux)
3. [Fase 3: Nuova Tab Statistiche](#fase-3-nuova-tab-statistiche)
4. [Fase 4: Miglioramenti Calendario](#fase-4-miglioramenti-calendario)
5. [Fase 5: Sistema Notifiche 2.0](#fase-5-sistema-notifiche-20)
6. [Fase 6: Esportazione Dati](#fase-6-esportazione-dati)

---

## 🔴 FASE 1: Ottimizzazioni Performance (CRITICO)

> **Priorità:** MASSIMA
> **Motivazione:** Con poche prenotazioni l'app è veloce, ma crescendo diventerà lenta. Prevenire prima di scalare.

### 1.1 Lazy Loading Lista Prenotazioni
**PROBLEMA:** Attualmente tutte le prenotazioni vengono caricate in memoria, incluse quelle storiche.

**SOLUZIONE:**
- Implementare **paginazione** o **scroll infinito**
- Caricare inizialmente solo **prime 20 prenotazioni**
- Caricare altre quando l'utente scrolla (trigger a 80% scroll)
- Query ottimizzate con `LIMIT` e `OFFSET`

**FILE DA MODIFICARE:**
```
lib/features/reservations/data/datasources/reservation_datasource.dart
lib/features/reservations/data/repositories/reservation_repository_impl.dart
lib/features/reservations/presentation/providers/reservation_provider.dart
```

**QUERY SQL DA OTTIMIZZARE:**
```sql
-- PRIMA (potenzialmente migliaia di row)
SELECT * FROM reservations ORDER BY created_at DESC;

-- DOPO (pagination)
SELECT * FROM reservations ORDER BY created_at DESC LIMIT 20 OFFSET 0;
```

**TASK:**
- [ ] Creare metodo `getReservationsPaginated(int limit, int offset)` nel repository
- [ ] Implementare `ScrollController` nella lista che triggera il caricamento
- [ ] Aggiungere indicatore "Carica altre..." o loading spinner
- [ ] Test con 100+ prenotazioni verificare fluidità

---

### 1.2 Filtri Intelligente per Periodo
**PROBLEMA:** Utente vuole vedere solo future o periodi specifici senza caricare tutto.

**SOLUZIONE:**
- Implementare filtri **SQL-based** (non caricare tutto e filtrare in memoria)
- Filtri predefiniti con checkbox/toggle
- Query con clausole `WHERE` ottimizzate

**FILTRI DA IMPLEMENTARE:**
```
☑️ Solo Future (check-in >= oggi)
☑️ Ultime 30 giorni
☑️ Ultimi 3 mesi
☑️ Ultimi 6 mesi
☑️ Tutto il 2025
☑️ Tutto il 2024
☑️ Range date personalizzato (Da - A)
```

**FILTRI AGGIUNTIVI:**
```
☑️ Stato Pagamento: Pagato / Pending
☑️ Piattaforma: Airbnb / Booking / WhatsApp / Sito Web / TikTok
☑️ Camera: Stanza 1 / Stanza 2 / Stanza 3 / Appartamento
```

**IMPLEMENTAZIONE:**
- Widget `FilterChip` o ChoiceChip per filtri rapidi
- `showDatePicker()` per range personalizzato
- Combinazione di filtri con `AND`/`OR` logici

**QUERY ESEMPIO:**
```sql
SELECT * FROM reservations
WHERE check_in >= '2025-03-07'
  AND payment_status = 'received'
  AND platform_id = 'airbnb'
ORDER BY check_in ASC
LIMIT 50;
```

**FILE DA MODIFICARE:**
```
lib/features/reservations/presentation/pages/reservations_list_page.dart
lib/features/reservations/presentation/widgets/reservation_filter_sheet.dart (NUOVO)
lib/features/reservations/domain/repositories/reservation_repository.dart
```

**TASK:**
- [ ] Creare widget `ReservationFilterSheet` con tutti i filtri
- [ ] Aggiungere FAB o icona filtro nella lista prenotazioni
- [ ] Implementare metodo `getReservationsWithFilters(FilterParams params)`
- [ ] Salvare preferenze filtri in SharedPreferences (ricorda ultimo filtro usato)
- [ ] Mostrare contatore risultati applicati (es. "Mostrando 15 di 48 prenotazioni")
- [ ] Test query con diverse combinazioni di filtri

---

### 1.3 Ottimizzazione Calendario
**PROBLEMA:** Il calendario carica TUTTE le prenotazioni per mostrare i marker, anche quelle storiche.

**SOLUZIONE:**
- Caricare **solo prenotazioni del mese visibile + mese precedente e successivo**
- Ricaricare quando utente cambia mese
- Non caricare prenotazioni degli anni passati

**QUERY OTTIMIZZATA:**
```sql
-- Carica solo range necessario
SELECT * FROM reservations
WHERE check_out >= '2025-02-01' AND check_in <= '2025-04-30'
ORDER BY check_in;
```

**FILE DA MODIFICARE:**
```
lib/features/calendar/presentation/pages/calendar_page.dart
lib/features/calendar/providers/calendar_provider.dart
```

**TASK:**
- [ ] Modificare `CalendarProvider` per caricare solo range date del mese + adiacenti
- [ ] Aggiungere listener `onCalendarPageChanged` del `TableCalendar`
- [ ] Implementare debounce per non fare query a ogni swipe
- [ ] Test con molti mesi di dati storici

---

### 1.4 Ottimizzazione Query Database
**VERIFICA INDICI:**
- Controllare che gli indici esistenti siano ottimali
- Aggiungere indici mancanti se necessario

**INDICI ATTUALI (da verificare):**
```sql
CREATE INDEX idx_reservations_check_in ON reservations(check_in);
CREATE INDEX idx_reservations_check_out ON reservations(check_out);
CREATE INDEX idx_reservations_created_at ON reservations(created_at);
```

**INDICI DA AGGIUNGERE (se mancanti):**
```sql
-- Per filtri piattaforma
CREATE INDEX idx_reservations_platform_id ON reservations(platform_id);

-- Per filtri stato pagamento
CREATE INDEX idx_reservations_payment_status ON reservations(payment_status);

-- Per query combinata (check-in + platform)
CREATE INDEX idx_reservations_check_in_platform ON reservations(check_in, platform_id);

-- Per query combinata (check-in + room)
CREATE INDEX idx_reservations_check_in_room ON reservations(check_in, room_id);
```

**TASK:**
- [ ] Verificare indici attuali in `database_helper.dart`
- [ ] Aggiungere indici mancanti in migration
- [ ] Test performance con EXPLAIN QUERY PLAN
- [ ] Documentare tempi query prima/dopo

---

### 1.5 Cache Statistiche (24h)
**PROBLEMA:** Calcolare statistiche ogni volta che apro l'app è lento.

**SOLUZIONE:**
- Calcolare statistiche **una volta al giorno** o **quando aggiungo prenotazione**
- Salvare risultato cache in SharedPreferences o SQLite
- Mostrare data ultimo aggiornamento ("Aggiornato: 7 Mar 2025, 10:30")

**STRATEGIA:**
1. All'apertura dell'app, controllo se cache è valida (< 24h)
2. Se valida: uso cache
3. Se scaduta: ricalcolo e aggiorno cache
4. Quando aggiungo/modifico/elimino prenotazione: invalida cache

**IMPLEMENTAZIONE:**
```dart
class StatisticsCacheService {
  static const Duration cacheValidity = Duration(hours: 24);

  Future<DashboardStatistics?> getCachedStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('stats_last_update');

    if (lastUpdate != null) {
      final lastUpdateDate = DateTime.parse(lastUpdate);
      if (DateTime.now().difference(lastUpdateDate) < cacheValidity) {
        return DashboardStatistics.fromJson(
          prefs.getString('stats_data')!
        );
      }
    }

    return null;
  }

  Future<void> updateCache(DashboardStatistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stats_last_update', DateTime.now().toIso8601String());
    await prefs.setString('stats_data', stats.toJson());
  }

  Future<void> invalidateCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stats_last_update');
    await prefs.remove('stats_data');
  }
}
```

**FILE DA MODIFICARE:**
```
lib/core/services/statistics_cache_service.dart (NUOVO)
lib/features/dashboard/providers/dashboard_provider.dart
lib/features/reservations/presentation/providers/reservation_provider.dart
```

**TASK:**
- [ ] Creare `StatisticsCacheService`
- [ ] Integrare nel `DashboardProvider`
- [ ] Invalidare cache quando aggiungo/modifico prenotazione
- [ ] Mostrare data ultimo aggiornamento nella dashboard
- [ ] Aggiungere tasto "Aggiorna ora" per forzare refresh
- [ ] Test con 100+ prenotazioni

---

## 🔵 FASE 2: Restructuring UI/UX

> **Priorità:** ALTA
> **Motivazione:** Migliorare usability e semplificare navigazione

### 2.1 Dashboard Semplificata
**PROBLEMA:** Dashboard attuale ha box "Vai al Calendario" che è ridondante (calendario è già una tab).

**SOLUZIONE:** Rimuovere il box superfluo e mantenere solo KPI essenziali.

**CONTENUTI RIMOSSI:**
- ❌ Box "Calendario" con link alla tab Calendario

**CONTENUTI MANTENUTI:**
- ✅ **Occupazione Oggi:** Box "2/4 camere occupate" con percentuale
- ✅ **Incassi Mese Corrente:** "€2,500 / €500 pending"
- ✅ **Prossimi Arrivi/Partenze:** Lista prossimi 5 check-in e check-out
- ✅ **Countdown Prossimo Evento:** "Prossimo check-in: 2 giorni - Mario Rossi"

**FILE DA MODIFICARE:**
```
lib/features/dashboard/presentation/pages/dashboard_page.dart
lib/features/dashboard/presentation/widgets/ (alcuni widget rimossi)
```

**TASK:**
- [ ] Rimuovere widget `CalendarAccessCard`
- [ ] Mantenere `RoomOccupancyGrid`, `IncomeBreakdownCard`, `UpcomingReservationsCard`
- [ ] Aggiungere `NextEventCountdownCard` (NUOVO)
- [ ] Test layout su schermi diversi (mobile, tablet)

---

### 2.2 Nuova Tab "Statistiche"
**PROBLEMA:** Non c'è una sezione dedicata alle statistiche approfondite.

**SOLUZIONE:** Creare nuova tab "Statistiche" al posto di "Piattaforme".

**POSIZIONAMENTO NELLE TAB:**
```
PRIMA:
1. Dashboard
2. Calendario
3. Prenotazioni
4. Piattaforme  ← RIMOSSA
5. Impostazioni

DOPO:
1. Dashboard
2. Calendario
3. Prenotazioni
4. Statistiche  ← NUOVA
5. Impostazioni
```

**CONTENUTI TAB STATISTICHE:**
1. **Filtri Temporali** (in alto)
   - Mese corrente
   - Mese precedente
   - Trimestre corrente
   - Anno corrente
   - Anno precedente
   - Range personalizzato (Da - A)

2. **KPI Numerici** (card in alto)
   - Revenue Totale
   - Tasso Occupazione %
   - Durata Media Soggiorno
   - Numero Prenotazioni
   - Numero Ospiti Totali

3. **Grafico 1: Comparazione Anno su Anno**
   - Barre affiancate: 2024 vs 2025
   - Comparazione incassi mese per mese
   - Oppure comparazione stesso mese (es. Mar 2024 vs Mar 2025)

4. **Grafico 2: Revenue per Piattaforma**
   - Grafico a torta (Pie Chart)
   - Mostra % e importo per ogni piattaforma
   - Colori coerenti con piattaforme

5. **Grafico 3: Trend Mensile**
   - Line chart con incassi mensili (gen-dic)
   - Mostra trend e picchi stagionali
   - Possibilità di vedere trend anno precedente in sovraimpressione

6. **Grafico 4: Numero Prenotazioni per Piattaforma**
   - Grafico a barre
   - Confronto quantitativo tra piattaforme

**FILE DA CREARE/MODIFICARE:**
```
lib/features/statistics/ (NUOVA feature completa)
  ├── domain/
  │   ├── entities/statistics.dart
  │   └── repositories/statistics_repository.dart
  ├── data/
  │   ├── repositories/statistics_repository_impl.dart
  │   └── datasources/statistics_datasource.dart
  ├── presentation/
  │   ├── pages/statistics_page.dart
  │   ├── providers/statistics_provider.dart
  │   └── widgets/
  │       ├── kpi_cards.dart
  │       ├── year_over_year_chart.dart
  │       ├── platform_revenue_chart.dart
  │       ├── monthly_trend_chart.dart
  │       └── platform_bookings_chart.dart
```

**TASK:**
- [ ] Creare struttura feature `statistics`
- [ ] Implementare `StatisticsRepository` con query per calcolare metriche
- [ ] Integrazione FL Chart per grafici
- [ ] Implementare filtri temporali
- [ ] Creare widget card KPI
- [ ] Creare 4 grafici con FL Chart
- [ ] Implementare cache 24h per statistiche
- [ ] Responsive layout per mobile/tablet

---

### 2.3 Spostare "Piattaforme" in "Impostazioni"
**PROBLEMA:** La tab "Piattaforme" è usata raramente e occupa spazio prezioso.

**SOLUZIONE:** Spostare la gestione piattaforme nella tab "Impostazioni".

**POSIZIONE NELLE IMPOSTAZIONI:**
```
Impostazioni
├─ Gestione Camere (esistente?)
├─ Gestione Piattaforme  ← SPOSTATO QUI
├─ Backup e Ripristino
├─ Notifiche
└─ Info App
```

**FILE DA MODIFICARE:**
```
lib/features/platforms/presentation/pages/platforms_page.dart (spostato)
lib/features/settings/presentation/pages/settings_page.dart (aggiungere link)
lib/core/widgets/app_shell.dart (rimuovere tab piattaforme)
```

**TASK:**
- [ ] Rimuovere tab "Piattaforme" dal `AppShell`
- [ ] Aggiungere "Gestione Piattaforme" in `SettingsPage`
- [ ] Creare tile navigazione piattaforme in impostazioni
- [ ] Verificare che deeplinks a piattaforme funzionino ancora

---

### 2.4 Ridefinizione Tab Iniziale
**PROBLEMA:** L'utente deve poter scegliere quale tab vedere all'avvio.

**SOLUZIONE:** Per ora manteniamo Dashboard, ma in futuro potremmo aggiungere impostazione.

**DECISIONE CORRENTE:**
- ✅ Dashboard rimane tab iniziale
- 📝 FUTURE: Aggiungere preferenza in Impostazioni

---

## 🟢 FASE 3: Nuova Tab Statistiche

> **Priorità:** ALTA
> **Motivazione:** Feature principale richiesta dall'utente

### 3.1 Implementazione Dominio Statistiche
**ENTITÀ DA CREARE:**

```dart
// lib/features/statistics/domain/entities/statistics.dart

@freezed
class DashboardStatistics with _$DashboardStatistics {
  const factory DashboardStatistics({
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalRevenue,
    required double occupancyRate,
    required double averageStayDuration,
    required int totalBookings,
    required int totalGuests,
    required List<PlatformRevenue> platformRevenues,
    required List<MonthlyRevenue> monthlyRevenues,
    required List<YearOverYearComparison> yearOverYearData,
  }) = _DashboardStatistics;
}

@freezed
class PlatformRevenue with _$PlatformRevenue {
  const factory PlatformRevenue({
    required String platformId,
    required String platformName,
    required Color color,
    required double amount,
    required int bookingCount,
  }) = _PlatformRevenue;
}

@freezed
class MonthlyRevenue with _$MonthlyRevenue {
  const factory MonthlyRevenue({
    required int year,
    required int month,
    required double amount,
    required int bookingCount,
  }) = _MonthlyRevenue;
}

@freezed
class YearOverYearComparison with _$YearOverYearComparison {
  const factory YearOverYearComparison({
    required int month, // 1-12
    required double currentYearAmount,
    required double previousYearAmount,
    required double percentageChange,
  }) = _YearOverYearComparison;
}
```

**FILE DA CREARE:**
```
lib/features/statistics/domain/entities/statistics.dart
lib/features/statistics/domain/repositories/statistics_repository.dart
```

**TASK:**
- [ ] Definire entità del dominio statistiche
- [ ] Creare interface `StatisticsRepository`
- [ ] Aggiungere dipendenze FL Chart e freezed

---

### 3.2 Implementazione Data Layer Statistiche
**REPOSITORY IMPLEMENTATION:**

```dart
// lib/features/statistics/data/repositories/statistics_repository_impl.dart

class StatisticsRepositoryImpl implements StatisticsRepository {
  final ReservationDataSource _dataSource;

  @override
  Future<DashboardStatistics> getStatistics({
    required DateTime start,
    required DateTime end,
    String? compareWithPreviousYear,
  }) async {
    // 1. Fetch prenotazioni nel periodo
    final reservations = await _dataSource.getReservationsInPeriod(start, end);

    // 2. Calcolare metriche base
    final totalRevenue = reservations
        .where((r) => r.amount != null)
        .fold<double>(0, (sum, r) => sum + r.amount!);

    // 3. Calcolare occupancy rate
    final occupiedDays = _calculateOccupiedDays(reservations);
    final totalDays = end.difference(start).inDays + 1;
    final occupancyRate = occupiedDays / (totalDays * 4); // 4 camere

    // 4. Calcolare durata media
    final totalStayDuration = reservations.fold<int>(
      0, (sum, r) => sum + r.checkOut.difference(r.checkIn).inDays
    );
    final avgStayDuration = totalStayDuration / reservations.length;

    // 5. Revenue per piattaforma
    final platformRevenues = _calculatePlatformRevenue(reservations);

    // 6. Revenue mensile
    final monthlyRevenues = _calculateMonthlyRevenue(reservations);

    // 7. Comparazione anno su anno
    final yearOverYear = compareWithPreviousYear != null
      ? await _calculateYearOverYear(start, end, compareWithPreviousYear)
      : [];

    return DashboardStatistics(
      periodStart: start,
      periodEnd: end,
      totalRevenue: totalRevenue,
      occupancyRate: occupancyRate,
      averageStayDuration: avgStayDuration,
      totalBookings: reservations.length,
      totalGuests: reservations.length, // Assumiamo 1 ospite per prenotazione
      platformRevenues: platformRevenues,
      monthlyRevenues: monthlyRevenues,
      yearOverYearData: yearOverYear,
    );
  }

  // ... metodi helper privati per calcoli
}
```

**QUERY SQL:**

```sql
-- Revenue per piattaforma
SELECT
  p.name as platform_name,
  p.color,
  SUM(r.amount) as total_amount,
  COUNT(*) as booking_count
FROM reservations r
JOIN platforms p ON r.platform_id = p.id
WHERE r.check_in >= ? AND r.check_out <= ?
  AND r.amount IS NOT NULL
GROUP BY r.platform_id
ORDER BY total_amount DESC;

-- Revenue mensile
SELECT
  strftime('%Y', check_in) as year,
  strftime('%m', check_in) as month,
  SUM(amount) as total_amount,
  COUNT(*) as booking_count
FROM reservations
WHERE check_in >= ? AND check_out <= ?
  AND amount IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

-- Comparazione anno su anno (stesso mese, anni diversi)
SELECT
  strftime('%m', check_in) as month,
  SUM(amount) as amount
FROM reservations
WHERE check_in >= ? AND check_out <= ?
GROUP BY month;
```

**FILE DA CREARE:**
```
lib/features/statistics/data/datasources/statistics_datasource.dart
lib/features/statistics/data/repositories/statistics_repository_impl.dart
```

**TASK:**
- [ ] Implementare `StatisticsDataSource` con query SQL
- [ ] Implementare `StatisticsRepositoryImpl` con logica calcolo statistiche
- [ ] Test query SQL con dati reali
- [ ] Verificare correttezza calcoli (occupancy rate, durata media, etc.)

---

### 3.3 Implementazione Presentation Layer Statistiche
**PROVIDER:**

```dart
// lib/features/statistics/presentation/providers/statistics_provider.dart

@riverpod
class Statistics extends _$Statistics {
  @override
  Future<DashboardStatistics> build() async {
    final start = DateTime.now().subtract(Duration(days: 30));
    final end = DateTime.now();

    final repo = ref.watch(statisticsRepositoryProvider);
    return await repo.getStatistics(start: start, end: end);
  }

  Future<void> filterByPeriod(DatePeriod period) async {
    state = const AsyncValue.loading();

    final repo = ref.watch(statisticsRepositoryProvider);
    state = await AsyncValue.guard(() async {
      return await repo.getStatistics(
        start: period.start,
        end: period.end,
        compareWithPreviousYear: period.compareWithYear,
      );
    });
  }
}
```

**PAGE:**

```dart
// lib/features/statistics/presentation/pages/statistics_page.dart

class StatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      body: Column(
        children: [
          // Filtri temporali
          PeriodFilterSelector(
            onPeriodSelected: (period) {
              ref.read(statisticsProvider.notifier).filterByPeriod(period);
            },
          ),

          // Contenuto statistiche
          Expanded(
            child: statistics.when(
              data: (stats) => StatisticsContent(statistics: stats),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Errore: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
```

**FILE DA CREARE:**
```
lib/features/statistics/presentation/pages/statistics_page.dart
lib/features/statistics/presentation/providers/statistics_provider.dart
lib/features/statistics/presentation/widgets/
  ├── kpi_cards.dart
  ├── year_over_year_chart.dart
  ├── platform_revenue_pie_chart.dart
  ├── monthly_trend_line_chart.dart
  ├── platform_bookings_bar_chart.dart
  └── period_filter_selector.dart
```

**TASK:**
- [ ] Creare `StatisticsProvider` con Riverpod
- [ ] Implementare `StatisticsPage` con layout responsive
- [ ] Creare `PeriodFilterSelector` per filtri temporali
- [ ] Creare widget card KPI numerici
- [ ] Implementare grafico comparazione anno su anno (bar chart)
- [ ] Implementare grafico revenue piattaforma (pie chart)
- [ ] Implementare grafico trend mensile (line chart)
- [ ] Implementare grafico prenotazioni piattaforma (bar chart)
- [ ] Integrare cache 24h
- [ ] Test responsive layout

---

### 3.4 Integrazione FL Chart
**DIPENDENZE:**

```yaml
# pubspec.yaml
dependencies:
  fl_chart: ^0.66.0
  flutter_riverpod: ^2.4.9
```

**ESEMPIO IMPLEMENTAZIONE PIE CHART:**

```dart
// lib/features/statistics/presentation/widgets/platform_revenue_pie_chart.dart

class PlatformRevenuePieChart extends StatelessWidget {
  final List<PlatformRevenue> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue per Piattaforma', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.map((revenue) {
                    final percentage = (revenue.amount / data.fold<double>(
                      0, (sum, r) => sum + r.amount
                    )) * 100;

                    return PieChartSectionData(
                      color: revenue.color,
                      value: revenue.amount,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Legenda
            ...data.map((revenue) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 12, height: 12, color: revenue.color),
                  SizedBox(width: 8),
                  Text(revenue.platformName),
                  Spacer(),
                  Text('€${revenue.amount.toStringAsFixed(2)}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
```

**TASK:**
- [ ] Aggiungere dipendenza `fl_chart`
- [ ] Implementare Pie Chart per revenue piattaforma
- [ ] Implementare Bar Chart per comparazione anno su anno
- [ ] Implementare Line Chart per trend mensile
- [ ] Implementare Bar Chart per prenotazioni piattaforma
- [ ] Personalizzare colori e stile
- [ ] Test rendering grafici su diversi device

---

## 🟡 FASE 4: Miglioramenti Calendario

> **Priorità:** MEDIA
> **Motivazione:** Migliorare UX e completezza funzionale

### 4.1 Tocco Prenotazione nel Bottom Sheet
**PROBLEMA:** Quando premo su una data con prenotazioni, vedo la lista nel bottom sheet ma non posso cliccareci sopra per modificarle.

**SOLUZIONE:** Rendere gli elementi della lista tappabili e navigare alla pagina dettagli.

**IMPLEMENTAZIONE:**

```dart
// lib/features/calendar/widgets/day_reservations_bottom_sheet.dart

Widget _buildReservationItem(Reservation reservation) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: reservation.platform.color,
      child: Icon(Icons.bed, color: Colors.white),
    ),
    title: Text(reservation.guest.name),
    subtitle: Text('${reservation.room.name} • ${reservation.platform.name}'),
    trailing: Text('€${reservation.amount ?? 0}'),
    onTap: () {
      // Chiudi bottom sheet
      Navigator.of(context).pop();

      // Naviga a pagina dettagli/modifica
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReservationFormPage(reservation: reservation),
        ),
      );
    },
  );
}
```

**FILE DA MODIFICARE:**
```
lib/features/calendar/presentation/widgets/day_reservations_bottom_sheet.dart
```

**TASK:**
- [ ] Aggiungere `onTap` ai `ListTile` delle prenotazioni
- [ ] Chiudi bottom sheet prima di navigare
- [ ] Passare reservation alla `ReservationFormPage`
- [ ] Test navigazione e ritorno al calendario

---

### 4.2 Indicatore Prenotazioni Multiple
**PROBLEMA:** Quando ci sono più prenotazioni nello stesso giorno, non è chiaro quante sono.

**SOLUZIONE:** Mostrare un contatore o indicatori visivi multipli.

**IMPLEMENTAZIONE:**

```dart
// lib/features/calendar/presentation/widgets/calendar_builder.dart

Widget _buildDayCell(DateTime day, List<Reservation> reservations) {
  return Container(
    margin: EdgeInsets.all(4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Stack(
      children: [
        Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        // Indicatori prenotazioni
        if (reservations.isNotEmpty)
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              children: reservations.take(4).map((r) =>
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: r.platform.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ).toList(),
            ),
          ),
        // Contatore se più di 4
        if (reservations.length > 4)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${reservations.length - 4}',
                style: TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
      ],
    ),
  );
}
```

**TASK:**
- [ ] Modificare `calendar_builder.dart` per mostrare indicatori multipli
- [ ] Mostrare pallini colorati fino a 4
- [ ] Mostrare contatore "+X" se più di 4
- [ ] Test con giorni che hanno molte prenotazioni

---

### 4.3 Swipe Gesture per Cambiare Mese
**PROBLEMA:** Per cambiare mese devo usare le frecce, vorrei poter swipare.

**SOLUZIONE:** Abilitare swipe gestures su TableCalendar (già supportato nativamente).

**IMPLEMENTAZIONE:**

```dart
// lib/features/calendar/presentation/pages/calendar_page.dart

TableCalendar(
  calendarFormat: CalendarFormat.month,
  availableGestures: AvailableGestures.all, // ABILITA SWIPE
  onCalendarCreated: (controller) => _pageController = controller,
  onDaySelected: (selectedDay, focusedDay) {
    // ...
  },
  // ... altri parametri
)
```

**TASK:**
- [ ] Impostare `availableGestures: AvailableGestures.all`
- [ ] Test swipe orizzontale per cambiare mese
- [ ] Verificare che non confligga con altri gesture

---

## 🟣 FASE 5: Sistema Notifiche 2.0

> **Priorità:** MEDIA
> **Motivazione:** Utente ha dubbi sul funzionamento, servono strumenti di verifica

### 5.1 Tasto "Test Notifica"
**PROBLEMA:** Non c'è modo verificare se le notifiche funzionano senza aspettare un check-in reale.

**SOLUZIONE:** Aggiungere tasto in Impostazioni per inviare notifica di prova immediata.

**IMPLEMENTAZIONE:**

```dart
// lib/features/settings/presentation/pages/settings_page.dart

class SettingsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ... altre impostazioni

        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notifiche'),
          subtitle: Text('Test notifiche e preferenze'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => NotificationsSettingsPage())
            );
          },
        ),
      ],
    );
  }
}

// lib/features/settings/presentation/pages/notifications_settings_page.dart

class NotificationsSettingsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Impostazioni Notifiche')),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.test),
              title: Text('Invia Notifica di Prova'),
              subtitle: Text('Verifica se le notifiche funzionano'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final service = ref.watch(notificationServiceProvider);
                  await service.showTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notifica inviata!'))
                  );
                },
                child: Text('INVIA'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**FILE DA CREARE:**
```
lib/core/services/notification_service.dart (aggiungere metodo test)
lib/features/settings/presentation/pages/notifications_settings_page.dart (NUOVO)
```

**TASK:**
- [ ] Creare `NotificationsSettingsPage`
- [ ] Aggiungere metodo `showTestNotification()` in `NotificationService`
- [ ] Collegare tasto "Invia Notifica di Prova"
- [ ] Test invio notifica su Android
- [ ] Gestire caso notifiche disabilitate (show dialog per abilitare)

---

### 5.2 Log Notifiche Inviato
**PROBLEMA:** Non c'è tracciabilità delle notifiche inviate.

**SOLUZIONE:** Salvare log delle notifiche in database e mostrare lista storico.

**SCHEMA DATABASE:**

```sql
CREATE TABLE notification_logs (
  id TEXT PRIMARY KEY,
  reservation_id TEXT,
  type TEXT, -- '5_days', '3_days', '2_days', '1_day', 'same_day', 'test'
  scheduled_date TEXT,
  sent_date TEXT,
  status TEXT, -- 'pending', 'sent', 'failed'
  error_message TEXT,
  created_at TEXT
);
```

**IMPLEMENTAZIONE:**

```dart
// lib/features/notifications/data/models/notification_log.dart

@freezed
class NotificationLog with _$NotificationLog {
  const factory NotificationLog({
    required String id,
    String? reservationId,
    required NotificationType type,
    required DateTime scheduledDate,
    DateTime? sentDate,
    required NotificationStatus status,
    String? errorMessage,
    required DateTime createdAt,
  }) = _NotificationLog;
}

enum NotificationType {
  fiveDays,
  threeDays,
  twoDays,
  oneDay,
  sameDay,
  test,
}

enum NotificationStatus {
  pending,
  sent,
  failed,
}
```

**UI LOG NOTIFICHE:**

```dart
// lib/features/notifications/presentation/pages/notification_logs_page.dart

class NotificationLogsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(notificationLogsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Log Notifiche')),
      body: logs.when(
        data: (logsList) => ListView.builder(
          itemCount: logsList.length,
          itemBuilder: (context, index) {
            final log = logsList[index];
            return ListTile(
              leading: Icon(
                log.status == NotificationStatus.sent
                  ? Icons.check_circle
                  : log.status == NotificationStatus.failed
                    ? Icons.error
                    : Icons.schedule,
                color: log.status == NotificationStatus.sent
                  ? Colors.green
                  : log.status == NotificationStatus.failed
                    ? Colors.red
                    : Colors.orange,
              ),
              title: Text(_getTypeLabel(log.type)),
              subtitle: Text(
                'Programmata: ${DateFormat('dd/MM/yyyy HH:mm').format(log.scheduledDate)}'
              ),
              trailing: log.sentDate != null
                ? Text(
                    'Inviata: ${DateFormat('dd/MM HH:mm').format(log.sentDate!)}',
                    style: TextStyle(fontSize: 12),
                  )
                : null,
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
      ),
    );
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.fiveDays: return '5 giorni prima';
      case NotificationType.threeDays: return '3 giorni prima';
      case NotificationType.twoDays: return '2 giorni prima';
      case NotificationType.oneDay: return '1 giorno prima';
      case NotificationType.sameDay: return 'Stesso giorno';
      case NotificationType.test: return 'Notifica di prova';
    }
  }
}
```

**FILE DA CREARE:**
```
lib/features/notifications/ (NUOVA feature)
  ├── domain/
  │   └── entities/notification_log.dart
  ├── data/
  │   ├── models/notification_log_model.dart
  │   └── datasources/notification_log_datasource.dart
  └── presentation/
      ├── pages/notification_logs_page.dart
      └── providers/notification_logs_provider.dart
```

**TASK:**
- [ ] Creare tabella `notification_logs` in migration
- [ ] Creare entità `NotificationLog`
- [ ] Implementare salvataggio log quando notifica inviata
- [ ] Creare `NotificationLogsPage` con lista storico
- [ ] Aggiungere link a log in `NotificationsSettingsPage`
- [ ] Test logging notifiche reali

---

### 5.3 Personalizzazione Giorni Prima
**PROBLEMA:** Utente vuole scegliere quando ricevere notifiche (non fisso a 5, 3, 2, 1 giorni).

**SOLUZIONE:** Creare pannello impostazioni per selezionare giorni.

**UI:**

```dart
// lib/features/settings/presentation/pages/notifications_settings_page.dart

Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giorni prima del check-in',
          style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        CheckboxListTile(
          title: Text('5 giorni prima'),
          value: _settings.notifyFiveDays,
          onChanged: (value) => _updateSetting('notifyFiveDays', value),
        ),
        CheckboxListTile(
          title: Text('3 giorni prima'),
          value: _settings.notifyThreeDays,
          onChanged: (value) => _updateSetting('notifyThreeDays', value),
        ),
        CheckboxListTile(
          title: Text('2 giorni prima'),
          value: _settings.notifyTwoDays,
          onChanged: (value) => _updateSetting('notifyTwoDays', value),
        ),
        CheckboxListTile(
          title: Text('1 giorno prima'),
          value: _settings.notifyOneDay,
          onChanged: (value) => _updateSetting('notifyOneDay', value),
        ),
        CheckboxListTile(
          title: Text('Stesso giorno (mattina)'),
          value: _settings.notifySameDay,
          onChanged: (value) => _updateSetting('notifySameDay', value),
        ),
      ],
    ),
  ),
)
```

**SALVATAGGIO IMPOSTAZIONI:**

```dart
// SharedPreferences
await prefs.setBool('notify_five_days', true);
await prefs.setBool('notify_three_days', true);
await prefs.setBool('notify_two_days', false);
await prefs.setBool('notify_one_day', true);
await prefs.setBool('notify_same_day', true);
```

**FILE DA MODIFICARE:**
```
lib/core/services/notification_scheduler.dart
lib/core/models/notification_settings.dart (NUOVO)
lib/features/settings/presentation/pages/notifications_settings_page.dart
```

**TASK:**
- [ ] Creare modello `NotificationSettings`
- [ ] Implementare salvataggio/lettura preferenze in SharedPreferences
- [ ] Modificare `NotificationScheduler` per leggere preferenze
- [ ] Creare UI con checkbox per ogni opzione
- [ ] Test notifiche con diverse combinazioni di preferenze

---

### 5.4 Personalizzazione Orario
**PROBLEMA:** Utente vuole scegliere orario notifica (range 9:00-10:00).

**SOLUZIONE:** Aggiungere time picker per scegliere orario.

**UI:**

```dart
// lib/features/settings/presentation/pages/notifications_settings_page.dart

Card(
  child: ListTile(
    leading: Icon(Icons.access_time),
    title: Text('Orario notifiche'),
    subtitle: Text('${_settings.notificationTime.format(context)}'),
    trailing: Icon(Icons.chevron_right),
    onTap: () async {
      final time = await showTimePicker(
        context: context,
        initialTime: _settings.notificationTime,
      );

      if (time != null) {
        await ref.read(notificationSettingsProvider.notifier)
          .updateNotificationTime(time);
      }
    },
  ),
),
```

**VALIDAZIONE ORARIO:**

```dart
TimeOfDay? _validateTimeRange(TimeOfDay time) {
  if (time.hour < 9 || (time.hour == 9 && time.minute < 0)) {
    return TimeOfDay(hour: 9, minute: 0); // Minimo 9:00
  }
  if (time.hour > 10 || (time.hour == 10 && time.minute > 0)) {
    return TimeOfDay(hour: 10, minute: 0); // Massimo 10:00
  }
  return time;
}
```

**TASK:**
- [ ] Aggiungere campo `notificationTime` in `NotificationSettings`
- [ ] Implementare Time Picker con validazione range 9:00-10:00
- [ ] Modificare `NotificationScheduler` per usare orario personalizzato
- [ ] Test notifiche con orari diversi

---

## 🔵 FASE 6: Esportazione Dati

> **Priorità:** BASSA
> **Motivazione:** Utente vuole export CSV per Excel

### 6.1 Export CSV Prenotazioni
**PROBLEMA:** Utente vuole esportare prenotazioni per analisi in Excel.

**SOLUZIONE:** Implementare esportazione CSV con tutte le prenotazioni filtrate.

**FORMATO CSV:**

```csv
ID,Ospite,Telefono,Camera,Piattaforma,Check-in,Check-out,Importo,Stato Pagamento,Note,Creato Il
550e8400-e29b-41d4-a716-446655440000,Mario Rossi,+39 123 4567890,Stanza 1,Airbnb,2025-03-10,2025-03-15,450.00,Ricevuto,,2025-03-07 10:30
...
```

**IMPLEMENTAZIONE:**

```dart
// lib/features/reservations/services/reservation_export_service.dart

class ReservationExportService {
  Future<String> exportToCSV(List<Reservation> reservations) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Ospite,Telefono,Camera,Piattaforma,Check-in,Check-out,Importo,Stato Pagamento,Note,Creato Il');

    // Rows
    for (final reservation in reservations) {
      buffer.writeln(
        '${reservation.id},'
        '${_escapeCSV(reservation.guest.name)},'
        '${_escapeCSV(reservation.guest.phone ?? '')},'
        '${_escapeCSV(reservation.room.name)},'
        '${_escapeCSV(reservation.platform.name)},'
        '${DateFormat('yyyy-MM-dd').format(reservation.checkIn)},'
        '${DateFormat('yyyy-MM-dd').format(reservation.checkOut)},'
        '${reservation.amount ?? 0.00},'
        '${_getPaymentStatusLabel(reservation.paymentStatus)},'
        '${_escapeCSV(reservation.notes ?? '')},'
        '${DateFormat('yyyy-MM-dd HH:mm').format(reservation.createdAt)}'
      );
    }

    return buffer.toString();
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> shareCSV(String csvContent) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/prenotazioni_export.csv');
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Prenotazioni Export',
    );
  }
}
```

**INTEGRAZIONE UI:**

```dart
// lib/features/reservations/presentation/pages/reservations_list_page.dart

AppBar(
  title: Text('Prenotazioni'),
  actions: [
    IconButton(
      icon: Icon(Icons.file_download),
      onPressed: () async {
        final reservations = ref.watch(filteredReservationsProvider);
        final exportService = ReservationExportService();

        final csv = await exportService.exportToCSV(reservations);
        await exportService.shareCSV(csv);
      },
      tooltip: 'Esporta CSV',
    ),
  ],
),
```

**FILE DA CREARE:**
```
lib/features/reservations/services/reservation_export_service.dart (NUOVO)
```

**TASK:**
- [ ] Creare `ReservationExportService`
- [ ] Implementare generazione CSV con escaping corretto
- [ ] Aggiungere icona export nella AppBar lista prenotazioni
- [ ] Implementare condivisione file con `share_plus`
- [ ] Test apertura CSV in Excel
- [ ] Localizzazione italiana CSV (punto decimale, formato date)

---

### 6.2 Export Statistiche CSV
**PROBLEMA:** Utente vuole esportare anche i dati statistici.

**SOLUZIONE:** Implementare export CSV per statistiche (opzionale).

**FORMATO CSV:**

```csv
Tipo Statistica,Valore
Revenue Totale,€5,250.00
Tasso Occupazione,75.5%
Durata Media Soggiorno,4.2 giorni
Numero Prenotazioni,25
Numero Ospiti,25

Piattaforma,Revenue,N. Prenotazioni
Airbnb,€3,200.00,15
Booking,€1,500.00,7
WhatsApp,€550.00,3

Mese,Revenue
Gennaio 2025,€1,200.00
Febbraio 2025,€1,800.00
Marzo 2025,€2,250.00
```

**TASK:**
- [ ] Valutare se implementare export statistiche CSV
- [ ] Creare `StatisticsExportService` se confermato

---

## 📊 RIASSUNTO IMPLEMENTAZIONE

### Priorità Sviluppo (Ordine Cronologico):

```
1. FASE 1: Ottimizzazioni Performance (CRITICO)
   ├─ 1.1 Lazy Loading (20+20)
   ├─ 1.2 Filtri Periodo
   ├─ 1.3 Ottimizzazione Calendario
   ├─ 1.4 Ottimizzazione Query
   └─ 1.5 Cache Statistiche

2. FASE 2: Restructuring UI
   ├─ 2.1 Dashboard Semplificata
   ├─ 2.2 Nuova Tab Statistiche (struttura vuota)
   └─ 2.3 Piattaforme → Impostazioni

3. FASE 3: Implementazione Statistiche
   ├─ 3.1 Dominio Statistiche
   ├─ 3.2 Data Layer (query)
   ├─ 3.3 Presentation Layer
   └─ 3.4 Integrazione FL Chart

4. FASE 4: Calendario Migliorato
   ├─ 4.1 Tocco Prenotazione
   ├─ 4.2 Indicatori Multipli
   └─ 4.3 Swipe Gestures

5. FASE 5: Notifiche 2.0
   ├─ 5.1 Tasto Test
   ├─ 5.2 Log Notifiche
   ├─ 5.3 Giorni Prima
   └─ 5.4 Orario Personalizzato

6. FASE 6: Esportazione CSV
   └─ 6.1 Export Prenotazioni
```

### Tempo Stimato:
- **Fase 1:** 3-4 giorni (ottimizzazioni critiche)
- **Fase 2:** 1-2 giorni (restructuring)
- **Fase 3:** 5-7 giorni (statistiche + grafici)
- **Fase 4:** 1 giorno (calendario)
- **Fase 5:** 2-3 giorni (notifiche)
- **Fase 6:** 1 giorno (export CSV)

**TOTALE:** 13-18 giorni di sviluppo

---

## ✅ CRITERI DI SUCCESSO

### Performance:
- [ ] App rimane fluida con 1000+ prenotazioni
- [ ] Lista carica < 500ms con filtri applicati
- [ ] Calendario cambia mese < 300ms
- [ ] Statistiche calcolate < 1s (cache 24h)

### UX:
- [ ] Filtri intuitivi e facili da usare
- [ ] Grafici leggibili e informativi
- [ ] Navigazione fluida tra sezioni
- [ ] Notifiche verificabili e testabili

### Funzionalità:
- [ ] Tutte le feature richieste implementate
- [ ] Test superati
- [ ] Zero crash noti
- [ ] Performance stabili

---

## 🎯 NEXT STEPS

1. **Approvazione Piano** ✅ (In attesa feedback utente)
2. **Setup Ambiente** (FL Chart, dipendenze)
3. **Sviluppo Fase 1** (Ottimizzazioni)
4. **Testing Performance** (1000+ prenotazioni di test)
5. **Sviluppo Fase 2-6** (Feature restanti)
6. **Testing Integrale** (UAT)
7. **Release** (Build APK con Android Studio)

---

**Vuoi che proceda con l'implementazione di questo piano?** 🚀

Oppure preferisci modificare/aggiungere/togliere qualcosa prima di iniziare?
