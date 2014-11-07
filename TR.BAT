@echo off
tasm /zi  /l /c /m2 %1
if errorlevel 1 goto ert
tlink /v /m /i /l /s /n %1 
if errorlevel 1 goto erl
echo *********** Нормально !!!!!! *************
goto end
:ert
echo *********** Транслятор обнаружил ошибки !!!! **************
goto end
:erl
echo *********** Редактор связей обнаружил ошибки !!!! **************
:end
