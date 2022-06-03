:: edge.bat
::
:: open MS Edge with the specified parameters
::
:: Edge does not support multiple input URLs at the same time, but it does open multiple tabs/windows easily
::
@echo off
:loop
if "%1" == "" GOTO :END
for %%I in ("%1") do call set URL=%%~fI
start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" %URL%
shift
GOTO :loop

:END
