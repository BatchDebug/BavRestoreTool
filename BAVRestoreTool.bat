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
echo 4. Full Cleanup (BROKEN)
echo 5. Help
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto :restore_all
if "%choice%"=="2" goto :restore_individual
if "%choice%"=="3" goto :view_log
if "%choice%"=="4" goto :full_cleanup
if "%choice%"=="5" goto :help
if "%choice%"=="6" exit /b
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

:full_cleanup
cls
color 4F
echo ===============================================================================
echo WARNING: This tool may alter important system settings and registry entries.
echo It should only be used by experienced users or under guidance.
echo Running this tool incorrectly may lead to system issues.
echo ===============================================================================
set /p confirm="Are you sure you want to proceed? (Y/N): "
if /i not "%confirm%"=="Y" (
    goto :mainmenu
cls
color 07
echo Performing Full Cleanup...

:: Example cleanup tasks to remove old files, associations, and registry keys
echo Removing old context menu entries...
reg delete "HKEY_CLASSES_ROOT\*\shell\BatchAntivirus" /f >nul 2>&1 && (
    echo Removed Batch Antivirus context menu entry.
) || (
    echo No old context menu entry found.
)

echo Removing related registry keys...
for %%A in ("oldbatfile" "oldcmdfile" "oldexefile") do (
    reg delete "HKEY_CLASSES_ROOT\%%~A\shell\open\command" /f >nul 2>&1 && (
        echo Removed old association for '%%~A'.
    ) || (
        echo No old association found for '%%~A'.
    )
)

echo Checking for leftover files...
set "cleanup_dirs=%APPDATA%\BatchAntivirus %ProgramData%\BatchAntivirus %LOCALAPPDATA%\BatchAntivirus"
for %%D in (%cleanup_dirs%) do (
    if exist "%%D" (
        rmdir /s /q "%%D"
        echo Removed leftover files in '%%D'
    ) else (
        echo No leftover files found in '%%D'
    )
)

:: Ensure no services remain running
echo Stopping any related services...
net stop "BatchAntivirusService" /y >nul 2>&1 && (
    sc delete "BatchAntivirusService" >nul 2>&1
    echo Stopped and deleted Batch Antivirus service.
) || (
    echo No Batch Antivirus service found.
)

echo Cleanup completed. Returning to main menu.
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
