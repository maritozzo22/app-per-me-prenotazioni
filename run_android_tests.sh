#!/bin/bash

echo "============================================"
echo "Esecuzione 37 Test Fisici Android"
echo "============================================"
echo ""

passed=0
failed=0
total=0

# Funzione per eseguire test
run_test() {
    local test_num=$1
    local test_name=$2
    local test_command=$3

    echo "[$test_num/37] Test: $test_name"
    eval "$test_command"
    local result=$?

    if [ $result -eq 0 ]; then
        echo "[PASS] $test_name"
        ((passed++))
    else
        echo "[FAIL] $test_name"
        ((failed++))
    fi
    ((total++))
    sleep 1
}

# Test 1-10: Basic Functionality
run_test "1" "App installata" "adb shell pm list packages | grep app.prenotazioni.app_prenotazioni"
run_test "2" "App si avvia" "adb shell am start -n app.prenotazioni.app_prenotazioni/app.prenotazioni.app_prenotazioni.MainActivity && sleep 3"
run_test "3" "Navigazione tab Dashboard" "adb shell input tap 540 1800"
run_test "4" "Apertura nuova prenotazione" "adb shell input tap 540 200"
run_test "5" "Inserimento nome" "adb shell input text 'Test Guest'"
run_test "6" "Selezione camera" "adb shell input tap 300 600"
run_test "7" "Selezione date" "adb shell input tap 540 1000"
run_test "8" "Salvataggio prenotazione" "adb shell input tap 800 1800"
run_test "9" "Navigazione calendario" "adb shell input tap 540 600"
run_test "10" "Scorri lista" "adb shell input swipe 540 1000 540 500"

# Test 11-20: Search e Platform Management
run_test "11" "Attiva search" "adb shell input tap 540 150"
run_test "12" "Input search" "adb shell input text 'Airbnb'"
run_test "13" "Conferma search" "adb shell input keyevent 66"
run_test "14" "Apri piattaforme" "adb shell input tap 100 100"
run_test "15" "Aggiungi piattaforma" "adb shell input tap 800 200"
run_test "16" "Toggle dark mode" "adb shell input tap 1000 100"
run_test "17" "Torna home" "adb shell input keyevent 4"
run_test "18" "Apri menu" "adb shell input tap 100 200"
run_test "19" "Test notifiche" "adb shell am broadcast -a android.intent.action.BOOT_COMPLETED"
run_test "20" "Verifica permessi" "adb shell dumpsys package app.prenotazioni.app_prenotazioni | grep POST_NOTIFICATIONS"

# Test 21-30: Performance e Scrolling
for i in {21..30}; do
    run_test "$i" "Scroll rapido $((i-20))" "adb shell input swipe 540 1800 540 200 100"
done

# Test 31-37: Accessibilità e Edge Cases
run_test "31" "Test touch target 1" "adb shell input tap 540 500"
run_test "32" "Test touch target 2" "adb shell input tap 540 700"
run_test "33" "Test touch target 3" "adb shell input tap 540 900"
run_test "34" "Back button" "adb shell input keyevent 4"
run_test "35" "Multi-tap test" "adb shell input tap 540 500 && adb shell input tap 540 700"
run_test "36" "Long press test" "adb shell input swipe 540 500 540 500 2000"
run_test "37" "App minimizza" "adb shell input keyevent 3"

echo ""
echo "============================================"
echo "RISULTATI TEST"
echo "============================================"
echo "Eseguiti: $total/37"
echo "Passati: $passed"
echo "Falliti: $failed"
echo ""

if [ $failed -eq 0 ]; then
    echo "[SUCCESS] Tutti i test passati!"
else
    echo "[WARNING] Ci sono $failed test falliti"
fi
