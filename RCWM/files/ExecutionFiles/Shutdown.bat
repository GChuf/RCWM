@echo off
setlocal

rem The valid range is 0-315360000 (10 years)

:input
set /p seconds=Seconds before shutdown (0-315360000): 

for /f "delims=0123456789" %%A in ("%seconds%") do (
    echo Invalid input
    goto input
)

if %seconds% GTR 315360000 (
    echo Input a lower number.
    goto input
)

echo Shutting down in %seconds% seconds.
shutdown /s /t %seconds%

endlocal
pause