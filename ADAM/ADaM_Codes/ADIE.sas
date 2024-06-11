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
		
		
Data Test_IE;
set ADAM.IE;

ADT = input(IEDTC, yymmdd10.);
Format ADT date9.;

ADY = IEDY;
AVISIT = VISIT;
AVISITN = VISITNUM;

PARAM = IETEST;
PARAMCD = IETESTCD;

AVALC = IEORRES;

IF IEORRES = 'Y' THEN AVAL = 1;
ELSE IF IEORRES = 'N' THEN AVAL = 0;

Keep USUBJID IESEQ IESPID IETESTCD IETEST IECAT IEORRES IESTRESC ADT IEDTC ADY IEDY VISITNUM 
		VISIT AVISIT AVISITN PARAM PARAMCD AVALC AVAL;
run;

Data IEEXEMPT;
set ADAM.SUPPIE;
where QNAM = 'IEEXEMPT';
	if QNAM = 'IEEXEMPT' then IEEXEMPT=QVAL;
keep USUBJID QNAM QVAL IEEXEMPT;
run;

Data IEEXPLAN;
set ADAM.SUPPIE;
where QNAM = 'IEEXPLAN';
	if QNAM = 'IEEXPLAN' then IEEXPLAN=QVAL;
keep USUBJID QNAM QVAL IEEXPLAN;
run;


	%macro sort(dsname, var);
	    PROC SORT data=&dsname; 
	    by &var;
	    Run;
	%mend;
 
	%sort(Test_IE, USUBJID); 
	%sort(IEEXEMPT, USUBJID); 
	%sort(IEEXPLAN, USUBJID);
	%sort(Test_ADSL, USUBJID);
	
Data ADIE_01;
merge Test_IE(in=a) IEEXEMPT IEEXPLAN;
by USUBJID;
if a;
run;

Data ADIE_02;
merge ADIE_01(in=a) Test_ADSL;
by USUBJID;
if a;
run;

Data ADIE_03;
Set ADIE_02;
by USUBJID;
	if first.usubjid then IESEQ = 1;
		else IESEQ = IESEQ + 1;
run;

%let varlist =  STUDYID USUBJID SUBJID SITEID IESEQ TRT01A TRT01AN TRT01P TRT01PN AGE AGEU
				SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM
				TR01EDT TR01ETM TR01EDTM IESPID IETESTCD IETEST IECAT IEORRES IESTRESC ADT
				IEDTC IEDY ADY VISITNUM VISIT AVISIT AVISITN PARAM PARAMCD IEEXEMPT IEEXPLAN 
				AVALC AVAL;

Data ADIE_04(keep = &varlist.);
Attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		IESEQ	label ='Sequence Number'	length = 8
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
		IESPID	label = 'Sponsor-Defined Identifier' length =$8
		IETESTCD label = 'Inclusion/Exclusion Criterion Short Name'	length =$8
		IETEST	label = 'Inclusion/Exclusion Criterion'	length =$200
		IECAT	label = 'Inclusion/Exclusion Category'	length =$10
		IEORRES	label = 'I/E Criterion Original Result'	length =$10
		IESTRESC label = 'I/E Criterion Result in Std Format' length =$10
		ADT		label = 'Analysis Date'	 length =8
		IEDTC	label = 'Date/Time of Collection'	length =$20 
		IEDY	label = 'Study Day of Collection'	length =	8
		ADY		label = 'Analysis Relative Day'		length =8
		VISITNUM label = 'Visit Number'	length =8
		VISIT	label = 'Visit Name'		length = $60
		AVISIT	label = 'Analysis Visit'	length = $60
		AVISITN	label = 'Analysis Visit (N)'	length = 8
		PARAM	label = 'Parameter'	 length = $200
		PARAMCD	label = 'Parameter Code' length = $8
		IEEXEMPT label = 'Exemption Granted?' length = $200 
		IEEXPLAN label = 'Explanation'	length = $200 
		AVALC	label = 'Analysis Value (C)'	length = $200 
		AVAL	label = 'Analysis Value' length = 8;
		
set ADIE_03;
run;


Data ADIE_05;
retain &varlist.;
set ADIE_04;
keep &varlist.;
run;

proc export data=work.ADIE_05
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADIE.xlsx'
  dbms=xlsx
  replace;
  sheet="ADIE";
run;


