@echo off
tasm /zi  /l /c /m2 %1
if errorlevel 1 goto ert
tlink /v /m /i /l /s /n /t %1 
if errorlevel 1 goto erl
echo *********** ��ଠ�쭮 !!!!!! *************
goto end
:ert
echo *********** �࠭���� �����㦨� �訡�� !!!! **************
goto end
:erl
echo *********** ������� �痢� �����㦨� �訡�� !!!! **************
:end
