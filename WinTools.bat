@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title WinTools 3.2.4

:: --- НАСТРОЙКИ ---
set "LOG_DIR=C:\Program Files\WinTools\Log"
if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)
set "LOG_FILE=%LOG_DIR%\WinTools.log"
set "BACKUP_DIR=%USERPROFILE%\Desktop\WinTools_Backup"
set "LOCAL_VERSION=3.3.4"

:: Форматируем временную метку без спецсимволов
set "TIMESTAMP=%DATE% %TIME%"
set "TIMESTAMP=!TIMESTAMP:/=-%"
set "TIMESTAMP=!TIMESTAMP::=-%"
set "TIMESTAMP=!TIMESTAMP: =-%"

:: --- ЗАГОЛОВОК И ЛОГ ---
>> "%LOG_FILE%" echo ===========================
>> "%LOG_FILE%" echo === WinTools Beta Log ===
>> "%LOG_FILE%" echo Start: %TIMESTAMP%
>> "%LOG_FILE%" echo User: %USERNAME%
>> "%LOG_FILE%" echo Host: %COMPUTERNAME%
>> "%LOG_FILE%" echo ---------------------------
echo WinTools v3.2.4
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

:: --- ГЛАВНОЕ МЕНЮ ---
:menu
echo.
echo === MAIN MENU ===
echo 1. Проверить целостность системы (SFC/DISM)
echo 2. Очистить кэш
echo 3. Сброс настроек хранилища лицензий (tokens.dat)
echo 4. Активация Windows
echo 5. Резервное копирование важных данных
echo 6. Просмотр лога
echo 7. Путь к логу
echo 8. Удалить лог
echo 9. Деактивация Window
echo 10. Проверить и обновить утилиту
echo 11. Пинг
echo 12. Выход
echo.
set /p choice="Выберите опцию (1-12): "

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
if "%choice%"=="11" goto ping
if "%choice%"=="12" goto exit_script
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

:: Get the latest version from GitHub
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

:: Error handling
if not defined GITHUB_VERSION (
    echo Warning: failed to fetch the latest version. This warning does not affect the operation of zapret
    timeout /T 9
    if "%1"=="soft" exit 
    goto menu
)

:: Version comparison
if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
    echo Latest version installed: %LOCAL_VERSION%
    
    if "%1"=="soft" exit 
    pause
    goto menu
) 

echo New version available: %GITHUB_VERSION%
echo Release page: %GITHUB_RELEASE_URL%

set "CHOICE="
set /p "CHOICE=Do you want to automatically download the new version? (Y/N) "
if "%CHOICE%"=="" set "CHOICE=Y"
if /i "%CHOICE%"=="y" set "CHOICE=Y"

if /i "%CHOICE%"=="Y" (
powershell -command "Invoke-WebRequest -Uri '%GITHUB_DOWNLOAD_URL%' -OutFile '%USERPROFILE%\Desktop\WinTools.bat'"
echo Новая версия была установлена на рабочий стол. Замените старую версию на только что скачанную.
)
set "SOURCE_DIR=C:\Desktop"
set "TARGET_DIR=C:\Program Files\WinTools"


>> "%LOG_FILE%" echo UPDATE_START %TIME::=.%

echo [INFO] Проверка наличия обновлений...
if not exist "%SOURCE_DIR%\WinTools.bat" (
    echo [ERROR] Файл обновления не найден: %SOURCE_DIR%\WinTools.bat
    goto menu
)

echo [INFO] Копирование обновлённой версии...
robocopy "%SOURCE_DIR%" "%TARGET_DIR%" "WinTools.bat" /R:3 /W:1 /NFL /NDL /NP >> "%LOG_FILE%" 2>&1

if %errorlevel% leq 3 (
    echo [OK] Обновление успешно установлено.
    >> "%LOG_FILE%" echo UPDATE_SUCCESS %TIME::=.%
    del %SOURCE_DIR%\WinTools.bat 
) else (
    echo [ERROR] Ошибка при обновлении. Код robocopy: %errorlevel%
    >> "%LOG_FILE%" echo UPDATE_FAILED %TIME::=.% ERROR=%errorlevel%
)

pause
goto menu

:: --- 11. ПИНГ ---
:ping
set /p HOST="Введите адрес сайта или IP (например, www.google.com или 216.239.38.120): "

if "%HOST%"=="" (
    echo Вы ничего не ввели!
    pause
    goto menu
)

echo.
echo Замер пинга до %HOST%...
echo ---------------------------
ping %HOST% -n 4


echo.
set /p show_details="Показать расширенную статистику? (Y/N): "
if /i "%show_details%"=="Y" ping %HOST% -n 10

pause
goto menu

:: --- 12. ВЫХОД ---
:exit_script
echo [INFO] Выход. Журнал сохранён в: %LOG_FILE%
>> "%LOG_FILE%" echo EXIT %TIME::=.%
echo ======================================
pause
exit /b 0
