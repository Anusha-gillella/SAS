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
keep STUDYID USUBJID SUBJID SITEID TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
				SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
				TR01EDT TR01ETM TR01EDTM;
run;

Proc sort data = ADAM.EX out= Test_EX;
	by USUBJID;
run;

Data Test_EX1;
set Test_EX;
	AVAL = EXDOSE;
	AVALC = put(EXDOSE, 8.2);
	
	ASTDT = input(substr(EXSTDTC, 1, 10), yymmdd10.);
	AENDT = input(substr(EXENDTC, 1, 10), yymmdd10.);
	
	Format ASTDT AENDT Date9.;
run;


%macro sort(dsname, var);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;

%sort(ADSL1, USUBJID); 
%sort(Test_EX1, USUBJID); 

Data ADEX_01;
merge Test_EX1(in=a) ADSL1;
by USUBJID;
if a;
run;

%let Varlist = STUDYID USUBJID SUBJID SITEID TRT01A TRT01AN TRT01P TRT01PN  AGE AGEU 
				SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
				TR01EDT TR01ETM TR01EDTM EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE AVAL AVALC
				EXTRT EXSEQ EXSTDTC EXENDTC ASTDT AENDT ASTDY AENDY;
				
Data ADEX_02(keep = &varlist.);
retain &varlist.;
Attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		TRT01A	label = 'Actual Treatment for Period 01'	length = $40
		TRT01AN label = 'Actual Treatment for Period 01 (N)' length = 8
		TRT01P label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)'	length = 8
		AGE		label = 'Age' 	length = 8
		AGEU 	label = 'Age Units' length = $5
		SEX		label = 'Sex' length = $8
		SEXN	label = 'SEXN' length = 8
		RACE 	label = 'Race'	 length = $50
		RACEN 	label = 'Race (N)' length = 8
		ETHNIC 	label = 'Ethnicity'	 length = $30
		ETHNICN	label = 'Ethnicity (N)'	length = 8
		SAFFL label = 'Safety Population Flag'	length = $1
		SAFFN label = 'Safety Population Flag (N)' length = 8
		TR01SDT	label = 'Date of First Exposure in Period 01' length = 8 Format = DATE9.
		TR01STM	label = 'Time of First Exposure in Period 01' length = 8 Format = TIME5.
		TR01SDTM label = 'Datetime of First Exposure in Period 01'	length = 8 Format = DATETIME15.
		TR01EDT	label = 'Date of Last Exposure in Period 01' length = 8 Format = DATE9. 
		TR01ETM	label = 'Time of Last Exposure in Period 01' length = 8 Format = TIME5.
		TR01EDTM label = 'Datetime of Last Exposure in Period 01' length = 8 Format = DATETIME15.	
		EXDOSE	label = 'Dose'	length = 8	
		EXDOSU	label = 'Dose Units'	length = $10 	
		EXDOSFRM	label = 'Dose Form'	length = $10 	
		EXDOSFRQ	label = 'Dosing Frequency per Interval'	length = $10 	
		EXROUTE	label = 'Route of Administration'	length = $10 	
		AVAL	label = 'Analysis Value'	length = 8	
		AVALC	label = 'Analysis Value (C)'	length = $10 	
		EXTRT	label = 'Name of Treatment'	length = $10 	
		EXSEQ	label = 'Sequence Number'	length = 8	
		EXSTDTC	label = 'Start Date/Time of Treatment'	length = $20 	
		EXENDTC	label = 'End Date/Time of Treatment'	length = $20 	
		ASTDT	label = 'Analysis Start Date'	length = 8	Format =DATE9.
		AENDT	label = 'Analysis End Date'	length = 8	Format =DATE9.
		ASTDY	label = 'Analysis Start Relative Day'	length = 8	
		AENDY	label = 'Analysis End Relative Day'	length = 8	
	;
set ADEX_01;
keep &varlist.;
run;

proc export data=work.ADEX_02
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADEX.xlsx'
  dbms=xlsx
  replace;
  sheet="ADEX";
run;




