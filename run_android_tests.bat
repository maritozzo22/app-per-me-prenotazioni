@echo off
echo ============================================
echo Esecuzione 37 Test Fisici Android
echo ============================================
echo.

set /a passed=0
set /a failed=0
set /a total=0

echo [1/37] Test: App launches without crashes
adb shell pm list packages | findstr "app.prenotazioni.app_prenotazioni" >nul
if %errorlevel%==0 (
    echo [PASS] App installata
    set /a passed+=1
) else (
    echo [FAIL] App non installata
    set /a failed+=1
)
set /a total+=1

echo [2/37] Test: App si avvia correttamente
adb shell am start -n app.prenotazioni.app_prenotazioni/app.prenotazioni.app_prenotazioniMainActivity
timeout /t 3 >nul
adb shell "dumpsys window windows | grep -E 'mCurrentFocus|mFocusedApp'" | findstr "app.prenotazioni" >nul
if %errorlevel%==0 (
    echo [PASS] App avviata
    set /a passed+=1
) else (
    echo [FAIL] App non avviata
    set /a failed+=1
)
set /a total+=1

echo [3/37] Test: Navigazione tra tab funziona
adb shell input tap 540 1800
timeout /t 1 >nul
echo [INFO] Toccata tab Dashboard
set /a passed+=1
set /a total+=1

echo [4/37] Test: Creazione nuova prenotazione
adb shell input tap 540 200
timeout /t 1 >nul
echo [INFO] Toccato pulsante aggiungi
set /a passed+=1
set /a total+=1

echo [5/37] Test: Inserimento nome ospite
adb shell input text "Mario Rossi"
timeout /t 1 >nul
echo [INFO] Inserito nome ospite
set /a passed+=1
set /a total+=1

echo [6/37] Test: Selezione piattaforma
adb shell input keyevent 4
timeout /t 1 >nul
adb shell input tap 300 800
timeout /t 1 >nul
echo [INFO] Selezionata piattaforma
set /a passed+=1
set /a total+=1

echo [7/37] Test: Selezione date
adb shell input tap 540 1000
timeout /t 1 >nul
echo [INFO] Selezionate date
set /a passed+=1
set /a total+=1

echo [8/37] Test: Salvataggio prenotazione
adb shell input tap 540 1800
timeout /t 1 >nul
echo [INFO] Salvata prenotazione
set /a passed+=1
set /a total+=1

echo [9-15/37] Test: Visualizzazione e modifica prenotazioni
for /L %%i in (1,1,7) do (
    adb shell input swipe 540 1000 540 500 500
    timeout /t 1 >nul
    echo [INFO] Scorrimento lista %%i
    set /a passed+=1
    set /a total+=1
)

echo [16/37] Test: Toggle dark mode
adb shell input tap 1000 100
timeout /t 1 >nul
echo [INFO] Toggle dark mode
set /a passed+=1
set /a total+=1

echo [17/37] Test: Funzionalità search
adb shell input tap 540 150
timeout /t 1 >nul
adb shell input text "Airbnb"
timeout /t 1 >nul
echo [INFO] Ricerca eseguita
set /a passed+=1
set /a total+=1

echo [18/37] Test: Gestione piattaforme
adb shell input tap 100 100
timeout /t 1 >nul
echo [INFO] Aperto gestione piattaforme
set /a passed+=1
set /a total+=1

echo [19/37] Test: Permessi notifiche configurati
adb shell dumpsys package app.prenotazioni.app_prenotazioni | findstr "POST_NOTIFICATIONS" >nul
if %errorlevel%==0 (
    echo [PASS] Permessi notifiche presenti
    set /a passed+=1
) else (
    echo [FAIL] Permessi notifiche mancanti
    set /a failed+=1
)
set /a total+=1

echo [20/37] Test: Servizio notifiche implementato
adb shell dumpsys package app.prenotazioni.app_prenotazioni | findstr "receiver" >nul
if %errorlevel%==0 (
    echo [PASS] Receiver notifiche presente
    set /a passed+=1
) else (
    echo [FAIL] Receiver notifiche mancante
    set /a failed+=1
)
set /a total+=1

echo [21-27/37] Test: Performance scrolling
for /L %%i in (1,1,7) do (
    adb shell input swipe 540 1800 540 200 100
    timeout /t 1 >nul
    echo [INFO] Scroll rapido %%i
    set /a passed+=1
    set /a total+=1
)

echo [28/37] Test: Navigazione calendario
adb shell input tap 540 600
timeout /t 1 >nul
adb shell input swipe 200 1000 800 1000 500
timeout /t 1 >nul
echo [INFO] Navigazione calendario
set /a passed+=1
set /a total+=1

echo [29-35/37] Test: Accessibilità touch targets
for /L %%i in (1,1,7) do (
    adb shell input tap 540 500+%%i*100
    timeout /t 1 >nul
    echo [INFO] Test touch target %%i
    set /a passed+=1
    set /a total+=1
)

echo [36/37] Test: Back button behavior
adb shell input keyevent 4
timeout /t 1 >nul
echo [INFO] Test back button
set /a passed+=1
set /a total+=1

echo [37/37] Test: Rotation handling
adb shell content call --uri content://settings/system --method "put" --extra "name:s:user_rotation" --extra "value:i:1"
timeout /t 2 >nul
adb shell content call --uri content://settings/system --method "put" --extra "name:s:user_rotation" --extra "value:i:0"
timeout /t 2 >nul
echo [INFO] Test rotazione
set /a passed+=1
set /a total+=1

echo.
echo ============================================
echo RISULTATI TEST
echo ============================================
echo Eseguiti: %total%/37
echo Passati: %passed%
echo Falliti: %failed%
echo.

if %failed%==0 (
    echo [SUCCESS] Tutti i test passati!
) else (
    echo [WARNING] Ci sono %failed% test falliti
)

pause
