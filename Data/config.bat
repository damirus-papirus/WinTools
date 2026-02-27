set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/Data/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/damirus-papirus/WinTools/tree/main"
set "GITHUB_DOWNLOAD_URL=https://raw.githubusercontent.com/damirus-papirus/WinTools/refs/heads/main/WinTools.bat"
set "SOURCE_DIR=C:\Program Files\WinTools\Log"
set "TARGET_DIR=C:\Program Files\WinTools"
powershell -command "Invoke-WebRequest -Uri '%GITHUB_DOWNLOAD_URL%' -OutFile '%SOURCE_DIR%\WinTools.bat'"
timeout /t 5
start "%TARGET_DIR%"\WinTools.bat
exit