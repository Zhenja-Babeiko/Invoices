CREATE OR REPLACE PACKAGE INVPAY.PKG_NRI_BASE 
IS

FUNCTION load_org
RETURN pkg_base.tcursor;
-------------------------------------------------------
FUNCTION load_org_bank
RETURN pkg_base.tcursor;
-------------------------------------------------------
FUNCTION load_prog
(
  in_code_prog INVPAY.USERS.CODE_PROG%TYPE
)
RETURN pkg_base.tcursor;
-------------------------------------------------------
FUNCTION load_role
RETURN pkg_base.tcursor;
-------------------------------------------------------
FUNCTION load_prog_point
(
  in_code_prog INVPAY.DICT_PROG.CODE_PROG%TYPE,
  in_date_create INVPAY.DICT_PROG_POINT.DATE_START%TYPE
)
RETURN pkg_base.tcursor;
-------------------------------------------------------
FUNCTION load_month
RETURN pkg_base.tcursor;
-------------------------------------------------------

END PKG_NRI_BASE;
/

CREATE OR REPLACE PACKAGE BODY INVPAY.PKG_NRI_BASE 
IS

FUNCTION load_org_bank
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR 
  SELECT
     org1.ID CODE_ORG,
     DECODE(org1.PARENT_ID, -1, org1.NAME, org1.NAME || '('|| org2.NAME || ')') NAME_ORG
  FROM ICS."ORGANIZATION" org1, ICS."ORGANIZATION" org2
  WHERE org1.PARENT_ID = org2.ID
    AND ORG1.LVL = 2 --берем лесхозы
    AND INSTR(org1."NAME", 'Аппарат управления') = 0
    AND org1.ID NOT IN (SELECT CODE_ORG FROM INVPAY.DICT_BANK_INFO)
  ORDER BY NAME_ORG;

RETURN l_result;
END load_org_bank;
-------------------------------------------------------
FUNCTION load_org
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR 
  SELECT
     org1.ID CODE_ORG,
     DECODE(org1.PARENT_ID, -1, org1.NAME, org1.NAME || '('|| org2.NAME || ')') NAME_ORG
  FROM ICS."ORGANIZATION" org1, ICS."ORGANIZATION" org2
  WHERE org1.PARENT_ID = org2.ID
    AND ORG1.LVL = 2 --берем лесхозы
    AND INSTR(org1."NAME", 'Аппарат управления') = 0
    UNION 
     SELECT
       DBI.CODE_ORG,
       dbi.NAME_ORG
     FROM INVPAY.DICT_BANK_INFO dbi
     WHERE dbi.IS_NEW_ORG = 1
  ORDER BY NAME_ORG;

RETURN l_result;
END load_org;
-------------------------------------------------------
FUNCTION load_prog
(
  in_code_prog INVPAY.USERS.CODE_PROG%TYPE
)
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  --если пользователь имеет доступ ко все мпрограммам
  IF IN_CODE_PROG = '0' THEN
    OPEN L_RESULT FOR 
    SELECT
       *
    FROM INVPAY.DICT_PROG
    ORDER BY NAME_PROG_FULL;
  -- иначе к конкретной программе
  ELSE
    OPEN L_RESULT FOR 
    SELECT
       *
    FROM INVPAY.DICT_PROG
    WHERE INSTR('|' || IN_CODE_PROG || '|', '|' || CODE_PROG || '|', 1) <> 0
    ORDER BY NAME_PROG_FULL;
  END IF;
RETURN l_result;
END load_prog;
-------------------------------------------------------
FUNCTION load_role
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR 
  SELECT
     *
  FROM INVPAY.DICT_ROLE
  ORDER BY NAME_ROLE;
RETURN l_result;
END load_role;
-------------------------------------------------------
FUNCTION load_prog_point
(
  in_code_prog INVPAY.DICT_PROG.CODE_PROG%TYPE,
  in_date_create INVPAY.DICT_PROG_POINT.DATE_START%TYPE
)
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR 
  SELECT
     *
  FROM INVPAY.DICT_PROG_POINT
  WHERE CODE_PROG = IN_CODE_PROG
    AND INVPAY.pkg_base.to_datef(DATE_START) = (SELECT MAX(INVPAY.pkg_base.to_datef(DATE_START)) FROM INVPAY.DICT_PROG_POINT WHERE (CODE_PROG = IN_CODE_PROG) AND (INVPAY.pkg_base.to_datef(DATE_START) <= INVPAY.pkg_base.to_datef(IN_DATE_CREATE)))
    ORDER BY CODE_PROG_POINT;
RETURN l_result;
END load_prog_point;
--------------------------------------------------------------------------------
FUNCTION load_month
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
   OPEN L_RESULT FOR
     SELECT
       *
     FROM INVPAY.DICT_MONTH
     ORDER BY CODE_MONTH;

RETURN L_RESULT;
END LOAD_MONTH;
-------------------------------------------------------
END PKG_NRI_BASE;
/