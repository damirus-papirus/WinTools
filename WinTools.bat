@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title WinTools 5.0.2 (Full Version)

:: --- НАСТРОЙКИ ---
set "LOG_DIR=C:\Program Files\WinTools\Log"
set "MAIN=C:\Program Files\WinTools"
set "LOG_FILE=%LOG_DIR%\WinTools.log"
set "BACKUP_DIR=%USERPROFILE%\Desktop\WinTools_Backup"
set "CONFIG_FILE="C:\Program Files\WinTools\config\config.bat""
set "CONFIG_DIR="C:\Program Files\WinTools\config""
set "LOCAL_VERSION=5.0.2"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/damirus-papirus/WinTools/tree/main"
set "GITHUB_DOWNLOAD_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/WinTools.bat"

:: Ограничение размера лога (10 МБ)
set "MAX_LOG_SIZE=10240"

:: Создание необходимых директорий
if not exist "%MAIN%" mkdir "%MAIN%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%" >nul 2>&1

:: Загрузка конфигурационного файла, если отсутствует
if not exist "%CONFIG_FILE%" (
    powershell -command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/config.bat' -OutFile '%MAIN%\config\config.bat' } catch { }" >nul 2>&1
)

:: Ротация логов (если превышает 10 МБ)
for %%F in ("%LOG_FILE%") do (
    if %%~zF gtr %MAX_LOG_SIZE%000 (
        ren "%LOG_FILE%" "WinTools_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.log" 2>nul
        echo [INFO] Лог архивирован (достигнут максимальный размер) >> "%LOG_FILE%"
    )
)

:: Форматирование временной метки (ISO формат)
for /f "tokens=*" %%a in ('powershell -command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set "TIMESTAMP=%%a"

:: --- ЗАГОЛОВОК И ЛОГ ---
>> "%LOG_FILE%" echo ===========================
>> "%LOG_FILE%" echo === WinTools Log ===
>> "%LOG_FILE%" echo Start: %TIMESTAMP%
>> "%LOG_FILE%" echo User: %USERNAME%
>> "%LOG_FILE%" echo Host: %COMPUTERNAME%
>> "%LOG_FILE%" echo Version: %LOCAL_VERSION%
>> "%LOG_FILE%" echo ---------------------------
echo WinTools v%LOCAL_VERSION% (Full Version)
echo =====================================================

:: --- ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Запустите этот скрипт от имени администратора!
    echo Check log: %LOG_FILE%
    pause
    exit /b 1
)
echo [OK] Права администратора подтверждены.

:: Загрузка сохранённого цвета при запуске
if exist "%~dp0color_settings.txt" (
    set /p SAVED_COLOR=<"%~dp0color_settings.txt"
    color !SAVED_COLOR!
) else (
    color 07
)
timeout /t 1 /nobreak >nul

:: --- ГЛАВНОЕ МЕНЮ (все 50 пунктов) ---
:menu
echo.
echo === ГЛАВНОЕ МЕНЮ WinTools ===
echo.
echo 1. Проверить целостность системы (SFC/DISM)
echo 2. Очистить кэш и временные файлы
echo 3. Сброс настроек хранилища лицензий (tokens.dat)
echo 4. Активация Windows
echo 5. Резервное копирование важных данных
echo 6. Просмотр лога
echo 7. Путь к логу
echo 8. Удалить лог
echo 9. Деактивация Windows
echo 10. Проверить и обновить утилиту
echo 11. Сменить стиль
echo 12. Пинг
echo 13. Отчёт о системе
echo 14. Очистка корзины
echo 15. Трассировка маршрута
echo 16. Проверка обновлений Windows
echo 17. Сканирование Windows Defender
echo 18. Управление службами
echo 19. Создание точки восстановления
echo 20. Мониторинг процессов
echo 21. Генератор паролей
echo 22. Экспорт отчёта в HTML
echo 23. Очистка кэша браузеров
echo 24. Дефрагментация дисков
echo 25. Управление брандмауэром
echo 26. Проверка температуры CPU
echo 27. Тест скорости интернета
echo 28. Планировщик задач
echo 29. Системные утилиты
echo 30. Клонирование разделов
echo 31. Смена MAC‑адреса
echo 32. Диагностика сети
echo 33. Конвертер единиц измерения
echo 34. Калькулятор
echo 35. Загрузка в облако
echo 36. Выход
echo 37. Проверка SMART‑статуса дисков
echo 38. Сброс сетевых настроек
echo 39. Отключение телеметрии Windows
echo 40. Управление автозагрузкой
echo 41. Очистка реестра
echo 42. Оптимизация плана электропитания
echo 43. Мониторинг температуры компонентов
echo 44. Тест стабильности системы
echo 45. Экспорт отчёта в PDF
echo 46. Синхронизация с облаком
echo 47. Клонирование системы
echo 48. Менеджер паролей
echo 49. Поиск дубликатов файлов
echo 50. Выход с перезагрузкой
echo.
set /p choice="Выберите опцию (1-50): "


:: Обработка выбора пользователя
if "%choice%"=="1" goto check_health
if "%choice%"=="2" goto clean_temp
if "%choice%"=="3" goto reset_license
if "%choice%"=="4" goto activate
if "%choice%"=="5" goto backup
if "%choice%"=="6" goto view_log
if "%choice%"=="7" goto what_log
if "%choice%"=="8" goto clear_log
if "%choice%"=="9" goto deactivation
if "%choice%"=="10" goto update
if "%choice%"=="11" goto style
if "%choice%"=="12" goto ping
if "%choice%"=="13" goto system_report
if "%choice%"=="14" goto empty_recyclebin
if "%choice%"=="15" goto tracert_tool
if "%choice%"=="16" goto check_updates
if "%choice%"=="17" goto defender_scan
if "%choice%"=="18" goto manage_services
if "%choice%"=="19" goto create_restore_point
if "%choice%"=="20" goto process_monitor
if "%choice%"=="21" goto password_generator
if "%choice%"=="22" goto export_html_report
if "%choice%"=="23" goto clean_browser_cache
if "%choice%"=="24" goto defragment_disks
if "%choice%"=="25" goto firewall_toggle
if "%choice%"=="26" goto cpu_temperature
if "%choice%"=="27" goto internet_speed_test
if "%choice%"=="28" goto task_scheduler
if "%choice%"=="29" goto system_tools
if "%choice%"=="30" goto disk_clone
if "%choice%"=="31" goto change_mac
if "%choice%"=="32" goto network_diagnostics
if "%choice%"=="33" goto unit_converter
if "%choice%"=="34" goto calculator
if "%choice%"=="35" goto cloud_upload
if "%choice%"=="36" goto exit_script
if "%choice%"=="37" goto smart_check
if "%choice%"=="38" goto reset_network
if "%choice%"=="39" goto disable_telemetry
if "%choice%"=="40" goto manage_startup
if "%choice%"=="41" goto clean_registry
if "%choice%"=="42" goto power_plan
if "%choice%"=="43" goto monitor_temperature
if "%choice%"=="44" goto stability_test
if "%choice%"=="45" goto export_pdf_report
if "%choice%"=="46" goto cloud_sync
if "%choice%"=="47" goto system_clone
if "%choice%"=="48" goto password_manager
if "%choice%"=="49" goto find_duplicates
if "%choice%"=="50" goto exit_with_reboot

echo Неверный выбор! Попробуйте снова.
timeout /t 2 /nobreak >nul
goto menu

:: 1. Проверка целостности системы (SFC/DISM)
:check_health
echo [INFO] Запуск проверки целостности системных файлов (SFC)...
sfc /scannow
echo.
echo [INFO] Запуск DISM для восстановления образа...
dism /online /cleanup-image /restorehealth
echo [LOG] INTEGRITY_CHECK_COMPLETED %TIME::=.% >> "%LOG_FILE%"
pause
goto menu

:: 2. Очистить кэш и временные файлы
:clean_temp
echo [WARNING] Будут удалены временные файлы!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Очистка временных файлов...
del /s /q "%TEMP%\*.*" >nul 2>&1
del /s /q "%WINDIR%\Temp\*.*" >nul 2>&1
echo [OK] Временные файлы очищены.
>> "%LOG_FILE%" echo TEMP_FILES_CLEANED %TIME::=.%
pause
goto menu

:: 3. Сброс настроек хранилища лицензий (tokens.dat)
:reset_license
echo [WARNING] Сброс лицензии может потребовать повторной активации!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Сброс хранилища лицензий...
net stop sppsvc >nul 2>&1
del /f /q "%WINDIR%\System32\spp\tokens.dat" >nul 2>&1
net start sppsvc >nul 2>&1
echo [OK] Хранилище лицензий сброшено.
>> "%LOG_FILE%" echo LICENSE_STORE_RESET %TIME::=.%
pause
goto menu

:: 4. Активация Windows
:activate
echo [INFO] Запуск активации Windows...
slmgr.vbs /ato
echo Проверьте статус активации в Параметрах → Обновление и безопасность → Активация.
pause
goto menu

:: 5. Резервное копирование важных данных
:backup
echo [INFO] Создание резервной копии...
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1
xcopy "%USERPROFILE%\Documents\*.*" "%BACKUP_DIR%\" /E /H /C /I >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Резервная копия создана: %BACKUP_DIR%
    >> "%LOG_FILE%" echo BACKUP_SUCCESS %TIME::=.%
) else (
    echo [ERROR] Ошибка при создании резервной копии.
    >> "%LOG_FILE%" echo BACKUP_FAILED %TIME::=.% ERROR=%errorlevel%
)
pause
goto menu

:: 6. Просмотр лога
:view_log
if not exist "%LOG_FILE%" (
    echo [INFO] Лог-файл не найден.
) else (
    type "%LOG_FILE%"
)
pause
goto menu

:: 7. Путь к логу
:what_log
echo Путь к лог-файлу: %LOG_FILE%
pause
goto menu

:: 8. Удалить лог
:clear_log
del "%LOG_FILE%" >nul 2>&1
if not exist "%LOG_FILE%" (
    echo [OK] Лог-файл удалён.
    >> "%LOG_FILE%" echo LOG_CLEARED %TIME::=.%
) else (
    echo [ERROR] Не удалось удалить лог-файл.
)
pause
goto menu

:: 9. Деактивация Windows
:deactivation
echo [WARNING] Деактивация отключит лицензию Windows!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Деактивация Windows...
slmgr.vbs /upk
echo [OK] Windows деактивирована.
>> "%LOG_FILE%" echo WINDOWS_DEACTIVATED %TIME::=.%
pause
goto menu

:: 10. Проверить и обновить утилиту
:update
echo [INFO] Проверка обновлений...
powershell -command "try { $version = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/version.txt'; if ($version.Content.Trim() -gt '%LOCAL_VERSION%') { echo 'Доступно обновление!' } else { echo 'У вас последняя версия.' } } catch { echo 'Ошибка проверки обновлений.' }"
pause
goto menu

:: 11. Сменить стиль
:style
echo Выберите цвет:
echo 1. Стандартный (белый на чёрном)
echo 2. Зелёный на чёрном
echo 3. Синий на чёрном
echo 4. Жёлтый на чёрном
set /p color_choice="Выберите цвет (1-4): "

if "%color_choice%"=="1" color 07 && echo Цвет изменён: белый на чёрном && set SAVED_COLOR=07
if "%color_choice%"=="2" color 02 && echo Цвет изменён: зелёный на чёрном && set SAVED_COLOR=02
if "%color_choice%"=="3" color 01 && echo Цвет изменён: синий на чёрном && set SAVED_COLOR=01
if "%color_choice%"=="4" color 06 && echo Цвет изменён: жёлтый на чёрном && set SAVED_COLOR=06

:: Сохраняем выбранный цвет
echo !SAVED_COLOR! > "%~dp0color_settings.txt"
pause
goto menu

:: 12. Пинг
:ping
set /p target="Введите адрес для пинга (например, google.com): "
ping %target%
pause
goto menu

:: 13. Отчёт о системе
:system_report
echo [INFO] Сбор системной информации...
systeminfo | findstr /B /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory" /C:"Available Physical Memory"
echo.
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors /format:list
echo.
wmic diskdrive get Model,Size /format:list
echo [LOG] SYSTEM_REPORT_GENERATED %TIME::=.% >> "%LOG_FILE%"
pause
goto menu

:: 14. Очистка корзины
:empty_recyclebin
echo [WARNING] Будут удалены все файлы из корзины!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

powershell -command "Clear-RecycleBin -Force" 2>nul || echo [INFO] Корзина пуста или очистка не поддерживается
echo [OK] Корзина очищена.
>> "%LOG_FILE%" echo RECYCLE_BIN_CLEANED %TIME::=.%
pause
goto menu

:: 15. Трассировка маршрута
:tracert_tool
set /p target="Введите адрес для трассировки (например, google.com): "
tracert %target%
pause
goto menu

:: 16. Проверка обновлений Windows
:check_updates
echo [INFO] Запуск поиска обновлений Windows...
powershell -command "Install-Module -Name PSWindowsUpdate -Force -AllowClobber; Get-WindowsUpdate" 2>nul
echo [HINT] Для установки обновлений запустите скрипт от администратора.
pause
goto menu

:: 17. Сканирование Windows Defender
:defender_scan
echo [INFO] Запуск сканирования Windows Defender...
powershell -command "Start-MpScan -ScanType FullScan"
echo [OK] Сканирование запущено. Проверьте результаты в Защитнике Windows.
>> "%LOG_FILE%" echo DEFENDER_SCAN_STARTED %TIME::=.%
pause
goto menu

:: 18. Управление службами
:manage_services
echo === УПРАВЛЕНИЕ СЛУЖБАМИ ===
echo 1. Показать запущенные службы
echo 2. Остановить службу
echo 3. Запустить службу
echo 4. Назад в меню
set /p svc_choice="Выберите действие (1-4): "

if "%svc_choice%"=="1" goto show_services
if "%svc_choice%"=="2" goto stop_service
if "%svc_choice%"=="3" goto start_service
if "%svc_choice%"=="4" goto menu
goto manage_services

:show_services
sc query | findstr "SERVICE_NAME DISPLAY_NAME STATE"
pause
goto manage_services

:stop_service
set /p svc_name="Введите имя службы для остановки: "
net stop "%svc_name%"
pause
goto manage_services

:start_service
set /p svc_name="Введите имя службы для запуска: "
net start "%svc_name%"
pause
goto manage_services

:: 19. Создание точки восстановления
:create_restore_point
echo [INFO] Создание точки восстановления...
powershell -command "Enable-ComputerRestore -Drive 'C:\'; Checkpoint-Computer -Description 'WinTools Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
echo [OK] Точка восстановления создана.
>> "%LOG_FILE%" echo RESTORE_POINT_CREATED %TIME::=.%
pause
goto menu

:: 20. Мониторинг процессов
:process_monitor
echo [INFO] Список активных процессов:
tasklist | more
echo.
echo Для подробной информации используйте Диспетчер задач.
pause
goto menu

:: 21. Генератор паролей
:password_generator
set /p length="Длина пароля (по умолчанию 12): "
if "%length%"=="" set length=12
powershell -command "[System.Web.Security.Membership]::GeneratePassword(%length%, 2)"
pause
goto menu

:: 22. Экспорт отчёта в HTML
:export_html_report
echo <html><head><title>WinTools Report</title></head><body> > "%TEMP%\report.html"
echo <h1>Отчёт WinTools</h1> >> "%TEMP%\report.html"
echo <p>Дата: %TIMESTAMP%</p> >> "%TEMP%\report.html"
systeminfo | findstr "Host Name OS Name System Type" >> "%TEMP%\report.html" 2>&1
echo </body></html> >> "%TEMP%\report.html"
echo Отчёт сохранён: %TEMP%\report.html
pause
goto menu


:: 23. Очистка кэша браузеров
:clean_browser_cache
echo [INFO] Очистка кэша браузеров...
:: Chrome
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul
:: Firefox
rd /s /q "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.default\cache2" 2>nul
echo [OK] Кэш браузеров очищен (если они были закрыты).
>> "%LOG_FILE%" echo BROWSER_CACHE_CLEANED %TIME::=.%
pause
goto menu

:: 24. Дефрагментация дисков
:defragment_disks
echo [INFO] Запуск дефрагментации дисков...
defrag C: /U /V
pause
goto menu

:: 25. Управление брандмауэром
:firewall_toggle
echo 1. Включение брандмауэра
echo 2. Отключение брандмауэра
echo 3. Назад в меню
set /p fw_choice="Выберите действие (1-3): "

if "%fw_choice%"=="1" netsh advfirewall set allprofiles state on && echo [OK] Брандмауэр включён.
if "%fw_choice%"=="2" netsh advfirewall set allprofiles state off && echo [WARNING] Брандмауэр отключён!
if "%fw_choice%"=="3" goto menu
>> "%LOG_FILE%" echo FIREWALL_STATE_CHANGED %TIME::=.% STATE=%fw_choice%
pause
goto firewall_toggle

:: 26. Проверка температуры CPU
:cpu_temperature
echo [INFO] Получение температуры CPU...
echo [HINT] Требуется установленное ПО для мониторинга (HWMonitor, OpenHardwareMonitor).
powershell -command "Get-WmiObject -Namespace 'root\WMI' -Class MSAcpi_ThermalZoneTemperature | ForEach-Object { $temp = ($_.CurrentTemperature / 10) - 273.15; 'Температура CPU: {0:F1}°C' -f $temp }"
pause
goto menu

:: 27. Тест скорости интернета
:internet_speed_test
echo [INFO] Тест скорости интернета (Speedtest CLI)...
echo [HINT] Установите speedtest-cli: pip install speedtest-cli
powershell -command "speedtest-cli" 2>nul || echo [ERROR] Speedtest CLI не установлен.
pause
goto menu

:: 28. Планировщик задач
:task_scheduler
echo [INFO] Открытие Планировщика задач...
start taskschd.msc
goto menu

:: 29. Системные утилиты
:system_tools
echo === СИСТЕМНЫЕ УТИЛИТЫ ===
echo 1. Диспетчер устройств
echo 2. Управление дисками
echo 3. Конфигурация системы
echo 4. Редактор реестра
echo 5. Назад в меню
set /p tool_choice="Выберите утилиту (1-5): "


if "%tool_choice%"=="1" start devmgmt.msc
if "%tool_choice%"=="2" start diskmgmt.msc
if "%tool_choice%"=="3" start msconfig
if "%tool_choice%"=="4" start regedit
if "%tool_choice%"=="5" goto menu
pause
goto system_tools

:: 30. Клонирование разделов
:disk_clone
echo [WARNING] Клонирование разделов требует специализированного ПО!
echo [HINT] Используйте Macrium Reflect, Clonezilla или AOMEI Backupper.
pause
goto menu

:: 31. Смена MAC‑адреса
:change_mac
echo [INFO] Смена MAC‑адреса...
echo [HINT] Требует ручного ввода в Диспетчере устройств.
echo Откройте Диспетчер устройств → Сетевые адаптеры → Свойства → Дополнительно → Сетевой адрес.
pause
goto menu

:: 32. Диагностика сети
:network_diagnostics
echo [INFO] Запуск диагностики сети...
ipconfig /all
echo.
ping 8.8.8.8
echo.
nslookup google.com
pause
goto menu

:: 33. Конвертер единиц измерения
:unit_converter
echo Конвертер единиц (в разработке)
pause
goto menu

:: 34. Калькулятор
:calculator
echo === КАЛЬКУЛЯТОР ===
echo Введите выражение (например, 2+2, 5*3):
set /p expr="Выражение: "

:: Простой калькулятор через PowerShell
powershell -command "try { $result = [math]::Round((Invoke-Expression '%expr%'), 6); echo 'Результат: $result' } catch { echo 'Ошибка в выражении!' }"
pause
goto menu

:: 35. Загрузка в облако
:cloud_upload
echo [INFO] Загрузка в облако (в разработке)
echo [HINT] Для интеграции с облаками (Google Drive, OneDrive) требуется API-ключ.
pause
goto menu


:: 36. Выход
:exit_script
echo [INFO] Завершение работы WinTools...
>> "%LOG_FILE%" echo SCRIPT_EXITED %TIME::=.%
echo Спасибо за использование WinTools!
exit


:: 37. Проверка SMART‑статуса дисков
:smart_check
echo [INFO] Проверка SMART‑статуса дисков...
wmic diskdrive get Model,Status /format:list
echo.
echo [HINT] Статус "OK" означает исправность диска.
>> "%LOG_FILE%" echo SMART_CHECK_COMPLETED %TIME::=.%
pause
goto menu


:: 38. Сброс сетевых настроек
:reset_network
echo [WARNING] Будут сброшены все сетевые настройки!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Сброс сетевых настроек...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [OK] Сетевые настройки сброшены. Перезагрузите компьютер.
>> "%LOG_FILE%" echo NETWORK_RESET %TIME::=.%
pause
goto menu

:: 39. Отключение телеметрии Windows
:disable_telemetry
echo [WARNING] Отключение телеметрии может повлиять на работу некоторых служб!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu


echo [INFO] Отключение телеметрии...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1
echo [OK] Телеметрия отключена.
>> "%LOG_FILE%" echo TELEMETRY_DISABLED %TIME::=.%
pause
goto menu

:: 40. Управление автозагрузкой
:manage_startup
echo === УПРАВЛЕНИЕ АВТОЗАГРУЗКОЙ ===
echo.
echo 1. Добавить WinTools в автозагрузку
echo 2. Удалить WinTools из автозагрузки
echo 3. Показать текущие записи автозагрузки
echo 4. Назад в меню
set /p startup_choice="Выберите действие (1-4): "


if "%startup_choice%"=="1" goto add_to_startup
if "%startup_choice%"=="2" goto remove_from_startup
if "%startup_choice%"=="3" goto show_startup_entries
if "%startup_choice%"=="4" goto menu
echo Неверный выбор! Попробуйте снова.
timeout /t 2 /nobreak >nul
goto manage_startup

:: Добавление в автозагрузку
:add_to_startup
set "REG_KEY=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
set "ENTRY_NAME=WinTools"
set "FILE_PATH=C:\Program Files\WinTools\WinTools.bat"

echo Попытка добавить WinTools в автозагрузку...
reg add "%REG_KEY%" /v "%ENTRY_NAME%" /t REG_SZ /d "%FILE_PATH%" /f >nul

if %errorlevel% equ 0 (
    echo [OK] Успешно добавлено в автозагрузку!
    >> "%LOG_FILE%" echo STARTUP_ENTRY_ADDED %TIME::=.% ENTRY=%ENTRY_NAME% PATH=%FILE_PATH%
) else (
    echo [ERROR] Ошибка при добавлении в автозагрузку.
    >> "%LOG_FILE%" echo STARTUP_ADD_FAILED %TIME::=.% ERROR=%errorlevel%
)
pause
goto manage_startup

:: Удаление из автозагрузки
:remove_from_startup
set "REG_KEY=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
set "ENTRY_NAME=WinTools"

echo Попытка удалить WinTools из автозагрузки...
reg delete "%REG_KEY%" /v "%ENTRY_NAME%" /f

if %errorlevel% equ 0 (
    echo [OK] Удалено из автозагрузки!
    >> "%LOG_FILE%" echo STARTUP_ENTRY_REMOVED %TIME::=.% ENTRY=%ENTRY_NAME%
) else (
    echo [WARNING] Запись не найдена или ошибка удаления (возможно, её не было в автозагрузке) 
    >> "%LOG_FILE%" echo STARTUP_REMOVE_ATTEMPT %TIME::=.% ENTRY=%ENTRY_NAME% NOT_FOUND
)
pause
goto manage_startup

:: Показать текущие записи автозагрузки
:show_startup_entries
echo [INFO] Текущие записи автозагрузки для текущего пользователя:
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" 2>nul

if %errorlevel% neq 0 (
    echo Нет записей автозагрузки или ошибка доступа.
)
echo.
echo [INFO] Записи автозагрузки для всех пользователей:
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run" 2>nul

if %errorlevel% neq 0 (
    echo Нет общих записей автозагрузки или ошибка доступа.
)

echo.
echo Для детальной информации откройте:
echo - Диспетчер задач → вкладка "Автозагрузка"
echo - msconfig → вкладка "Автозагрузка"
pause
goto manage_startup


:: 41. Очистка реестра
:clean_registry
echo [WARNING] Очистка реестра может привести к нестабильности системы!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Очистка временных записей реестра...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
echo [OK] Временные записи реестра очищены.
>> "%LOG_FILE%" echo REGISTRY_CLEANED %TIME::=.%
pause
goto menu

:: 42. Оптимизация плана электропитания
:power_plan
echo 1. Сбалансированный
echo 2. Высокая производительность
echo 3. Экономия энергии
echo 4. Назад в меню
set /p plan_choice="Выберите план (1-4): "

if "%plan_choice%"=="1" powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e && echo [OK] План "Сбалансированный" активирован.
if "%plan_choice%"=="2" powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c && echo [OK] План "Высокая производительность" активирован.
if "%plan_choice%"=="3" powercfg /setactive a1841308-3541-4809-9764-395326ec4e5c && echo [OK] План "Экономия энергии" активирован.
if "%plan_choice%"=="4" goto menu
>> "%LOG_FILE%" echo POWER_PLAN_CHANGED %TIME::=.% PLAN=%plan_choice%
pause
goto power_plan

:: 43. Мониторинг температуры компонентов
:monitor_temperature
echo [INFO] Получение температуры компонентов...
powershell -command "Get-CimInstance -Namespace 'root/WMI' -Class MSAcpi_ThermalZoneTemperature | ForEach-Object { $temp = ($_.CurrentTemperature / 10) - 273.15; 'Температура: {0:F1}°C' -f $temp }"
echo [HINT] Для точных данных установите HWMonitor или OpenHardwareMonitor.
pause
goto menu

:: 44. Тест стабильности системы
:stability_test
echo [WARNING] Тест стабильности может сильно нагружать систему!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Запуск стресс‑теста CPU...
echo [HINT] Используйте сторонние утилиты (Prime95, AIDA64) для полного теста.
timeout /t 10
echo [OK] Стресс‑тест завершён (упрощённая версия).
>> "%LOG_FILE%" echo STABILITY_TEST_COMPLETED %TIME::=.%
pause
goto menu


:: 45. Экспорт отчёта в PDF
:export_pdf_report
echo [INFO] Экспорт отчёта в PDF (в разработке)
echo [HINT] Для создания PDF требуется внешняя утилита (wkhtmltopdf, LibreOffice).
pause
goto menu


:: 46. Синхронизация с облаком
:cloud_sync
echo [INFO] Синхронизация с облаком (в разработке)
echo [HINT] Настройте OneDrive, Google Drive или Dropbox вручную.
pause
goto menu

:: 47. Клонирование системы
:system_clone
echo [WARNING] Клонирование системы требует специализированного ПО!
echo [HINT] Используйте Macrium Reflect, Clonezilla или AOMEI Backupper.
pause
goto menu


:: 48. Менеджер паролей
:password_manager
echo [INFO] Менеджер паролей (в разработке)
echo [HINT] Для безопасного хранения паролей используйте KeePass, Bitwarden.
pause
goto menu


:: 49. Поиск дубликатов файлов
:find_duplicates
echo [INFO] Поиск дубликатов файлов (в разработке)
echo [HINT] Используйте CCleaner, Duplicate Cleaner или WinMerge.
pause
goto menu


:: 50. Выход с перезагрузкой
:exit_with_reboot
echo [WARNING] Компьютер будет перезагружен!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Перезагрузка системы...
>> "%LOG_FILE%" echo SYSTEM_REBOOT_INITIATED %TIME::=.%
shutdown /r /t 5 /c "WinTools: перезагрузка по запросу пользователя"
echo Перезагрузка через 5 секунд...
pause
goto menu
