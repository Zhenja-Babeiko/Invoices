CREATE OR REPLACE PROCEDURE INVPAY.PKG_INVOICE_$DEL
(
  in_id_invoice     INVPAY.INVOICE.ID_INVOICE%TYPE
)
IS
BEGIN
  PKG_INVOICE.del_invoice (in_id_invoice);
END PKG_INVOICE_$DEL;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_INVOICE_$SAVE_INV_PP
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
BEGIN
  PKG_INVOICE.save_invoice_prog_point (in_id_invoice,
                                  in_id_inv_prog_point,
                                  in_code_prog_point,
                                  in_name_unit,
                                  in_count,
                                  in_cost_one,
                                  in_cost_clear,
                                  in_nds,
                                  in_count_nds,
                                  in_cost_all);
END PKG_INVOICE_$SAVE_INV_PP;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_PROG_$DEL
(
   in_code_prog INVPAY.DICT_PROG.CODE_PROG%TYPE
)
IS
BEGIN
  PKG_PROG.DELETE_PROG(in_code_prog);
END PKG_PROG_$DEL;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_PROG_$SAVE
(
   in_code_prog         INVPAY.DICT_PROG.CODE_PROG%TYPE,
   in_name_prog_full    INVPAY.DICT_PROG.NAME_PROG_FULL%TYPE,
   in_name_prog_short   INVPAY.DICT_PROG.NAME_PROG_SHORT%TYPE,
   in_num_doc           INVPAY.DICT_PROG.NUM_DOC%TYPE,
   in_date_doc          INVPAY.DICT_PROG.DATE_DOC%TYPE
)
IS
BEGIN
  PKG_PROG.SAVE_PROG (in_code_prog,
                      in_name_prog_full,
                      in_name_prog_short,
                      in_num_doc,
                      in_date_doc);
END PKG_PROG_$SAVE;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_PROG_POINT_$DEL_PP
(
   in_code_prog_point INVPAY.DICT_PROG_POINT.CODE_PROG_POINT%TYPE
)
IS
BEGIN
  PKG_PROG_POINT.DELETE_PROG_POINT(in_code_prog_point);
END PKG_PROG_POINT_$DEL_PP;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_PROG_POINT_$SAVE_PP
(
   in_code_prog_point   INVPAY.DICT_PROG_POINT.CODE_PROG_POINT%TYPE,
   in_name_prog_point    INVPAY.DICT_PROG_POINT.NAME_PROG_POINT%TYPE,
   in_name_unit         INVPAY.DICT_PROG_POINT.NAME_UNIT%TYPE,
   in_cost_one          INVPAY.DICT_PROG_POINT.COST_ONE%TYPE,
   in_code_prog         INVPAY.DICT_PROG_POINT.CODE_PROG%TYPE,
   in_num_price         INVPAY.DICT_PROG_POINT.NUM_PRICE%TYPE,
   in_date_start        INVPAY.DICT_PROG_POINT.DATE_START%TYPE
)
IS
BEGIN
  PKG_PROG_POINT.SAVE_PROG_POINT (in_code_prog_point,
                                  in_name_prog_point,
                                  in_name_unit,
                                  in_cost_one,
                                  in_code_prog,
                                  in_num_price,
                                  in_date_start);
END PKG_PROG_POINT_$SAVE_PP;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_INVOICE_$LOAD_ALL 
(
  in_date_start_load    INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_date_end_load      INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_code_prog          INVPAY.USERS.CODE_PROG%TYPE
)
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN PKG_INVOICE.LOAD_ALL(in_date_start_load, in_date_end_load, in_code_prog);
END PKG_INVOICE_$LOAD_ALL;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_INVOICE_$LOAD_INV_PP 
(
  in_id_invoice         INVPAY.INVOICE_PROG_POINT.ID_INVOICE%TYPE
)
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN PKG_INVOICE.LOAD_INVOICE_PROG_POINT(in_id_invoice);
END PKG_INVOICE_$LOAD_INV_PP;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_INVOICE_$SAVE_INVOICE 
(
  in_id_invoice     INVPAY.INVOICE.ID_INVOICE%TYPE,
  in_num_invoice    INVPAY.INVOICE.NUM_INVOICE%TYPE,
  in_date_invoice   INVPAY.INVOICE.DATE_INVOICE%TYPE,
  in_code_org       INVPAY.INVOICE.CODE_ORG%TYPE,
  in_code_prog      INVPAY.INVOICE.CODE_PROG%TYPE ,
  in_date_paid      INVPAY.INVOICE.DATE_PAID%TYPE,
  in_sum_paid       INVPAY.INVOICE.SUM_PAID%TYPE,
  in_date_start_ext INVPAY.INVOICE.DATE_START_EXT%TYPE,
  in_date_end_ext   INVPAY.INVOICE.DATE_END_EXT%TYPE,
  in_note           INVPAY.INVOICE.NOTE%TYPE
)
RETURN INVPAY.INVOICE.ID_INVOICE%TYPE
IS
BEGIN
  RETURN PKG_INVOICE.save_invoice (in_id_invoice,
                                   in_num_invoice,
                                   in_date_invoice,
                                   in_code_org,
                                   in_code_prog,
                                   in_date_paid,
                                   in_sum_paid,
                                   in_date_start_ext,
                                   in_date_end_ext,
                                   in_note);
END PKG_INVOICE_$SAVE_INVOICE;
/

CREATE OR REPLACE FUNCTION INVPAY.pkg_nri_base_$load_month 
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN pkg_nri_base.load_month;
END pkg_nri_base_$load_month;
/

CREATE OR REPLACE FUNCTION INVPAY.pkg_nri_base_$load_org 
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN pkg_nri_base.load_org;
END pkg_nri_base_$load_org;
/

CREATE OR REPLACE FUNCTION INVPAY.pkg_nri_base_$load_pp
(
  in_code_prog INVPAY.DICT_PROG.CODE_PROG%TYPE,
  in_date_create INVPAY.DICT_PROG_POINT.DATE_START%TYPE
)
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN pkg_nri_base.load_prog_point(in_code_prog, in_date_create);
END pkg_nri_base_$load_pp;
/

CREATE OR REPLACE FUNCTION INVPAY.pkg_nri_base_$load_prog 
(
  in_code_prog INVPAY.USERS.CODE_PROG%TYPE
)
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN pkg_nri_base.load_prog (in_code_prog);
END pkg_nri_base_$load_prog;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_PROG_$LOAD_ALL 
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN PKG_PROG.LOAD_ALL;
END PKG_PROG_$LOAD_ALL;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_PROG_POINT_$LOAD_ALL 
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN PKG_PROG_POINT.LOAD_ALL;
END PKG_PROG_POINT_$LOAD_ALL;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_BANK_INFO_$SAVE
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
BEGIN
  PKG_BANK_INFO.save_bank_info (in_code_org,
                                          in_unp,
                                          in_address_info,
                                          in_payment_account,
                                          in_bank,
                                          in_name_org,
                                          in_is_new_org);
END PKG_BANK_INFO_$SAVE;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_BANK_INFO_$NEW_ID
RETURN INVPAY.DICT_BANK_INFO.CODE_ORG%TYPE
IS
BEGIN
  RETURN PKG_BANK_INFO.get_new_id;
END PKG_BANK_INFO_$NEW_ID;
/


CREATE OR REPLACE FUNCTION INVPAY.PKG_AUTH_$CHECK
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE,
  in_pass   INVPAY.USERS."PASSWORD"%TYPE
)
RETURN NUMBER
IS
BEGIN
  RETURN PKG_AUTH.check_user (IN_LOGGIN, IN_PASS);
END PKG_AUTH_$CHECK;
/

CREATE OR REPLACE FUNCTION INVPAY.PKG_AUTH_$LOAD_ALL 
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN PKG_AUTH.LOAD_ALL;
END PKG_AUTH_$LOAD_ALL;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_AUTH_$SAVE_USER
(
  in_fio        INVPAY.USERS.FIO%TYPE,
  in_loggin     INVPAY.USERS.LOGGIN%TYPE,
  in_code_role  INVPAY.USERS."ROLE"%TYPE,
  in_code_prog  INVPAY.USERS.CODE_PROG%TYPE
)
IS
BEGIN
  PKG_AUTH.SAVE_USER (in_fio,
                      in_loggin,
                      in_code_role,
                      in_code_prog);
END PKG_AUTH_$SAVE_USER;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_AUTH_$DEL_USER
(
  in_loggin     INVPAY.USERS.LOGGIN%TYPE
)
IS
BEGIN
  PKG_AUTH.DEL_USER (in_loggin);
END PKG_AUTH_$DEL_USER;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_AUTH_$LOCK
(
  in_loggin     INVPAY.USERS.LOGGIN%TYPE
)
IS
BEGIN
  PKG_AUTH.BLOCK_USER (in_loggin);
END PKG_AUTH_$LOCK;
/

CREATE OR REPLACE PROCEDURE INVPAY.PKG_AUTH_$UNLOCK
(
  in_loggin     INVPAY.USERS.LOGGIN%TYPE
)
IS
BEGIN
  PKG_AUTH.unlock_user (in_loggin);
END PKG_AUTH_$UNLOCK;
/

CREATE OR REPLACE FUNCTION INVPAY.pkg_nri_base_$load_role
RETURN pkg_base.tcursor
IS
BEGIN
  RETURN pkg_nri_base.load_role;
END pkg_nri_base_$load_role;
/