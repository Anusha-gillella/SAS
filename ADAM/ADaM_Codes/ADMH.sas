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

Proc sort data = ADAM.MH out= Test_MH;
	by USUBJID;
run;

Data Test_MH1;
set Test_MH;
	  /* Convert character dates to numeric */
	 IF length(MHSTDTC) >= 4 then  ASTDT = mdy(1,1,input(substr(MHSTDTC,1,4), 4.));
			else ASTDT = mdy(1,1,input(MHSTDTC, 4.));
	 IF length(MHENDTC) >= 4 then  AENDT = mdy(1,1,input(substr(MHENDTC,1,4), 4.));
			else AENDT = mdy(1,1,input(MHENDTC, 4.));

    /* Check for missing values */
    if missing(ASTDT) then ASTDT = .;
    if missing(AENDT) then AENDT = .;
	
	ASTDY = MHSTDY;
	AENDY = MHENDY;
	
Format ASTDT AENDT date9.;
run;

%macro sort(dsname, var);
    PROC SORT data=&dsname;
    by &var;
    Run;
%mend;

%sort(Test_MH1, USUBJID); 
%sort(Test_ADSL, USUBJID); 

Data ADMH_01;
merge Test_MH1(in=a) Test_ADSL;
by USUBJID;
if a;
run;

%let varlist = STUDYID USUBJID SUBJID SITEID TRT01A TRT01AN TRT01P TRT01PN AGE AGEU SEX SEXN 
				RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM TR01EDT TR01ETM 
				TR01EDTM ARFSTDT ARFSTTM ARFSTDTM ARFENDT ARFENTM ARFENDTM MHSEQ MHSPID MHTERM 
				MHMODIFY MHLLT MHLLTCD MHDECOD MHPTCD MHHLT MHHLTCD MHHLGT MHHLGTCD MHBODSYS 
				MHBDSYCD MHSOC MHSOCCD MHDTC MHSTDTC MHENDTC MHDY MHSTDY MHENDY MHENRF ASTDT 
				AENDT ASTDY AENDY;
				


Data ADMH_02(keep = &varlist.);
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
		ARFSTDT	label = 'Analysis Subject Reference Start Date'	length = 8 Format = DATE9.
		ARFSTTM	label = 'Analysis Subject Reference Start Time'	length = 8 Format =TIME5.
		ARFSTDTM label = 'Analysis Subject Reference Start Date/Time'	length = 8 Format = DATETIME15.
		ARFENDT	label = 'Analysis Subject Reference End Date' length = 8 Format = DATE9.
		ARFENTM	label = 'Analysis Subject Reference End Time'	length = 8 Format =TIME5.
		ARFENDTM label ='Analysis Subject Reference End Date/Time'  length = 8 Format = DATETIME15.
		MHSEQ	 label = 'Sequence Number'	 length = 8
		MHSPID	 label = 'Sponsor-Defined Identifier'	 length = $200
		MHTERM	 label = 'Reported Term for the Medical History' length = $200
		MHMODIFY label = 'Modified Reported Term'	 length = $200
		MHLLT	 label = 'Lowest Level Term'	 length = $200
		MHLLTCD	 label = 'Lowest Level Term Code'	 length = 8
		MHDECOD	 label = 'Dictionary-Derived Term'  length = $200
		MHPTCD	 label = 'Preferred Term Code'	 length = 8
		MHHLT	 label = 'High Level Term'	 length = $200
		MHHLTCD	 label = 'High Level Term Code'	 length = 8
		MHHLGT	 label = 'High Level Group Term'	 length = $200
		MHHLGTCD label = 'High Level Group Term Code' length = 	8
		MHBODSYS label = 'Body System or Organ Class'	 length = $200
		MHBDSYCD label = 'Body System or Organ Class Code'	 length = 8
		MHSOC	 label = 'Primary System Organ Class'	 length = $200
		MHSOCCD	 label = 'Primary System Organ Class Code'	 length = 8
		MHDTC	 label = 'Date/Time of History Collection'	 length = $200
		MHSTDTC	 label = 'Start Date/Time of Medical History Event' length = 	$200
		MHENDTC	 label = 'End Date/Time of Medical History Event'	 length = $200
		MHDY	 label = 'Study Day of History Collection'	 length = 8
		MHSTDY	 label = 'Study Day of Start of Observation'	 length = 8
		MHENDY	 label = 'Study Day of End of Observation'	 length =  8
		MHENRF	 label = 'End Relative to Reference Period' length = 	$8 
		ASTDT	 label = 'Analysis Start Date'	 length = 8
		AENDT	 label = 'Analysis End Date'	 length = 8
		ASTDY	 label = 'Analysis Start Relative Day'	 length = 8
		AENDY	 label = 'Analysis End Relative Day'	 length = 8;	  
Set ADMH_01;
run;



Data ADMH_03;
retain &varlist.;
set ADMH_02;
keep &varlist.;
run;

proc export data=work.ADMH_03
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADMH.xlsx'
  dbms=xlsx
  replace;
  sheet="ADMH";
run;







