@echo off
chcp 1251
echo ������ ����� ������� ������� �������� ��

sqlplus.exe system/manager@ICSE @CreateDB_8.sql

pause

