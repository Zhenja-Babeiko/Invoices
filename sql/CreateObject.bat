@echo off
chcp 1251
echo Сейчас будет запущен процесс создания объектов БД

sqlplus.exe INVPAY/INVPAY @CreateObject.sql

pause
