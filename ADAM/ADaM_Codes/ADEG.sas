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
  
Data Test_EG;
set ADAM.EG;

	ASEQ = EGSEQ;
	PARAM = catx('',EGTEST, '(', EGSTRESU, ')');
	
	PARAMCD = EGTESTCD;
	AVISIT = VISIT;
	AVISITN = VISITNUM;
	AVAL = EGSTRESN;
	AVALC = EGORRES;
	
	If length(EGDTC) > 10 then ADT = input(substr(EGDTC, 1, 10), yymmdd10.);
	If length(EGDTC) > 10 then ATM = input(substr(EGDTC, 12), anydtdtm.);
	ADTM = dhms(ADT, hour(ATM), minute(ATM), second(ATM));
	
	ADY =EGDY;
	
Format ADT date9. ATM Time5. ADTM Datetime15.;
*keep USUBJID ASEQ EGTEST EGSTRESU PARAM PARAMCD VISIT VISITNUM AVISIT AVISITN 
		AVAL AVALC  ADT ATM ADTM ADY;
run;

Data Test_EG2;
set Test_EG;

  if PARAMCD = "QTCF" then do;
        if AVAL <= 450 then do;
            QTCFGR1 = "<450";
            QTCFGR1N = 1;
        end;
        else if AVAL > 450 and AVAL <= 480 then do;
            QTCFGR1 = "> 450 to <= 480";
            QTCFGR1N = 2;
        end;
        else if AVAL > 480 and AVAL <= 500 then do;
            QTCFGR1 = "> 480 to <= 500";
            QTCFGR1N = 3;
        end;
        else if AVAL > 500 then do;
            QTCFGR1 = ">500";
            QTCFGR1N = 4;
        end;
    end;

run;

data Test_SUPPEG;
    set ADAM.SUPPEG;
    if QNAM = "ABNOSPEC" then ABNOSPEC = QVAL;
run;

Data Test_DM;
set ADAM.DM;
RFSTDT = input(substr(RFSTDTC, 1, 10), yymmdd10.);
Format RFSTDT date9.;
keep STUDYID USUBJID RFSTDT;
run;


%macro sort(dsname, var);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;


%sort(Test_EG2, USUBJID Param: ADT);
%sort(Test_DM, USUBJID); 


************* Deriving ABLFL Variable **************;
Data ADEG_01;
merge Test_EG2(in=a) Test_DM(in=b);
by USUBJID;
if a and b;
run;

*To find the pre-treatment records;
proc sort data=ADEG_01 out = base_01;
    by USUBJID PARAMCD ADT visitnum EGSEQ;
    *if not missing(ADT) and ADT > . and ADT <= RFSTDT;
   where . lt ADT le RFSTDT and aval ne .;
run;

Data base_02;
set base_01;
 by USUBJID PARAMCD ADT visitnum EGSEQ;
 	if last.paramcd;
 keep  USUBJID PARAMCD ADT RFSTDT visitnum EGSEQ ABLFL aval ;
 ABLFL = 'Y';
 run;
 
 %sort(base_02, USUBJID PARAMCD ADT visitnum);
 %sort(ADEG_01, USUBJID PARAMCD ADT visitnum);
 
 
 Data ADEG_02;
 merge ADEG_01(in=a) base_02(in=b drop=aval);
 by USUBJID PARAMCD ADT visitnum EGSEQ;
 if a;
 run;
 
 
 Data ADEG_03;
 Set ADEG_02;
 if ABLFL = 'Y' then ABLFN = 1;
 else do; ABLFL = 'N';ABLFN = 0; end;
 run;
 
 
 ****DERIVING BASE, CHANGE, PCHG ARIABLES*******;
 
 %sort(base_02, USUBJID PARAMCD);
 %sort(ADEG_03, USUBJID PARAMCD);
 
 

  Data ADEG_04;
 merge ADEG_03(in=a) base_02(in=b Keep=USUBJID PARAMCD aval rename=(aval=base));
 by USUBJID PARAMCD;
 run;
 
Data ADEG_05;
 Set ADEG_04;
	if ADT gt RFSTDT gt . then do;
			if aval ne . and base ne . then do;
				chg = aval - base;
				pchg = (chg/base)*100;
			end;
	end;
Run;
 
 
data ADEG_06;
 set ADEG_05;
    
    if AVAL <= 30 then do; QTCFGR2 = "<= 30"; QTCFGR2N = 1; end;
    else if AVAL > 30 and AVAL <= 60 then do; QTCFGR2 = "> 30 to <= 60"; QTCFGR2N = 2; end;
    else if AVAL > 60 then do; QTCFGR2 = "> 60"; QTCFGR2N = 3; end;
    
run;

%sort(Test_ADSL, USUBJID); 
%sort(Test_SUPPEG, USUBJID);
%sort(ADEG_06, USUBJID);

Data ADEG_07;
merge ADEG_06(in=a) Test_SUPPEG Test_ADSL;
by  USUBJID;
run;

%let varlist = STUDYID USUBJID SUBJID SITEID ASEQ TRT01P TRT01PN TRT01A TRT01AN AGE AGEU
	SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM TR01EDT TR01ETM
	TR01EDTM PARAM PARAMCD VISIT VISITNUM AVISIT AVISITN AVAL AVALC ABLFL ABLFN ADT ATM ADTM
	BASE CHG PCHG QTCFGR1 QTCFGR1N QTCFGR2 QTCFGR2N ADY EGTPT EGTPTNUM EGCAT EGMETHOD ABNOSPEC;


Data ADEG_08(keep = &varlist.);
attrib STUDYID	label = 'Study Identifier' length = $15
		USUBJID	label = 'Unique Subject Identifier' length = $22
		SUBJID	label = 'Subject Identifier for the Study' length = $10
		SITEID	label = 'Study Site Identifier' length = $5
		ASEQ	label = 'Analysis Sequence Number' length = 8
		TRT01P	label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)' length = 8
		TRT01A	label = 'Actual Treatment for Period 01' length = $40
		TRT01AN	label = 'Actual Treatment for Period 01 (N)' length = 8
		AGE		label = 'Age' length = 8
		AGEU	label = 'Age Units' length = $5
		SEX		label = 'Sex' length = $8
		SEXN	label = 'Sex (N)' length = 8
		RACE	label = 'Race' length = $50
		RACEN	label = 'Race (N)' length = 8
		ETHNIC	label = 'Ethnicity' length = $30
		ETHNICN	label = 'Ethnicity (N)' length = 8
		SAFFL	label = 'Safety Population Flag' length = $1
		SAFFN	label = 'Safety Population Flag (N)' length = 8
		TR01SDT	label = 'Date of First Exposure in Period 01' length = 8 format=date9.
		TR01STM	label = 'Time of First Exposure in Period 01' length = 8 format=time5.
		TR01SDTM	label = 'Datetime of First Exposure in Period 01' length = 8 format=datetime15.
		TR01EDT	label = 'Date of Last Exposure in Period 01' length = 8 format=date9.
		TR01ETM	label = 'Time of Last Exposure in Period 01' length = 8 format=time5.
		TR01EDTM	label = 'Datetime of Last Exposure in Period 01' length = 8 format=datetime15.
		PARAM	label = 'Parameter' length = $100
		PARAMCD	label = 'Parameter Code' length = $8
		VISIT	label = 'Visit Name' length = $60
		VISITNUM label = 'Visit Number' length = 8
		AVISIT	label = 'Analysis Visit' length = $100
		AVISITN	label = 'Analysis Visit (N)' length = 8
		AVAL	label = 'Analysis Value'  length = 8
		AVALC	label = 'Analysis Value (C)' length = $100
		ABLFL	label = 'Baseline Record Flag' length = $1 
		ABLFN	label = 'Baseline Record Flag (N)' length = 8
		ADT		label = 'Analysis Date' length = 8 format=date9.
		ATM		label = 'Analysis Time' length = 8 format=time5.
		ADTM	label = 'Analysis Datetime' length = 8 format=datetime15.
		BASE	label = 'Baseline Value' length = 8
		CHG		label = 'Change from Baseline' length = 8
		PCHG	label = 'Percent Change from Baseline' length = 8
		QTCFGR1	label = 'QTCF Group 1' length = $20 
		QTCFGR1N	label = 'QTCF Group 1 (N)' length = 8
		QTCFGR2	label = 'QTCF Group 2' length = $20 
		QTCFGR2N	label = 'QTCF Group 2 (N)' length = 8
		ADY			label = 'Analysis Relative Day' length = 8
		EGTPT	label = 'Planned Time Point Name' length = $100 
		EGTPTNUM	label = 'Planned Time Point Number' length = 8
		EGCAT	label = 'Category for ECG' length = $100 
		EGMETHOD	label = 'Method of ECG Test' length = $100 
		ABNOSPEC	label = 'Reason for Abnormal' length = $100 ;
Set ADEG_07;
run;
 
Data ADEG_09;
retain &varlist.;
set ADEG_08;
keep &varlist.;
run;

proc export data=work.ADEG_09
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADEG.xlsx'
  dbms=xlsx
  replace;
  sheet="ADEG";
run;




 