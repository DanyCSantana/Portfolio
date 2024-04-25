OPTIONS COMPRESS = YES 
		REUSE = YES
		OBS = MAX;

LIBNAME PLANTA "/sasdata/ger_trafego_mkt/RETENTION/RETENTION/PLNT/LANDLINE_BROADBAND_TV";
LIBNAME DANYELLA "/sasdata/ger_trafego_mkt/RETENTION/RETENTION/AD_HOC/DANYELLA";

/*------------------- PLANTAS UP TO M-1 -------------------*/

%MACRO REF (MES);

DATA PLANTA_LANDLINE_BROADBAND_TV_OIT_&MES.;
SET  PLANTA.PLANTA_LANDLINE_BROADBAND_TV_OIT_&MES._T (KEEP=ANOMES_PLANTA ALONE_OIT_FINAL POSSE_GERENCIAL_RESIDENCIAL POSSE_GERENCIAL_COMPLETA RANGE_AGING_LANDLINE RANGE_AGING_BROADBAND RANGE_AGING_TV RANGE_AGING_OIT QTD_UGR);
RUN;

%MEND REF;
%REF(201905);
%REF(201906);
%REF(201907);

DATA PLANTA_FINAL_FULL;
SET 
PLANTA_LANDLINE_BROADBAND_TV_OIT_201905
PLANTA_LANDLINE_BROADBAND_TV_OIT_201906
PLANTA_LANDLINE_BROADBAND_TV_OIT_201907;
RUN;

/*Data Processing*/

PROC SQL;
   CREATE TABROADBANDE WORK.PLANTA_FINAL_FULL_II AS 
   SELECT t1.ANOMES_PLANTA, 
          t1.ALONE_OIT_FINAL, 
	  t1.POSSE_GERENCIAL_COMPLETA,
          t1.POSSE_GERENCIAL_RESIDENCIAL, 
          t1.RANGE_AGING_LANDLINE, 
          t1.RANGE_AGING_BROADBAND, 
          t1.RANGE_AGING_TV, 
          t1.RANGE_AGING_OIT, 
          /* SUM_of_QTD_UGR */
            (SUM(t1.QTD_UGR)) AS SUM_of_QTD_UGR
      FROM PLANTA_FINAL_FULL t1
      GROUP BY t1.ANOMES_PLANTA,
               t1.ALONE_OIT_FINAL,
	       t1.POSSE_GERENCIAL_COMPLETA,
               t1.POSSE_GERENCIAL_RESIDENCIAL,
               t1.RANGE_AGING_LANDLINE,
               t1.RANGE_AGING_BROADBAND,
               t1.RANGE_AGING_TV,
               t1.RANGE_AGING_OIT;
QUIT;

PROC EXPORT 
    DATA = PLANTA_FINAL_FULL_II
    OUTFILE= "/sasdata/ger_trafego_mkt/RETENTION/RETENTION/AD_HOC/DANYELLA/PLANTA_FINAL_BOOK.txt" 
    DBMS = TAB REPLACE;
RUN;

/*BUDGET: PARTITION CHANGES BY AGING*/

DATA DANYELLA.PLANTA_LANDLINE_BROADBAND_TV_OIT_201812;
SET PLANTA.PLANTA_LANDLINE_BROADBAND_TV_OIT_201812_T;

INFORMAT RANGE_AGING_LANDLINE_II $20.;
	IF AGING_LANDLINE =. THEN  RANGE_AGING_LANDLINE_II = ''; ELSE
	IF AGING_LANDLINE >= 0 AND AGING_LANDLINE <= 3 THEN RANGE_AGING_LANDLINE_II = '0_M0aM3'; ELSE
	IF AGING_LANDLINE > 3 AND AGING_LANDLINE <= 8 THEN  RANGE_AGING_LANDLINE_II = '1_M4aM8'; ELSE
	IF AGING_LANDLINE > 8 AND AGING_LANDLINE <= 13 THEN  RANGE_AGING_LANDLINE_II = '2_M9aM13'; ELSE
	IF AGING_LANDLINE > 13 AND AGING_LANDLINE <= 24 THEN  RANGE_AGING_LANDLINE_II = '3_M14aM24'; ELSE
	IF AGING_LANDLINE > 24 THEN  RANGE_AGING_LANDLINE_II = '4_2Years+'; ELSE
	RANGE_AGING_LANDLINE_II='4_2Years+';

INFORMAT RANGE_AGING_BROADBAND_II $20.;
	IF AGING_BROADBAND =. THEN  RANGE_AGING_BROADBAND_II = ''; ELSE
	IF AGING_BROADBAND >= 0 AND AGING_BROADBAND <= 3 THEN RANGE_AGING_BROADBAND_II = '0_M0aM3'; ELSE
	IF AGING_BROADBAND > 3 AND AGING_BROADBAND <= 8 THEN  RANGE_AGING_BROADBAND_II = '1_M4aM8'; ELSE
	IF AGING_BROADBAND > 8 AND AGING_BROADBAND <= 13 THEN  RANGE_AGING_BROADBAND_II = '2_M9aM13'; ELSE
	IF AGING_BROADBAND > 13 AND AGING_BROADBAND <= 24 THEN  RANGE_AGING_BROADBAND_II = '3_M14aM24'; ELSE
	IF AGING_BROADBAND > 24 THEN  RANGE_AGING_BROADBAND_II = '4_2Years+'; ELSE
	RANGE_AGING_BROADBAND_II='4_2Years+';

INFORMAT RANGE_AGING_TV_II $20.;
	IF AGING_TV =. THEN  RANGE_AGING_TV_II = ''; ELSE
	IF AGING_TV >= 0 AND AGING_TV <= 3 THEN RANGE_AGING_TV_II = '0_M0aM3'; ELSE
	IF AGING_TV > 3 AND AGING_TV <= 8 THEN  RANGE_AGING_TV_II = '1_M4aM8'; ELSE
	IF AGING_TV > 8 AND AGING_TV <= 13 THEN  RANGE_AGING_TV_II = '2_M9aM13'; ELSE
	IF AGING_TV > 13 AND AGING_TV <= 24 THEN  RANGE_AGING_TV_II = '3_M14aM24'; ELSE
	IF AGING_TV > 24 THEN  RANGE_AGING_TV_II = '4_2Years+'; ELSE
	RANGE_AGING_TV_II='4_2Years+';

INFORMAT RANGE_AGING_OIT_II $20.;
	IF AGING_OIT =. THEN  RANGE_AGING_OIT_II = ''; ELSE
	IF AGING_OIT >= 0 AND AGING_OIT <= 3 THEN RANGE_AGING_OIT_II = '0_M0aM3'; ELSE
	IF AGING_OIT > 3 AND AGING_OIT <= 8 THEN  RANGE_AGING_OIT_II = '1_M4aM8'; ELSE
	IF AGING_OIT > 8 AND AGING_OIT <= 13 THEN  RANGE_AGING_OIT_II = '2_M9aM13'; ELSE
	IF AGING_OIT > 13 AND AGING_OIT <= 24 THEN  RANGE_AGING_OIT_II = '3_M14aM24'; ELSE
	IF AGING_OIT > 24 THEN  RANGE_AGING_OIT_II = '4_2Years+'; ELSE
	RANGE_AGING_OIT_II='4_2Years+';

RUN;