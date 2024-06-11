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
		
		
Data Test_DV;
set ADAM.DV;

DVSTDT = input(DVSTDTC, yymmdd10.);
Format DVSTDT date9.;

ADVSTDY = DVSTDY;

Keep USUBJID DVSEQ DVTERM DVCAT DVSCAT DVSTDT ADVSTDY;
run;


Data ACTTKN01;
set ADAM.SUPPDV;
where QNAM = 'ACTTKN01';
	if QNAM = 'ACTTKN01' then ACTTKN01=QVAL;
keep USUBJID QNAM QVAL ACTTKN01;
run;

Data ACTTKN02;
set ADAM.SUPPDV;
where QNAM = 'ACTTKN02';
	if QNAM = 'ACTTKN02' then ACTTKN02=QVAL;
keep USUBJID QNAM QVAL ACTTKN02;
run;

Data ACTTKN03;
set ADAM.SUPPDV;
where QNAM = 'ACTTKN03';
	if QNAM = 'ACTTKN03' then ACTTKN03=QVAL;
keep USUBJID QNAM QVAL ACTTKN03;
run;

Data ACTTKN04;
set ADAM.SUPPDV;
where QNAM = 'ACTTKN04';
	if QNAM = 'ACTTKN04' then ACTTKN04=QVAL;
keep USUBJID QNAM QVAL ACTTKN04;
run;

Data ACTTKN05;
set ADAM.SUPPDV;
where QNAM = 'ACTTKN05';
	if QNAM = 'ACTTKN05' then ACTTKN05=QVAL;
keep USUBJID QNAM QVAL ACTTKN05;
run;


	%macro sort(dsname, var);
	    PROC SORT data=&dsname; 
	    by &var;
	    Run;
	%mend;
	
	%sort(Test_ADSL, USUBJID); 
	%sort(Test_DV, USUBJID); 
	%sort(ACTTKN01, USUBJID); 
	%sort(ACTTKN02, USUBJID); 
	%sort(ACTTKN03, USUBJID); 
	%sort(ACTTKN04, USUBJID); 
	%sort(ACTTKN05, USUBJID);
	
	
%let Varlist = STUDYID USUBJID SUBJID SITEID DVSEQ TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
		SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
		TR01EDT TR01ETM TR01EDTM DVTERM DVCAT DVSCAT DVSTDT ADVSTDY ACTTKN01 ACTTKN02 
		ACTTKN03 ACTTKN04 ACTTKN05;
		
Data ADDV_01;
merge Test_ADSL(in=a) Test_DV ACTTKN01 ACTTKN02 ACTTKN03 ACTTKN04 ACTTKN05;
by USUBJID;
if a;
keep &varlist.;
run;

Data ADDV_02;
retain &varlist.;
attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		DVSEQ	label = 'Sequence Number' length = 8
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
		
		DVTERM	label = 'Protocol Deviation Term' length = $200
		DVCAT	label = 'Category for Protocol Deviation' length = $100
		DVSCAT	label = 'Subcategory for Protocol Deviation' length = $100
		DVSTDT	label = 'Analysis Date of Deviation' length = 8 Format = DATE9.
		ADVSTDY	label = 'Study Day of Start of Deviation' length = 8
		
		ACTTKN01 label = 'Action Taken 01' length = $100
		ACTTKN02 label = 'Action Taken 02' length = $100
		ACTTKN03 label = 'Action Taken 03' length = $100
		ACTTKN04 label = 'Action Taken 04' length = $100
		ACTTKN05 label = 'Action Taken 05' length = $100;
		
set ADDV_01;
keep &varlist.;
run;

proc export data=work.ADDV_02
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADDV.xlsx'
  dbms=xlsx
  replace;
  sheet="ADDV";
run;

