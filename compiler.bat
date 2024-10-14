@echo off

set luajit64dir=%~dp0x64\
set luajit86dir=%~dp0x86\
set luajitexe=luajit.exe

set obfuscatorExe=%~dp0obfuscator\prometheus.exe
set protectorLuaScript=%~dp0protector\main.lua

chcp 1251 > nul

rem Выбор сервера
echo Выберите сервер привязки (не обязательно):
echo 1 - Молодая Гвардия
echo 2 - Вечный Зов
echo 3 - Наследие Богов
echo Введите номер (или оставьте пустым):
set /p serverChoice=

rem Преобразование выбора сервера в имя
set serverName=
if "%serverChoice%"=="1" set serverName=Молодая Гвардия
if "%serverChoice%"=="2" set serverName=Вечный Зов
if "%serverChoice%"=="3" set serverName=Наследие Богов

rem Проверка результата выбора сервера
echo Сервер: "%serverName%"

rem Ввод гильдии
echo Введите гильдию (не обязательно):
echo 1 - Рыцари Крови
echo Любое другое значение - ваша гильдия.
echo Можно оставить пустым.
set /p guildChoice=

rem Преобразование выбора гильдии
if "%guildChoice%"=="1" (
    set guildName=Рыцари Крови
) else (
    set guildName=%guildChoice%
)

rem Проверка результата ввода гильдии
echo Гильдия: "%guildName%"

rem Ввод даты окончания действия скрипта
echo Дата и время окончания срока действия скрипта (не обязательно, в формате ГГГГ-ММ-ДД ЧЧ:ММ:СС):
set /p availableUntilDate=

:loop
if "%~1"=="" goto end
	cd %~dp0

	rem Копия файла. Пускать на обработки будем копию - как входной и как выходной файл.
	set tmpFileName=%~dpn1.tmp.lua
	copy %~f1 %tmpFileName%

	rem Переход в директорию с 64-битным luajit
	cd %luajit64dir%
	
	rem Защита
    %luajitexe% %protectorLuaScript% "%tmpFileName%" --guild="%guildName%" --server="%serverName%" --until="%availableUntilDate%"
	
	rem Обфускация
	%obfuscatorExe% %tmpFileName% --out %tmpFileName%
	
	rem Компиляция для 64-битной версии
    %luajitexe% -b %tmpFileName% %~f1c.x64

    rem Компиляция для 32-битной версии
	cd %luajit86dir%
	%luajitexe% -b %tmpFileName% %~f1c.x86

	del %tmpFileName%
shift
goto loop
:end

pause
