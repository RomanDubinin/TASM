@echo off
tasm /zi  /l /c /m2 %1.asm
if errorlevel 1 goto ert
tlink /v /m /i /l /s /n %1.obj
if errorlevel 1 goto erl
echo *********** 1 *************
goto end
:ert
echo *********** 2 **************
goto end
:erl
echo *********** 3 **************
:end
