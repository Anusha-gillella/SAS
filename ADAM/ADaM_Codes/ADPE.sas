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

Proc sort data = ADAM.PE out= Test_PE;
	by USUBJID;
run;

Data Test_PE1;
set Test_PE;
	PARAMCD = PETESTCD;
	PARAM = PETEST;
	
		AVAL = PESTRESC;
		if AVAL = 'NORMAL' then AVALC = '1';
		else AVALC = '0';
		
	if length(PEDTC) = 10 then ADT = input(PEDTC, yymmdd10.);
	if length(PEDTC) > 10 then ADT = input(substr(PEDTC,1,10), yymmdd10.);
	
	ADY = PEDY;
	AVISITN = VISITNUM;
	AVISIT = VISIT;
	
Format ADT date9.;
run;


%macro sort(dsname, var);
    PROC SORT data=&dsname;
    by &var;
    Run;
%mend;

%sort(Test_PE1, USUBJID); 
%sort(Test_ADSL, USUBJID);


Data Test_PE2;
merge Test_PE1(in=a) Test_ADSL;
by usubjid;
if a;
run;

%let varlist = STUDYID USUBJID SUBJID SITEID TRT01A TRT01AN TRT01P TRT01PN AGE AGEU SEX SEXN 
				RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM TR01EDT TR01ETM 
				TR01EDTM PESEQ PETESTCD PETEST PARAMCD PARAM PECAT PEORRES PESTRESC AVAL AVALC
				PEMETHOD PEDTC PEDY ADT ADY VISITNUM VISIT AVISITN AVISIT;
				
				
Data Test_PE3(keep = &varlist.);
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
		TR01SDT	label = 'Date of First Exposure in Period 01' length = 8 Format = DATE9.
		TR01STM	label = 'Time of First Exposure in Period 01' length = 8 Format = TIME5.
		TR01SDTM label = 'Datetime of First Exposure in Period 01'	length = 8 Format = DATETIME15.
		TR01EDT	label = 'Date of Last Exposure in Period 01' length = 8 Format = DATE9. 
		TR01ETM	label = 'Time of Last Exposure in Period 01' length = 8 Format = TIME5.
		TR01EDTM label = 'Datetime of Last Exposure in Period 01' length = 8 Format = DATETIME15.			
		PESEQ	 label = 'Sequence Number'	length = 8
		PETESTCD label = 'Body System Examined Short Name'		length = $8
		PETEST	 label = 'Body System Examined'		length = $40
		PARAMCD	 label = 'Parameter Code'		length = $8
		PARAM	 label = 'Parameter'		length = $40
		PECAT	 label = 'Category for Examination'		length = $40
		PEORRES	 label = 'Verbatim Examination Finding' length = $200
		PESTRESC label = 'Character Result/Finding in Standard Format'	length = $200
		AVAL	 label = 'Analysis Value'	length = $8 
		AVALC	 label = 'Analysis Value (C)' length = $200 
		PEMETHOD label = 'Method of Test or Examination'		length = $50 
		PEDTC	 label = 'Date/Time of Examination'		length = $50 
		PEDY	 label = 'Study Day of Examination'		length = 8
		ADT	 	 label = 'Analysis Date'		length = 8 Format = date9.
		ADY	 	 label = 'Analysis Relative Day'		length = 8
		VISITNUM label = 'Visit Number'	length = 8
		VISIT	 label = 'Visit Name'	length = $40 
		AVISITN	 label = 'Analysis Visit (N)'	length = 8
		AVISIT	 label = 'Analysis Visit'	length = $40;
set Test_PE2;
run;
		
		
		
		
		
Data ADPE_01;
retain &varlist.;
set Test_PE3;
keep &varlist.;
run;

proc export data=work.ADPE_01
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADPE.xlsx'
  dbms=xlsx
  replace;
  sheet="ADPE";
run;

		
			
			
			
			
			
			
			
			
			
			
			
			
			
			