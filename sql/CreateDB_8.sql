spool .\LOG\CreateDB.log;

prompt ... Создание пользователей БД...
@@ CreateUser.sql
prompt ...............................................

@@ CreateDBContent.sql

spool off;

exit