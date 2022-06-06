﻿
CREATE TABLE INVPAY.INVOICE_PROG_POINT (
  ID_INV_PROG_POINT NUMBER,
  ID_INVOICE        NUMBER NOT NULL,
  NAME_UNIT         NVARCHAR2(50),
  COUNT             NUMBER,
  COST_ONE          NUMBER(7, 2),
  COST_CLEAR        NUMBER(7, 2),
  NDS               NUMBER(3, 0),
  COUNT_NDS         NUMBER(7, 2),
  COST_ALL          NUMBER(7, 2),
  CODE_PROG_POINT   NUMBER NOT NULL,
  CONSTRAINT PK_INVOICE_PROG_POINT_ID_INV_P PRIMARY KEY (ID_INV_PROG_POINT) USING INDEX TABLESPACE USERS STORAGE (INITIAL 64 K
                                                                                                                  MAXEXTENTS UNLIMITED)
)
TABLESPACE USERS
STORAGE (INITIAL 64 K
         MAXEXTENTS UNLIMITED)
LOGGING;

COMMENT ON TABLE INVPAY.INVOICE_PROG_POINT IS 'Информация о стоимости услуг в счете';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.CODE_PROG_POINT IS 'Идентификатор услуги';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.COST_ALL IS 'Стоимость итоговая';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.COST_CLEAR IS 'Стоимость всего(без НДС)';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.COST_ONE IS 'Стоимость одной еденицы';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.COUNT IS 'Количество';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.COUNT_NDS IS 'Сумма НДС';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.ID_INV_PROG_POINT IS 'Идентификатор записи';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.ID_INVOICE IS 'Идентификатор привязанного счета';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.NAME_UNIT IS 'Еденица измерения';
COMMENT ON COLUMN INVPAY.INVOICE_PROG_POINT.NDS IS 'Ставка НДС, %';

--
-- Создать внешний ключ "FK_INVOICE_PROG_POINT_CODE_PRO" для объекта типа таблица "INVPAY"."INVOICE_PROG_POINT"
--
ALTER TABLE INVPAY.INVOICE_PROG_POINT
ADD CONSTRAINT FK_INVOICE_PROG_POINT_CODE_PRO FOREIGN KEY (CODE_PROG_POINT)
REFERENCES INVPAY.DICT_PROG_POINT (CODE_PROG_POINT);

--
-- Создать внешний ключ "FK_INVOICE_PROG_POINT_ID_INVOI" для объекта типа таблица "INVPAY"."INVOICE_PROG_POINT"
--
ALTER TABLE INVPAY.INVOICE_PROG_POINT
ADD CONSTRAINT FK_INVOICE_PROG_POINT_ID_INVOI FOREIGN KEY (ID_INVOICE)
REFERENCES INVPAY.INVOICE (ID_INVOICE) ON DELETE CASCADE;

COMMIT;