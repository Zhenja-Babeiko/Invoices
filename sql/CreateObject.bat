@echo off
chcp 1251
echo ������ ����� ������� ������� �������� �������� ��

sqlplus.exe INVPAY/INVPAY @CreateObject.sql

pause
