@echo off
rem Adds "Smash Hit VR" to Steam and SteamVR, with artwork made from your game.apk.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0add-to-steam.ps1" %*
pause
