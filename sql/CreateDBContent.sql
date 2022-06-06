connect INVPAY/INVPAY

prompt ... Создание таблиц...
@@ DICT_MONTH.sql
@@ DICT_PROG.sql
@@ DICT_PROG_POINT.sql
@@ INVOICE.sql
@@ INVOICE_PROG_POINT.sql
@@ DICT_ROLE.sql
@@ USERS.sql

prompt ... Вставка данных...
@@ expdata.sql
COMMIT;

prompt ... Создание объектов БД ...
@@ CreateObject.sql
prompt ...............................................