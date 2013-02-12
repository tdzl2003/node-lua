@echo off
setlocal

set NODE_PATH=%~dp0

%NODE_PATH%\luajit.exe %NODE_PATH%\node\main.lua %*