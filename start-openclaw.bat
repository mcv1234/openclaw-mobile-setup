@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   OpenClaw SSH Tunnel
echo ========================================
echo.

REM Configuration - Modify these values
set SSH_KEY=C:\Users\YourUsername\.ssh\termux_tailscale
set LOCAL_PORT=18789
set REMOTE_PORT=8022
set USERNAME=u0_a328
set TOKEN=your_token_here

REM Prompt for phone IP (required)
echo Enter phone IP address:
set /p PHONE_IP="Phone IP: "
if "!PHONE_IP!"=="" (
    echo.
    echo ERROR: Phone IP is required!
    echo Please run the script again and enter a valid IP address.
    pause
    exit /b
)

echo.
echo Using configuration:
echo - Phone IP: !PHONE_IP!
echo - SSH Key: !SSH_KEY!
echo - Username: !USERNAME!
echo.

REM Stop existing SSH tunnels
echo Stopping existing SSH tunnels...
taskkill /F /IM ssh.exe >nul 2>&1
timeout /t 1 >nul

REM Start SSH tunnel
echo.
echo Starting SSH tunnel to phone at !PHONE_IP!...
start /B ssh -N -L !LOCAL_PORT!:127.0.0.1:!LOCAL_PORT! -p !REMOTE_PORT! -i "!SSH_KEY!" -o StrictHostKeyChecking=no !USERNAME!@!PHONE_IP!

echo.
echo Waiting for tunnel to be ready...
timeout /t 3 >nul

echo.
echo ========================================
echo   Opening OpenClaw in browser...
echo ========================================
echo.

REM Open browser with token
start http://127.0.0.1:!LOCAL_PORT!?token=!TOKEN!

echo.
echo ========================================
echo   Tunnel Status
echo ========================================
echo.
echo SSH tunnel is running in background.
echo Phone IP: !PHONE_IP!
echo.
echo OpenClaw URL: http://127.0.0.1:!LOCAL_PORT!?token=!TOKEN!
echo.
echo ========================================
echo   Tips
echo ========================================
echo.
echo To find your phone IP:
echo - In Termux: ip addr show wlan0 ^| grep 'inet '
echo - Or check your router's DHCP client list
echo.
echo Brave Search proxy is configured on the phone.
echo Edit ~/.proxy.conf in Ubuntu to change proxy settings.
echo.
echo Press any key to stop the tunnel when done...
pause >nul

echo.
echo Stopping SSH tunnel...
taskkill /F /IM ssh.exe >nul 2>&1
echo Tunnel stopped.
