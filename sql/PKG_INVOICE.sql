CREATE OR REPLACE PACKAGE INVPAY.PKG_INVOICE 
IS

---------------------------------------
FUNCTION save_invoice
(
  in_id_invoice     INVPAY.INVOICE.ID_INVOICE%TYPE,
  in_num_invoice    INVPAY.INVOICE.NUM_INVOICE%TYPE,
  in_date_invoice   INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_code_org       INVPAY.INVOICE.CODE_ORG%TYPE,
  in_code_prog      INVPAY.INVOICE.CODE_PROG%TYPE,
  in_date_paid      INVPAY.INVOICE.DATE_PAID%TYPE,
  in_sum_paid       INVPAY.INVOICE.SUM_PAID%TYPE,
  in_date_start_ext INVPAY.INVOICE.DATE_START_EXT%TYPE,
  in_date_end_ext   INVPAY.INVOICE.DATE_END_EXT%TYPE,
  in_note           INVPAY.INVOICE.NOTE%TYPE
)
RETURN INVPAY.INVOICE.ID_INVOICE%TYPE;
-----------------------------------
PROCEDURE save_invoice_prog_point
(
  in_id_invoice         INVPAY.INVOICE_PROG_POINT.ID_INVOICE%TYPE,
  in_id_inv_prog_point  INVPAY.INVOICE_PROG_POINT.ID_INV_PROG_POINT%TYPE,
  in_code_prog_point    INVPAY.INVOICE_PROG_POINT.CODE_PROG_POINT%TYPE,
  in_name_unit          INVPAY.INVOICE_PROG_POINT.NAME_UNIT%TYPE,
  in_count              INVPAY.INVOICE_PROG_POINT."COUNT"%TYPE,
  in_cost_one           INVPAY.INVOICE_PROG_POINT.COST_ONE%TYPE,
  in_cost_clear         INVPAY.INVOICE_PROG_POINT.COST_CLEAR%TYPE,
  in_nds                INVPAY.INVOICE_PROG_POINT.NDS%TYPE,
  in_count_nds          INVPAY.INVOICE_PROG_POINT.COUNT_NDS%TYPE,
  in_cost_all           INVPAY.INVOICE_PROG_POINT.COST_ALL%TYPE
);
--------------------------------------
FUNCTION load_all
(
  in_date_start_load    INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_date_end_load      INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_code_prog          INVPAY.USERS.CODE_PROG%TYPE
)
RETURN pkg_base.tcursor;
---------------------------------------------
FUNCTION load_invoice_prog_point
(
  in_id_invoice         INVPAY.INVOICE_PROG_POINT.ID_INVOICE%TYPE
)
RETURN pkg_base.tcursor;
---------------------------------------------
PROCEDURE del_invoice
(
  in_id_invoice     INVPAY.INVOICE.ID_INVOICE%TYPE
);
---------------------------------------------
FUNCTION act_print
(
  in_code_month       INVPAY.DICT_MONTH.CODE_MONTH%TYPE,
  in_year             NUMBER,
  in_code_prog        INVPAY.DICT_PROG.CODE_PROG%TYPE,
  in_code_org         ICS."ORGANIZATION".ID%TYPE,
  in_rep_post         NVARCHAR2,
  in_rep_fio          NVARCHAR2
)
RETURN pkg_base.tcursor;

END PKG_INVOICE;
/

CREATE OR REPLACE PACKAGE BODY INVPAY.PKG_INVOICE 
IS

---------------------------------------
FUNCTION save_invoice
( 
  in_id_invoice     INVPAY.INVOICE.ID_INVOICE%TYPE,
  in_num_invoice    INVPAY.INVOICE.NUM_INVOICE%TYPE,
  in_date_invoice   INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_code_org       INVPAY.INVOICE.CODE_ORG%TYPE,
  in_code_prog      INVPAY.INVOICE.CODE_PROG%TYPE,
  in_date_paid      INVPAY.INVOICE.DATE_PAID%TYPE,
  in_sum_paid       INVPAY.INVOICE.SUM_PAID%TYPE,
  in_date_start_ext INVPAY.INVOICE.DATE_START_EXT%TYPE,
  in_date_end_ext   INVPAY.INVOICE.DATE_END_EXT%TYPE,
  in_note           INVPAY.INVOICE.NOTE%TYPE
)
RETURN INVPAY.INVOICE.ID_INVOICE%TYPE
IS
  l_result INVPAY.INVOICE.ID_INVOICE%TYPE;
BEGIN
  IF IN_ID_INVOICE = 0 THEN
    SELECT NVL(MAX(ID_INVOICE), 0) + 1 INTO L_RESULT FROM INVPAY.INVOICE;     

    INSERT INTO INVPAY.INVOICE (ID_INVOICE, NUM_INVOICE, DATE_INVOICE, CODE_ORG, CODE_PROG,
                                DATE_PAID, SUM_PAID, DATE_START_EXT, DATE_END_EXT, NOTE)
                        VALUES (L_RESULT, IN_NUM_INVOICE, IN_DATE_INVOICE, IN_CODE_ORG, IN_CODE_PROG,
                                IN_DATE_PAID, IN_SUM_PAID, IN_DATE_START_EXT, IN_DATE_END_EXT, IN_NOTE);
  ELSE
    L_RESULT := IN_ID_INVOICE;

    UPDATE INVPAY.INVOICE SET 
      NUM_INVOICE = IN_NUM_INVOICE, 
      DATE_INVOICE = IN_DATE_INVOICE, 
      CODE_ORG = IN_CODE_ORG, 
      CODE_PROG = IN_CODE_PROG,
      DATE_PAID = IN_DATE_PAID,
      SUM_PAID = IN_SUM_PAID,
      DATE_START_EXT = IN_DATE_START_EXT,
      DATE_END_EXT = IN_DATE_END_EXT,
      NOTE = IN_NOTE
     WHERE ID_INVOICE = L_RESULT;
  END IF;

RETURN L_RESULT;
END SAVE_INVOICE;
-----------------------------------
PROCEDURE save_invoice_prog_point
(
  in_id_invoice         INVPAY.INVOICE_PROG_POINT.ID_INVOICE%TYPE,
  in_id_inv_prog_point  INVPAY.INVOICE_PROG_POINT.ID_INV_PROG_POINT%TYPE,
  in_code_prog_point    INVPAY.INVOICE_PROG_POINT.CODE_PROG_POINT%TYPE,
  in_name_unit          INVPAY.INVOICE_PROG_POINT.NAME_UNIT%TYPE,
  in_count              INVPAY.INVOICE_PROG_POINT."COUNT"%TYPE,
  in_cost_one           INVPAY.INVOICE_PROG_POINT.COST_ONE%TYPE,
  in_cost_clear         INVPAY.INVOICE_PROG_POINT.COST_CLEAR%TYPE,
  in_nds                INVPAY.INVOICE_PROG_POINT.NDS%TYPE,
  in_count_nds          INVPAY.INVOICE_PROG_POINT.COUNT_NDS%TYPE,
  in_cost_all           INVPAY.INVOICE_PROG_POINT.COST_ALL%TYPE
)
IS
  vID_INVOICE_PP INVPAY.INVOICE_PROG_POINT.ID_INV_PROG_POINT%TYPE;
BEGIN

  IF IN_ID_INV_PROG_POINT = 0 THEN
    SELECT NVL(MAX(ID_INV_PROG_POINT), 0) + 1 INTO vID_INVOICE_PP FROM INVPAY.INVOICE_PROG_POINT;     

    INSERT INTO INVPAY.INVOICE_PROG_POINT (ID_INV_PROG_POINT, ID_INVOICE, CODE_PROG_POINT, NAME_UNIT, "COUNT", COST_ONE, COST_CLEAR, NDS, COUNT_NDS, COST_ALL)
                                   VALUES (VID_INVOICE_PP, IN_ID_INVOICE, IN_CODE_PROG_POINT, IN_NAME_UNIT, IN_COUNT, IN_COST_ONE, IN_COST_CLEAR, IN_NDS, IN_COUNT_NDS, IN_COST_ALL);
  ELSE
    UPDATE INVPAY.INVOICE_PROG_POINT SET 
    NAME_UNIT = IN_NAME_UNIT, 
    "COUNT" = IN_COUNT, 
    COST_ONE = IN_COST_ONE, 
    COST_CLEAR = IN_COST_CLEAR, 
    NDS = IN_NDS, 
    COUNT_NDS = IN_COUNT_NDS, 
    COST_ALL = IN_COST_ALL
  WHERE ID_INV_PROG_POINT = IN_ID_INV_PROG_POINT;
  END IF;

END SAVE_INVOICE_PROG_POINT;
--------------------------------------
FUNCTION load_all
(
  in_date_start_load    INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_date_end_load      INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_code_prog          INVPAY.USERS.CODE_PROG%TYPE
)
RETURN pkg_base.tcursor
IS
  l_result pkg_base.tcursor; 
BEGIN

 IF IN_CODE_PROG = '0' THEN
    if (in_date_start_load IS NULL) AND (in_date_end_load IS NULL) THEN
      OPEN L_RESULT FOR
      SELECT 
       *
      FROM INVPAY.V_INVOICES;
  
    ELSIF (in_date_start_load IS NOT NULL) AND (in_date_end_load IS NULL) THEN
      OPEN L_RESULT FOR
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INVPAY.pkg_base.to_datef(DATE_INVOICE) >= INVPAY.pkg_base.to_datef(in_date_start_load);
  
     ELSIF (in_date_start_load IS NULL) AND (in_date_end_load IS NOT NULL) THEN
      OPEN L_RESULT FOR
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INVPAY.pkg_base.to_datef(DATE_INVOICE) <= INVPAY.pkg_base.to_datef(in_date_end_load);
  
     ELSE
      OPEN L_RESULT FOR 
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INVPAY.pkg_base.to_datef(DATE_INVOICE) BETWEEN INVPAY.pkg_base.to_datef(in_date_start_load) AND INVPAY.pkg_base.to_datef(in_date_end_load); 
     END IF;
  ELSE
     if (in_date_start_load IS NULL) AND (in_date_end_load IS NULL) THEN
      OPEN L_RESULT FOR
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INSTR('|' || IN_CODE_PROG || '|', '|' || CODE_PROG || '|', 1) <> 0;
  
    ELSIF (in_date_start_load IS NOT NULL) AND (in_date_end_load IS NULL) THEN
      OPEN L_RESULT FOR
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INVPAY.pkg_base.to_datef(DATE_INVOICE) >= INVPAY.pkg_base.to_datef(in_date_start_load)
      AND INSTR('|' || IN_CODE_PROG || '|', '|' || CODE_PROG || '|', 1) <> 0;
  
     ELSIF (in_date_start_load IS NULL) AND (in_date_end_load IS NOT NULL) THEN
      OPEN L_RESULT FOR
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INVPAY.pkg_base.to_datef(DATE_INVOICE) <= INVPAY.pkg_base.to_datef(in_date_end_load)
      AND INSTR('|' || IN_CODE_PROG || '|', '|' || CODE_PROG || '|', 1) <> 0;
  
     ELSE
      OPEN L_RESULT FOR 
      SELECT 
       *
      FROM INVPAY.V_INVOICES
      WHERE INVPAY.pkg_base.to_datef(DATE_INVOICE) BETWEEN INVPAY.pkg_base.to_datef(in_date_start_load) AND INVPAY.pkg_base.to_datef(in_date_end_load)
      AND INSTR('|' || IN_CODE_PROG || '|', '|' || CODE_PROG || '|', 1) <> 0;  
     END IF;
  END IF;
RETURN L_RESULT;
END load_all;
---------------------------------------------
FUNCTION load_invoice_prog_point
(
  in_id_invoice         INVPAY.INVOICE_PROG_POINT.ID_INVOICE%TYPE
)
RETURN pkg_base.tcursor
IS
  l_result pkg_base.tcursor; 
BEGIN
   OPEN L_RESULT FOR
     SELECT 
        ipp.*,
        dpp.NAME_PROG_POINT
     FROM INVPAY.INVOICE_PROG_POINT ipp 
       INNER JOIN INVPAY.DICT_PROG_POINT dpp ON IPP.CODE_PROG_POINT = DPP.CODE_PROG_POINT
     WHERE IPP.ID_INVOICE = IN_ID_INVOICE
     ORDER BY IPP.ID_INV_PROG_POINT;

RETURN L_RESULT;
END LOAD_INVOICE_PROG_POINT;
---------------------------------------------
PROCEDURE del_invoice
(
  in_id_invoice     INVPAY.INVOICE.ID_INVOICE%TYPE
)
IS
BEGIN
    DELETE FROM INVPAY.INVOICE WHERE ID_INVOICE = IN_ID_INVOICE;
END DEL_INVOICE;
---------------------------------------------
FUNCTION act_print
(
  in_code_month       INVPAY.DICT_MONTH.CODE_MONTH%TYPE,
  in_year             NUMBER,
  in_code_prog        INVPAY.DICT_PROG.CODE_PROG%TYPE,
  in_code_org         ICS."ORGANIZATION".ID%TYPE,
  in_rep_post         NVARCHAR2,
  in_rep_fio          NVARCHAR2
)
RETURN pkg_base.tcursor
IS
  l_result pkg_base.tcursor; 
BEGIN
   --АРМ, ЕГАИС
  IF (IN_CODE_ORG IS NULL) AND (IN_CODE_PROG IN (1, 4)) THEN
   OPEN L_RESULT FOR
     SELECT
        INVPAY.PKG_BASE.to_charf_datel(LAST_DAY(INVPAY.PKG_BASE.to_datef('01.' || IN_CODE_MONTH || '.' || IN_YEAR))) DATE_REP,
        o."NAME" || ', УНП ' || dbi.UNP || ', ' || dbi.ADDRESS_INFO || ', р/с ' || dbi.PAYMENT_ACCOUNT || ', Банк: ' || dbi.BANK NAME_ORG,
        IN_REP_POST REP_POST,
        IN_REP_FIO REP_FIO,
        DPP.NAME_PROG_POINT,
        IPP.NAME_UNIT,
        DECODE(IN_CODE_PROG, 1, 1, IPP."COUNT") "COUNT",
        IPP.COST_ONE,
        DECODE(IN_CODE_PROG, 1, IPP.COST_ONE, IPP.COST_CLEAR) COST_CLEAR,
        IPP.NDS,
        DECODE(IN_CODE_PROG, 1, ROUND((IPP.COST_ONE * IPP.NDS / 100), 2), IPP.COUNT_NDS) COUNT_NDS,
        DECODE(IN_CODE_PROG, 1, ROUND((IPP.COST_ONE + (IPP.COST_ONE * IPP.NDS / 100)), 2), IPP.COST_ALL) COST_ALL,
        DP.NUM_DOC || ' от ' || DP.DATE_DOC DOC_INFO,
        '№' || DPP.NUM_PRICE || ' от ' || DPP.DATE_START PRICE
      FROM INVPAY.INVOICE i
         INNER JOIN ICS."ORGANIZATION" o ON i.CODE_ORG = o.ID
         INNER JOIN INVPAY.INVOICE_PROG_POINT IPP ON I.ID_INVOICE = IPP.ID_INVOICE AND IPP."COUNT" IS NOT NULL
         LEFT JOIN INVPAY.DICT_BANK_INFO dbi ON I.CODE_ORG = DBI.CODE_ORG
         INNER JOIN INVPAY.DICT_PROG_POINT DPP ON IPP.CODE_PROG_POINT = DPP.CODE_PROG_POINT AND DPP.CODE_PROG = IN_CODE_PROG
         INNER JOIN INVPAY.DICT_PROG DP ON DPP.CODE_PROG = DP.CODE_PROG
      WHERE 
       INVPAY.PKG_BASE.to_datef('01.' || IN_CODE_MONTH || '.' || IN_YEAR) BETWEEN INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT) AND INVPAY.PKG_BASE.to_datef(i.DATE_END_EXT)
      AND i.DATE_START_EXT IS NOT NULL
      ORDER BY DATE_REP, NAME_ORG, NAME_PROG_POINT;
   ELSIF (IN_CODE_ORG IS NOT NULL) AND (IN_CODE_PROG IN (1, 4)) THEN
     OPEN L_RESULT FOR
     SELECT
        INVPAY.PKG_BASE.to_charf_datel(LAST_DAY(INVPAY.PKG_BASE.to_datef('01.' || IN_CODE_MONTH || '.' || IN_YEAR))) DATE_REP,
        o."NAME" || ', УНП ' || dbi.UNP || ', ' || dbi.ADDRESS_INFO || ', р/с ' || dbi.PAYMENT_ACCOUNT || ', Банк: ' || dbi.BANK NAME_ORG,
        IN_REP_POST REP_POST,
        IN_REP_FIO REP_FIO,
        DPP.NAME_PROG_POINT,
        IPP.NAME_UNIT,
        DECODE(IN_CODE_PROG, 1, 1, IPP."COUNT") "COUNT",
        IPP.COST_ONE,
        DECODE(IN_CODE_PROG, 1, IPP.COST_ONE, IPP.COST_CLEAR) COST_CLEAR,
        IPP.NDS,
        DECODE(IN_CODE_PROG, 1, ROUND((IPP.COST_ONE * IPP.NDS / 100), 2), IPP.COUNT_NDS) COUNT_NDS,
        DECODE(IN_CODE_PROG, 1, ROUND((IPP.COST_ONE + (IPP.COST_ONE * IPP.NDS / 100)), 2), IPP.COST_ALL) COST_ALL,
        DP.NUM_DOC || ' от ' || DP.DATE_DOC DOC_INFO,
        '№' || DPP.NUM_PRICE || ' от ' || DPP.DATE_START PRICE
      FROM INVPAY.INVOICE i
         INNER JOIN ICS."ORGANIZATION" o ON i.CODE_ORG = o.ID
         INNER JOIN INVPAY.INVOICE_PROG_POINT IPP ON I.ID_INVOICE = IPP.ID_INVOICE AND IPP."COUNT" IS NOT NULL
         LEFT JOIN INVPAY.DICT_BANK_INFO dbi ON I.CODE_ORG = DBI.CODE_ORG
         INNER JOIN INVPAY.DICT_PROG_POINT DPP ON IPP.CODE_PROG_POINT = DPP.CODE_PROG_POINT AND DPP.CODE_PROG = IN_CODE_PROG
         INNER JOIN INVPAY.DICT_PROG DP ON DPP.CODE_PROG = DP.CODE_PROG
      WHERE 
          (INVPAY.PKG_BASE.to_datef('01.' || IN_CODE_MONTH || '.' || IN_YEAR) BETWEEN INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT) AND INVPAY.PKG_BASE.to_datef(i.DATE_END_EXT))
     AND o.ID = IN_CODE_ORG
     AND i.DATE_START_EXT IS NOT NULL
      ORDER BY DATE_REP, NAME_ORG, NAME_PROG_POINT;
     --Мобильная ГИС, Qgis
   ELSIF (IN_CODE_ORG IS NULL) AND (IN_CODE_PROG IN (2, 3)) THEN
     OPEN L_RESULT FOR
       SELECT
        INVPAY.PKG_BASE.to_charf_datel(INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT)) DATE_REP,
        o."NAME" || ', УНП ' || dbi.UNP || ', ' || dbi.ADDRESS_INFO || ', р/с ' || dbi.PAYMENT_ACCOUNT || ', Банк: ' || dbi.BANK NAME_ORG,
        IN_REP_POST REP_POST,
        IN_REP_FIO REP_FIO,
        DPP.NAME_PROG_POINT,
        IPP.NAME_UNIT,
        IPP."COUNT",
        IPP.COST_ONE,
        IPP.COST_CLEAR,
        IPP.NDS,
        IPP.COUNT_NDS,
        IPP.COST_ALL,
        DP.NUM_DOC || ' от ' || DP.DATE_DOC DOC_INFO,
        '№' || DPP.NUM_PRICE || ' от ' || DPP.DATE_START PRICE
        FROM INVPAY.INVOICE i
         INNER JOIN ICS."ORGANIZATION" o ON i.CODE_ORG = o.ID
         INNER JOIN INVPAY.INVOICE_PROG_POINT IPP ON I.ID_INVOICE = IPP.ID_INVOICE AND IPP."COUNT" IS NOT NULL
         LEFT JOIN INVPAY.DICT_BANK_INFO dbi ON I.CODE_ORG = DBI.CODE_ORG
         INNER JOIN INVPAY.DICT_PROG_POINT DPP ON IPP.CODE_PROG_POINT = DPP.CODE_PROG_POINT AND DPP.CODE_PROG = IN_CODE_PROG
         INNER JOIN INVPAY.DICT_PROG DP ON DPP.CODE_PROG = DP.CODE_PROG
        WHERE 
         ((EXTRACT(MONTH FROM INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT)) = IN_CODE_MONTH) OR (IN_CODE_MONTH IS NULL))
     AND ((EXTRACT(YEAR FROM INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT)) = IN_YEAR) OR (IN_YEAR IS NULL))
     AND i.DATE_START_EXT IS NOT NULL
     ORDER BY DATE_REP, NAME_ORG, NAME_PROG_POINT;
   ELSIF (IN_CODE_ORG IS NOT NULL) AND (IN_CODE_PROG IN (2, 3)) THEN
     OPEN L_RESULT FOR
       SELECT
        INVPAY.PKG_BASE.to_charf_datel(INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT)) DATE_REP,
        o."NAME" || ', УНП ' || dbi.UNP || ', ' || dbi.ADDRESS_INFO || ', р/с ' || dbi.PAYMENT_ACCOUNT || ', Банк: ' || dbi.BANK NAME_ORG,
        IN_REP_POST REP_POST,
        IN_REP_FIO REP_FIO,
        DPP.NAME_PROG_POINT,
        IPP.NAME_UNIT,
        IPP."COUNT",
        IPP.COST_ONE,
        IPP.COST_CLEAR,
        IPP.NDS,
        IPP.COUNT_NDS,
        IPP.COST_ALL,
        DP.NUM_DOC || ' от ' || DP.DATE_DOC DOC_INFO,
        '№' || DPP.NUM_PRICE || ' от ' || DPP.DATE_START PRICE
        FROM INVPAY.INVOICE i
         INNER JOIN ICS."ORGANIZATION" o ON i.CODE_ORG = o.ID
         INNER JOIN INVPAY.INVOICE_PROG_POINT IPP ON I.ID_INVOICE = IPP.ID_INVOICE AND IPP."COUNT" IS NOT NULL
         LEFT JOIN INVPAY.DICT_BANK_INFO dbi ON I.CODE_ORG = DBI.CODE_ORG
         INNER JOIN INVPAY.DICT_PROG_POINT DPP ON IPP.CODE_PROG_POINT = DPP.CODE_PROG_POINT AND DPP.CODE_PROG = IN_CODE_PROG
         INNER JOIN INVPAY.DICT_PROG DP ON DPP.CODE_PROG = DP.CODE_PROG
        WHERE 
         ((EXTRACT(MONTH FROM INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT)) = IN_CODE_MONTH) OR (IN_CODE_MONTH IS NULL))
     AND ((EXTRACT(YEAR FROM INVPAY.PKG_BASE.to_datef(i.DATE_START_EXT)) = IN_YEAR) OR (IN_YEAR IS NULL))
     AND o.ID = IN_CODE_ORG
     AND i.DATE_START_EXT IS NOT NULL
     ORDER BY DATE_REP, NAME_ORG, NAME_PROG_POINT;
   END IF;
RETURN L_RESULT;
END ACT_PRINT;
--------------------------------------------------------------------------------
END PKG_INVOICE;
/