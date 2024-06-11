LIBNAME ADaM '/home/u63665225/sasuser.v94/ADaM';


PROC IMPORT OUT=ADSL1
    DATAFILE='/home/u63665225/sasuser.v94/ADaM/Datasets/ADSL.xlsx'
    Dbms = xlsx replace;
    getnames = yes;
  run;

Data Test_ADSL;
set ADSL1;
keep STUDYID USUBJID SUBJID SITEID AESEQ TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
				SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
				TR01EDT TR01ETM TR01EDTM;
run;

Data Test_DM;
set ADAM.DM;

	ARFSTDT = input(substr(RFXSTDTC, 1, 10), yymmdd10.);
	ARFSTTM = input(substr(RFXSTDTC, 12), anydtdtm.);
	ARFSTDTM  = input(RFXSTDTC, IS8601DT.);

	 ARFENDT = input(substr(RFENDTC, 1, 10), yymmdd10.);
	 ARFENTM = input(substr(RFENDTC, 12), anydtdtm.);
	 ARFENDTM = input(RFENDTC, IS8601DT.);
	 
Format ARFSTDT ARFENDT date9.
		ARFSTTM ARFENTM time5.
		ARFSTDTM ARFENDTM datetime15.;
		
keep USUBJID RFXSTDTC ARFSTDT ARFSTTM ARFSTDTM RFENDTC ARFENDT ARFENTM ARFENDTM;
Run;


Data Test_AE;
set ADAM.AE;

	If length(AESTDTC) > 10 then ASTDT = input(substr(AESTDTC, 1, 10), yymmdd10.);
	If length(AESTDTC) = 10  then ASTDT= input(substr(AESTDTC, 1, 10), yymmdd10.); 
	
	If length(AESTDTC) > 10 then ASTTM = input(substr(AESTDTC, 12), anydtdtm.);
	if missing(AESTDTC) then ASTTM = hms(0,0,0);

	ASTDTM = dhms(ASTDT, hour(ASTTM), minute(ASTTM), second(ASTTM));
	
	ASTDY = AESTDY;
	
	Format ASTDT  date9. ASTTM  time5. ASTDTM  datetime15.;
			
	*if first.USUBJID then output; 
	
	If length(AEENDTC) > 10 then AENDT = input(substr(AEENDTC, 1, 10), yymmdd10.);
	If length(AEENDTC) = 10  then AENDT= input(substr(AEENDTC, 1, 10), yymmdd10.); 
	
	If length(AEENDTC) > 10 then AENTM = input(substr(AEENDTC, 12), anydtdtm.);
	if missing(AENTM) then AENTM = hms(0,0,0);

	AENDTM = dhms(AENDT, hour(AENTM), minute(AENTM), second(AENTM));
	
	AENDY = AEENDY;
	
	Format AENDT  date9. AENTM  time5. AENDTM  datetime15.;
	
keep USUBJID AESEQ AESTDTC ASTDT ASTTM ASTDTM AESTDY ASTDY AESEQ AEENDTC AENDT 
	AENTM AENDTM AEENDY AENDY AETERM AEDECOD AEBODSYS AELLT AELLTCD AEDECOD AEPTCD 
	AEHLT AEHLTCD AEHLGT AEHLGTCD AESOC AESER AESEV AEREL AEACN AEACNOTH AEOUT;;
run;

%macro sort(dsname, var);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;

%sort(Test_ADSL, USUBJID); 
%sort(Test_DM, USUBJID); 
%sort(Test_AE, USUBJID);


%let Varlist = STUDYID USUBJID SUBJID SITEID AESEQ TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
				SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
				TR01EDT TR01ETM TR01EDTM ARFSTDT ARFSTTM ARFSTDTM ARFENDT ARFENTM ARFENDTM
				 AESTDTC ASTDT ASTTM ASTDTM AESTDY ASTDY ASTTMF AEENDTC AENDT AENTM AENDTM 
				 AENDY AEENDY AENTMF ADURN AETERM AEDECOD AEBODSYS AELLT AELLTCD AEDECOD 
				 AEPTCD AEHLT AEHLTCD AEHLGT AEHLGTCD AESOC AESER AESEV ASEV AEREL AREL 
				 AEACN AEACNOTH AEOUT TRTEMFL;
				 
			
Data ADAE_01;
merge Test_AE(in=a) Test_DM Test_ADSL;
by USUBJID;

	if missing(ASTTM) then ASTTMF = 'H';
	else if ASTTM = input(substr(AESTDTC, 12), time5.) then ASTTMF = 'NULL';
	
	 if missing(AENTM) then AENTMF = 'H';
	else if AENTM = input(substr(AEENDTC, 12), time5.) then AENTMF = 'NULL';
	
	ADURN = (AEENDY - AESTDY) + 1;
	
	If AESEV= 'MILD' then ASEV= 'Mild';
		Else if AESEV= 'MODERATE' then ASEV= 'Moderate';
		Else if AESEV = 'SEVERE' then ASEV= 'Severe';
		
	if AEREL= "NOT RELATED" then AREL= 'Unrelated';
		ELSE AREL= 'Related';
	
	 if ASTDT >= TR01SDT then TRTEMFL = "Y";
    else if ASTDT < TR01SDT and AESEV = "MILD" then TRTEMFL = "Y";
    else if ASTDT < TR01SDT and AESEV in ("MODERATE", "SEVERE") then TRTEMFL = "Y";
    else if missing(ASTDT) then TRTEMFL = "Y";
    else TRTEMFL = " ";

keep &varlist.;
run;

%sort(ADAE_01, USUBJID);
				 
Data ADAE_02(keep = &varlist.);
retain &varlist.;
Attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		AESEQ	label = 'Sequence Number' length = 8
		TRT01P label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)'	length = 8
		TRT01A	label = 'Actual Treatment for Period 01'	length = $40
		TRT01AN label = 'Actual Treatment for Period 01 (N)' length = 8
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
		ARFSTDT	label = 'Analysis Subject Reference Start Date'	length = 8 Format = DATE9.
		ARFSTTM	label = 'Analysis Subject Reference Start Time'	length = 8 Format =TIME5.
		ARFSTDTM label = 'Analysis Subject Reference Start Date/Time'	length = 8 Format = DATETIME15.
		ARFENDT	label = 'Analysis Subject Reference End Date' length = 8 Format = DATE9.
		ARFENTM	label = 'Analysis Subject Reference End Time'	length = 8 Format =TIME5.
		ARFENDTM label ='Analysis Subject Reference End Date/Time'  length = 8 Format = DATETIME15.
		AESTDTC	label = 'Analysis Start Date/Time of Adverse Event' length = $20
		ASTDT	label = 'Analysis Start Date' length = 8 Format = DATE9.
		ASTTM	label = 'Analysis Start Time' length = 8 Format =TIME5.
		ASTDTM	label = 'Analysis Start Date/Time' length = 8   Format = DATETIME15.
		ASTDY	label = 'Analysis Start Relative Day' length = 8
		AESTDY	label = 'Analysis Study Day of Start of Adverse Event' length = 8
		ASTTMF	label = 'Analysis Start Time Imputation Flag' length = $1
		AEENDTC	label = 'Analysis End Date/Time of Adverse Event' length = $20
		AENDT	label = 'Analysis End Date' length = 8 Format = DATE9.
		AENTM	label = 'Analysis End Time' length = 8 Format =TIME5.
		AENDTM	label = 'Analysis End Date/Time' length = 8  Format = DATETIME15.
		AENDY	label = 'Analysis End Relative Day'	length = 8
		AEENDY	label = 'Study Day of End of Adverse Event'	length = 8
		AENTMF	label = 'Analysis End Time Imputation Flag'	length = $1
		ADURN	label = 'AE Duration (Day)'	length = 8
		AETERM	label = 'Reported Term for the Adverse Event'	length = $200
		AEDECOD	label = 'Dictionary-Derived Term' length = $200
		AEBODSYS label = 'Body System or Organ Class' length = $200
		AELLT	label = 'Lowest Level Term'	length = $200
		AELLTCD	label = 'Lowest Level Term Code' length = 8
		AEDECOD	label = 'Dictionary-Derived Term'	length = $200
		AEPTCD	label = 'Preferred Term Code' length = 8
		AEHLT	label = 'High Level Term'	length = $200
		AEHLTCD	label = 'High Level Term Code'	length = 8
		AEHLGT	label = 'High Level Group Term'	length = $200
		AEHLGTCD	label = 'High Level Group Term Code' length = 8
		AESOC	label = 'Primary System Organ Class' length = $200
		AESER	label = 'Serious Event' length = $1
		AESEV	label = 'Severity/Intensity' length = $15
		ASEV	label = 'Analysis Severity/Intensity' length = $15
		AEREL	label = 'Causality'	 length = $25
		AREL	label = 'Analysis Causality' length = $25
		AEACN	label = 'Action Taken with Study Treatment'	 length = $25
		AEACNOTH label = 'Other Action Term'  length = $200
		AEOUT	label = 'Outcome of Adverse Event'	 length = $35
		TRTEMFL	label = 'Treatment Emergent Analysis Flag'	 length = $1;
set ADAE_01;
run;


proc export data=work.ADAE_02
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADAE.xlsx'
  dbms=xlsx
  replace;
  sheet="ADAE";
run;






