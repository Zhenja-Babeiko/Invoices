CREATE OR REPLACE PACKAGE INVPAY.PKG_AUTH 
IS

FUNCTION check_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE,
  in_pass   INVPAY.USERS."PASSWORD"%TYPE
)
RETURN NUMBER;
--------------------------------------
FUNCTION load_all
RETURN pkg_base.tcursor;
--------------------------------------
PROCEDURE save_user
(
  in_fio        INVPAY.USERS.FIO%TYPE,
  in_loggin     INVPAY.USERS.LOGGIN%TYPE,
  in_code_role  INVPAY.USERS."ROLE"%TYPE,
  in_code_prog  INVPAY.USERS.CODE_PROG%TYPE
);
--------------------------------------
PROCEDURE del_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE
);
--------------------------------------
PROCEDURE block_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE
);
--------------------------------------
PROCEDURE unlock_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE
);
--------------------------------------
FUNCTION gel_str_prog_name
(
 in_code_prog INVPAY.USERS.CODE_PROG%TYPE
)
RETURN VARCHAR2;

END PKG_AUTH;
/

CREATE OR REPLACE PACKAGE BODY INVPAY.PKG_AUTH 
IS

FUNCTION check_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE,
  in_pass   INVPAY.USERS."PASSWORD"%TYPE
)
RETURN NUMBER
IS
 l_result NUMBER; -- 0-пользователя нет в списке, 1-пользователь есть, 2-пользователь есть, но нет пароля, 3 - заблокирован
 l_is_block NUMBER;
BEGIN
 --если есть совпадение, то вернет 1, иначе 0
  SELECT COUNT(*) INTO L_RESULT FROM INVPAY.USERS
  WHERE LOGGIN = IN_LOGGIN AND "PASSWORD" = IN_PASS;
 
  --проверяем есть ли пользователь в списке, но без пароля, чтобы потом предложить ввести новый или он заблокирован
  IF L_RESULT = 0 THEN
      SELECT DECODE(COUNT(*), 1, 2, 0) INTO L_RESULT FROM INVPAY.USERS
      WHERE LOGGIN = IN_LOGGIN AND "PASSWORD" IS NULL;
  END IF;
  
  IF L_RESULT <> 0 THEN
    SELECT U.IS_BLOCKED INTO L_IS_BLOCK FROM INVPAY.USERS U WHERE U.LOGGIN = IN_LOGGIN;
    IF L_IS_BLOCK = 1 THEN
        L_RESULT := 3;
    END IF;
  END IF;
 
RETURN l_result;
END check_user;
--------------------------------------
FUNCTION load_all
RETURN pkg_base.tcursor
IS
 l_result pkg_base.tcursor;
BEGIN
  OPEN L_RESULT FOR
  SELECT 
     U.LOGGIN,
     DR.NAME_ROLE,
     U."ROLE" code_role,
     U.FIO,
     NVL(INVPAY.PKG_AUTH.gel_str_prog_name(U.CODE_PROG), 'Все') NAME_PROG,
     U.CODE_PROG,
     NVL(U.IS_BLOCKED,0) IS_BLOCKED
  FROM INVPAY.USERS U
    LEFT JOIN INVPAY.DICT_ROLE DR ON U."ROLE" = DR.CODE_ROLE
  ORDER BY U.FIO;

RETURN L_RESULT;
END LOAD_ALL;
--------------------------------------
FUNCTION gel_str_prog_name
(
 in_code_prog INVPAY.USERS.CODE_PROG%TYPE
)
RETURN VARCHAR2
IS
  l_resutl VARCHAR2(256 BYTE);
BEGIN
   FOR vData IN (SELECT
                  DP.NAME_PROG_SHORT
                 FROM INVPAY.DICT_PROG DP
                 WHERE INSTR('|' || IN_CODE_PROG || '|', '|' || DP.CODE_PROG || '|', 1) <> 0)
   LOOP
     L_RESUTL := CASE
                  WHEN L_RESUTL IS NULL THEN vData.NAME_PROG_SHORT
                  ELSE L_RESUTL || ',' || vData.NAME_PROG_SHORT
                 END;
   END LOOP;

RETURN L_RESUTL;
END GEL_STR_PROG_NAME;
--------------------------------------
PROCEDURE save_user
(
  in_fio        INVPAY.USERS.FIO%TYPE,
  in_loggin     INVPAY.USERS.LOGGIN%TYPE,
  in_code_role  INVPAY.USERS."ROLE"%TYPE,
  in_code_prog  INVPAY.USERS.CODE_PROG%TYPE
)
IS
 l_result NUMBER(1); -- 0 - создание, 1- обновление
BEGIN

 SELECT COUNT(*) INTO L_RESULT FROM INVPAY.USERS U WHERE U.LOGGIN = IN_LOGGIN;

 IF L_RESULT = 0 THEN
 --сохраняем
    INSERT INTO INVPAY.USERS (LOGGIN, "PASSWORD", "ROLE", FIO, CODE_PROG) VALUES (IN_LOGGIN, NULL, IN_CODE_ROLE, IN_FIO, NVL(IN_CODE_PROG, 0));
 ELSE
 --обновляем
    UPDATE INVPAY.USERS SET
    "ROLE" = IN_CODE_ROLE,
    FIO = IN_FIO,
    CODE_PROG = NVL(IN_CODE_PROG, 0)
    WHERE LOGGIN = IN_LOGGIN;
 END IF;
END SAVE_USER;
--------------------------------------
PROCEDURE del_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE
)
IS
BEGIN
  DELETE FROM INVPAY.USERS WHERE LOGGIN = IN_LOGGIN;
END DEL_USER;
--------------------------------------
PROCEDURE block_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE
)
IS
BEGIN
  UPDATE INVPAY.USERS SET IS_BLOCKED = 1 WHERE LOGGIN = IN_LOGGIN;
END BLOCK_USER;
--------------------------------------
PROCEDURE unlock_user
(
  in_loggin INVPAY.USERS.LOGGIN%TYPE
)
IS
BEGIN
  UPDATE INVPAY.USERS SET IS_BLOCKED = NULL WHERE LOGGIN = IN_LOGGIN;
END UNLOCK_USER;


END PKG_AUTH;
/