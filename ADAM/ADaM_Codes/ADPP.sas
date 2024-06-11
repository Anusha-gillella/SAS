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
keep STUDYID USUBJID SUBJID SITEID ARM ARMN TRT01P TRT01PN TRT01A TRT01AN TR01SDT TR01STM 
		TR01SDTM TR01EDT TR01ETM TR01EDTM AGE AGEU SEX SEXN ASEX RACE RACEN ETHNIC ETHNICN 
		SAFFL SAFFN ;
run;

Proc sort data = ADAM.PP out= Test_PP;
	by USUBJID;
run;

Data Test_PP1;
set Test_PP;
	Paramcd = PPSTRESU;
	 if not missing(PPSTRESU) then
        Param = catx(' ', PPTEST, '(' || strip(PPSTRESU) || ')');
    else
        Param = PPTEST;
        
 	if not missing(PPSTRESN) then AVALC = '';
    	else AVALC = PPSTRESC;

    AVAL = PPSTRESN;
run;
        
%macro sort(dsname, var);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;

%sort(Test_ADSL, USUBJID); 
%sort(Test_PP1, USUBJID); 
	
Data ADPP_01;
merge Test_PP1(in=a) Test_ADSL;
by USUBJID;
if a;
run;


%let varlist = STUDYID USUBJID SUBJID SITEID ARM ARMN TRT01P TRT01PN TRT01A TRT01AN 
		TR01SDT TR01STM TR01SDTM TR01EDT TR01ETM TR01EDTM AGE AGEU SEX SEXN ASEX 
		RACE RACEN ETHNIC ETHNICN SAFFL SAFFN PARAM PARAMCD AVALC AVAL AVISIT
		AVISITN PPCAT PPSPEC;

Data ADPP_02(keep = &varlist.);
retain &varlist.;
Attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		ARM		label = 'Description of Planned Arm'	length = $40
		ARMN	label = 'Description of Planned Arm (N)'	length = 8
		TRT01P label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)'	length = 8
		TRT01A	label = 'Actual Treatment for Period 01'	length = $40
		TRT01AN label = 'Actual Treatment for Period 01 (N)' length = 8
		TR01SDT	label = 'Date of First Exposure in Period 01' length = 8 Format = DATE9.
		TR01STM	label = 'Time of First Exposure in Period 01' length = 8 Format = TIME5.
		TR01SDTM label = 'Datetime of First Exposure in Period 01'	length = 8 Format = DATETIME15.
		TR01EDT	label = 'Date of Last Exposure in Period 01' length = 8 Format = DATE9. 
		TR01ETM	label = 'Time of Last Exposure in Period 01' length = 8 Format = TIME5.
		TR01EDTM label = 'Datetime of Last Exposure in Period 01' length = 8 Format = DATETIME15.
		AGE		label = 'Age' 	length = 8
		AGEU 	label = 'Age Units' length = $5
		SEX		label = 'Sex' length = $8
		SEXN	label = 'SEXN' length = 8
		ASEX	label = 'Analysis Sex' length = $8
		RACE 	label = 'Race'	 length = $50
		RACEN 	label = 'Race (N)' length = 8
		ETHNIC 	label = 'Ethnicity'	 length = $30
		ETHNICN	label = 'Ethnicity (N)'	length = 8
		SAFFL label = 'Safety Population Flag'	length = $1
		SAFFN label = 'Safety Population Flag (N)' length = 8
		PARAM	label = 'Parameter'	length = $100
		PARAMCD	label = 'Parameter Code'	length = $8
		AVALC	label = 'Analysis Value (C)'	length = $200
		AVAL	label = 'Analysis Value'	length = 8
		AVISIT	label = 'Analysis Visit'	length = $60
		AVISITN	label = 'Analysis Visit (N)'	length = 8
		PPCAT	label = 'Test Category'	length = $40
		PPSPEC	label = 'Specimen Material Type' length = $20
	;
set ADPP_01;
keep &varlist.;
run;

proc export data=work.ADPP_02
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADPP.xlsx'
  dbms=xlsx
  replace;
  sheet="ADPP";
run;


		
