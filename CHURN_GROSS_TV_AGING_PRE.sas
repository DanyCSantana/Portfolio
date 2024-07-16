OPTIONS COMPRESS = YES 
        REUSE = YES
        OBS = MAX;

Libname PLNTA '/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/PLNT/TV';
Libname RET '/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/RETIRADAS/TV';
LIBNAME	GROSS_TV '/sasdata/ger_trafego_mkt/TV';

proc datasets library=WORK kill; run; quit;

%MACRO ANOMES_RET (M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12,M13,M14,M15,M16);

DATA WORK.RET_TV_2018;
SET RET.RET_TV_&M1. 
    RET.RET_TV_&M2. 
    RET.RET_TV_&M3. 
    RET.RET_TV_&M4. 
    RET.RET_TV_&M5. 
    RET.RET_TV_&M6. 
    RET.RET_TV_&M7. 
    RET.RET_TV_&M8. 
    RET.RET_TV_&M9. 
    RET.RET_TV_&M10.
    RET.RET_TV_&M11.
    RET.RET_TV_&M12.
    RET.RET_TV_&M13.
    RET.RET_TV_&M14.
    RET.RET_TV_&M15.
    RET.RET_TV_&M16.;
RUN;

%MEND ANOMES_RET;
%ANOMES_RET
(201806
,201807
,201808
,201809
,201810
,201811
,201812
,201901
,201902
,201903
,201904
,201905
,201906
,201907
,201908
,201909);

%MACRO ANOMES (MES_REF);

DATA WORK.GRO_&MES_REF.;
SET GROSS_TV.GROSS_&MES_REF. 
(KEEP=INDICADOR CONTRATO IND_COMBO TIPO_PRODUTO FORMA_PGTO TIPO_CONTRATO PLANO ANOMES GRUPO_UNIDADE DATA_HABILITACAO);
WHERE TIPO_PRODUTO <> 'TV ANTENEIROS PRE-PAGO' AND GRUPO_UNIDADE = 'VAREJO';
RUN;

DATA WORK.MIG_&MES_REF.;
SET GROSS_TV.GROSSMIG_&MES_REF. 
(KEEP=INDICADOR CONTRATO IND_COMBO TIPO_PRODUTO_ATUAL FORMA_PGTO TIPO_CONTRATO PLANO_ATUAL ANOMES GRUPO_UNIDADE DATA_HABILITACAO);
WHERE TIPO_PRODUTO_ATUAL <> 'TV ANTENEIROS PRE-PAGO' AND GRUPO_UNIDADE = 'VAREJO';
RENAME TIPO_PRODUTO_ATUAL = TIPO_PRODUTO;
RENAME PLANO_ATUAL = PLANO;
RUN;

DATA WORK.GROSSS_&MES_REF.;
SET WORK.GRO_&MES_REF.
    WORK.MIG_&MES_REF.;
RUN;

PROC SQL;
CREATE TABLE WORK.GROSS_&MES_REF. AS
SELECT T1.*,
T2.FAIXA_AGING
FROM WORK.GROSSS_&MES_REF. T1 LEFT JOIN TV.PLANTA_TV_PRE_&MES_REF. T2
ON T1.CONTRATO = T2.CONTRATO;
QUIT;

DATA RET_ACUM_&MES_REF.;
SET WORK.RET_TV_2018;
WHERE ANOMES_RETIRADA >= &MES_REF;
RUN;

PROC SQL;

CREATE TABLE RET_SAFRA_&MES_REF. AS 

SELECT    T1.*, 
          T2.ANOMES_RETIRADA, 
          T2.DATA_RETIRADA_TV,
          T2.INDICADOR AS INDICADOR_CHURN, 
		  T2.TIPO_RETIRADA,

          CASE 
          WHEN (T2.ANOMES_RETIRADA - INPUT(T1.ANOMES,8.))>12 THEN (T2.ANOMES_RETIRADA - INPUT(T1.ANOMES,8.)) - 88 ELSE (T2.ANOMES_RETIRADA - INPUT(T1.ANOMES,8.)) END  AS AGING_RETIRADA,

          CASE
          WHEN T2.DATA_RETIRADA_TV IS NULL THEN ''
          WHEN ((T2.DATA_RETIRADA_TV - INPUT(T1.DATA_HABILITACAO, yymmdd8.)) /30) <= 3  THEN '1 - DE 0 A 3 MESES'
          WHEN ((T2.DATA_RETIRADA_TV - INPUT(T1.DATA_HABILITACAO, yymmdd8.)) /30) <= 6  THEN '2 - DE 3 A 6 MESES'
          WHEN ((T2.DATA_RETIRADA_TV - INPUT(T1.DATA_HABILITACAO, yymmdd8.)) /30) <= 9  THEN '3 - DE 6 A 9 MESES'
          WHEN ((T2.DATA_RETIRADA_TV - INPUT(T1.DATA_HABILITACAO, yymmdd8.)) /30) <= 12 THEN '4 - DE 9 A 12 MESES'
          WHEN ((T2.DATA_RETIRADA_TV - INPUT(T1.DATA_HABILITACAO, yymmdd8.)) /30) <= 18 THEN '5 - DE 12 A 18 MESES'
          ELSE '6 - ACIMA DE 18 MESES' END AS FAIXA_AGING_RET

     FROM WORK.GROSS_&MES_REF. T1 LEFT JOIN WORK.RET_ACUM_&MES_REF. T2 ON T1.CONTRATO = T2.CONTRATO_TV;
QUIT;

%MEND ANOMES;
%ANOMES(201806);
%ANOMES(201807);
%ANOMES(201808);
%ANOMES(201809);
%ANOMES(201810);
%ANOMES(201811);
%ANOMES(201812);
%ANOMES(201901);
%ANOMES(201902);
%ANOMES(201903);
%ANOMES(201904);
%ANOMES(201905);
%ANOMES(201906);
%ANOMES(201907);
%ANOMES(201908);
%ANOMES(201909);

DATA RET_SAFRA_2019;
SET	RET_SAFRA_201806 
	RET_SAFRA_201807 
	RET_SAFRA_201808
	RET_SAFRA_201809
	RET_SAFRA_201810
	RET_SAFRA_201811
	RET_SAFRA_201812
	RET_SAFRA_201901
	RET_SAFRA_201902
	RET_SAFRA_201903
        RET_SAFRA_201904
        RET_SAFRA_201905
        RET_SAFRA_201906
	RET_SAFRA_201907
        RET_SAFRA_201908
	RET_SAFRA_201909;
RUN; 


PROC SQL;
CREATE TABLE COUNT_RET_SAFRA_2019 AS
SELECT 
ANOMES,
INDICADOR,
IND_COMBO,
TIPO_PRODUTO,
FORMA_PGTO,
TIPO_CONTRATO,
PLANO,
ANOMES_RETIRADA,
INDICADOR_CHURN,
TIPO_RETIRADA,
AGING_RETIRADA,
FAIXA_AGING,
COUNT(CONTRATO) AS TOTAL
FROM WORK.RET_SAFRA_2019
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12;
QUIT;



