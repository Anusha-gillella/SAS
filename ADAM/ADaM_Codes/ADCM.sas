LIBNAME ADaM '/home/u63665225/sasuser.v94/ADaM';


PROC IMPORT OUT=ADSL1
    DATAFILE='/home/u63665225/sasuser.v94/ADaM/Datasets/ADSL.xlsx'
    Dbms = xlsx replace;
    getnames = yes;
  run;
 
 Data Test_ADSL;
 set ADSL1;
 keep STUDYID USUBJID SUBJID SITEID TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
		SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
		TR01EDT TR01ETM TR01EDTM;
run;
  
DATA TSET_DM;
SET ADAM.DM;
  		ARFSTDT = input(substr(RFSTDTC, 1, 10), yymmdd10.);
        ARFENDT = input(substr(RFENDTC, 1, 10), yymmdd10.);
        ARFSTTM = input(substr(RFSTDTC, 12), anydtdtm.);
        ARFENTM = input(substr(RFENDTC, 12), anydtdtm.);
        
        ARFSTDTM = input(RFSTDTC, IS8601DT.);
        ARFENDTM = input(RFENDTC, IS8601DT.); 
        
        FORMAT ARFSTDT ARFENDT DATE9.
        	ARFSTTM ARFENTM TIME5.
        	ARFSTDTM ARFENDTM DATETIME15.;
        	
KEEP USUBJID RFSTDTC ARFSTDT ARFSTTM ARFSTDTM RFENDTC ARFENDT ARFENTM ARFENDTM;
RUN;

DATA TEST_CM;
SET ADAM.CM;

 ASTDT = input(CMSTDTC, yymmdd10.);
 AENDT = input(CMENDTC, yymmdd10.);
 
 ASTDY = CMSTDY;
 AENDY = CMENDY;

 format ASTDT AENDT date9.;
 
KEEP USUBJID CMSEQ ASTDT ASTDY CMSTDY AENDT AENDY CMENDY 
	CMTRT CMDECOD CMROUTE CMINDC CMDOSE CMDOSTXT CMDOSU CMDOSFRQ;

RUN;



Data ATCTEXT1;
set ADAM.SUPPCM;
where QNAM = 'ATCTEXT1';
	if QNAM = 'ATCTEXT1' then ATCTEXT1=QVAL;
keep USUBJID QNAM QVAL ATCTEXT1;
run;
Data ATCTEXT2;
set ADAM.SUPPCM;
where QNAM = 'ATCTEXT2';
	if QNAM = 'ATCTEXT2' then ATCTEXT2=QVAL;
keep USUBJID QNAM QVAL ATCTEXT2;
run;
Data ATCTEXT3;
set ADAM.SUPPCM;
where QNAM = 'ATCTEXT3';
	if QNAM = 'ATCTEXT3' then ATCTEXT3=QVAL;
keep USUBJID QNAM QVAL ATCTEXT3;
run;
Data ATCTEXT4;
set ADAM.SUPPCM;
where QNAM = 'ATCTEXT4';
	if QNAM = 'ATCTEXT4' then ATCTEXT4=QVAL;
keep USUBJID QNAM QVAL ATCTEXT4;
run;




%let Varlist = STUDYID USUBJID SUBJID SITEID CMSEQ TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
		SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
		TR01EDT TR01ETM TR01EDTM ARFSTDT ARFSTTM ARFSTDTM RFENDTC ARFENDT ARFENTM ARFENDTM
		ASTDT ASTDY CMSTDY AENDT AENDY CMENDY CMTRT CMDECOD CMROUTE CMINDC CMDOSE CMDOSTXT 
		CMDOSU CMDOSFRQ ATCTEXT1 ATCTEXT2 ATCTEXT3 ATCTEXT4;

%macro sort(dsname, var);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;

%sort(Test_ADSL, USUBJID); 
%sort(TEST_CM, USUBJID); 
%sort(ATCTEXT1, USUBJID); 
%sort(ATCTEXT2, USUBJID); 
%sort(ATCTEXT3, USUBJID); 
%sort(ATCTEXT4, USUBJID); 
%sort(TSET_DM, USUBJID); 
		
Data ADCM_01;
merge Test_ADSL(in=a) TEST_CM ATCTEXT1 ATCTEXT2 ATCTEXT3 ATCTEXT4 TSET_DM;
by USUBJID;
if a;
keep &varlist.;
run;

Data ADCM_02;
retain &varlist.;
attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		CMSEQ	label = 'Sequence Number' length = 8
		TRT01P label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)'	length = 8
		TRT01A	label = 'Actual Treatment for Period 01'	length = $40
		TRT01AN label = 'Actual Treatment for Period 01 (N)' length = 8
		AGE label = 'Age'  length = 8
		AGEU label = 'Age Units' length = $5
		SEX	label = 'Sex' length = $8
		SEXN label = 'Sex (N)' length = 8
		RACE label = 'Race'	 length = $50
		RACEN label = 'Race (N)' length = 8
		ETHNIC label = 'Ethnicity'	 length = $30
		ETHNICN	label = 'Ethnicity (N)'	length = 8
		SAFFL label = 'Safety Population Flag'	length = $1
		SAFFN label = 'Safety Population Flag (N)' length = 8
		TR01SDT	label = 'Date of First Exposure in Period 01' length = 8 Format = DATE9.
		TR01STM	label = 'Time of First Exposure in Period 01' length = 8 Format = TIME5.
		TR01SDTM label = 'Datetime of First Exposure in Period 01'	length = 8 Format = DATETIME15.
		TR01EDT	label = 'Date of Last Exposure in Period 01' length = 8 Format = DATE9. 
		TR01ETM	label = 'Time of Last Exposure in Period 01' length = 8 Format = TIME5.
		TR01EDTM label = 'Datetime of Last Exposure in Period 01' length = 8 Format = DATETIME15.
		
		ARFSTDT	label = 'Analysis Subject Reference Start Date'	length = 8 Format = DATE9.
		ARFSTTM	label = 'Analysis Subject Reference Start Time'	length = 8 Format =TIME5.
		ARFSTDTM label = 'Analysis Subject Reference Start Date/Time'	length = 8 Format = DATETIME15.
		ARFENDT	label = 'Analysis Subject Reference End Date' length = 8 Format = DATE9.
		ARFENTM	label = 'Analysis Subject Reference End Time'	length = 8 Format =TIME5.
		ARFENDTM label ='Analysis Subject Reference End Date/Time'  length = 8 Format = DATETIME15.

		ASTDT	label ='Analysis Start Date' 	length = 8 Format = DATE9.
		ASTDY	label ='Analysis Start Relative Day' 	length = 8
		CMSTDY	label ='Study Day of Start of medication'	length = 8
		AENDT	label ='Analysis End Date' 	length = 8 Format = DATE9.
		AENDY	label ='Analysis End Relative Day'	length = 8
		CMENDY	label ='Study Day of End of medication'	length = 8
		
		CMTRT	label ='Reported Name of Drug, Med, or Therapy' length = $200
		CMDECOD	label ='Standardized Medication Name' length = $200
		CMROUTE	label ='Route of Administration' length = $200
		CMINDC	label ='Indication' length = $200
		CMDOSE	label ='Dose per Administration' length = 8
		CMDOSTXT	label ='Dose Description' length = $100
		CMDOSU	label ='Dose Units' length = $100
		CMDOSFRQ	label ='Dosing Frequency per Interval' length = $100
		ATCTEXT1	label ='WHO_DRUG ATC Level 1 Text' length = $100
		ATCTEXT2	label ='WHO_DRUG ATC Level 2 Text' length = $100
		ATCTEXT3	label ='WHO_DRUG ATC Level 3 Text' length = $100
		ATCTEXT4	label ='WHO_DRUG ATC Level 4 Text' length = $100;

set ADCM_01;
keep &varlist.;
run;

proc export data=work.ADCM_02
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADCM.xlsx'
  dbms=xlsx
  replace;
  sheet="ADCM";
run;



