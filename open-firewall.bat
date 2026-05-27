@echo off
:: Запрашивает права администратора и открывает порт 7654
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
netsh advfirewall firewall add rule name="Portfolio v6 dev" dir=in action=allow protocol=TCP localport=7654
echo.
echo Port 7654 opened. Press any key to close.
pause >nul


