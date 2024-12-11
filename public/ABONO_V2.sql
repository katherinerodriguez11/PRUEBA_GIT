-- View: public.ABONO_V2

-- DROP VIEW public."ABONO_V2";

CREATE OR REPLACE VIEW public."ABONO_V2"
 AS
 WITH tab AS (
         SELECT
                CASE
                    WHEN ma."MAYO_DIRECTO" = 3 THEN t."MAYO_ID"
                    ELSE t."COME_ID"
                END AS "ENTI_ID",
            sum(t."TRAN_VALOR"::numeric) AS "DEBITO",
            0 AS "CREDITO"
           FROM "TRANSACCIONDIA" t
             JOIN "MAYORISTA" ma ON ma."MAYO_ID" = t."MAYO_ID"
             JOIN "MOVIMIENTO_DIA" m ON m."TRAN_ID" = t."TRAN_ID" AND t."TRAN_TIPO"::text = '22'::text AND (m."TIMO_ID" = ANY (ARRAY[15, 37, 51]))
          WHERE t."TRAN_ESTADO" = 1 AND t."TRAN_FECHA" = CURRENT_DATE
          GROUP BY (
                CASE
                    WHEN ma."MAYO_DIRECTO" = 3 THEN t."MAYO_ID"
                    ELSE t."COME_ID"
                END)
        UNION ALL
         SELECT
                CASE
                    WHEN ma."MAYO_DIRECTO" = 3 THEN t."MAYO_ID"
                    ELSE t."COME_ID"
                END AS "ENTI_ID",
            0 AS "DEBITO",
            sum(t."TRAN_VALOR"::numeric) AS "CREDITO"
           FROM "TRANSACCIONDIA" t
             JOIN "MAYORISTA" ma ON ma."MAYO_ID" = t."MAYO_ID"
          WHERE t."TRAN_ESTADO" = 1 AND t."TRAN_FECHA" = CURRENT_DATE AND (t."TRAN_TIPO"::text = ANY (ARRAY['20'::character varying::text, '21'::character varying::text]))
          GROUP BY (
                CASE
                    WHEN ma."MAYO_DIRECTO" = 3 THEN t."MAYO_ID"
                    ELSE t."COME_ID"
                END)
        )
 SELECT tab."ENTI_ID",
    sum(tab."CREDITO") - sum(tab."DEBITO") AS "VALOR"
   FROM tab
     JOIN "ENTIDAD" e ON e."ENTI_ID" = tab."ENTI_ID"
  GROUP BY tab."ENTI_ID";

ALTER TABLE public."ABONO_V2"
    OWNER TO postgres;

GRANT SELECT ON TABLE public."ABONO_V2" TO nivel_3;
GRANT INSERT, SELECT, UPDATE, REFERENCES, TRIGGER ON TABLE public."ABONO_V2" TO nivel_2;
GRANT ALL ON TABLE public."ABONO_V2" TO postgres;
GRANT ALL ON TABLE public."ABONO_V2" TO nivel_1;