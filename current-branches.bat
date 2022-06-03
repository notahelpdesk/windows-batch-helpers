:: current-branches.bat
::
:: finds all directores in the current directory, then for each one:
::     says which directory it is,
::     changes into the directory,
::     displays the branches for that repo

@echo off
setlocal

for /f "Tokens=*" %%G in ('dir /b /ad .') do call :displayBranch %%G
goto :END

:displayBranch
pushd "%1"
for %%I in (.) do set CurrDirName=%%~nxI
echo %CurrDirName%
set isGitDirectory=
for /F "usebackq delims=" %%D in (`git rev-parse --is-inside-work-tree 2^>nul`) DO SET isGitDirectory=%%D
if "%isGitDirectory%"=="" (
    echo %CurrDirName% is not a Git directory
    popd
    echo.
    EXIT /B
)
git branch --show-current
popd
echo.
EXIT /B

:END
endlocal