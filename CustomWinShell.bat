@echo off
:: Version 1.0 - Initial release
>nul chcp 65001
title Command Prompt Customisation - he3als
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell -NoProfile Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
		echo The self-elevation failed, there might be an issue with PowerShell?
        pause & exit 1
    )
    exit 0
)

:: --------------------------------
:: Settings
:: --------------------------------

:: Colours for prompt
:: Format is RGB, you need to format it like r;g;b

:: Darkest red - used for the brackets
set darkestred=191;97;106
:: Red-ish orange - used for the characters to 'join' the two prompts
set redorange=208;135;112
:: Purple - for the actual prompt $
set purple=180;142;173

:: Misc

:: Sets the join between the two lines to not be rounded
:: Makes aliasing issue (with unicode box drawing characters) better on Windows Terminal if it is not rounded
set rounded=true
:: Set the prompt for all users
set allusers=true

:: --------------------------------
:: Script
:: --------------------------------

:: Do not touch anything below
set join1=╭
set join2=╰
if %rounded%==false (
	set join1=┌
	set join2=└
)
:: For janky error detection of multiple commands...
:: It works... at least...
set error1=1
set error2=1
set error3=1

:: The prompt for CMD
:: If you know what you are doing, you can change this to your liking
:: https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
:: https://ss64.com/nt/prompt.html
set cmdprompt=$E[38;2;208;135;112m$E[1m%join1%╴$E[0m$E[38;2;%darkestred%m$E[1m[$E[0m$S$T$S$E[38;2;191;97;106m$E[1m]$E[0m$S$E[38;2;191;97;106m$E[1m[$E[0m$S$D$S$E[38;2;191;97;106m$E[1m]$E[0m$_$E[38;2;%redorange%m$E[1m%join2%╴$E[0m$P $E[38;2;%purple%m$E[1m$$$E[0m 

:: Credit to Mathieu#4291 - I tried to do this but I am not that good at batch scripting so it was messy and didn't work well. Thank you so much for your help!
:: Checks if the user is on Windows 10 1903 or below
set 1903_or_below=true
for /f "tokens=4-6delims=. " %%A in ('ver') do (
    if "%%A.%%B"=="10.0" (
        if not "%%C"=="" (
            if %%C gtr 18362 (
                set 1903_or_below=false
            )
        )
    )
)
if %1903_or_below%==false (goto main) else (goto ansicolors_old)

:main
cls
color 0b
mode con:cols=111 lines=27
echo Welcome! This script applies a customised Command Prompt with the time, date, directory and better aestethics.
echo What would you like to do?
echo ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo 1) Apply the customised prompt
echo 2) Revert to the regular command prompt
echo]
echo 3) Customised colour pallet
echo 4) Configure the script
echo 5) Goto the GitHub
echo 6) Test out the prompt
echo 7) Exit
echo]
CHOICE /N /C:1234567 /M "Please input your answer ->"
if %ERRORLEVEL%==1 goto customprompt
if %ERRORLEVEL%==2 goto revertcustomprompt
if %ERRORLEVEL%==3 goto colours
if %ERRORLEVEL%==4 notepad %~f0 && goto main
IF %ERRORLEVEL%==5 start "" "https://github.com/he3als/CMD-Customisation" && goto main
IF %ERRORLEVEL%==6 goto test
IF %ERRORLEVEL%==7 exit /b

:customprompt
cls
echo This will apply the prompt.
echo Waiting 5 seconds, then you can continue...
timeout /t 5 /nobreak > nul
pause
if %allusers%==true (
	reg add "HKCU\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "PROMPT" /t REG_SZ /d "%cmdprompt%" /f > nul
) else (
	reg add "HKCU\Environment" /v "PROMPT" /t REG_SZ /d "%cmdprompt%" /f > nul
)
if %errorlevel%==0 (goto custompromptfinish) else (goto custompromptfail)
:custompromptfinish
echo]
echo Done, restart all of your Command Prompt windows.
echo What would you like to do?
echo]
echo 1^) Goto the main menu
echo 2^) Exit
choice /n /c:12 /m "Input your answer ->"
if %errorlevel%==1 goto main
if %errorlevel%==2 exit /b
:custompromptfail
echo]
echo Something went wrong whilst setting the PROMPT environment variable.
pause
exit /b
	
:revertcustomprompt
cls
echo This will revert the prompt back to default.
echo Waiting 3 seconds, then you can continue...
timeout /t 3 /nobreak > nul
pause
reg query "HKCU\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" >nul 2>&1 | findstr prompt >nul 2>&1
if %errorlevel%==0 (reg delete "HKCU\SOFTWARE\Microsoft\Command Processor" /f /v "AutoRun" && set error1=0)
reg delete "HKCU\Environment" /f /v "PROMPT" >nul 2>&1
if %errorlevel%==0 (set error2=0)
reg delete "HKCU\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f /v "PROMPT" >nul 2>&1
if %errorlevel%==0 (set error3=0)
set all_errors=%error1% %error2% %error3%
:: If all of commands above error out, then fail, else goto the finish (probably a better way of doing this but idk)
if "%all_errors%"=="1 1 1" (goto revertcustompromptfail) else (goto revertcustompromptfinish)
:revertcustompromptfinish
echo]
echo Done, restart all of your Command Prompt windows.
echo What would you like to do?
echo]
echo 1^) Goto the main menu
echo 2^) Exit
choice /n /c:12 /m "Input your answer ->"
if %errorlevel%==1 goto main
if %errorlevel%==2 exit /b
:revertcustompromptfail
echo]
echo Something went wrong whilst deleting the PROMPT environment variable for the current user.
echo You might of never had the prompt in the first place?
pause
exit /b

:test
cls
prompt %cmdprompt%
@echo on
echo This is a command!
echo This is another command!
@echo off
pause
goto main

:ansicolors_old
cls
reg query HKCU\Console /v "VirtualTerminalLevel" >nul 2>&1
if %errorlevel%==0 goto main
echo It seems like you are on Windows 10 1903 and below.
echo You need to make a registry change to properly display colours in Console Host.
echo https://ss64.com/nt/syntax-ansi.html
echo]
choice /n /c:yn /m "Would you like to do that now? [Y/N] "
if %errorlevel%==2 exit
reg add "HKCU\Console" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /f > nul
if %errorlevel%==0 (
	echo Completed successfully.
	pause
	start %~f0 && exit /b
) else (
	echo Something failed applying the registry change! 
	pause
	exit /b
)

:colours
cls
echo You can use custom colour schemes by using ColorTool and iTerm themes.
echo I would recommend using the Nord theme with this prompt.
echo Use the 'Find' tool in your web browser on the iTerm themes website to find themes.
echo]
echo 1) Visit the ColourTool page
echo 2) Visit the iTerm themes page
echo 3) Goto the main menu
choice /n /c:123 /m "What would you like to do? ->"
if %errorlevel%==1 start "" "https://github.com/Microsoft/Terminal/tree/main/src/tools/ColorTool" && goto colours
if %errorlevel%==2 start "" "https://iterm2colorschemes.com/" && goto colours
if %errorlevel%==3 goto main