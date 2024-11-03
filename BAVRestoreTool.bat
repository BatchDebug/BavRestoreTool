@echo off
title BAVRestoreTool by BatchDebug (originally BavRemoveIntercept by Jo8ujethoia)
setlocal enabledelayedexpansion

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Please run this program as an administrator.
    pause
    exit /b
)

color 07

:mainmenu
cls
echo ================================
echo          BAVRestoreTool         
echo   Made with love by BatchDebug  
echo ================================
echo.
echo Please choose an option:
echo.
echo 1. Restore all file associations
echo 2. Restore individual file associations
echo 3. View restoration log
echo 4. Help
echo 5. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto :restore_all
if "%choice%"=="2" goto :restore_individual
if "%choice%"=="3" goto :view_log
if "%choice%"=="4" goto :help
if "%choice%"=="5" exit /b
goto :mainmenu

:restore_all
cls
echo Restoring all file associations...

set "logfile=%~dp0restore_log.txt"
echo Restoration Log - %date% %time% >> "%logfile%"
echo ============================== >> "%logfile%"

for %%A in ("batfile" "cmdfile" "exefile" "VBSFile" "VBEfile" "JSFile" "JSEfile" "comfile" "mscfile" "WSFFile" "WSHFile") do (
    if exist "%~dp0RegBackup\%%~A_backup.reg" (
        reg import "%~dp0RegBackup\%%~A_backup.reg" >nul 2>&1
        if %errorLevel%==0 (
            echo Successfully restored '%%~A' >> "%logfile%"
            echo Successfully restored '%%~A'
        ) else (
            echo Failed to restore '%%~A' >> "%logfile%"
            echo Failed to restore '%%~A'
        )
    ) else (
        echo No backup found for '%%~A'. Skipping. >> "%logfile%"
        echo No backup found for '%%~A'. Skipping.
    )
)

:: Restore context menu if backup exists
if exist "%~dp0RegBackup\shell_backup.reg" (
    reg import "%~dp0RegBackup\shell_backup.reg" >nul 2>&1
    if %errorLevel%==0 (
        echo Successfully restored context menu backup. >> "%logfile%"
        echo Successfully restored context menu backup.
    ) else (
        echo Failed to restore context menu backup. >> "%logfile%"
        echo Failed to restore context menu backup.
    )
) else (
    echo No context menu backup found. >> "%logfile%"
    echo No context menu backup found.
)

echo.
echo Restoration completed. Please check the log for details.
pause
goto :mainmenu

:restore_individual
cls
echo Select file type to restore:
echo.
echo 1. .bat (batfile)
echo 2. .cmd (cmdfile)
echo 3. .exe (exefile)
echo 4. .vbs (VBSFile)
echo 5. .vbe (VBEfile)
echo 6. .js (JSFile)
echo 7. .jse (JSEfile)
echo 8. .com (comfile)
echo 9. .msc (mscfile)
echo 10. .wsf (WSFFile)
echo 11. .wsh (WSHFile)
echo 12. Return to Main Menu
echo.
set /p filetype="Choose a file type to restore (1-12): "

:: Define the file type based on user input
set "fileext="
if "%filetype%"=="1" set "fileext=batfile"
if "%filetype%"=="2" set "fileext=cmdfile"
if "%filetype%"=="3" set "fileext=exefile"
if "%filetype%"=="4" set "fileext=VBSFile"
if "%filetype%"=="5" set "fileext=VBEfile"
if "%filetype%"=="6" set "fileext=JSFile"
if "%filetype%"=="7" set "fileext=JSEfile"
if "%filetype%"=="8" set "fileext=comfile"
if "%filetype%"=="9" set "fileext=mscfile"
if "%filetype%"=="10" set "fileext=WSFFile"
if "%filetype%"=="11" set "fileext=WSHFile"
if "%filetype%"=="12" goto :mainmenu

if defined fileext (
    cls
    echo Restoring backup for '%fileext%'...
    if exist "%~dp0RegBackup\%fileext%_backup.reg" (
        reg import "%~dp0RegBackup\%fileext%_backup.reg" >nul 2>&1
        if %errorLevel%==0 (
            echo Successfully restored '%fileext%'.
        ) else (
            echo Failed to restore '%fileext%'. Please check the backup file.
        )
    ) else (
        echo No backup found for '%fileext%'. Skipping.
    )
    pause
) else (
    echo Invalid choice. Returning to menu.
    pause
)
goto :mainmenu

:view_log
cls
echo Viewing Restoration Log:
echo ============================
if exist "%~dp0restore_log.txt" (
    type "%~dp0restore_log.txt"
) else (
    echo No restoration log found.
)
echo.
pause
goto :mainmenu

:help
cls
echo ================================
echo        Help - BAV Restore Tool
echo ================================
echo.
echo This tool allows you to restore file associations modified by BAV.
echo Options include:
echo - Restoring all associations at once
echo - Restoring individual file types
echo - Viewing the restoration log for details
echo - Full Cleanup to remove any remaining files, services, and associations
echo - Exiting at any menu level
echo.
echo Note: Running as Administrator is required.
echo.
pause
goto :mainmenu
