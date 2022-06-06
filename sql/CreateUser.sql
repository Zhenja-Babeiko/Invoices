CREATE USER INVPAY IDENTIFIED BY INVPAY DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE temp PROFILE DEFAULT;
GRANT CONNECT TO INVPAY;
GRANT RESOURCE TO INVPAY;

GRANT UNLIMITED TABLESPACE TO INVPAY;
GRANT SELECT ANY DICTIONARY TO INVPAY;
GRANT SELECT ANY TABLE TO INVPAY;
GRANT INSERT ANY TABLE TO INVPAY;
GRANT UPDATE ANY TABLE TO INVPAY;
GRANT CREATE ANY TABLE TO INVPAY;
GRANT DROP ANY TABLE TO INVPAY;
GRANT DELETE ANY TABLE TO INVPAY;
GRANT ALTER ANY TABLE TO INVPAY;
GRANT COMMENT ANY TABLE TO INVPAY;
GRANT CREATE ANY INDEX TO INVPAY;
GRANT CREATE ANY VIEW TO INVPAY;
GRANT CREATE ANY PROCEDURE TO INVPAY;
GRANT EXECUTE ANY PROCEDURE TO INVPAY;
GRANT ALTER ANY PROCEDURE TO INVPAY;
GRANT SELECT ANY SEQUENCE TO INVPAY;
GRANT CREATE ANY SEQUENCE TO INVPAY;
GRANT DROP ANY SEQUENCE TO INVPAY;
ALTER USER INVPAY DEFAULT ROLE ALL;
commit;