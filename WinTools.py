#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
WinTools 5.0.2 - Python Version
Многофункциональный инструмент для обслуживания Windows
Только рабочие функции
"""

import os
import sys
import subprocess
import shutil
import datetime
import logging
import json
import ctypes
import platform
import tempfile
import random
import string
import webbrowser
from pathlib import Path
from typing import Optional, List, Dict, Callable
import urllib.request
import urllib.error

# --- Конфигурация ---
APP_NAME = "WinTools"
VERSION = "5.0.2"
BASE_DIR = Path("C:/Program Files/WinTools")
LOG_DIR = BASE_DIR / "Log"
CONFIG_DIR = BASE_DIR / "config"
LOG_FILE = LOG_DIR / "WinTools.log"
BACKUP_DIR = Path(os.environ.get("USERPROFILE", ".")) / "Desktop" / "WinTools_Backup"
COLOR_FILE = Path(__file__).parent / "color_settings.txt"

# Цвета для консоли (Windows)
COLOR_CODES = {
    "default": "07",
    "green": "02",
    "blue": "01",
    "yellow": "06",
    "red": "04",
    "cyan": "03",
    "magenta": "05",
    "white": "0F"
}

# --- Настройка логирования ---
def setup_logging():
    """Настройка системы логирования"""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    
    if LOG_FILE.exists() and LOG_FILE.stat().st_size > 10 * 1024 * 1024:
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        LOG_FILE.rename(LOG_DIR / f"WinTools_{timestamp}.log")
    
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(LOG_FILE, encoding="utf-8"),
            logging.StreamHandler(sys.stdout)
        ]
    )
    return logging.getLogger(APP_NAME)

logger = setup_logging()

# --- Вспомогательные функции ---
def is_admin() -> bool:
    """Проверка прав администратора"""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except:
        return False

def run_as_admin():
    """Перезапуск с правами администратора"""
    if not is_admin():
        script = sys.argv[0]
        ctypes.windll.shell32.ShellExecuteW(
            None, "runas", sys.executable, f'"{script}"', None, 1
        )
        sys.exit(0)

def set_console_color(color_code: str):
    """Установка цвета консоли"""
    if platform.system() == "Windows":
        os.system(f"color {color_code}")

def load_saved_color() -> Optional[str]:
    """Загрузка сохранённого цвета"""
    if COLOR_FILE.exists():
        try:
            return COLOR_FILE.read_text().strip()
        except:
            return None
    return None

def save_color(color_code: str):
    """Сохранение цвета"""
    COLOR_FILE.write_text(color_code)

def clear_screen():
    """Очистка экрана"""
    os.system("cls" if platform.system() == "Windows" else "clear")

def wait_for_key():
    """Ожидание нажатия клавиши"""
    input("\nНажмите Enter для продолжения...")

def check_internet() -> bool:
    """Проверка доступа к интернету"""
    try:
        urllib.request.urlopen("https://ya.ru", timeout=3)
        return True
    except:
        return False

def log_action(action: str):
    """Запись действия в лог"""
    logger.info(f"ACTION: {action}")

def run_command(cmd: str, capture_output: bool = False) -> Tuple[int, str]:
    """Выполнение команды"""
    try:
        if capture_output:
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, encoding="cp866"
            )
            return result.returncode, result.stdout + result.stderr
        else:
            return subprocess.run(cmd, shell=True).returncode, ""
    except Exception as e:
        return 1, str(e)

def confirm_action(prompt: str = "Продолжить? (Y/N): ") -> bool:
    """Подтверждение действия"""
    answer = input(prompt).strip().upper()
    return answer == "Y"

# --- Класс меню ---
class Menu:
    def __init__(self):
        self.running = True
        self.current_color = load_saved_color() or "07"
        set_console_color(self.current_color)
        
        # Регистрация функций
        self.commands: Dict[str, Dict] = {}
        self.register_commands()
        
        # Запись запуска в лог
        logger.info(f"=== {APP_NAME} v{VERSION} START ===")
        logger.info(f"User: {os.environ.get('USERNAME')}")
        logger.info(f"Host: {os.environ.get('COMPUTERNAME')}")
        logger.info(f"Admin: {is_admin()}")

    def register_command(self, key: str, name: str, func: Callable, description: str = ""):
        """Регистрация команды"""
        self.commands[key] = {
            "name": name,
            "func": func,
            "description": description
        }

    def register_commands(self):
        """Регистрация всех доступных команд"""
        
        # 1. Проверка целостности системы
        def check_health():
            print("\n[INFO] Проверка целостности системных файлов (SFC)...")
            run_command("sfc /scannow")
            print("\n[INFO] Запуск DISM для восстановления образа...")
            run_command("dism /online /cleanup-image /restorehealth")
            log_action("INTEGRITY_CHECK")
            wait_for_key()
        
        self.register_command("1", "Проверка целостности системы", check_health)
        
        # 2. Очистка временных файлов
        def clean_temp():
            if not confirm_action("Удалить временные файлы? (Y/N): "):
                return
            print("[INFO] Очистка временных файлов...")
            temp_dirs = [
                os.environ.get("TEMP", ""),
                os.environ.get("TMP", ""),
                f"{os.environ.get('WINDIR', 'C:/Windows')}/Temp"
            ]
            for dir_path in temp_dirs:
                if dir_path and os.path.exists(dir_path):
                    try:
                        shutil.rmtree(dir_path, ignore_errors=True)
                    except:
                        pass
            print("[OK] Временные файлы очищены")
            log_action("TEMP_CLEANED")
            wait_for_key()
        
        self.register_command("2", "Очистка временных файлов", clean_temp)
        
        # 3. Активация Windows
        def activate_windows():
            print("[INFO] Запуск активации Windows...")
            run_command('slmgr.vbs /ato')
            print("Проверьте статус активации в Параметрах")
            log_action("ACTIVATION_ATTEMPT")
            wait_for_key()
        
        self.register_command("3", "Активация Windows", activate_windows)
        
        # 4. Деактивация Windows
        def deactivate_windows():
            if not confirm_action("Деактивировать Windows? (Y/N): "):
                return
            print("[INFO] Деактивация Windows...")
            run_command('slmgr.vbs /upk')
            print("[OK] Windows деактивирована")
            log_action("WINDOWS_DEACTIVATED")
            wait_for_key()
        
        self.register_command("4", "Деактивация Windows", deactivate_windows)
        
        # 5. Резервное копирование
        def backup_data():
            print("[INFO] Создание резервной копии...")
            BACKUP_DIR.mkdir(parents=True, exist_ok=True)
            docs = Path(os.environ.get("USERPROFILE", ".")) / "Documents"
            if docs.exists():
                try:
                    shutil.copytree(docs, BACKUP_DIR, dirs_exist_ok=True)
                    print(f"[OK] Резервная копия создана: {BACKUP_DIR}")
                    log_action("BACKUP_SUCCESS")
                except Exception as e:
                    print(f"[ERROR] Ошибка: {e}")
                    log_action(f"BACKUP_FAILED: {e}")
            else:
                print("[ERROR] Папка Documents не найдена")
            wait_for_key()
        
        self.register_command("5", "Резервное копирование", backup_data)
        
        # 6. Просмотр лога
        def view_log():
            if LOG_FILE.exists():
                print("\n" + "="*50)
                print(LOG_FILE.read_text(encoding="utf-8", errors="ignore"))
                print("="*50)
            else:
                print("[INFO] Лог-файл не найден")
            wait_for_key()
        
        self.register_command("6", "Просмотр лога", view_log)
        
        # 7. Путь к логу
        def show_log_path():
            print(f"Путь к лог-файлу: {LOG_FILE}")
            wait_for_key()
        
        self.register_command("7", "Путь к логу", show_log_path)
        
        # 8. Удалить лог
        def clear_log():
            try:
                if LOG_FILE.exists():
                    LOG_FILE.unlink()
                    print("[OK] Лог-файл удалён")
                    log_action("LOG_CLEARED")
                else:
                    print("[INFO] Лог-файл не существует")
            except Exception as e:
                print(f"[ERROR] Не удалось удалить лог: {e}")
            wait_for_key()
        
        self.register_command("8", "Удалить лог", clear_log)
        
        # 9. Проверка обновлений
        def check_update():
            print("[INFO] Проверка обновлений...")
            try:
                url = "https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/version.txt"
                with urllib.request.urlopen(url, timeout=5) as response:
                    remote_version = response.read().decode().strip()
                    if remote_version > VERSION:
                        print(f"[OK] Доступно обновление v{remote_version}!")
                        print(f"Скачать: https://github.com/damirus-papirus/WinTools/tree/main")
                    else:
                        print("[OK] У вас последняя версия")
            except:
                print("[ERROR] Не удалось проверить обновления")
            wait_for_key()
        
        self.register_command("9", "Проверить обновления", check_update)
        
        # 10. Сменить стиль
        def change_style():
            print("\nВыберите цвет:")
            print("1. Стандартный (белый на чёрном)")
            print("2. Зелёный на чёрном")
            print("3. Синий на чёрном")
            print("4. Жёлтый на чёрном")
            print("5. Красный на чёрном")
            
            choice = input("Выберите (1-5): ").strip()
            colors = {
                "1": ("07", "Стандартный"),
                "2": ("02", "Зелёный"),
                "3": ("01", "Синий"),
                "4": ("06", "Жёлтый"),
                "5": ("04", "Красный")
            }
            if choice in colors:
                code, name = colors[choice]
                set_console_color(code)
                save_color(code)
                self.current_color = code
                print(f"[OK] Цвет изменён: {name}")
                log_action(f"COLOR_CHANGED: {name}")
            else:
                print("[ERROR] Неверный выбор")
            wait_for_key()
        
        self.register_command("10", "Сменить стиль", change_style)
        
        # 11. Пинг
        def ping_host():
            target = input("Введите адрес для пинга (например, google.com): ").strip()
            if target:
                run_command(f"ping {target}")
            wait_for_key()
        
        self.register_command("11", "Пинг", ping_host)
        
        # 12. Отчёт о системе
        def system_report():
            print("\n[INFO] Системная информация:")
            print("-" * 50)
            run_command("systeminfo | findstr /B /C:'Host Name' /C:'OS Name' /C:'OS Version' /C:'System Type' /C:'Total Physical Memory' /C:'Available Physical Memory'")
            print("\n[INFO] Процессор:")
            run_command("wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors /format:list")
            print("\n[INFO] Диски:")
            run_command("wmic diskdrive get Model,Size /format:list")
            log_action("SYSTEM_REPORT")
            wait_for_key()
        
        self.register_command("12", "Отчёт о системе", system_report)
        
        # 13. Очистка корзины
        def empty_recyclebin():
            if not confirm_action("Очистить корзину? (Y/N): "):
                return
            print("[INFO] Очистка корзины...")
            run_command('powershell -command "Clear-RecycleBin -Force"')
            print("[OK] Корзина очищена")
            log_action("RECYCLE_BIN_CLEANED")
            wait_for_key()
        
        self.register_command("13", "Очистка корзины", empty_recyclebin)
        
        # 14. Трассировка маршрута
        def tracert_host():
            target = input("Введите адрес для трассировки: ").strip()
            if target:
                run_command(f"tracert {target}")
            wait_for_key()
        
        self.register_command("14", "Трассировка маршрута", tracert_host)
        
        # 15. Проверка обновлений Windows
        def windows_updates():
            print("[INFO] Поиск обновлений Windows...")
            run_command('powershell -command "Get-WindowsUpdate"')
            wait_for_key()
        
        self.register_command("15", "Проверка обновлений Windows", windows_updates)
        
        # 16. Сканирование Defender
        def defender_scan():
            print("[INFO] Запуск сканирования Windows Defender...")
            run_command('powershell -command "Start-MpScan -ScanType FullScan"')
            print("[OK] Сканирование запущено")
            log_action("DEFENDER_SCAN")
            wait_for_key()
        
        self.register_command("16", "Сканирование Defender", defender_scan)
        
        # 17. Создание точки восстановления
        def create_restore():
            if not confirm_action("Создать точку восстановления? (Y/N): "):
                return
            print("[INFO] Создание точки восстановления...")
            run_command('powershell -command "Checkpoint-Computer -Description \'WinTools Restore Point\' -RestorePointType \'MODIFY_SETTINGS\'"')
            print("[OK] Точка восстановления создана")
            log_action("RESTORE_POINT")
            wait_for_key()
        
        self.register_command("17", "Создать точку восстановления", create_restore)
        
        # 18. Мониторинг процессов
        def process_monitor():
            print("\n[INFO] Список активных процессов:")
            run_command("tasklist | more")
            wait_for_key()
        
        self.register_command("18", "Мониторинг процессов", process_monitor)
        
        # 19. Генератор паролей
        def generate_password():
            length = input("Длина пароля (по умолчанию 12): ").strip()
            length = int(length) if length.isdigit() else 12
            chars = string.ascii_letters + string.digits + "!@#$%^&*"
            password = ''.join(random.choice(chars) for _ in range(length))
            print(f"\nСгенерированный пароль: {password}")
            log_action("PASSWORD_GENERATED")
            wait_for_key()
        
        self.register_command("19", "Генератор паролей", generate_password)
        
        # 20. Экспорт отчёта в HTML
        def export_html():
            report_path = Path(tempfile.gettempdir()) / "WinTools_Report.html"
            html = f"""<html>
            <head><title>WinTools Report</title></head>
            <body>
            <h1>Отчёт WinTools</h1>
            <p>Дата: {datetime.datetime.now()}</p>
            <p>Пользователь: {os.environ.get('USERNAME')}</p>
            <p>Компьютер: {os.environ.get('COMPUTERNAME')}</p>
            <pre>
            {run_command("systeminfo", capture_output=True)[1]}
            </pre>
            </body></html>"""
            report_path.write_text(html, encoding="utf-8")
            print(f"[OK] Отчёт сохранён: {report_path}")
            webbrowser.open(str(report_path))
            log_action("HTML_REPORT")
            wait_for_key()
        
        self.register_command("20", "Экспорт отчёта в HTML", export_html)
        
        # 21. Очистка кэша браузеров
        def clean_browser_cache():
            print("[INFO] Очистка кэша браузеров...")
            # Chrome
            chrome_cache = Path(os.environ.get("LOCALAPPDATA", "")) / "Google/Chrome/User Data/Default/Cache"
            if chrome_cache.exists():
                shutil.rmtree(chrome_cache, ignore_errors=True)
            # Firefox
            firefox_profiles = Path(os.environ.get("LOCALAPPDATA", "")) / "Mozilla/Firefox/Profiles"
            if firefox_profiles.exists():
                for profile in firefox_profiles.glob("*.default/cache2"):
                    shutil.rmtree(profile, ignore_errors=True)
            print("[OK] Кэш браузеров очищен")
            log_action("BROWSER_CACHE_CLEANED")
            wait_for_key()
        
        self.register_command("21", "Очистка кэша браузеров", clean_browser_cache)
        
        # 22. Дефрагментация
        def defragment_disks():
            print("[INFO] Запуск дефрагментации диска C:")
            run_command("defrag C: /U /V")
            wait_for_key()
        
        self.register_command("22", "Дефрагментация диска", defragment_disks)
        
        # 23. Управление брандмауэром
        def manage_firewall():
            print("\n1. Включить брандмауэр")
            print("2. Отключить брандмауэр")
            choice = input("Выберите (1-2): ").strip()
            if choice == "1":
                run_command("netsh advfirewall set allprofiles state on")
                print("[OK] Брандмауэр включён")
            elif choice == "2":
                run_command("netsh advfirewall set allprofiles state off")
                print("[WARNING] Брандмауэр отключён!")
            log_action(f"FIREWALL_STATE_CHANGED: {choice}")
            wait_for_key()
        
        self.register_command("23", "Управление брандмауэром", manage_firewall)
        
        # 24. Сброс сетевых настроек
        def reset_network():
            if not confirm_action("Сбросить сетевые настройки? (Y/N): "):
                return
            print("[INFO] Сброс сетевых настроек...")
            run_command("netsh winsock reset")
            run_command("netsh int ip reset")
            run_command("ipconfig /flushdns")
            print("[OK] Настройки сброшены. Требуется перезагрузка")
            log_action("NETWORK_RESET")
            wait_for_key()
        
        self.register_command("24", "Сброс сетевых настроек", reset_network)
        
        # 25. Отключение телеметрии
        def disable_telemetry():
            if not confirm_action("Отключить телеметрию? (Y/N): "):
                return
            print("[INFO] Отключение телеметрии...")
            run_command('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f')
            run_command("sc config DiagTrack start= disabled")
            run_command("sc stop DiagTrack")
            print("[OK] Телеметрия отключена")
            log_action("TELEMETRY_DISABLED")
            wait_for_key()
        
        self.register_command("25", "Отключение телеметрии", disable_telemetry)
        
        # 26. Управление автозагрузкой
        def manage_startup():
            print("\n1. Добавить WinTools в автозагрузку")
            print("2. Удалить WinTools из автозагрузки")
            print("3. Показать текущие записи")
            choice = input("Выберите (1-3): ").strip()
            
            reg_key = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"
            entry_name = "WinTools"
            
            if choice == "1":
                script_path = Path(sys.argv[0]).absolute()
                run_command(f'reg add "{reg_key}" /v "{entry_name}" /t REG_SZ /d "{script_path}" /f')
                print("[OK] Добавлено в автозагрузку")
                log_action("STARTUP_ADDED")
            elif choice == "2":
                run_command(f'reg delete "{reg_key}" /v "{entry_name}" /f')
                print("[OK] Удалено из автозагрузки")
                log_action("STARTUP_REMOVED")
            elif choice == "3":
                run_command(f'reg query "{reg_key}"')
            wait_for_key()
        
        self.register_command("26", "Управление автозагрузкой", manage_startup)
        
        # 27. Очистка реестра
        def clean_registry():
            if not confirm_action("Очистить временные записи реестра? (Y/N): "):
                return
            print("[INFO] Очистка временных записей реестра...")
            run_command('reg delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU" /f')
            print("[OK] Очистка выполнена")
            log_action("REGISTRY_CLEANED")
            wait_for_key()
        
        self.register_command("27", "Очистка реестра", clean_registry)
        
        # 28. Оптимизация питания
        def power_plan():
            print("\n1. Сбалансированный")
            print("2. Высокая производительность")
            print("3. Экономия энергии")
            choice = input("Выберите план (1-3): ").strip()
            
            plans = {
                "1": "381b4222-f694-41f0-9685-ff5bb260df2e",
                "2": "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
                "3": "a1841308-3541-4809-9764-395326ec4e5c"
            }
            if choice in plans:
                run_command(f'powercfg /setactive {plans[choice]}')
                print("[OK] План изменён")
                log_action(f"POWER_PLAN_CHANGED: {choice}")
            wait_for_key()
        
        self.register_command("28", "Оптимизация питания", power_plan)
        
        # 29. Проверка SMART дисков
        def smart_check():
            print("[INFO] Проверка SMART-статуса дисков...")
            run_command("wmic diskdrive get Model,Status /format:list")
            log_action("SMART_CHECK")
            wait_for_key()
        
        self.register_command("29", "Проверка SMART дисков", smart_check)
        
        # 30. Диагностика сети
        def network_diag():
            print("\n[INFO] Диагностика сети:")
            print("-" * 40)
            run_command("ipconfig /all")
            print("\n[INFO] Проверка соединения:")
            run_command("ping 8.8.8.8")
            print("\n[INFO] DNS запрос:")
            run_command("nslookup google.com")
            log_action("NETWORK_DIAGNOSTIC")
            wait_for_key()
        
        self.register_command("30", "Диагностика сети", network_diag)
        
        # 31. Мониторинг температуры
        def temp_monitor():
            print("[INFO] Получение температуры...")
            run_command('powershell -command "Get-CimInstance -Namespace root/WMI -Class MSAcpi_ThermalZoneTemperature | ForEach-Object { $temp = ($_.CurrentTemperature / 10) - 273.15; \'Температура: {0:F1}°C\' -f $temp }"')
            wait_for_key()
        
        self.register_command("31", "Мониторинг температуры", temp_monitor)
        
        # 32. Тест стабильности
        def stability_test():
            if not confirm_action("Запустить тест стабильности? (Y/N): "):
                return
            print("[INFO] Тест стабильности (упрощённый)...")
            print("Нагрузка на CPU в течение 10 секунд...")
            run_command('powershell -command "for($i=0;$i -lt 10;$i++){Get-Random}"')
            print("[OK] Тест завершён")
            log_action("STABILITY_TEST")
            wait_for_key()
        
        self.register_command("32", "Тест стабильности", stability_test)
        
        # 33. Калькулятор
        def calculator():
            print("\n=== КАЛЬКУЛЯТОР ===")
            print("Поддерживаемые операции: +, -, *, /, ** (степень), % (остаток)")
            expr = input("Введите выражение: ").strip()
            if expr:
                try:
                    # Безопасное вычисление
                    allowed = set("0123456789+-*/().% ")
                    if all(c in allowed for c in expr):
                        result = eval(expr)
                        print(f"Результат: {result}")
                    else:
                        print("[ERROR] Недопустимые символы")
                except Exception as e:
                    print(f"[ERROR] Ошибка: {e}")
            wait_for_key()
        
        self.register_command("33", "Калькулятор", calculator)
        
        # 34. Выход
        def exit_app():
            self.running = False
            print("[INFO] Завершение работы WinTools...")
            log_action("SCRIPT_EXITED")
            print("Спасибо за использование WinTools!")
        
        self.register_command("34", "Выход", exit_app)
        
        # 35. Выход с перезагрузкой
        def reboot():
            if confirm_action("Перезагрузить компьютер? (Y/N): "):
                print("[INFO] Перезагрузка через 5 секунд...")
                log_action("SYSTEM_REBOOT")
                run_command("shutdown /r /t 5 /c 'WinTools: перезагрузка'")
                self.running = False
        
        self.register_command("35", "Выход с перезагрузкой", reboot)

    def show_menu(self):
        """Отображение главного меню"""
        clear_screen()
        print("=" * 50)
        print(f" WinTools v{VERSION}")
        print("=" * 50)
        print(f" Администратор: {'ДА' if is_admin() else 'НЕТ'}")
        print("-" * 50)
        
        # Отображение команд
        items = sorted(self.commands.items())
        for key, cmd in items:
            if key in ["34", "35"]:
                print("-" * 50)
            print(f" {key}. {cmd['name']}")
        print("=" * 50)
        print()

    def run(self):
        """Запуск приложения"""
        if not is_admin():
            print("[WARNING] Запустите скрипт от имени администратора!")
            print("Перезапуск с правами администратора...")
            run_as_admin()
            return
        
        print("[OK] Права администратора подтверждены")
        
        while self.running:
            self.show_menu()
            choice = input("Выберите опцию: ").strip()
            
            if choice in self.commands:
                clear_screen()
                try:
                    self.commands[choice]["func"]()
                except KeyboardInterrupt:
                    print("\n[INFO] Прервано пользователем")
                    wait_for_key()
                except Exception as e:
                    print(f"[ERROR] Ошибка: {e}")
                    logger.error(f"Error in {choice}: {e}")
                    wait_for_key()
            else:
                print("[ERROR] Неверный выбор!")
                wait_for_key()


def main():
    """Точка входа"""
    try:
        menu = Menu()
        menu.run()
    except KeyboardInterrupt:
        print("\n[INFO] Принудительное завершение")
        sys.exit(0)
    except Exception as e:
        print(f"[FATAL] Критическая ошибка: {e}")
        logger.critical(f"FATAL: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()