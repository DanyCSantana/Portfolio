/*-----------------------------------------------------------------------------------------------------*/
/*CHURN_SAFRADO*/

OPTIONS OBS = MAX
          REUSE = YES
          COMPRESS = YES;

LIBNAME TEMPORA "/sasdata/varejo/ger_var_banda_larga/Temporario_sera_apagado/SVOI/"; 
LIBNAME RET_BL  "/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/RETIRADAS/VELOX";
LIBNAME GROSS   "/sasdata/ger_trafego_mkt/AQUISICAO/GROSS";
LIBNAME WAR     "/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/WAR";
LIBNAME PLANTA "/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/PLNT/FIXO_BL_TV";

%MACRO A (ANOMES);

DATA GROSS_&ANOMES.;
SET GROSS.GROSS_VELOX_&ANOMES.;
SAFRA = &ANOMES.;
CPF_FIM = INPUT(CPF_CNPJ,11.);
DDD_TERMINAL = CAT(DDD,INPUT(NUM_TERMINAL,8.));
DROP QTD_REAGENDAMENTO_CLICK;
DROP CPF_CNPJ;
DROP cnpj_pdv;
DROP contrato;
RUN;

%MEND A;
%A (201701);
%A (201702);
%A (201703);
%A (201704);
%A (201705);
%A (201706);
%A (201707);
%A (201708);
%A (201709);
%A (201710);
%A (201711);
%A (201712);
%A (201801);
%A (201802);
%A (201803);
%A (201804);

DATA GROSS_TT;
SET
GROSS_201701
GROSS_201702
GROSS_201703
GROSS_201704
GROSS_201705
GROSS_201706
GROSS_201707
GROSS_201708
GROSS_201709
GROSS_201710
GROSS_201711
GROSS_201712
GROSS_201801
GROSS_201802
GROSS_201803
GROSS_201804;
RUN;

DATA RETIRADA_TT;
SET
RET_BL.RET_BL_201701
RET_BL.RET_BL_201702
RET_BL.RET_BL_201703
RET_BL.RET_BL_201704
RET_BL.RET_BL_201705
RET_BL.RET_BL_201706
RET_BL.RET_BL_201707
RET_BL.RET_BL_201708
RET_BL.RET_BL_201709
RET_BL.RET_BL_201710
RET_BL.RET_BL_201711
RET_BL.RET_BL_201712
RET_BL.RET_BL_201801
RET_BL.RET_BL_201802
RET_BL.RET_BL_201803
RET_BL.RET_BL_201804
RET_BL.RET_BL_201805
RET_BL.RET_BL_201806
RET_BL.RET_BL_201807
RET_BL.RET_BL_201808
RET_BL.RET_BL_201809
RET_BL.RET_BL_201810
RET_BL.RET_BL_201811
RET_BL.RET_BL_201812;
RUN;

DATA RETIRADA_TT;
SET RETIRADA_TT;
DDD_TERMINAL = PUT(DDD_TELEFONE,10.);
RUN;

PROC SORT DATA=RETIRADA_TT; BY DDD_TELEFONE ANOMES_RETIRADA; RUN;
PROC SORT DATA=RETIRADA_TT NODUPKEY; BY DDD_TELEFONE;RUN;

DATA WORK.PLANTA_TT;
SET
PLANTA.PLANTA_FX_BL_TV_OIT_201701_T
PLANTA.PLANTA_FX_BL_TV_OIT_201702_T;
/*PLANTA.PLANTA_FX_BL_TV_OIT_201703_T
PLANTA.PLANTA_FX_BL_TV_OIT_201704_T
PLANTA.PLANTA_FX_BL_TV_OIT_201705_T
PLANTA.PLANTA_FX_BL_TV_OIT_201706_T
PLANTA.PLANTA_FX_BL_TV_OIT_201707_T
PLANTA.PLANTA_FX_BL_TV_OIT_201708_T
PLANTA.PLANTA_FX_BL_TV_OIT_201709_T
PLANTA.PLANTA_FX_BL_TV_OIT_201710_T
PLANTA.PLANTA_FX_BL_TV_OIT_201711_T
PLANTA.PLANTA_FX_BL_TV_OIT_201712_T
PLANTA.PLANTA_FX_BL_TV_OIT_201801_T
PLANTA.PLANTA_FX_BL_TV_OIT_201802_T
PLANTA.PLANTA_FX_BL_TV_OIT_201803_T;*/
RUN;

DATA WORK.GROSS_TTT; 
SET WORK.GROSS_TT;
DDD_TERMINAL_NOVO = INPUT(DDD_TERMINAL,10.);
RUN;

PROC SQL;
   CREATE TABLE WORK.GROSS_TT1 AS 
   SELECT t1.IND_COMBO, 
          t1.GRUPO_UNIDADE, 
          t1.TIPO_POSSE, 
          t1.CLASSIFICACAO_COMBO, 
          t1.SAFRA, 
          t1.DDD_TERMINAL_NOVO, 
          t2.DDD_TELEFONE, 
          t2.ALONE_OIT_FINAL, 
          t2.POSSE_GERENCIAL_RESIDENCIAL 
		   FROM WORK.GROSS_TTT t1
           LEFT JOIN PLANTA_TT t2 ON (t1.DDD_TERMINAL_NOVO = t2.DDD_TELEFONE);
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_GROSS_TT2 AS 
   SELECT t1.IND_COMBO, 
          t1.GRUPO_UNIDADE, 
          t1.TIPO_POSSE, 
          t1.CLASSIFICACAO_COMBO, 
          t1.SAFRA, 
          t1.DDD_TERMINAL_NOVO, 
          t1.ALONE_OIT_FINAL, 
          t1.POSSE_GERENCIAL_RESIDENCIAL, 
		  t2.TIPO_RETIRADA, 
          t2.ANOMES_RETIRADA
          FROM WORK.GROSS_TT1 t1
      LEFT JOIN WORK.RETIRADA_TT t2 ON (t1.DDD_TERMINAL_NOVO = t2.DDD_TELEFONE);
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_GROSS_TT2_0000(label="QUERY_FOR_GROSS_TT2") AS 
   SELECT t1.SAFRA, 
          t1.ANOMES_RETIRADA, 
          t1.TIPO_RETIRADA, 
		   t1.TIPO_POSSE,
          t1.POSSE_GERENCIAL_RESIDENCIAL, 
          t1.IND_COMBO, 
          t1.CLASSIFICACAO_COMBO, 
          t1.ALONE_OIT_FINAL, 
          /* COUNT_of_DDD_TELEFONE */
            (COUNT(t1.DDD_TERMINAL_NOVO)) AS CLIENTES
      FROM WORK.QUERY_FOR_GROSS_TT2 t1
      WHERE t1.TIPO_POSSE = '2P' AND t1.GRUPO_UNIDADE = 'VAREJO'
      GROUP BY t1.SAFRA,
               t1.ANOMES_RETIRADA,
               t1.TIPO_RETIRADA,
			    t1.TIPO_POSSE,
               t1.POSSE_GERENCIAL_RESIDENCIAL,
               t1.IND_COMBO,
               t1.CLASSIFICACAO_COMBO,
               t1.ALONE_OIT_FINAL;
QUIT;

PROC SQL;
   CREATE TABLE WORK.GROSS_F AS 
   SELECT t1.IND_COMBO, 
          t1.GRUPO_UNIDADE, 
          t1.TIPO_POSSE, 
          t1.CLASSIFICACAO_COMBO, 
		t1.DDD,
		t1.NUM_TERMINAL 
         FROM BI_ADHOC.BOV_RELAT_REG_VELOX_INSTALACAO;
QUIT;

DATA WORK.GROSS_FF; 
SET WORK.GROSS_F;
DDD_TERMINAL = CAT(DDD,INPUT(NUM_TERMINAL,8.));
RUN;

/*-----------------------------------------------------------------------------------------------------*/
/*AGING_BL_OIT*/

LIBNAME OIT "/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/OIT";
LIBNAME RET_BL "/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/RETIRADAS/VELOX";
LIBNAME PLANTA "/sasdata/ger_trafego_mkt/RETENCAO/RETENCAO/PLNT/FIXO_BL_TV";

%MACRO AGING(MES,MESANT);

PROC SORT DATA=NBA_OIT_&MES. NODUPKEY;BY DDD_TELEFONE;RUN;

DATA WORK.PLANTA_&MESANT.;
SET PLANTA.PLANTA_FX_BL_TV_OIT_&MESANT._T;
RUN;

PROC SORT DATA=WORK.PLANTA_&MESANT. NODUPKEY;BY DDD_TELEFONE;RUN;

PROC SQL;
   CREATE TABLE WORK.CHURN_AGING_&MES. AS 
   SELECT B.ANOMES, 
   		  A.ANOMES_PLANTA,
          A.POSSE_GERENCIAL_COMPLETA, 
		  B.TP_PRODUTO_OITOTAL,
          A.FAIXA_TEMPO_BASE_BL,
 CASE WHEN A.DDD_TELEFONE IS NULL THEN 0 ELSE A.DDD_TELEFONE END AS DDD_TELEFONE_PLANTA,
 CASE WHEN B.DDD_TELEFONE IS NULL THEN 0 ELSE B.DDD_TELEFONE END AS DDD_TELEFONE_NBA
       	  FROM WORK.NBA_OIT_&MES. B
		  LEFT JOIN WORK.PLANTA_&MESANT. A ON (A.DDD_TELEFONE = B.DDD_TELEFONE)
		  WHERE B.STATUS_FINAL_BANDA_LARGA = 'Cancelado' AND B.FLAG_STATUS = 0;
QUIT;

%MEND AGING;
/*------------(MES,MESANT)-----*/
%AGING (201905,201904);

DATA CHURN_AGING_T;
SET 
CHURN_AGING_201901 - CHURN_AGING_201905;
RUN;

DATA WORK.CHURN_AGING_T;
SET WORK.CHURN_AGING_T;
IF FAIXA_TEMPO_BASE_BL = ' ' AND DDD_TELEFONE_PLANTA = DDD_TELEFONE_NBA THEN FAIXA_TEMPO_BASE_BL_II = '4_2Anos+'; ELSE
IF FAIXA_TEMPO_BASE_BL = ' ' AND DDD_TELEFONE_PLANTA = 0 THEN FAIXA_TEMPO_BASE_BL_II = '0_M0aM3'; ELSE
FAIXA_TEMPO_BASE_BL_II = FAIXA_TEMPO_BASE_BL;
RUN;

PROC SQL;
   CREATE TABLE WORK.CHURN_AGING_T AS 
   SELECT ANOMES, 
          TP_PRODUTO_OITOTAL, 
          FAIXA_TEMPO_BASE_BL, 
          (COUNT(ANOMES)) AS QTD
      FROM WORK.CHURN_AGING
      GROUP BY ANOMES,
               TP_PRODUTO_OITOTAL,
               FAIXA_TEMPO_BASE_BL;
QUIT;

/*-----------------------------------------------------------------------------------------------------*/
/*OFERTA_ACEITA_UF*/

DATA CHAMADAS;
SET WORK.NBA_OIT_201904
WORK.NBA_OIT_201905
WORK.NBA_OIT_201906;
RUN;

PROC SQL;
CREATE TABLE OFERTAS AS 
SELECT
ANOMES,
TP_PRODUTO_OITOTAL,
RESULTADO,
COD_UF,
COD_CAMPANHA_ACEITA_OITOTAL
FROM CHAMADAS
WHERE FLAG_STATUS = 0 AND COD_UF = 'SC' AND
COD_CAMPANHA_ACEITA_OITOTAL IN
('OT_MAE19_SMART_WEB_FID_SCOM_START_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_SCOM_START_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_SCOM_START_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_SCOM_START_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_SCOM_START_14GB_BL5',
'OT_MAE19_AVA_WEB_FID_SCOM_MIX_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_SCOM_MIX_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_SCOM_MIX_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_SCOM_MIX_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_SCOM_MIX_20GB_BL5.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL5.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL5.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL2.',
'OT_MAE19_AVA_WEB_FID_SCOM_MIXFIL_20GB_BL5.',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL5.',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-HBO-TLC_40GB_BL5.',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-CINE_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-CINE_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-CINE_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-CINE_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_SCOM_TOT-CINE_40GB_BL5.',
'OT_MAE19_SMART_WEB_FID_CONEC_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_CONEC_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_CONEC_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_CONEC_14GB_BL2',
'OT_MAE19_SMART_WEB_FID_CONEC_14GB_BL5',
'OT_MAE19_AVA_WEB_FID_CONEC_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_CONEC_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_CONEC_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_CONEC_20GB_BL2',
'OT_MAE19_AVA_WEB_FID_CONEC_20GB_BL5.',
'OT_MAE19_TOP_ESP_FID_CONEC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_CONEC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_CONEC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_CONEC_40GB_BL2',
'OT_MAE19_TOP_ESP_FID_CONEC_40GB_BL5.',
'OT_MAE19_LIGHT_FID_RES_LIVRE_BL2',
'OT_MAE19_LIGHT_FID_RES_LIVRE_BL2',
'OT_MAE19_LIGHT_FID_RES_LIVRE_BL2',
'OT_MAE19_LIGHT_FID_RES_LIVRE_BL2',
'OT_MAE19_LIGHT_FID_RES_LIVRE_BL5',
'OT_MAE19_SMART_WEB_FID_RES_START_BL2',
'OT_MAE19_SMART_WEB_FID_RES_START_BL2',
'OT_MAE19_SMART_WEB_FID_RES_START_BL2',
'OT_MAE19_SMART_WEB_FID_RES_START_BL2',
'OT_MAE19_SMART_WEB_FID_RES_START_BL5',
'OT_MAE19_AVA_WEB_FID_RES_MIX_BL2',
'OT_MAE19_AVA_WEB_FID_RES_MIX_BL2',
'OT_MAE19_AVA_WEB_FID_RES_MIX_BL2',
'OT_MAE19_AVA_WEB_FID_RES_MIX_BL2',
'OT_MAE19_AVA_WEB_FID_RES_MIX_BL5.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL5.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL5.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL2.',
'OT_MAE19_AVA_WEB_FID_RES_MIXFIL_BL5.',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL5.',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL2',
'OT_MAE19_TOP_FID_RES_TOT-HBO-TLC_BL5.',
'OT_MAE19_TOP_FID_RES_TOT-CINE_BL2',
'OT_MAE19_TOP_FID_RES_TOT-CINE_BL2',
'OT_MAE19_TOP_FID_RES_TOT-CINE_BL2',
'OT_MAE19_TOP_FID_RES_TOT-CINE_BL2',
'OT_MAE19_TOP_FID_RES_TOT-CINE_BL5.',
'OT_MAE19_SMART_FID_TV1_START',
'OT_MAE19_AVA_FID_TV2_MIX',
'OT_MAE19_TOP_FID_TV3_TOTAL-HBO-TLC',
'OT_MAE19_TOP_FID_TV3_TOTAL-HBO-TLC',
'OT_MAE19_TOP_FID_TV3_TOTAL-HBO-TLC',
'OT_MAE19_TOP_FID_TV3_TOTAL-CINEMA');
QUIT;