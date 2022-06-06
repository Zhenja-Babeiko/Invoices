CREATE OR REPLACE PACKAGE INVPAY.PKG_BANK_INFO 
IS

FUNCTION load_all
RETURN pkg_base.tcursor;
-------------------------------------
FUNCTION load_data_org
(
  in_code_org   ICS."ORGANIZATION".ID%TYPE
)
RETURN pkg_base.tcursor;
-------------------------------------
PROCEDURE delete_bank_info
(
   in_code_org INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE
);
---------------------------------------
PROCEDURE save_bank_info 
(
   in_code_org        INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE,
   in_unp             INVPAY.DICT_BANK_INFO.UNP%TYPE,
   in_address_info    INVPAY.DICT_BANK_INFO.ADDRESS_INFO%TYPE,
   in_payment_account INVPAY.DICT_BANK_INFO.PAYMENT_ACCOUNT%TYPE,
   in_bank            INVPAY.DICT_BANK_INFO.BANK%TYPE,
   in_name_org        INVPAY.DICT_BANK_INFO.NAME_ORG%TYPE,
   in_is_new_org      INVPAY.DICT_BANK_INFO.IS_NEW_ORG%TYPE
);
--------------------------------------
FUNCTION get_address (in_id_org NUMBER)
RETURN VARCHAR2;
--------------------------------------
FUNCTION get_new_id
RETURN INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE;

END PKG_BANK_INFO;
/

CREATE OR REPLACE PACKAGE BODY INVPAY.PKG_BANK_INFO 
IS

FUNCTION load_all
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR 
  SELECT
    DBI.CODE_ORG,
    o."NAME" NAME_ORG,
    DBI.UNP,
    DBI.ADDRESS_INFO,
    DBI.PAYMENT_ACCOUNT,
    DBI.BANK,
    DBI.IS_NEW_ORG
  FROM INVPAY.DICT_BANK_INFO dbi 
    INNER JOIN ICS."ORGANIZATION" o ON DBI.CODE_ORG = O.ID
  UNION
   SELECT
    DBI.CODE_ORG,
    DBI.NAME_ORG,
    DBI.UNP,
    DBI.ADDRESS_INFO,
    DBI.PAYMENT_ACCOUNT,
    DBI.BANK,
    DBI.IS_NEW_ORG
  FROM INVPAY.DICT_BANK_INFO dbi
  WHERE DBI.IS_NEW_ORG = 1 
  ORDER BY NAME_ORG;
RETURN l_result;
END load_all;
-------------------------------------
FUNCTION load_data_org
(
  in_code_org   ICS."ORGANIZATION".ID%TYPE
)
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
   OPEN L_RESULT FOR 
     SELECT
       REG_NUMBER UNP,
       INVPAY.PKG_BANK_INFO.get_address(IN_CODE_ORG) ADDRESS_INFO
     FROM ICS."ORGANIZATION" 
     WHERE ID = IN_CODE_ORG;
RETURN L_RESULT;
END LOAD_DATA_ORG;
-------------------------------------
PROCEDURE delete_bank_info
(
   in_code_org INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE
)
IS
BEGIN
   DELETE FROM INVPAY.DICT_BANK_INFO WHERE CODE_ORG = IN_CODE_ORG;
END DELETE_BANK_INFO;
---------------------------------------
PROCEDURE save_bank_info
(
   in_code_org        INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE,
   in_unp             INVPAY.DICT_BANK_INFO.UNP%TYPE,
   in_address_info    INVPAY.DICT_BANK_INFO.ADDRESS_INFO%TYPE,
   in_payment_account INVPAY.DICT_BANK_INFO.PAYMENT_ACCOUNT%TYPE,
   in_bank            INVPAY.DICT_BANK_INFO.BANK%TYPE,
   in_name_org        INVPAY.DICT_BANK_INFO.NAME_ORG%TYPE,
   in_is_new_org      INVPAY.DICT_BANK_INFO.IS_NEW_ORG%TYPE
)
IS
   vCount NUMBER;
BEGIN
  SELECT COUNT(*) INTO VCOUNT FROM INVPAY.DICT_BANK_INFO WHERE CODE_ORG = IN_CODE_ORG;
  
  IF VCOUNT = 0 THEN
    INSERT INTO INVPAY.DICT_BANK_INFO (CODE_ORG, UNP, ADDRESS_INFO, PAYMENT_ACCOUNT, BANK, NAME_ORG, IS_NEW_ORG)
                               VALUES (IN_CODE_ORG, IN_UNP, IN_ADDRESS_INFO, IN_PAYMENT_ACCOUNT, IN_BANK, IN_NAME_ORG, IN_IS_NEW_ORG);
  ELSE
    UPDATE INVPAY.DICT_BANK_INFO SET 
    UNP = IN_UNP, 
    ADDRESS_INFO = IN_ADDRESS_INFO, 
    PAYMENT_ACCOUNT = IN_PAYMENT_ACCOUNT, 
    BANK = IN_BANK,
    NAME_ORG = IN_NAME_ORG,
    IS_NEW_ORG = IN_IS_NEW_ORG
  WHERE CODE_ORG = IN_CODE_ORG;
  END IF;
END SAVE_BANK_INFO;
--------------------------------------------------------------------------------
FUNCTION get_address (in_id_org NUMBER)
RETURN VARCHAR2
IS
  res VARCHAR2(256 byte);
  addressID NUMBER;
  address VARCHAR2(255 byte);
  city VARCHAR2(60 byte);
  post_code VARCHAR2(20);
  parrentName ICS.ORGANIZATION.NAME%TYPE;
  curr_id NUMBER(13);
  par_id NUMBER(13);
  lvl_curr NUmBER(1);
BEGIN

 select address_id, lvl into addressID, lvl_curr from ics.organization where id = in_id_org;

 parrentName := NULL;

 IF addressID is NULL THEN
    curr_id := in_id_org;
    WHILE curr_id <> -1
    LOOP
        SELECT PARENT_ID INTO par_id FROM ICS.ORGANIZATION WHERE ID = curr_id;
        IF (par_id = 1500100000) AND ((lvl_curr = 3) or (lvl_curr = 4)) THEN
          select address_id, name into addressID, parrentName  from ics.organization where id = (SELECT parent_id FROM ics.organization WHERE id = in_id_org);
        END IF;
        SELECT PARENT_ID INTO curr_id FROM ICS.ORGANIZATION WHERE ID = curr_id;
    END LOOP;
 END IF;

    IF addressID IS NOT NULL THEN
        select ADDRESS_LINE1, CITY, POSTAL_CODE into address, city, post_code FROM ics.ADDRESS WHERE ID = addressID;
        res := case
                when ((post_code is not NULL) AND (city is not NULL) AND (address is not NULL)) then post_code || ', ' || city || ', ' || address
                when ((post_code is NULL) AND (city is not NULL) AND (address is not NULL)) then city || ', ' || address
                when ((post_code is NULL) AND (city is NULL) AND (address is not NULL)) then address
                when ((post_code is not NULL) AND (city is NULL) AND (address is not NULL)) then post_code || ', ' || address
                when ((post_code is NULL) AND (city is not NULL) AND (address is NULL)) then city
                when ((post_code is not NULL) AND (city is NULL) AND (address is NULL)) then post_code
                when ((post_code is not NULL) AND (city is not NULL) AND (address is NULL)) then post_code || ', ' || city
                else NULL
                end;
    ELSE res := NULL;
    END IF;

    res := case
            when ((parrentName is not NULL) AND (res is NULL)) THEN parrentName
            when ((parrentName is not NULL) AND (res is not NULL)) THEN parrentName || ', ' || res
            when ((parrentName is NULL) AND (res is not NULL)) THEN res
            else NULL
            end;
RETURN res;
END GET_ADDRESS;
--------------------------------------
FUNCTION get_new_id 
RETURN INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE
IS
  L_RESULT INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE;
BEGIN
   SELECT NVL(MAX(CODE_ORG), 0) + 1 INTO L_RESULT FROM INVPAY.DICT_BANK_INFO WHERE IS_NEW_ORG = 1;
RETURN L_RESULT;
END GET_NEW_ID;

END PKG_BANK_INFO;
/