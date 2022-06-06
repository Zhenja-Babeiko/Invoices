CREATE OR REPLACE FORCE VIEW INVPAY.V_INVOICES (
  ID_INVOICE,
  NUM_INVOICE,
  DATE_INVOICE,
  CODE_ORG,
  NAME_ORG,
  CODE_PROG,
  NAME_PROG_FULL,
  SUMM_INVOICE,
  IS_PAID,
  DATE_PAID,
  SUM_PAID,
  NOTE,
  IS_EXTENSION,
  DATE_START_EXT,
  DATE_END_EXT,
  DATE_CURR_KEY,
  COUNT_MONTH
) AS
    SELECT I.ID_INVOICE,
           I.NUM_INVOICE,
           I.DATE_INVOICE,
           I.CODE_ORG,
           NVL(O."NAME", dbi.NAME_ORG),
           I.CODE_PROG,
           DP.NAME_PROG_FULL,
           SUM(ipp.COST_ALL),
           DECODE(I.DATE_PAID, NULL, 0, 1),
           I.DATE_PAID,
           I.SUM_PAID,
           I.NOTE,
           DECODE(I.DATE_START_EXT, NULL, 0, 1),
           I.DATE_START_EXT,
           I.DATE_END_EXT,
           iKey.DATE_END_EXT,
           DECODE(i.CODE_PROG, 1, ipp.COUNT, 0) --для лесопользования возвращаем кол-во месяцев
      FROM INVOICE i
        INNER JOIN DICT_PROG dp
          ON I.CODE_PROG = DP.CODE_PROG
        LEFT JOIN ICS."ORGANIZATION" o
          ON I.CODE_ORG = O.ID
        LEFT JOIN INVPAY.DICT_BANK_INFO dbi
          ON dbi.CODE_ORG = I.CODE_ORG
        LEFT JOIN INVOICE_PROG_POINT ipp
          ON I.ID_INVOICE = IPP.ID_INVOICE
        LEFT JOIN (SELECT PKG_BASE.TO_CHARF(MAX(PKG_BASE.TO_DATEF(DATE_END_EXT))) DATE_END_EXT,
                          CODE_ORG,
                          CODE_PROG
            FROM INVOICE
            GROUP BY CODE_ORG,
                     CODE_PROG) iKey
          ON iKey.CODE_ORG = i.CODE_ORG
          AND iKey.CODE_PROG = i.CODE_PROG
      GROUP BY I.ID_INVOICE,
               I.NUM_INVOICE,
               I.DATE_INVOICE,
               I.CODE_ORG,
               NVL(O."NAME", dbi.NAME_ORG),
               I.CODE_PROG,
               DP.NAME_PROG_FULL,
               DECODE(I.DATE_PAID, NULL, 0, 1),
               I.DATE_PAID,
               I.SUM_PAID,
               I.NOTE,
               DECODE(I.DATE_START_EXT, NULL, 0, 1),
               I.DATE_START_EXT,
               I.DATE_END_EXT,
               iKey.DATE_END_EXT,
               DECODE(i.CODE_PROG, 1, ipp.COUNT, 0)
      ORDER BY DECODE(I.DATE_PAID, NULL, 0, 1),
               DECODE(I.DATE_START_EXT, NULL, 0, 1),
               pkg_base.to_datef(I.DATE_INVOICE) DESC,
               i.NUM_INVOICE DESC;
/