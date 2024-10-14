@echo off

set luajit64dir=%~dp0x64\
set luajit86dir=%~dp0x86\
set luajitexe=luajit.exe

set obfuscatorExe=%~dp0obfuscator\prometheus.exe
set protectorLuaScript=%~dp0protector\main.lua

chcp 1251 > nul

rem ����� �������
echo �������� ������ �������� (�� �����������):
echo 1 - ������� �������
echo 2 - ������ ���
echo 3 - �������� �����
echo ������� ����� (��� �������� ������):
set /p serverChoice=

rem �������������� ������ ������� � ���
set serverName=
if "%serverChoice%"=="1" set serverName=������� �������
if "%serverChoice%"=="2" set serverName=������ ���
if "%serverChoice%"=="3" set serverName=�������� �����

rem �������� ���������� ������ �������
echo ������: "%serverName%"

rem ���� �������
echo ������� ������� (�� �����������):
echo 1 - ������ �����
echo ����� ������ �������� - ���� �������.
echo ����� �������� ������.
set /p guildChoice=

rem �������������� ������ �������
if "%guildChoice%"=="1" (
    set guildName=������ �����
) else (
    set guildName=%guildChoice%
)

rem �������� ���������� ����� �������
echo �������: "%guildName%"

rem ���� ���� ��������� �������� �������
echo ���� � ����� ��������� ����� �������� ������� (�� �����������, � ������� ����-��-�� ��:��:��):
set /p availableUntilDate=

:loop
if "%~1"=="" goto end
	cd %~dp0

	rem ����� �����. ������� �� ��������� ����� ����� - ��� ������� � ��� �������� ����.
	set tmpFileName=%~dpn1.tmp.lua
	copy %~f1 %tmpFileName%

	rem ������� � ���������� � 64-������ luajit
	cd %luajit64dir%
	
	rem ������
    %luajitexe% %protectorLuaScript% "%tmpFileName%" --guild="%guildName%" --server="%serverName%" --until="%availableUntilDate%"
	
	rem ����������
	%obfuscatorExe% %tmpFileName% --out %tmpFileName%
	
	rem ���������� ��� 64-������ ������
    %luajitexe% -b %tmpFileName% %~f1c.x64

    rem ���������� ��� 32-������ ������
	cd %luajit86dir%
	%luajitexe% -b %tmpFileName% %~f1c.x86

	del %tmpFileName%
shift
goto loop
:end

pause
