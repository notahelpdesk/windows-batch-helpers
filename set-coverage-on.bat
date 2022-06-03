:: set-coverage-on.bat
::
:: tell coverage.bat to open code coverage reports in Edge, but not unit tests

@echo off
set OpenReportsInEdge=true
set CreateUnitTestReport=false
set UseOpenCover=true