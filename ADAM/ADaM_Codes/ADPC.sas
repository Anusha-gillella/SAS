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

Proc sort data = ADAM.PC out= Test_PC;
	by USUBJID;
run;

data ADPC_01;
    set Test_PC;
    
    data ADPC_01;
    set Test_PC;

    /* Parse PCDTC into ADT (Date) and ATM (Time) */
    ADT = input(scan(PCDTC, 1, 'T'), yymmdd10.);
    ATM = input(scan(PCDTC, 2, 'T'), time5.);

    /* Ensure PCDTC is in the correct ISO8601 format before converting to datetime */
    if length(trim(PCDTC)) >= 10 then ADTM = input(PCDTC, is8601dt.);
    else ADTM = .;
    
    /*ADT = input(scan(PCDTC, 1, 'T'), yymmdd10.);
    ATM = input(scan(PCDTC, 2, 'T'), time5.);
    ADTM = input(PCDTC, IS8601DT.);*/
    format ADT yymmdd10. ATM time5. ADTM DATETIME15.;
    
    ADY = PCDY;
    
    PARAM = PCTEST;
    PARAMCD = PCTESTCD;
    
    AVAL = PCSTRESN;
    if not missing(PCSTRESN) then AVALC = '';
    	else AVALC = PCSTRESN;
    	
    if VISIT = 'Day 1' and PCTPTNUM = 1 then do;
        BASE = PCSTRESN;
        BASEC = PCSTRESC;
        ABLFL = 'Y';
        ABLFN = 1;
    end;
    else do;
        BASE = .;
        BASEC = '';
        ABLFL = '';
        ABLFN = .;
    end;
    
     if index(upcase(VISIT), 'UNSCHEDULED') = 0 then ANL01FL = 'Y';
    else ANL01FL = '';
    
    if ANL01FL = 'Y' then ANL01FN = 1;
    else ANL01FN = .;
 
 	CHG = AVAL - BASE;
    /* Only calculate PCHG for post-baseline values */
    if upcase(VISIT) not in ('DAY1', 'UNSCHEDULED') then
        PCHG = ((AVAL - BASE) / BASE) * 100;
    else
        PCHG = .;
        
        AVISIT = VISIT;
		AVISITN = VISITNUM;
		ATPT = PCTPT;
		ATPTN = PCTPTNUM;
run;

%macro sort(dsname, var);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;

%sort(Test_ADSL, USUBJID); 
%sort(ADPC_01, USUBJID); 
	
Data ADPC_02;
merge ADPC_01(in=a) Test_ADSL;
by USUBJID;
if a;
run;

%let varlist = STUDYID USUBJID SUBJID SITEID ARM ARMN TRT01P TRT01PN TRT01A TRT01AN 
		TR01SDT TR01STM TR01SDTM TR01EDT TR01ETM TR01EDTM AGE AGEU SEX SEXN ASEX 
		RACE RACEN ETHNIC ETHNICN SAFFL SAFFN ADT ATM ADTM ADY PCSEQ PARAM PARAMCD
		AVALC AVAL BASE BASEC ABLFL ABLFN ANL01FL ANL01FN CHG PCHG AVISIT AVISITN
		ATPT ATPTN PCCAT PCNAM PCSPEC PCLLOQ EPOCH;

Data ADPC_03(keep = &varlist.);
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
		ADT		label = 'Analysis Date'	length = 8	Format = DATE9.
		ATM		label = 'Analysis Time'	length = 8	Format = TIME5.
		ADTM	label = 'Analysis Date/Time'	length = 8	Format = DATETIME15.
		ADY		label = 'Analysis Relative Day'	length = 8	
		PCSEQ	label = 'Sequence Number'	length = 8	
		PARAM	label = 'Parameter'	length = $100	
		PARAMCD	label = 'Parameter Code'	length = $8	
		AVALC	label = 'Analysis Value (C)'	length = $200	
		AVAL	label = 'Analysis Value'	length = 8	
		BASE	label = 'Baseline Value'	length = 8	
		BASEC	label = 'Baseline Value (C)'	length = $30 	
		ABLFL	label = 'Baseline Record Flag'	length = $1	
		ABLFN	label = 'Baseline Record Flag (N)' length = 8	
		ANL01FL	label = 'Analysis Record Flag 01'	length = $1	
		ANL01FN	label = 'Analysis Flag 01 (N)'	length = 8	
		CHG		label = 'Change from Baseline'	length = 8	
		PCHG	label = 'Percent Change from Baseline' length = 8	
		AVISIT	label = 'Analysis Visit'	length = $60	
		AVISITN	label = 'Analysis Visit (N)'	length = 8	
		ATPT	label = 'Analysis Timepoint'	length = $60	
		ATPTN	label = 'Analysis Timepoint (N)'	length = 8	
		PCCAT	label = 'Test Category'	length = $40	
		PCNAM	label = 'Vendor Name'	length = $20	
		PCSPEC	label = 'Specimen Material Type'	length = $20	
		PCLLOQ	label = 'Lower Limit of Quantitation'	length = 8	
		EPOCH	label = 'Epoch'	length = $40
		;
set ADPC_02;
keep &varlist.;
run;


proc export data=work.ADPC_03
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADPC.xlsx'
  dbms=xlsx
  replace;
  sheet="ADPC";
run;


