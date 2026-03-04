@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title WinTools 4.0.0

:: --- НАСТРОЙКИ ---
set "LOG_DIR=C:\Program Files\WinTools\Log"
set "MAIN=C:\Program Files\WinTools"
set "LOG_FILE=%LOG_DIR%\WinTools.log"
set "BACKUP_DIR=%USERPROFILE%\Desktop\WinTools_Backup"
set "CONFIG_FILE="C:\Program Files\WinTools\config\config.bat""
set "CONFIG_DIR="C:\Program Files\WinTools\config""
set "LOCAL_VERSION=4.0.0"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/damirus-papirus/WinTools/tree/main"
set "GITHUB_DOWNLOAD_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/WinTools.bat"

if not exist "%MAIN%" (
    mkdir "%MAIN%"
)
if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%" >nul
)
if not exist %CONFIG_FILE% (
    mkdir %CONFIG_DIR% >nul
    powershell -command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/config.bat' -OutFile '"%MAIN%"\config\config.bat'"
)
if not exist "%MAIN%"\WinTools.bat (
    echo Переместите эту утилиту по пути C:\Program Files\WinTools
    pause
    exit /b
)

:: Форматируем временную метку без спецсимволов
set "TIMESTAMP=%DATE% %TIME%"
set "TIMESTAMP=!TIMESTAMP:/=-%"
set "TIMESTAMP=!TIMESTAMP::=-%"
set "TIMESTAMP=!TIMESTAMP: =-%"

:: --- ЗАГОЛОВОК И ЛОГ ---
>> "%LOG_FILE%" echo ===========================
>> "%LOG_FILE%" echo === WinTools Log ===
>> "%LOG_FILE%" echo Start: %TIMESTAMP%
>> "%LOG_FILE%" echo User: %USERNAME%
>> "%LOG_FILE%" echo Host: %COMPUTERNAME%
>> "%LOG_FILE%" echo ---------------------------
echo WinTools v4.0.0
echo ======================================

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

:: --- ГЛАВНОЕ МЕНЮ ---
:menu
echo.
echo === MAIN MENU ===
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
echo 22. Выход
echo.
set /p choice="Выберите опцию (1-22): "

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
if "%choice%"=="22" goto exit_script
echo Неверный выбор! Попробуйте снова.
goto menu

:: --- 1. ПРОВЕРКА СИСТЕМЫ ---
:check_health
echo [INFO] Запуск SFC...
>> "%LOG_FILE%" echo SFC запущен: %TIME%
sfc /scannow
echo [INFO] SFC завершён

echo [INFO] Запуск DISM...
>> "%LOG_FILE%" echo DISM запущен: %TIME%
DISM /Online /Cleanup-Image /RestoreHealth
echo [INFO] DISM завершён.
>> "%LOG_FILE%" echo CHECK_HEALTH_SUCCESS %TIME::=.%
goto menu

:: --- 2. ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ ---
:clean_temp
echo [INFO] Очистка временных файлов...

del /s /q "%TEMP%\*" >nul 2>&1
del /s /q "%WINDIR%\Temp\*" >nul 2>&1

echo [INFO] Очистка DNS-кэша…
ipconfig /flushdns >nul 2>&1
echo [INFO] Сброс Winsock…
netsh winsock reset >nul 2>&1
>> "%LOG_FILE%" echo CLEAR_TEMP %TIME::=.%

echo [OK] Очистка завершена.
goto menu

:: --- 3. ПЕРЕСОЗДАНИЕ ХРАНИЛИЩА ЛИЦЕНЗИЙ ---
:reset_license
echo [WARNING] Это приведёт к сбросу лицензионных данных!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Создание резервной копии tokens.dat...
if exist "%SystemRoot%\System32\spp\store\2.0\tokens.dat" (
    copy "%SystemRoot%\System32\spp\store\2.0\tokens.dat" "%BACKUP_DIR%\tokens.dat.bak" >nul 2>&1
)

echo [INFO] Остановка защиты программного обеспечения...
net stop sppsvc >> "%LOG_FILE%" 2>&1

echo [INFO] Удаление tokens.dat...
del /f /q "%SystemRoot%\System32\spp\store\2.0\tokens.dat" >> "%LOG_FILE%" 2>&1
del /f /q "%SystemRoot%\System32\spp\store\2.0\data.dat" >> "%LOG_FILE%" 2>&1

echo [INFO] Запуск защиты программного обеспечения...
net start sppsvc >> "%LOG_FILE%" 2>&1

echo [INFO] Переустановка лицензионных данных...
cscript.exe %windir%\system32\slmgr.vbs /rilc >> "%LOG_FILE%" 2>&1
>> "%LOG_FILE%" echo RESETTING_LICENSE_STORAGE %TIME::=.%

echo [OK] Сброс хранилища лицензий выполнен. Рекомендуется перезагрузить компьютер.
goto menu

:: --- 4. АКТИВАЦИЯ WINDOWS ---
:activate
:: --- Настройки ---
set "KMS_SERVER=kms.digiboy.ir"
set "TIMEOUT_SECS=10"

:: --- Запрос редакции ---
:ask_edition
echo Какой выпуск Windows 10 у вас установлен? (home, pro, education)
set "edition="
set /p edition=
if not defined edition (
    echo [INFO] Входные данные не могут быть пустыми. Попробуйте снова.
    goto ask_edition
)

:: --- Обрезка пробелов ---
for /f "delims=" %%i in ("%edition%") do set "edition=%%i"

:: --- Валидация ввода ---
if /i not "%edition%"=="home" if /i not "%edition%"=="pro" if /i not "%edition%"=="education" (
    echo [ERROR] Неверное значение: '%edition%'. Допустимо: home, pro, education.
    echo [LOG] %date% %time% INVALID_INPUT: '%edition%' >> "%LOG_FILE%"
    pause
    goto activate
)

:: --- Подтверждение ---
echo Вы выбрали: %edition%
echo Нажмите Y для продолжения, N для отмены
choice /c YN /n
if %errorlevel%==2 (
    echo [INFO] Отменено пользователем.
    goto menu
)

:: --- Ключи активации ---
set "KEY_HOME=7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"
set "KEY_PRO=W269N-WFGWX-YVC9B-4J6C9-T83GX"
set "KEY_EDUCATION=6TP4R-GNPTD-KYYHQ-7B7DP-J447Y"

:: --- Выполнение активации ---
echo [INFO] Начало активации для %edition%...
echo START_ACTIVATION: %edition% %time::=.% >> "%LOG_FILE%"

:: Сохраняем ключ
set "PRODUCT_KEY=!KEY_%edition%!"

:: 1. Установка ключа
echo [STEP 1/3] Установка ключа продукта...
slmgr /ipk %PRODUCT_KEY% >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Не удалось установить ключ продукта. Код ошибки: %errorlevel%
    >> "%LOG_FILE%" echo ACTIVATION_FAILED_KEY_INSTALL %TIME::=.% ERROR=%errorlevel%
    goto fail_activation
)

:: 2. Настройка KMS-сервера
echo [STEP 2/3] Настройка KMS сервера...
slmgr /skms %KMS_SERVER% >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Не удалось настроить KMS сервер. Код ошибки: %errorlevel%
    >> "%LOG_FILE%" echo ACTIVATION_FAILED_KMS_SETUP %TIME::=.% ERROR=%errorlevel%
    goto fail_activation
)

:: 3. Активация
echo [STEP 3/3] Активация...
slmgr /ato
set "ATO_ERROR=%errorlevel%"
if %ATO_ERROR%==0 (
    echo [SUCCESS] Windows успешно активирована!
    >> "%LOG_FILE%" echo ACTIVATION_SUCCESS %TIME::=.%
) else (
    echo [ERROR] Активация не удалась. Код ошибки: %ATO_ERROR%
    echo [HINT] Проверьте подключение к интернету или доступность KMS сервера.
    >> "%LOG_FILE%" echo ACTIVATION_FAILED %TIME::=.% ERROR=%ATO_ERROR%
)
goto menu

:fail_activation
echo [INFO] Активация прервана из‑за ошибки.
pause
goto menu

:: --- 5. РЕЗЕРВНОЕ КОПИРОВАНИЕ ---
:backup
echo [INFO] Создание директории резервных копий...
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%" 2>nul
    if %errorlevel% neq 0 (
        echo [ERROR] Не удалось создать директорию для резервных копий: %BACKUP_DIR%
        goto menu
    )
)

echo [INFO] Резервное копирование пользовательских файлов...
xcopy "%USERPROFILE%\Documents" "%BACKUP_DIR%\Documents" /E /H /C /I /Y >> "%LOG_FILE%" 2>&1
xcopy "%USERPROFILE%\Pictures" "%BACKUP_DIR%\Pictures" /E /H /C /I /Y >> "%LOG_FILE%" 2>&1
xcopy "%USERPROFILE%\Videos" "%BACKUP_DIR%\Videos" /E /H /C /I /Y >> "%LOG_FILE%" 2>&1
>> "%LOG_FILE%" echo BACKUP_FILES %TIME::=.%

echo [OK] Резервная копия сохранена в: %BACKUP_DIR%
goto menu

:: --- 6. ПОКАЗ ЛОГА ---
:view_log
echo [INFO] Отображение журнала...
if exist "%LOG_FILE%" (
    type "%LOG_FILE%"
) else (
    echo [WARNING] Файл лога не найден: %LOG_FILE%
)
echo.
>> "%LOG_FILE%" echo VIEW_LOG %TIME::=.%
pause
goto menu

:: --- 7. ПУТЬ К ЛОГУ ---
:what_log
echo Путь к логу: "%LOG_DIR%"
echo Полный путь к файлу: "%LOG_FILE%"
>> "%LOG_FILE%" echo WHAT_LOG_WAY %TIME::=.%
pause
goto menu

:: --- 8. УДАЛЕНИЕ ЛОГА ---
:clear_log
echo [WARNING] Вы собираетесь удалить файл лога!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

if exist "%LOG_FILE%" (
    del /f /q "%LOG_FILE%" >nul 2>&1
    if %errorlevel%==0 (
        echo [OK] Файл лога удалён.
        >> "%LOG_FILE%" echo LOG_CLEARED %TIME::=.%
    ) else (
        echo [ERROR] Не удалось удалить файл лога.
    )
) else (
    echo [INFO] Файл лога уже отсутствует.
)
pause
goto menu

:: --- 9. ДЕАКТИВАЦИЯ WINDOWS ---
:deactivation
echo [WARNING] Деактивация Windows приведёт к потере активации!
set /p confirm="Продолжить? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo [INFO] Деактивация...
slmgr /upk >nul 2>&1
slmgr /cpky >nul 2>&1

if %errorlevel%==0 (
    echo [OK] Windows деактивирована. Рекомендуется перезагрузить компьютер.
    >> "%LOG_FILE%" echo DEACTIVATION_WINDOWS %TIME::=.%
    set /p reboot="Перезагрузить компьютер сейчас? (Y/N): "
    if /i "%reboot%"=="Y" (
        shutdown /r /f /t 5 /c "Компьютер перезагрузится через 5 секунд для завершения деактивации."
    )
) else (
    echo [ERROR] Ошибка при деактивации. Код: %errorlevel%
)
pause
goto menu

:: --- 10. ОБНОВЛЕНИЕ ---
:update
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/damirus-papirus/WinTools/tree/main"
set "GITHUB_DOWNLOAD_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/WinTools.bat"
set "SOURCE_DIR=C:\Program Files\WinTools\Log"
set "TARGET_DIR=C:\Program Files\WinTools"

:: Get the latest version from GitHub
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

:: Error handling
if not defined GITHUB_VERSION (
    echo Предупреждение: не удалось загрузить последнюю версию. Это предупреждение не влияет на работу утилиты
    timeout /T 9
    if "%1"=="soft" exit
    goto menu
)

:: Version comparison
if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
echo Установлена последняя версия: %LOCAL_VERSION%
pause
) else (

echo Доступна новая версия: %GITHUB_VERSION%

set "CHOICE="
set /p "CHOICE=Вы хотите автоматически загрузить новую версию? (Y/N) "
if "%CHOICE%"=="" set "CHOICE=Y"
if /i "%CHOICE%"=="y" set "CHOICE=Y"

if /i "%CHOICE%"=="Y" (
    echo [INFO] Загрузка новой версии...
    powershell -command "Invoke-WebRequest -Uri '%GITHUB_DOWNLOAD_URL%' -OutFile '%TARGET_DIR%\WinTools_new.bat'" >nul 2>&1
    if %errorlevel%==0 (
        echo [SUCCESS] Новая версия загружена.
        move /y "%TARGET_DIR%\WinTools_new.bat" "%TARGET_DIR%\WinTools.bat" >nul 2>&1
        echo [INFO] Утилита обновлена до версии %GITHUB_VERSION%.
        >> "%LOG_FILE%" echo UPDATE_SUCCESS %TIME::=.% VERSION=%GITHUB_VERSION%
        echo Перезапустите скрипт для использования новой версии.
    ) else (
        echo [ERROR] Не удалось загрузить новую версию. Проверьте интернет‑соединение.
        >> "%LOG_FILE%" echo UPDATE_FAILED %TIME::=.%
    )
) else (
    echo [INFO] Обновление отменено.
)
pause
goto menu

:: --- 11. СМЕНА СТИЛЯ ---
:style
echo Выберите цветовую схему:
echo 1. Стандартный (белый текст на чёрном)
echo 2. Зелёный на чёрном
echo 3. Синий на чёрном
echo 4. Жёлтый на чёрном
echo 5. Сохранить текущую
set /p style_choice="Выберите опцию (1-5): "

if "%style_choice%"=="1" (
    color 07
    echo Цвет изменён на стандартный.
    echo >"%~dp0color_settings.txt" 07
)
if "%style_choice%"=="2" (
    color 0A
    echo Цвет изменён на зелёный.
    echo >"%~dp0color_settings.txt" 0A
)
if "%style_choice%"=="3" (
    color 09
    echo Цвет изменён на синий.
    echo >"%~dp0color_settings.txt" 09
)
if "%style_choice%"=="4" (
    color 0E
    echo Цвет изменён на жёлтый.
    echo >"%~dp0color_settings.txt" 0E
)
if "%style_choice%"=="5" (
    echo Текущая цветовая схема сохранена.
)
>> "%LOG_FILE%" echo STYLE_CHANGED %TIME::=.% CHOICE=%style_choice%
goto menu

:: --- 12. ПИНГ ---
:ping
set /p TARGET="Введите адрес для пинга (например, google.com): "
if "%TARGET%"=="" goto ping
echo.
echo Пинг до %TARGET%...
ping %TARGET%
pause
goto menu

:: --- 13. ОТЧЁТ О СИСТЕМЕ ---
:system_report
echo [INFO] Сбор информации о системе...
echo === SYSTEM REPORT === >> "%LOG_FILE%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Manufacturer" /C:"System Model" /C:"Total Physical Memory" >> "%LOG_FILE%" 2>nul
wmic cpu get name,NumberOfCores,NumberOfLogicalProcessors >> "%LOG_FILE%" 2>nul
echo REPORT_GENERATED %TIME::=.% >> "%LOG_FILE%"
echo Отчёт сохранён в лог.
pause
goto menu

:: --- 14. ОЧИСТКА КОРЗИНЫ ---
:empty_recyclebin
echo [INFO] Очистка корзины...
powershell -command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Корзина очищена.
    >> "%LOG_FILE%" echo EMPTY_RECYCLEBIN_SUCCESS %TIME::=.%
) else (
    echo [WARNING] Не удалось очистить корзину (возможно, она пуста).
)
pause
goto menu

:: --- 15. ТРАССИРОВКА МАРШРУТА ---
:tracert_tool
set /p TARGET="Введите адрес для трассировки (например, google.com): "
if "%TARGET%"=="" goto tracert_tool
echo.
echo Трассировка маршрута до %TARGET%...
tracert %TARGET%
pause
goto menu

:: --- 16. ПРОВЕРКА ОБНОВЛЕНИЙ WINDOWS ---
:check_updates
echo [INFO] Проверка обновлений Windows...
wuauclt.exe /detectnow >nul 2>&1
echo Запрошена проверка обновлений. Проверьте Центр обновления Windows.
>> "%LOG_FILE%" echo CHECK_UPDATES_REQUESTED %TIME::=.%
pause
goto menu

:: --- 17. СКАНИРОВАНИЕ WINDOWS DEFENDER ---
:defender_scan
if not exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (

echo [INFO] Запуск сканирования Windows Defender...
start "" "C:\Program Files\Windows Defender\MpCmdRun.exe" -Scan -ScanType 2
echo Запущено полное сканирование Defender.
>> "%LOG_FILE%" echo DEFENDER_SCAN_STARTED %TIME::=.%
pause
goto menu

:: --- 18. УПРАВЛЕНИЕ СЛУЖБАМИ ---
:manage_services
echo Выберите службу для управления:
echo 1. Отключить Superfetch
echo 2. Включить Superfetch
echo 3. Назад в меню
set /p svc_choice="Выберите опцию (1-3): "

if "%svc_choice%"=="1" (
    sc config SysMain start= disabled >nul 2>&1 && sc stop SysMain >nul 2>&1
    echo Superfetch отключён.
    >> "%LOG_FILE%" echo SUPERFETCH_DISABLED %TIME::=.%
)
if "%svc_choice%"=="2" (
    sc config SysMain start= auto >nul 2>&1 && sc start SysMain >nul 2>&1
    echo Superfetch включён.
    >> "%LOG_FILE%" echo SUPERFETCH_ENABLED %TIME::=.%
)
goto menu

:: --- 19. СОЗДАНИЕ ТОЧКИ ВОССТАНОВЛЕНИЯ ---
:create_restore_point
echo [INFO] Создание точки восстановления...
powershell -command "Enable-ComputerRestore -Drive 'C:\'; Checkpoint-Computer -Description 'WinTools Backup' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
if %errorlevel%==0 (
    echo Точка восстановления создана.
    >> "%LOG_FILE%" echo RESTORE_POINT_CREATED %TIME::=.%
) else (
    echo Ошибка создания точки восстановления.
)
pause
goto menu

:: --- 20. МОНИТОРИНГ ПРОЦЕССОВ ---
:process_monitor
echo Список запущенных процессов:
tasklist | findstr /I "chrome firefox explorer"
echo Для полного списка выполните tasklist в командной строке.
pause
goto menu


:: --- 21. ГЕНЕРАТОР ПАРОЛЕЙ С ВЫБОРОМ ДЛИНЫ ---
:password_generator
set "chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#@#$%^&*"

:get_length
set /p PASS_LENGTH="Введите длину пароля (рекомендуется 8-32 символа): "

:: Валидация ввода
if not defined PASS_LENGTH (
    echo Длина не может быть пустой. Попробуйте снова.
    goto get_length
)

:: Проверка, что введено число
echo %PASS_LENGTH%| findstr /R /C:"^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo Введите числовое значение. Попробуйте снова.
    goto get_length
)

:: Ограничение длины
if %PASS_LENGTH% LSS 1 (
    echo Минимальная длина — 1 символ. Попробуйте снова.
    goto get_length
)
if %PASS_LENGTH% GTR 128 (
    echo Максимальная длина — 128 символов. Попробуйте снова.
    goto get_length
)

:: Генерация пароля
setlocal enabledelayedexpansion
set "pass="
for /L %%i in (1,1,%PASS_LENGTH%) do (
    set /a "idx=!random! %% 70"
    for %%j in (!idx!) do set "pass=!pass!!chars:~%%j,1!"
)
echo Сгенерированный пароль: !pass!
endlocal

:: Копирование в буфер обмена (опционально)
set /p copy_choice="Скопировать пароль в буфер обмена? (Y/N): "
if /i "%copy_choice%"=="Y" (
    echo !pass!| clip
    echo Пароль скопирован в буфер обмена.
)

>> "%LOG_FILE%" echo PASSWORD_GENERATED LENGTH=%PASS_LENGTH% %TIME::=.%
pause
goto menu

:: --- 22. ВЫХОД ---
:exit_script
echo [INFO] Завершение работы WinTools...
echo ===========================
echo === WinTools Log ===
echo End: %TIMESTAMP%
echo User: %USERNAME%
echo Host: %COMPUTERNAME%
echo ---------------------------
echo.
echo Спасибо за использование WinTools!
timeout /t 3 /nobreak >nul
exit

:: --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---

:: Функция цветного вывода
:color_echo
set "text=%~2"
if "%~1"=="success" color 0A & echo [SUCCESS] %text% & color 07
if "%~1"=="error" color 0C & echo [ERROR] %text% & color 07
if "%~1"=="info" color 0B & echo [INFO] %text% & color 07
goto :eof

:: Проверка прав администратора
:check_admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :color_echo error "Запустите этот скрипт от имени администратора!"
    echo Check log: %LOG_FILE%
    pause
    exit /b 1
)
call :color_echo success "Права администратора подтверждены."
goto :eof

:: Создание директорий
:create_dirs
if not exist "%MAIN%" mkdir "%MAIN%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%" >nul 2>&1
goto :eof

:: Загрузка конфигурации
:load_config
if exist %CONFIG_FILE% (
    call %CONFIG_FILE% >nul 2>&1
) else (
    echo [WARNING] Конфигурационный файл не найден. Загрузка по умолчанию...
    powershell -command "Invoke-WebRequest -Uri '%GITHUB_DOWNLOAD_URL:WinTools.bat=config.bat%' -OutFile '%CONFIG_FILE%'" >nul 2>&1
    if exist %CONFIG_FILE% call %CONFIG_FILE% >nul 2>&1
)
goto :eof

:: Запись в лог
:write_log
>> "%LOG_FILE%" echo %*
goto :eof

:: Основной блок инициализации
:init
call :check_admin
call :create_dirs
call :load_config

:: Форматируем временную метку без спецсимволов
set "TIMESTAMP=%DATE% %TIME%"
set "TIMESTAMP=!TIMESTAMP:/=-%"
set "TIMESTAMP=!TIMESTAMP::=-%"
set "TIMESTAMP=!TIMESTAMP: =-%"

:: Записываем начало сессии в лог
>> "%LOG_FILE%" echo ===========================
>> "%LOG_FILE%" echo === WinTools Log ===
>> "%LOG_FILE%" echo Start: %TIMESTAMP%
>> "%LOG_FILE%" echo User: %USERNAME%
>> "%LOG_FILE%" echo Host: %COMPUTERNAME%
>> "%LOG_FILE%" echo ---------------------------
goto menu

:: Запуск инициализации при старте
call :init

:: Если скрипт запущен с аргументом, выполняем соответствующую функцию
if "%1" neq "" (
    goto %1
)

:: По умолчанию показываем меню
goto menu
