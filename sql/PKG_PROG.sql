CREATE OR REPLACE PACKAGE INVPAY.PKG_PROG 
IS

FUNCTION load_all
RETURN pkg_base.tcursor;
-------------------------------------
PROCEDURE delete_prog
(
   in_code_prog INVPAY.DICT_PROG.CODE_PROG%TYPE
);
---------------------------------------
PROCEDURE save_prog
(
   in_code_prog         INVPAY.DICT_PROG.CODE_PROG%TYPE,
   in_name_prog_full    INVPAY.DICT_PROG.NAME_PROG_FULL%TYPE,
   in_name_prog_short   INVPAY.DICT_PROG.NAME_PROG_SHORT%TYPE,
   in_num_doc           INVPAY.DICT_PROG.NUM_DOC%TYPE,
   in_date_doc          INVPAY.DICT_PROG.DATE_DOC%TYPE
);
-----------------------------------
END PKG_PROG;
/

CREATE OR REPLACE PACKAGE BODY INVPAY.PKG_PROG 
IS

FUNCTION load_all
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR 
  SELECT
    *
  FROM INVPAY.DICT_PROG
  ORDER BY NAME_PROG_FULL;
RETURN l_result;
END load_all;
-------------------------------------
PROCEDURE delete_prog
(
   in_code_prog INVPAY.DICT_PROG.CODE_PROG%TYPE
)
IS
BEGIN
   DELETE FROM INVPAY.DICT_PROG WHERE CODE_PROG = IN_CODE_PROG;
END DELETE_PROG;
---------------------------------------
PROCEDURE save_prog
(
   in_code_prog         INVPAY.DICT_PROG.CODE_PROG%TYPE,
   in_name_prog_full    INVPAY.DICT_PROG.NAME_PROG_FULL%TYPE,
   in_name_prog_short   INVPAY.DICT_PROG.NAME_PROG_SHORT%TYPE,
   in_num_doc           INVPAY.DICT_PROG.NUM_DOC%TYPE,
   in_date_doc          INVPAY.DICT_PROG.DATE_DOC%TYPE
)
IS
   iNEW_CODE_PROG INVPAY.DICT_PROG.CODE_PROG%TYPE;
BEGIN
  IF IN_CODE_PROG = 0 THEN
    SELECT NVL(MAX(CODE_PROG), 0) + 1 INTO INEW_CODE_PROG FROM INVPAY.DICT_PROG;     

    INSERT INTO INVPAY.DICT_PROG
           (CODE_PROG, NAME_PROG_FULL, NAME_PROG_SHORT, NUM_DOC, DATE_DOC)    
    VALUES (INEW_CODE_PROG, IN_NAME_PROG_FULL, IN_NAME_PROG_SHORT, IN_NUM_DOC, IN_DATE_DOC);
  ELSE
    UPDATE INVPAY.DICT_PROG SET 
      NAME_PROG_FULL = IN_NAME_PROG_FULL,
      NAME_PROG_SHORT = IN_NAME_PROG_SHORT,
      NUM_DOC = IN_NUM_DOC,
      DATE_DOC = IN_DATE_DOC
  WHERE CODE_PROG = IN_CODE_PROG;
  END IF;

END SAVE_PROG;
--------------------------------------------------------------------------------
END PKG_PROG;
/