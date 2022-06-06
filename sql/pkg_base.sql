CREATE OR REPLACE PACKAGE INVPAY.pkg_base 
IS
/******************************************************************************/
/* Функция: описание глобальных констант, общих процедур и функций            */
/* Разработчик: Рябов Д.В.                                                    */
/* Дата создания    : 24.11.2003                                              */
/* Дата модификации : 25.09.2018                                              */
/******************************************************************************/
--------------------------------------------------------------------------------
TYPE tcursor IS REF CURSOR;
--------------------------------------------------------------------------------
  -- -1
FUNCTION index_of_null RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (index_of_null, WNDS, WNPS);
  -- -2
FUNCTION index_of_nulls RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (index_of_nulls, WNDS, WNPS);
-- Формат даты
FUNCTION dformat RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (dformat, WNDS, WNPS);
  -- строка '\ нет \'
FUNCTION string_no RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (string_no, WNDS, WNPS);
  -- строка '\ все \'
FUNCTION string_all RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (string_all, WNDS, WNPS);
  -- Символ переноса каретки
FUNCTION carriage_return RETURN CHAR;
PRAGMA RESTRICT_REFERENCES (carriage_return, WNDS, WNPS);
  -- Символ разделитель чисел
FUNCTION separator_number RETURN CHAR;
PRAGMA RESTRICT_REFERENCES (separator_number, WNDS, WNPS);
--
FUNCTION get_nls_numeric_characters RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_nls_numeric_characters, WNDS, WNPS);
-- Минимальная и максимальная дата
FUNCTION min_date RETURN DATE;
PRAGMA RESTRICT_REFERENCES (min_date, WNDS, WNPS);
FUNCTION max_date RETURN DATE;
PRAGMA RESTRICT_REFERENCES (max_date, WNDS, WNPS);
--------------------------------------------------------------------------------
FUNCTION to_null(in_value NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (to_null, WNDS, WNPS);
FUNCTION to_numberf(in_value VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (to_numberf, WNDS, WNPS);
FUNCTION to_datef(in_date VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (to_datef, WNDS, WNPS);
FUNCTION to_charf(in_date DATE) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (to_charf, WNDS, WNPS);
FUNCTION to_charf(in_number NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (to_charf, WNDS, WNPS);
FUNCTION to_charf_datel(in_date DATE, in_format_year VARCHAR2 DEFAULT 'SHORT') RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (to_charf_datel, WNDS, WNPS);
FUNCTION y(in_date DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (y, WNDS, WNPS);
FUNCTION y(in_date VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (y, WNDS, WNPS);
FUNCTION mm(in_date DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (mm, WNDS, WNPS);
FUNCTION mm(in_date VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (mm, WNDS, WNPS);
FUNCTION first_daymonth(in_month NUMBER, in_year NUMBER) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (first_daymonth, WNDS, WNPS);
FUNCTION last_daymonth(in_month NUMBER, in_year NUMBER) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (last_daymonth, WNDS, WNPS);
FUNCTION to_datetimef(in_date VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (to_datetimef, WNDS, WNPS);
FUNCTION to_charf_datetime(in_date DATE) RETURN VARCHAR;
PRAGMA RESTRICT_REFERENCES (to_charf_datetime, WNDS, WNPS);
--------------------------------------------------------------------------------
-- Получить из строки символ
PROCEDURE get_symbol
(
 in_out_str IN OUT VARCHAR2,
 in_separator_number VARCHAR2,
 out_symbol OUT VARCHAR2
);
PRAGMA RESTRICT_REFERENCES (get_symbol, WNDS, WNPS);
PROCEDURE get_symbol
(
 in_out_str IN OUT VARCHAR2,
 out_symbol OUT VARCHAR2
);
PRAGMA RESTRICT_REFERENCES (get_symbol, WNDS, WNPS);
PROCEDURE get_symbol_number_lim
(
 in_out_str IN OUT VARCHAR2,
 in_separator_number VARCHAR2,
 out_symbol OUT VARCHAR2
);
-- Получить из строки символ и преобразовать его в число
PROCEDURE get_symbol_number
(
 in_out_str IN OUT VARCHAR2,
 in_separator_number VARCHAR2,
 out_symbol OUT NUMBER
);
PRAGMA RESTRICT_REFERENCES (get_symbol_number, WNPS);
PROCEDURE get_symbol_number
(
 in_out_str IN OUT VARCHAR2,
 out_symbol OUT NUMBER
);
PRAGMA RESTRICT_REFERENCES (get_symbol_number, WNPS);
--------------------------------------------------------------------------------
-- Разделить число x на число n, округлив до m знаков
FUNCTION get_round(in_x IN NUMBER,in_n IN NUMBER,in_m IN NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (get_round, WNDS, WNPS);
--------------------------------------------------------------------------------
FUNCTION safe_to_number(p VARCHAR2) RETURN NUMBER;

END pkg_base;
/

CREATE OR REPLACE PACKAGE BODY INVPAY.pkg_base 
IS
--------------------------------------------------------------------------------
-- -1
c_index_of_null CONSTANT NUMBER := -1;
-- -2
c_index_of_nulls CONSTANT NUMBER := -2;
-- строка '\ нет \'
c_string_no CONSTANT VARCHAR2(7) := '\ нет \';
-- строка '\ все \'
c_string_all CONSTANT VARCHAR2(7) := '\ все \';
-- Формат даты
c_dformat CONSTANT VARCHAR2(10) := 'DD.MM.YYYY';
c_lformat CONSTANT VARCHAR2(18) := 'DD.MM.YYYY-HH24:MI';
-- Символ переноса каретки
c_carriage_return CONSTANT CHAR(1) := CHR(10);
-- Символ разделитель чисел
c_separator_number CONSTANT CHAR(1) := '|';
-- Минимальная и максимальная дата
c_min_date CONSTANT DATE := TO_DATE('01.01.1900', c_dformat);
c_max_date CONSTANT DATE := TO_DATE('01.01.9999', c_dformat);
--------------------------------------------------------------------------------
-- -1
FUNCTION index_of_null RETURN NUMBER IS
BEGIN
 RETURN c_index_of_null;
END index_of_null;
-- -2
FUNCTION index_of_nulls RETURN NUMBER IS
BEGIN
 RETURN c_index_of_nulls;
END index_of_nulls;
-- Формат даты
FUNCTION dformat RETURN VARCHAR2 IS
BEGIN RETURN c_dformat; END dformat;
-- строка '< нет >'
FUNCTION string_no RETURN VARCHAR2 IS
BEGIN
 RETURN c_string_no;
END string_no;
-- строка '< все >'
FUNCTION string_all RETURN VARCHAR2 IS
BEGIN
 RETURN c_string_all;
END string_all;
-- Символ переноса каретки
FUNCTION carriage_return RETURN CHAR IS
BEGIN
 RETURN c_carriage_return;
END carriage_return;
-- Символ разделитель чисел
FUNCTION separator_number RETURN CHAR IS
BEGIN
 RETURN c_separator_number;
END separator_number;
--
FUNCTION get_nls_numeric_characters RETURN VARCHAR2 IS
 v_result VARCHAR2(3);
BEGIN
 v_result := '.'; -- по умолчанию ставим разделитель разрядов - точка
 SELECT DECODE( INSTR(RTRIM(LTRIM(VALUE)), '.'), 0, ',', '.') INTO v_result
   FROM v$nls_parameters --NLS_DATABASE_PARAMETERS
  WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
 RETURN v_result;
END get_nls_numeric_characters;
-- Минимальная и максимальная дата
FUNCTION min_date RETURN DATE IS
BEGIN
 RETURN c_min_date;
END min_date;
--
FUNCTION max_date RETURN DATE IS
BEGIN
 RETURN c_max_date;
END max_date;
--------------------------------------------------------------------------------
-- Если in_Value = -1 то вернуть Null иначе само значение in_Value
FUNCTION to_null(in_value NUMBER) RETURN NUMBER IS
BEGIN
 IF in_value = c_index_of_null OR in_value = 0 THEN
  RETURN NULL;
 ELSE
  RETURN in_value;
 END IF;
END to_null;
-- Преобразует строку в число в соответсвии с форматом локальной настройки БД
FUNCTION to_numberf(in_value VARCHAR2) RETURN NUMBER
IS
 v_nls_numeric_characters VARCHAR2(1);
BEGIN
 v_nls_numeric_characters := get_nls_numeric_characters;
    IF v_nls_numeric_characters = '.' THEN
     RETURN TO_NUMBER(REPLACE(in_value, ',', v_nls_numeric_characters));
 END IF;
    IF v_nls_numeric_characters = ',' THEN
     RETURN TO_NUMBER(REPLACE(in_value, '.', v_nls_numeric_characters));
    END IF;
END to_numberf;
-- Преобразует строку в дату в соответсвии с форматом
FUNCTION to_datef(in_date VARCHAR2) RETURN DATE
IS
BEGIN
 RETURN TO_DATE(in_date, c_dformat);
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END to_datef;
-- Преобразует дату в строку в соответсвии с форматом
FUNCTION to_charf(in_date DATE) RETURN VARCHAR2
IS
BEGIN
 RETURN TO_CHAR(in_date, c_dformat);
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
 END to_charf;
-- Преобразовать Number в Vachar2 учитывая ноль для лробных чисел
FUNCTION to_charf(in_number NUMBER) RETURN VARCHAR2
IS
 v_result VARCHAR2(200);
BEGIN
 v_result := TO_CHAR(in_number);
 IF in_number < 1 AND in_number > 0 THEN
  v_result := '0' || v_result;
 END IF;
 IF in_number > -1 AND in_number < 0 THEN
  v_result := REPLACE(v_result, '-', '-0');
 END IF;
 RETURN v_result;
END to_charf;
-- Преобразовать дату в формат вида "25 января 2002 г."
FUNCTION to_charf_datel(in_date DATE, in_format_year VARCHAR2 DEFAULT 'SHORT') RETURN VARCHAR2
IS
 v_day   NUMBER(2);
 v_month NUMBER(2);
 v_year  NUMBER(4);
 TYPE array_month IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
 a_month array_month;
 l_year  VARCHAR2(5) := '';
BEGIN
 IF in_date IS NULL THEN
  RETURN NULL;
 END IF;
 a_month(1) := 'января';
 a_month(2) := 'февраля';
 a_month(3) := 'марта';
 a_month(4) := 'апреля';
 a_month(5) := 'мая';
 a_month(6) := 'июня';
 a_month(7) := 'июля';
 a_month(8) := 'августа';
 a_month(9) := 'сентября';
 a_month(10) := 'октября';
 a_month(11) := 'ноября';
 a_month(12) := 'декабря';
 v_day := TO_NUMBER(TO_CHAR(in_date, 'DD'));
 v_month := TO_NUMBER(TO_CHAR(in_date, 'MM'));
 v_year := TO_NUMBER(TO_CHAR(in_date, 'YYYY'));
 IF in_format_year = 'SHORT' THEN
   l_year := 'г.';
 ELSE
   l_year := 'года';
 END IF;
 RETURN v_day || ' ' || a_month(v_month) || ' ' || v_year || ' ' || l_year;
END to_charf_datel;
-- Выделить из даты год
FUNCTION y(in_date DATE) RETURN NUMBER
IS
BEGIN
 RETURN TO_NUMBER(TO_CHAR(in_date, 'YYYY'));
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END y;
-- Выделить из даты год
FUNCTION y(in_date VARCHAR2) RETURN NUMBER
IS
BEGIN
 RETURN TO_NUMBER(TO_CHAR(to_datef(in_date), 'YYYY'));
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END y;
-- Выделить из даты месяц
FUNCTION mm(in_date DATE) RETURN NUMBER
IS
BEGIN
 RETURN TO_NUMBER(TO_CHAR(in_date, 'MM'));
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END mm;
-- Выделить из даты месяц
FUNCTION mm(in_date VARCHAR2) RETURN NUMBER
IS
BEGIN
 RETURN TO_NUMBER(TO_CHAR(to_datef(in_date), 'MM'));
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END mm;
-- Вернуть первое число месяца
FUNCTION first_daymonth(in_month NUMBER, in_year NUMBER) RETURN DATE
IS
 v_date VARCHAR(10);
BEGIN
 v_date := '01.' || LPAD(TO_CHAR(in_month), 2, '0') || '.' || TO_CHAR(in_year);
 RETURN to_datef(v_date);
 EXCEPTION
  WHEN OTHERS THEN
   RETURN NULL;
END first_daymonth;
-- Вернуть последнее число месяца
FUNCTION last_daymonth(in_month NUMBER, in_year NUMBER) RETURN DATE
IS
BEGIN
 RETURN LAST_DAY(first_daymonth(in_month, in_year));
 EXCEPTION
  WHEN OTHERS THEN
   RETURN NULL;
END last_daymonth;
--------------------------------------------------------------------------------
FUNCTION to_datetimef(in_date VARCHAR2) RETURN DATE
IS
BEGIN
 RETURN TO_DATE(in_date, c_lformat);
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END;
--------------------------------------------------------------------------------
FUNCTION to_charf_datetime(in_date DATE) RETURN VARCHAR
IS
BEGIN
 RETURN TO_CHAR(in_date, c_lformat);
 EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END;
--------------------------------------------------------------------------------
PROCEDURE get_symbol
-- Получить из строки символ
(
 in_out_str          IN OUT VARCHAR2,
 in_separator_number        VARCHAR2,
 out_symbol             OUT VARCHAR2
)
IS
 v_n NUMBER(3);
BEGIN
 v_n := INSTR(in_out_str, in_separator_number);
 IF v_n > 0 THEN
  out_symbol := SUBSTR(in_out_str, 1, v_n - 1);
  in_out_str := SUBSTR(in_out_str, v_n + 1);
 ELSE
  IF LENGTH(in_out_str) > 0 THEN
   out_symbol := in_out_str;
   in_out_str := NULL;
  END IF;
 END IF;
END get_symbol;
--------------------------------------------------------------------------------
PROCEDURE get_symbol
-- Получить из строки символ
(
 in_out_str IN OUT VARCHAR2,
 out_symbol    OUT VARCHAR2
)
IS
BEGIN
 get_symbol(in_out_str, c_separator_number, out_symbol);
END get_symbol;
--------------------------------------------------------------------------------
PROCEDURE get_symbol_number
-- Получить из строки символ и преобразовать его в число
(
 in_out_str          IN OUT VARCHAR2,
 in_separator_number        VARCHAR2,
 out_symbol             OUT NUMBER
)
IS
 v_symbol VARCHAR2(255);
BEGIN
 get_symbol(in_out_str, in_separator_number, v_symbol);
 out_symbol := pkg_base.to_numberf(NVL(v_symbol, '0'));
END get_symbol_number;

PROCEDURE get_symbol_number_lim
-- Получить из строки символ и преобразовать его в число
(
 in_out_str          IN OUT VARCHAR2,
 in_separator_number        VARCHAR2,
 out_symbol             OUT VARCHAR2
)
IS
 v_symbol VARCHAR2(255);
BEGIN
 get_symbol(in_out_str, in_separator_number, v_symbol);
 out_symbol := v_symbol;
END get_symbol_number_lim;
--------------------------------------------------------------------------------
PROCEDURE get_symbol_number
-- Получить из строки символ и преобразовать его в число
(
 in_out_str IN OUT VARCHAR2,
 out_symbol    OUT NUMBER
)
IS
BEGIN
 get_symbol_number(in_out_str, c_separator_number, out_symbol);
END get_symbol_number;
--------------------------------------------------------------------------------
FUNCTION get_round
-- Разделить число x на число n, округлив до m знаков
(
 in_x IN NUMBER,
 in_n IN NUMBER,
 in_m IN NUMBER
)
RETURN NUMBER
IS
BEGIN
 RETURN ROUND(NVL(in_x, 0) / in_n, in_m);
END;
--------------------------------------------------------------------------------
FUNCTION safe_to_number
(
    p VARCHAR2
)
RETURN NUMBER
IS
  v NUMBER;
BEGIN
    v := to_number(p);
    return v;
  exception when others then return -1;
END;

END pkg_base;
/