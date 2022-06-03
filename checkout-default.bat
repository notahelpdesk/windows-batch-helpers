:: checkout-default.bat
::
:: switch to the default(ish) branch
::   if the default branch is master, it'll switch to develop
::   any other branch (main, develop), it'll switch to that
::
@echo off
setlocal

for /F "Tokens=*" %%B in ('git branch --show-current') DO SET CurrBranch=%%B
for /F "Tokens=*" %%K in ('git remote show origin ^| sed -n '/HEAD branch/s/.*: //p') do set defaultBranch=%%K

if "%defaultBranch%"=="master" (
    git checkout develop
) else (
    git checkout %defaultBranch%
)

:END
endlocal
