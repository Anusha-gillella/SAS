LIBNAME ADaM '/home/u63665225/sasuser.v94/ADaM';


Proc datasets library=work kill;
quit;

PROC IMPORT OUT=ADSL1
    DATAFILE='/home/u63665225/sasuser.v94/ADaM/Datasets/ADSL.xlsx'
    Dbms = xlsx replace;
    getnames = yes;
  run;

Data Test_ADSL;
 set ADSL1;
run;

Proc sort data = ADAM.MO out= Test_MO;
	by USUBJID;
run;

Proc sort data = ADAM.PC out= Test_PC;
	by USUBJID;
run;


Data Test_MO1;
set Test_MO;
	PARAM = MOTEST;
	PARAMCD = MOTESTCD;
	
	AVAL = MOSTRESN;
	AVALC = MOSTRESC;
	AVISIT = VISIT;
	AVISITN = VISITNUM;

	ADT = input(MODTC, yymmdd10.);
	ADY = MODY;
	
	if MOTESTCD = 'VT' and 
		MOLOC  in ('HIPPOCAMPUS', 'CAUDATE', 'PUTAMEN', 'THALAMUS', 'LATERAL TEMPORAL CORTEX', 
		'ORBITAL FRONTAL CORTEX','PREFRONTAL CORTEX', 'SUPERIOR FRONTAL CORTEX', 'OCCIPITAL',
		'OCCIPITAL LOBE','PARIETAL', 'PARIETAL LOBE','ANTERIOR CINGULATE','ANTERIOR_CINGULATE' ,
		'POSTERIOR CINGULATE', 'POSTERIOR_CINGULATE', 'PONS', 'CEREBELLUM') 
		then do;
				ANL01FL = 'Y' ; 
				ANL01FN = 1; 
		end;
	
	Format ADT date9.;
run;



Proc sort data = ADAM.SUPPMO out= SUPPMO_01;
	by USUBJID;
run;

Data SUPPMO_02;
set SUPPMO_01;
where QNAM = 'MRISPC';
if QNAM = 'MRISPC' then MRISPC = QNAM;
keep USUBJID MRISPC;
run;

%macro sort(dsname, var);
    PROC SORT data=&dsname;
    by &var;
    Run;
%mend;

%sort(SUPPMO_02, USUBJID); 
%sort(Test_MO1, USUBJID); 
%sort(Test_ADSL, USUBJID);


Data ADMO_01;
merge Test_MO1(in=a) SUPPMO_02 Test_ADSL;
by usubjid;
if a;
run;


	
Proc SQL;
Create table Test_MO2 as (
SELECT USUBJID, TRT01AN, MOMETHOD, MOANMETH, MEAN(MOSTRESN) AS DTYPE
FROM ADMO_01
WHERE MOTESTCD = 'VT'
GROUP BY USUBJID, TRT01AN, MOMETHOD, MOANMETH
);
quit;

%sort(Test_MO2, USUBJID TRT01AN MOMETHOD MOANMETH); 
%sort(ADMO_01, USUBJID TRT01AN MOMETHOD MOANMETH);

Data ADMO_02;
merge ADMO_01(in=a) Test_MO2;
by USUBJID TRT01AN MOMETHOD MOANMETH;
if a;
run;


*To find the pre-treatment records;
proc sort data=ADMO_02 out = base_01; 
by USUBJID MOTESTCD MODTC VISIT VISITNUM MOSEQ;
run;

Data Base_02;
set Base_01;
  MODT = input(MODTC, yymmdd10.);
  Format MODT date9.;
  run;
  
Data Base_03;
set Base_02;
   by USUBJID MOTESTCD MODTC VISIT VISITNUM MOSEQ;

    if not missing(MODT) and MODT > . and MODT <= ARFSTDT;
    where MODT > . and MODT <= ARFSTDT and not missing(MODT) and AVAL ne .;
run;

Data base_04;
set base_03;
 by USUBJID MOTESTCD MODTC VISIT VISITNUM MOSEQ;
 	if last.MOTESTCD;
 keep  USUBJID MOTESTCD MODTC ARFSTDT VISIT VISITNUM MOSEQ ABLFL aval ;
 ABLFL = 'Y';
 run;
 
 %sort(base_04, USUBJID MOTESTCD MODTC VISIT VISITNUM MOSEQ);
 %sort(ADMO_02, USUBJID MOTESTCD MODTC VISIT VISITNUM MOSEQ);
 
 
Data ADMO_03;
merge ADMO_02(in=a) base_04(drop=aval);
 by USUBJID MOTESTCD MODTC VISIT VISITNUM MOSEQ;
 if a;
run;
 
Data ADMO_04;
Set ADMO_03;
 if ABLFL = 'Y' then ABLFN = 1;
 else do; ABLFL = 'N';ABLFN = 0; end;
 
 If ABLFL = 'Y'  and AVAL NE . then BASE = AVAL;
 If ABLFL = 'Y'  and AVALC NE . then BASEC = AVALC;
 
 If ANL01FL = 'Y' then CHG = . ;
 Else CHG = (AVAL - BASE);
run;
 
 Data ADMO_05;
 Set ADMO_04;
	if DTYPE = 'Average of ROI' then MOORRES = "";
	if DTYPE = 'Average of ROI' then MOSTRESC = "";
	if DTYPE = 'Average of ROI' then MOSTRESN = . ;
	if DTYPE = 'Average of ROI' then MOSTRESU = "";
	if DTYPE = 'Average of ROI' then MOLOC = "Average Of Regions";
 
 
	 if moloc = 'HIPPOCAMPUS' then MOLOCN = 1;  
	 if moloc = 'CAUDATE' then MOLOCN = 2;
	 if moloc =  'PUTAMEN' then MOLOCN = 3; 
	 if moloc =  'THALAMUS' then MOLOCN = 4;
	 if moloc =  'LATERAL TEMPORAL CORTEX' then MOLOCN = 5;  
	 if moloc =  'ORBITAL FRONTAL CORTEX'  then MOLOCN = 6; 
	 if moloc =  'PREFRONTAL CORTEX' then MOLOCN = 7;
	 if moloc =  'SUPERIOR FRONTAL CORTEX' then MOLOCN = 8;
	 if moloc in ('OCCIPITAL', 'OCCIPITAL LOBE')   then MOLOCN = 9; 
	 if moloc in ('PARIETAL' ,'PARIETAL LOBE') then MOLOCN = 10;
	 if moloc in('ANTERIOR CINGULATE','ANTERIOR_CINGULATE')  then MOLOCN = 11;  
	 if moloc in ("POSTERIOR CINGULATE", 'POSTERIOR_CINGULATE') then MOLOCN = 12; 
	 if moloc =  "PONS" then MOLOCN = 13;
	 if moloc =  "CEREBELLUM" then MOLOCN = 14; 
	 if moloc =  "Average of Regions"  then MOLOCN = 15;
	 
run;

proc sql;
    create table ADMO_06 as
    select *,
           monotonic() as ASEQ
    from ADMO_05
    group by USUBJID, MOMETHOD, MOANMETH, MOTESTCD, AVISITN, MOLOC, ADT, DTYPE;
quit;


%let varlist = STUDYID USUBJID SUBJID SITEID TRT01A TRT01AN TRT01P TRT01PN AGE AGEU SEX SEXN 
				RACE RACEN ETHNIC ETHNICN SAFFL SAFFN PKFL PKFN PPDFL PPDFN TR01SDT TR01STM 
				TR01SDTM TR01EDT TR01ETM TR01EDTM ARFSTDT ARFSTTM ARFSTDTM ARFENDT ARFENTM
				ARFENDTM MOTESTCD MOTEST PARAM PARAMCD MOCAT AVAL AVALC ABLFL ABLFN BASE BASEC 
				CHG MOORRES MOORRESU MOSTRESC MOSTRESN MOSTRESU MOLOC MOLOCN MOLAT MOMETHOD
				MOANMETH MOBLFL VISITNUM VISIT AVISIT AVISITN MODTC MODY ADT ADY MRISPC ANL01FL
				ANL01FN OCCUP ASEQ DTYPE;
				
 
Data ADMO_07(keep = &varlist.);
attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		TRT01A	label = 'Actual Treatment for Period 01'	length = $40
		TRT01AN label = 'Actual Treatment for Period 01 (N)' length = 8
		TRT01P label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)'	length = 8
		AGE label = 'Age'  length = 8
		AGEU label = 'Age Units' length = $5
		SEX	label = 'Sex' length = $8
		SEXN label = 'Sex (N)' length = 8
		RACE label = 'Race'	 length = $50
		RACEN label = 'Race (N)' length = 8
		ETHNIC label = 'Ethnicity'	 length = $30
		ETHNICN	label = 'Ethnicity (N)'	length = 8
		SAFFN label = 'Safety Population Flag (N)' length = 8
		SAFFL label = 'Safety Population Flag'	length = $1
		PKFL	label ='Pharmacokinetic Population Flag'	length = 	$1
		PKFN	label = 'Pharmacokinetic Population Flag (N)' length = 	8
		PPDFL	label = 'Pharmacodynamic Population Flag'		length = $1
		PPDFN	label = 'Pharmacodynamic Population Flag (N)' length = 	8
		TR01SDT	label = 'Date of First Exposure in Period 01' length = 8 Format = DATE9.
		TR01STM	label = 'Time of First Exposure in Period 01' length = 8 Format = TIME5.
		TR01SDTM label = 'Datetime of First Exposure in Period 01'	length = 8 Format = DATETIME15.
		TR01EDT	label = 'Date of Last Exposure in Period 01' length = 8 Format = DATE9. 
		TR01ETM	label = 'Time of Last Exposure in Period 01' length = 8 Format = TIME5.
		TR01EDTM label = 'Datetime of Last Exposure in Period 01' length = 8 Format = DATETIME15.
		
		ARFSTDT	 label = 'Analysis Subject Reference Start Date'	length = 8	Format = DATE9.
		ARFSTTM	 label = 'Analysis Subject Reference Start Time' length = 8	Format = TIME5.
		ARFSTDTM label = 'Analysis Subject Reference Start Date/Time' length = 8	Format = DATETIME15.
		ARFENDT	 label = 'Analysis Subject Reference End Date'	length = 8	Format = DATE9.
		ARFENTM	 label = 'Analysis Subject Reference End Time'	length = 8	Format = TIME5.
		ARFENDTM label = 'Analysis Subject Reference End Date/Time'	length = 8	Format = DATETIME15.


		MOTESTCD label = 'Test or Examination Short Name'	length =$40 
		MOTEST	label = 'Test or Examination Name'	length =$40 
		PARAM	label = 'Parameter'	length =$40 
		PARAMCD	label = 'Parameter Code'	length =$40 
		MOCAT	label = 'Category for Test'	length =$40 
		AVAL	label = 'Analysis Value'	length =8
		AVALC	label = 'Analysis Value (C)'	length =$200 
		ABLFL	label = 'Baseline Record Flag'	length =$1 
		ABLFN	label = 'Baseline Record Flag (N)'	length =8
		BASE	label = 'Baseline Value'	length =8
		BASEC	label = 'Baseline Value (C)'	length =$30 
		CHG		label = 'Change from Baseline'	length =8
		MOORRES	label = 'Result or Finding in Original Units'	length =$200 
		MOORRESU	label = 'Original Units'	length =$40 
		MOSTRESC	label = 'Character Result/Finding in Std Format'	length =$200 
		MOSTRESN	label = 'Numeric Result/Finding in Standard Units'	length =8
		MOSTRESU	label = 'Standard Units'	length =$40 
		MOLOC	label = 'Location Used for Measurement'	length =$40 
		MOLOCN	label = 'Location Used for Measurement (N)' length =	8
		MOLAT	label = 'Specimen Laterality within Subject'	length =$40 
		MOMETHOD	label = 'Method of Procedure Test'	length =$40 
		MOANMETH	label = 'Analysis Method'	length =$40 
		MOBLFL	label = 'Baseline Flag'	length =$1 
		VISITNUM	label = 'Visit Number'	length =8
		VISIT	label = 'Visit Name	' length =$20 
		AVISIT	label = 'Analysis Visit'	length =$40 
		AVISITN	label = 'Analysis Visit (N)'	length =8
		MODTC	label = 'Date/Time of Test'	length =$40 
		MODY	label = 'Study Day of Test'	length =8
		
		ADT	label = 'Analysis Date'	 length =8	Format = DATE9.
		ADY	label = 'Analysis Relative Day'	length =8	
		MRISPC	label = 'Reason for Abnormal'	length =$40 	
		ANL01FL	label = 'Analysis Flag 01'	length =$1 	
		ANL01FN	label = 'Analysis Flag 01 (N)'	length =8	
		Occup	label = 'Occupancy Percentage '	length =8	
		ASEQ	label = 'Analysis Sequence' 	length =8	
		DTYPE	label = 'Derivation Type'	length = 8	
		;
set ADMO_06;
run;
		
		
Data ADMO_08;
retain &varlist.;
set ADMO_07;
keep &varlist.;
run;

proc export data=work.ADMO_08
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADMO.xlsx'
  dbms=xlsx
  replace;
  sheet="ADMO";
run;








