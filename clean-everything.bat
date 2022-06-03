:: clean-everything.bat
::
:: The purpose of this is to remove everything that could be generated by building the project
:: This is a heavier version of clean.bat as it removes packages downloading by things like nuget and npm too
::
@echo off
setlocal ENABLEDELAYEDEXPANSION

if NOT "%1" == "" (
    pushd %1
    set dirPushed=true
)

call :removeDirectory bin
call :removeDirectory obj
call :removeDirectory node_modules
call :removeDirectory packages
call :removeDirectory .terraform
call :removeDirectory .vs
call :removeDirectory Reports

if "!dirPushed!" == "true" (
    popd
)
goto :END

:removeDirectory
set dirFound=false
for /f "Tokens=* Usebackq" %%F  IN (`dir /s /b /ad %1 2^>nul`) DO SET dirFound=true
if "!dirFound!"=="true" (
    for /f "Tokens=*" %%G IN ('dir /s /b /ad %1') do (
        ::echo Removing %%G
        rd /s /q %%G
    )
    if exist %1 rd /q %1
)

:END
endlocal