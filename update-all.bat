:: update-all.bat
::
:: loops through every directory in the current directory,
:: if the current branch is the default branch then it just runs 'git pull' to update
:: if the branch is NOT the default one, then it switches to the default one, runs 'git pull' to update, then switches back
:: to use a default branch other than 'develop', pass it in

@echo off
setlocal enabledelayedexpansion

for /f "Tokens=*" %%G in ('dir /b /ad .') do call :update_develop %%G
goto :END

:update_develop
pushd "%1"
:: need to do this because otherwise the comparison to "" doesn't work
set isGitDirectory=
for %%I in (.) do set CurrDirName=%%~nxI
echo %CurrDirName%
for /F "usebackq delims=" %%D in (`git rev-parse --is-inside-work-tree 2^>nul`) DO SET isGitDirectory=%%D
:: if it's not a Git directory, no need to try and update
if "%isGitDirectory%"=="" (
    echo %CurrDirName% is not a Git directory
    popd
    echo.
    EXIT /B
)
:: if there are files that haven't yet been staged (git add) then it'll prevent a pull from working
git status -uno | find /i "Changes not staged" > nul
if not ERRORLEVEL 1 (
    echo Changes not staged text found, skipping %CurrDirName%
    popd
    exit /B
)
:: if there are files that haven't yet be committed (git add has happened, but git commit hasn't)
:: then it'll prevent a pull from working
git status -uno | find /i "Changes to be committed" > nul
if not ERRORLEVEL 1 (
    echo Changes to be committed text found, skipping %CurrDirName%
    popd
    exit /B
)

:: find the current branch so that we can switch to the default branch if needed
for /F "Tokens=*" %%B in ('git branch --show-current') DO SET CurrBranch=%%B
:: find the default branch so that we can switch to it if needed
for /F "Tokens=*" %%K in ('git remote show origin ^| sed -n '/HEAD branch/s/.*: //p') do set defaultBranch=%%K

:: if we're on the default branch already then it's easy to just pull
if "%CurrBranch%"=="%defaultBranch%" (
    echo %CurrDirName%: already on default branch %defaultBranch%
    git pull
) else (
    :: if the default branch is master, we'll update develop
    if "%defaultBranch%"=="master" (
        if "%CurrBranch%"=="develop" (
            echo %CurrDirName%: default is master, already on develop, updating develop
            git pull
        ) else (
            echo %CurrDirName%: default is master, updating develop
            git checkout develop && git pull && git checkout %CurrBranch%
        )
    ) else (
        :: chances are the default branch will be 'main'
        echo %CurrDirName%: need to switch to default branch %defaultBranch%
        git checkout %defaultBranch% && git pull && git checkout %CurrBranch%
    )
)
popd
echo.
EXIT /B

:END
endlocal
