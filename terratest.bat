:: terratest.bat
::
:: batch file tailored to running terratest inside a Docker container

@echo off
:: we need delayed expansion for the use case of no module name being specified
setlocal ENABLEDELAYEDEXPANSION
:: we want the full path to the directory we're starting in
for /f %%i in ("%0") do set startDir=%%~dpi
for %%i in (.) do set currDirName=%%~nxi

:: get the name of the module from the parameters
set module_name=%1
:: if the module name wasn't specified, base it on the name of the directory we're in
if "%module_name%" == "" (
	echo No module name specified. Working it out
	set module_name=%currDirName%
	:: using !module_name! with delayed expansion means this is the value set in the line above
	echo Using '!module_name!' for module name
)

if not exist "%startDir%test_output" (
	:: if the directory doesn't exist, create it
	echo test_output does not exist, creating...
	md test_output
) else (
	:: if the directory does exist, remove it and recreate it
	echo Emptying current test_output directory
  	rd /s /q "%startDir%test_output"
	md test_output
)

set RENAMED_INTEGRATION_FILE=false
if "%TERRATEST_RUN_INTEGRATION_TESTS%" NEQ "true" (
	if exist "%startDir%\test\integration_test.go" (
		set RENAMED_INTEGRATION_FILE=true
		pushd "%startDir%\test"
		rename integration_test.go integration.go
		popd
	)
)
set RENAMED_UNIT_FILE=false
if "%TERRATEST_RUN_UNIT_TESTS%" == "false" (
	if exist "%startDir%\test\unit_test.go" (
		set RENAMED_UNIT_FILE=true
		pushd "%startDir%\test"
		rename unit_test.go unit.go
		popd
	)
)

:: build the container - skipping this can cause issues
docker build -t module-test:latest . --build-arg=ARG_MODULE_NAME=%module_name%
:: run the tests
docker run ^
--rm ^
-e ARM_CLIENT_ID=%ARM_CLIENT_ID% ^
-e AZURE_CLIENT_ID=%ARM_CLIENT_ID% ^
-e ARM_CLIENT_SECRET=%ARM_CLIENT_SECRET% ^
-e AZURE_CLIENT_SECRET=%ARM_CLIENT_SECRET% ^
-e ARM_SUBSCRIPTION_ID=%ARM_SUBSCRIPTION_ID% ^
-e AZURE_SUBSCRIPTION_ID=%ARM_SUBSCRIPTION_ID% ^
-e ARM_TENANT_ID=%ARM_TENANT_ID% ^
-e AZURE_TENANT_ID=%ARM_TENANT_ID% ^
-v %startDir%test_output:/go/src/%module_name%/test_output ^
module-test:latest

:END

if "%RENAMED_INTEGRATION_FILE%" == "true" (
	pushd "%startDir%\test"
	rename integration.go integration_test.go
	popd
)

if "%RENAMED_UNIT_FILE%" == "true" (
	pushd "%startDir%\test"
	rename unit.go unit_test.go
	popd
)

if "%TERRATEST_OPEN_OUTPUTS_DIR%" == "true" (
	if exist "%startDir%test_output\" (
		echo Opening directory "%startDir%test_output\"
		explorer "%startDir%test_output\"
	)
)

if "%TERRATEST_SHOW_RESULTS_IN_EDGE%" == "true" (
	if exist "%startDir%test_output\report.xml" (
		echo Generating HTML report and opening in Edge
		xunit-viewer -r test_output\report.xml && edge index.html
	) else (
		echo Cannot generate HTML report because XML file missing
	)
)

endlocal