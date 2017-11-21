@echo off
set DIR=%~dp0
set SIMULATOR_RELEASE_FOLDER=%DIR%\..\simulator\win32
set TARGET_FOLDER=%DIR%\bin
::del /a /f /s /q %TARGET_FOLDER%\

xcopy %SIMULATOR_RELEASE_FOLDER%\*.exe %TARGET_FOLDER% /S /F /R /Y /E /D
xcopy %SIMULATOR_RELEASE_FOLDER%\*.dll %TARGET_FOLDER% /S /F /R /Y /E /D