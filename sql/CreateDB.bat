@echo off
chcp 1251
echo Сейчас будет запущен процесс создания БД

sqlplus.exe system/manager@ICSE @CreateDB_8.sql

pause

