:: get-all-remotes.bat
::
:: loops through all the directories in the current repo and finds the URL for the repo
:: if a directory isn't Git-enabled then this will recurse to find them
::
@echo off

setlocal ENABLEDELAYEDEXPANSION
set MAX_DEPTH=4

for /f "Tokens=*" %%G in ('dir /b /ad .') do call :displayBranch %%G 1
goto :END

:displayBranch
pushd "%1"
set DEPTH_COUNTER=%2
set CurrDirName=
set isGitDirectory=
set originUrl=
for %%I in (.) do set CurrDirName=%%~pnxI
if %DEPTH_COUNTER%==%MAX_DEPTH% (
    ::echo Reached max depth for %CurrDirName%
    popd
    EXIT /B
)
::echo %CurrDirName% %DEPTH_COUNTER%
for /F "usebackq delims=" %%D in (`git rev-parse --is-inside-work-tree 2^>nul`) DO SET isGitDirectory=%%D
if "%isGitDirectory%"=="" (
    ::echo %CurrDirName% is not a Git directory %DEPTH_COUNTER%
    set /A DEPTH_COUNTER=!DEPTH_COUNTER!+1
    for /f "Tokens=*" %%H in ('dir /b /ad .') do call :displayBranch %%H !DEPTH_COUNTER!
    popd
    set /A DEPTH_COUNTER=!DEPTH_COUNTER!-1
    EXIT /B
)
for /F "usebackq delims=" %%U in (`git remote get-url origin`) DO SET originUrl=%%U
echo "%CurrDirName%",%originUrl%
::echo %CurrDirName% is Git %DEPTH_COUNTER%
popd
EXIT /B

:END
endlocal