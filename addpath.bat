:: 
:: I don't take any credit for this one, I just find it really helpful
:: source can be found here: https://gist.github.com/scheib/582036
::
@echo off
call :GOSUB__IS_A_DIR %1
if errorlevel 1 goto ERROR_not_found

set path_backup=%path%
set path=%1;%path%

echo Updated path. Backed up old path to path_backup.
goto END

:==ERROR_not_found
echo.
echo. Could not find directory:
echo. %1
echo. 
echo. doing nothing.
echo.
goto END

:==GOSUB__IS_A_DIR 
REM INPUT %1
REM OUTPUT errorlevel == 1 if input is not a dir
if (%1)==() exit /b 1
pushd "%~1" 2> nul
if errorlevel 1 exit /b 1
popd
exit /b 0

:END