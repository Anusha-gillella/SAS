LIBNAME ADaM '/home/u63665225/sasuser.v94/ADaM';

/*Transpose SUPPDM data, so that QNAM Becomes Variable*/ 
Proc Transpose data = ADaM.SUPPDM out = suppdm1;
	by STUDYID USUBJID;
	ID QNAM;
	IDLABEL QLABEL;
	Var QVAL;
Run;

PROC SORT DATA = ADAM.DM OUT = DM1;
	BY USUBJID;
RUN;

%macro sort(dsname, var);
    PROC SORT data=&dsname;
    by &var;
    Run;
%mend;

%sort(suppdm1, USUBJID); 


/*Merge DM and SUPPDM*/
data DM_1(drop=_NAME_ _LABEL_);
	merge DM1 (in=a) suppdm1;
	by STUDYID USUBJID;
	if a;
run;

DATA ADAM01;
	LENGTH INVNAM $20 REASNOT $40 OTHREASN $60;
	SET DM_1;
	LENGTH TRT01A TRT01P $40;
	
	/*PLANNED AND ACTUAL TREATMENT VARIABLES;*/
	
		IF ARM = '3 mg Cohort 1 Single Dose' 
			THEN DO;
				ARMN = 1;
				TRT01P = "Cohort 1, 3.0 mg, single dose";
				TRT01PN = 1;
				TRT01A = "Cohort 1, 3.0 mg, single dose";
				TRT01AN = 1;
			END;
		ELSE IF ARM = '7.5 mg Cohort 2 Single Dose' 
			THEN DO;
				ARMN = 2;
				TRT01P = "Cohort 2, 7.5 mg, single dose";
				TRT01PN = 2;
				TRT01A = "Cohort 2, 7.5 mg, single dose";
				TRT01AN = 2;
			END;
		ELSE IF ARM = '15 mg Cohort 3 Single Dose' 
			THEN DO;
				ARMN = 3;
				TRT01P = "Cohort 3, 15.0 mg, single dose";
				TRT01PN = 3;
				TRT01A = "Cohort 3, 15.0 mg, single dose";
				TRT01AN = 3;
			END;
		ELSE IF ARM = '5 mg Cohort 4 Multiple Dose' 
			THEN DO;
				ARMN = 4;
				TRT01P = "Cohort 4, 5.0 mg, multiple dose";
				TRT01PN = 4;
				TRT01A = "Cohort 4, 5.0 mg, multiple dose";
				TRT01AN = 4;
			END;
		
		
		if ARM = "Screen Failure" then do; SCRNFL = 'Y'; SCRNFLN = 1; end;
		else do; SCRNFL = 'N'; SCRNFLN = 0; end;
		
		
		/*DATE CONVERSIONS */
		/* Extract date and time components using substr */
        TR01SDT = input(substr(RFXSTDTC, 1, 10), yymmdd10.);
        TR01STM = input(substr(RFXSTDTC, 12), anydtdtm.);
        
        TR01EDT = input(substr(RFXENDTC, 1, 10), yymmdd10.);
        TR01ETM = input(substr(RFXENDTC, 12), anydtdtm.);
      
        ARFSTDT = input(substr(RFSTDTC, 1, 10), yymmdd10.);
        ARFENDT = input(substr(RFENDTC, 1, 10), yymmdd10.);
        ARFSTTM = input(substr(RFSTDTC, 12), anydtdtm.);
        ARFENTM = input(substr(RFENDTC, 12), anydtdtm.);
      
        
        /*Trying to convert Charater to numeric*/
        TR01SDTM = input(RFXSTDTC, IS8601DT.);
        TR01EDTM = input(RFXENDTC, IS8601DT.);
        ARFSTDTM = input(RFSTDTC, IS8601DT.);
        ARFENDTM = input(RFENDTC, IS8601DT.); 
        
     	BRTHDT = input(BRTHDTC, yymmdd10.);
     	CONSDT = input(RFICDTC, yymmdd10.);
     	DTHDT = input(DTHDTC, yymmdd10.);
     
        /* Apply formats */
        FORMAT TR01SDT TR01EDT ARFSTDT ARFENDT BRTHDT CONSDT DTHDT DATE9. 
               TR01STM TR01ETM ARFSTTM ARFENTM TIME5.
               TR01SDTM TR01EDTM ARFSTDTM ARFENDTM DATETIME15.;
 
 
 		/* Grouping Variables*/
 		length AGEGR1 $30.;
    If age ge 25 and age le 59 then do;
        AGEGR1 = '25-59';
        AGEGR1N = 1;
    end;
    else if age ge 60 and age le 80 then do;
        AGEGR1 = "60-80";
        AGEGR1N = 2;
    End;
    
    /*sex variable*/
       length ASEX $8;
    if sex= 'M' then do;
    	SEXN = 1;
    	ASEX = 'Male';
    End;
    if sex= 'F' then do;
    	SEXN = 0;
    	ASEX = 'Female';
    End;
    
    if RACE = "MULTIPLE" then RACE = "OTHER";
   If Race = "AMERICAN INDIAN OR ALASKA NATIVE" then RACEN = 1;
   ELSE If Race = "ASIAN" then RACEN = 2;
   Else If Race = "BLACK OR AFRICAN AMERICAN" then RACEN = 3;
   Else If Race = "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER" then RACEN = 4;
   Else If Race = "WHITE" then RACEN = 5;
   Else If Race = "OTHER" then RACEN = 6;
    
   
    IF ETHNIC = 'HISPANIC OR LATINO' THEN ETHNICN = 1;
    ELSE IF ETHNIC = 'NOT HISPANIC OR LATINO' THEN ETHNICN = 2;
    
    LENGTH DOSEDFL $1;
    IF MISSING(RFXSTDTC) THEN DO; DOSEDFL = "N";DOSEDFN=0; END;
    ELSE IF NOT MISSING(RFXSTDTC) THEN DO; DOSEDFL = "Y"; DOSEDFN=1;END;
   
RUN;
		

/*Process disposition data for treatment and study status*/

Data DS_Study;
set adam.ds;
length DCREASCD $200;

WHERE DSDECOD not in('INFORMED CONSENT OBTAINED' ,'RANDOMIZED','ENROLLED' ,'COMPLETED');
		DISCDT = input(DSSTDTC, yymmdd10.);
	if not missing(DSSTDTC) then DCREASCD = DSTERM;
	
FORMAT DISCDT DATE9.;
KEEP USUBJID DSSTDTC DSDECOD DISCDT DCREASCD;
RUN;
	
	
Data DS_Study_com;
set adam.ds;
	where DSDECOD = "COMPLETED";
		COMPDT = input(DSSTDTC, yymmdd10.);
FORMAT COMPDT DATE9.;
keep USUBJID DSDECOD COMPDT ;
run;
	
Data DS_Study_dth;
set adam.ds;
	where DSDECOD = 'DEATH';
keep USUBJID DSDECOD;
run;


Data DS_entro01;
set adam.ds;
where DSTERM = 'ENROLLED';
keep USUBJID DSTERM;
run;


%sort(DS_Study_com, USUBJID); 
%sort(DS_Study, USUBJID); 
%sort(DS_Study_dth, USUBJID); 
%sort(DS_entro01, USUBJID); 


DATA ADSL_01;
	MERGE ADAM01(IN=a) DS_Study DS_Study_com DS_Study_dth DS_entro01;
	by USUBJID;
Run;
    
Data ADSL_02;
set ADSL_01;
/*DSSTDT = input(substrn(DSSTDTC,1), yymmdd10.);
Format DSSTDT date9.;*/

	If DSDECOD = "COMPLETED" and not missing(COMPDT) then do; 
		COMPLFL = 'Y'; COMPLFN = 1; SUBJSTAT = 'COMPLETED'; END;
		ELSE do; 
			COMPLFL = 'N'; COMPLFN = 0; SUBJSTAT = 'DISCONTINUED'; END;
			
			
	If COMPLFL = 'Y' then COMPDY = COMPDT -  TR01SDT + 1;
	if DCREASCD ne '' then DISCDY = COMPDT -  TR01SDT + 1;

	if DSDECOD = 'DEATH' and not missing(DSSTDTC) then DTHFL = 'Y'; 
		else DTHFL = 'N';
		
	if DTHFL = 'Y' then DTHFN = 1; DTHFN = 0;
			
 	IF DSTERM = 'ENROLLED' THEN ENRLFN = 1;
    ELSE ENRLFN = 0;

   IF DSTERM = 'ENROLLED' THEN ENRLFL = 'Y';
    ELSE ENRLFL = 'N';
    
	if DCREASCD ne '' then do; WTHDFL = 'Y'; WTHDFN = 1; End;
		else do WTHDFL = 'N'; WTHDFN = 0; End;
run;


/*process Vital signs*/
Data heightb1;
set adam.VS_1;
where VSBLFL = "Y" and VSTESTCD = "HEIGHT" ;
if VSTESTCD = "HEIGHT" then HEIGHTBL = VSSTRESN;
keep USUBJID VSBLFL VSTESTCD VSSTRESN HEIGHTBL;
run;

Data weightb1;
set adam.VS_1;
where VSBLFL = "Y" and VSTESTCD = "WEIGHT" ;
if VSTESTCD = "WEIGHT" then WEIGHTBL = VSSTRESN; 
keep USUBJID VSBLFL VSTESTCD VSSTRESN WEIGHTBL;
run;

Data bmib1;
set adam.VS_1;
where VSBLFL = "Y" and VSTESTCD = "BMI";
if VSTESTCD = "BMI" then BMIBL = VSSTRESN; 
keep USUBJID VSBLFL VSTESTCD VSSTRESN BMIBL;
run;


/*process Exposure*/
Data EX_test;
set adam.EX_1;
by USUBJID;
if first.USUBJID then FSTDOSE = EXDOSE;
/*If not missing(EXDOSE) then do; SAFFL = 'Y'; SAFFLN = 1; END;
else do SAFFL = 'N'	;	SAFFLN = 0; END;
keep USUBJID EXDOSE FSTDOSE SAFFL SAFFLN*/
keep USUBJID EXDOSE FSTDOSE;
run;

/*process Inclusion/Exclusion*/
Data Test_IE;
set ADAM.IE;
	/* if IETESTCD ne '' then ALLIEFL = 'Y'; else  ALLIEFL = 'N';
	If  ALLIEFL = 'Y' then ALLIEFN = 1; else ALLIEFN = 1;
	
If index(IETESTCD,"INC") then do; INCNOFL = 'Y'; INCRIT= IETEST; end;
If index(IETESTCD,"EXC") then do; EXCNOFL = 'Y'; EXCRIT= IETEST; end; */
IEDT = input(IEDTC, yymmdd10.);
format IEDT date9.;
keep USUBJID IETESTCD IEORRES IECAT IETEST IEDT ;
run;

/*process Morphology*/
Data Test_MO;
set ADAM.MO;
length MRISCRN $50;
 	where VISIT = "Screening" and MOMETHOD = "MRI";
        MRISCRN = MOORRES;
keep USUBJID VISIT MOLAT MOMETHOD MRISCRN;
run; 

data Test_MO1 ;
set ADAM.MO;
by USUBJID;
    where MOMETHOD = "ALLEN'S TEST";
    ALENDTC = input(substr(modtc,1,10),is8601da.);
    if first.USUBJID;
    format ALENDTC date9.;
    keep USUBJID modtc MOMETHOD MOLAT MOORRES ALENDTC;
 run;


/*process supplementary Inclusion/Exclusion*/
Data Test_SUPPIE_IEEXEMPT;
set adam.suppie;
	where QNAM = 'IEEXEMPT';
	IEEXEMPT = QVAL;
	keep USUBJID QNAM QVAL IEEXEMPT;
	output Test_SUPPIE_IEEXEMPT; run;
	
Data Test_SUPPIE_IEEXPLAN;
set adam.suppie;	
	where QNAM = 'IEEXPLAN';
	IEEXPLAN = QVAL ;
	keep USUBJID QNAM QVAL IEEXPLAN;
	output Test_SUPPIE_IEEXPLAN;
	run;

   
%sort(heightb1, USUBJID); 
%sort(weightb1, USUBJID); 
%sort(bmib1, USUBJID); 
%sort(EX_test, USUBJID); 
%sort(Test_IE, USUBJID); 
%sort(Test_MO, USUBJID); 
%sort(Test_MO1, USUBJID); 
%sort(Test_SUPPIE_IEEXEMPT, USUBJID);
%sort(Test_SUPPIE_IEEXPLAN, USUBJID);  



Data ADSL_03;
merge ADSL_02(in=a)
	heightb1 weightb1 bmib1 EX_test Test_IE Test_MO Test_MO1 Test_SUPPIE_IEEXEMPT Test_SUPPIE_IEEXPLAN;
	by USUBJID;
run;

%sort(ADAM01, USUBJID); 


*Deriving from MO dataset;
Data ALENLFT;
merge ADAM01 Adam.Mo;
by usubjid;
modt = input(substr(modtc,1,10),is8601da.);
format modt date9.;
keep USUBJID TR01SDT MOMETHOD MOLAT MOORRES modt;
run;

data Test_MO_left;
set ALENLFT;
by usubjid;
where MOMETHOD = "ALLEN'S TEST" and MOLAT = "LEFT" and TR01SDT >= modt;
if first.usubjid;  /* Since adsl will contain demo and baseline characteristics we are 
considering first records after treatment */
keep usubjid molat tr01sdt visit visitnum  momethod modt;
if MOMETHOD = "ALLEN'S TEST" and MOLAT = "LEFT" and TR01SDT >= modt then ALENLFT = MOORRES;
keep USUBJID MOMETHOD MOLAT TR01SDT modt MOORRES ALENLFT;
run;


data Test_MO_right;
set ALENLFT;
by usubjid;
where MOMETHOD = "ALLEN'S TEST" and MOLAT = "RIGHT" and TR01SDT >= modt;
if first.usubjid;  /* Since adsl will contain demo and baseline characteristics we are 
considering first records after treatment */
if MOMETHOD = "ALLEN'S TEST" and MOLAT = "RIGHT" and TR01SDT >= modt then ALENRIT = MOORRES;
keep USUBJID MOMETHOD MOLAT TR01SDT modt MOORRES ALENRIT;
run;


%sort(Test_MO_left, USUBJID); 
%sort(Test_MO_right, USUBJID); 


Data ADSL_04;
merge ADSL_03(in=a)
	Test_MO_left Test_MO_right;
	by USUBJID;
run;

Data ADSL_05;
set ADSL_04;

If not missing(EXDOSE) then do; SAFFL = 'Y'; SAFFN = 1; END;
else do SAFFL = 'N'	;	SAFFN = 0; END;

if IETESTCD ne '' then ALLIEFL = 'Y'; else  ALLIEFL = 'N';
	If  ALLIEFL = 'Y' then ALLIEFN = 1; else ALLIEFN = 1;
	
If index(IETESTCD,"INC") then do; INCNOFL = 'Y'; INCRIT= IETEST; end;
else INCNOFL = 'N';
If index(IETESTCD,"EXC") then do; EXCNOFL = 'Y'; EXCRIT= IETEST; end;
else EXCNOFL = 'N';

run;


%let varlist = STUDYID USUBJID SUBJID SITEID ARM ARMN TRT01P TRT01PN TRT01A TRT01AN TR01SDT TR01STM TR01SDTM
				TR01EDT TR01ETM TR01EDTM ARFSTDT ARFSTTM ARFSTDTM ARFENDT ARFENTM ARFENDTM FSTDOSE BRTHDT CONSDT
				COMPDT DISCDT AGE AGEU AGEGR1 AGEGR1N SEX SEXN ASEX RACE RACEN ETHNIC ETHNICN REASNOT OTHREASN
				DOSEDFN DOSEDFL SAFFN SAFFL COMPLFN COMPLFL DTHDT DTHFN DTHFL SUBJSTAT DCREASCD WEIGHTBL HEIGHTBL
				BMIBL MRISCRN ENRLFL ENRLFN ALENLFT ALENRIT ALENDTC 
				SCRNFL SCRNFLN WTHDFL WTHDFN COMPDY DISCDY INCNOFL EXCNOFL INCRIT EXCRIT
				IEEXEMPT IEEXPLAN IEORRES IETESTCD IECAT INVNAM IEDT ALLIEFL ALLIEFN;
				
/*Create variables/assign Values to existing variables which are dependent on other variables;*/
Data ADSL_06(keep = &varlist.);

Attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		ARM	label = 'Description of Planned Arm' length =$40
		ARMN label = 'Description of Planned Arm (N)'	length = 8
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
		ARFSTDT	label = 'Analysis Subject Reference Start Date'	length = 8 Format = DATE9.
		ARFSTTM	label = 'Analysis Subject Reference Start Time'	length = 8 Format =TIME5.
		ARFSTDTM label = 'Analysis Subject Reference Start Date/Time'	length = 8 Format = DATETIME15.
		ARFENDT	label = 'Analysis Subject Reference End Date' length = 8 Format = DATE9.
		ARFENTM	label = 'Analysis Subject Reference End Time'	length = 8 Format =TIME5.
		ARFENDTM label ='Analysis Subject Reference End Date/Time'  length = 8 Format = DATETIME15.
		FSTDOSE	label = 'First Dose Admistered (mg)' length = 8
		BRTHDT	label = 'Date of Birth' length = 8 Format = DATE9.
		CONSDT	label = 'Date of Informed Consent'  length = 8 Format = DATE9. 
		COMPDT	label = 'Date of Study Completion' length = 8 Format = DATE9.
		DISCDT	label = 'Date of Study Discontinuation'	 length = 8 Format = DATE9.
		AGE label = 'Age'  length = 8
		AGEU label = 'Age Units' length = $5
		AGEGR1 label = 'Age Group 1' length = $30
		AGEGR1N	label = 'Age Group 1 (N)' length = 8
		SEX	label = 'Sex' length = $8
		SEXN label = 'Sex (N)' length = 8
		ASEX label = 'Analysis Sex'	 length = $8
		RACE label = 'Race'	 length = $50
		RACEN label = 'Race (N)' length = 8
		ETHNIC label = 'Ethnicity'	 length = $30
		ETHNICN	label = 'Ethnicity (N)'	length = 8
		REASNOT	label = 'Reason Subject Enrolled' length = $40
		OTHREASN label = 'Other Reason Subject Enrolled' length = $60
		DOSEDFN	label = 'Dosed Flag (N)' length = 8
		DOSEDFL	label = 'Dosed Flag' length =  $1
		SAFFN label = 'Safety Population Flag (N)' length = 8
		SAFFL label = 'Safety Population Flag'	length = $1
		COMPLFN	label = 'Completers Population Flag (N)' length = 8
		COMPLFL label = 'Completers Population Flag' length = $1
		DTHDT label = 'Date of Death' length = 8
		DTHFN label = 'Death Flag (N)' length = 8
		DTHFL label = 'Death Flag' length = $1
		SUBJSTAT label = 'Subject Status' length = $50
		DCREASCD label = 'Reason for Discontinuation' length = $200
		WEIGHTBL label = 'Baseline Weight (kg)'	length = 8
		HEIGHTBL label = 'Baseline Height (cm)'	length = 8
		BMIBL label = 'Baseline BMI (kg/m2)'	length = 8
		MRISCRN	label = 'MRI at Screening'	length = $50
		ENRLFL	label = 'Enrolled Population Flag'	length = $1
		ENRLFN	label = 'Enrolled Population Flag (N)'	length = 8
		ALENLFT	label ='Allens Test Left' length = $50
		ALENRIT label = 'Allens Test Right' length = $50
		ALENDTC	label = 'Date of Allen Performed'	length = 8 Format = DATE9.
		/*ALCMNT	label = 'Allens Comment'	length = $200*/
		SCRNFL	label = 'Screen Failure Flag' length = $1
		SCRNFLN	label = 'Screen Failure Flag (N)' length = 8
		WTHDFL	label = 'Withdrawal Flag'	length = $1
		WTHDFN	label = 'Withdrawal Flag (N)'	length = 8
		COMPDY	label = 'Completion Relative Day'	length = 8
		DISCDY	label = 'Discontinuation Relative Day' length = 8
		INCNOFL label = 'Inclusion criteria not met flag'	length = $1
		EXCNOFL	label = 'Exclusion criteria not met flag'	length = $1
		INCRIT	label = 'Inclusion not met details'	length = $200
		EXCRIT	label = 'Exclusion not met details'	length = $200
		/*PKFL	label = 'Pharmacokinetic Population Flag'	length = $1
		PKFN	label = 'Pharmacokinetic Population Flag (N)'	length = 8
		PPDFL	label = 'Pharmacodynamic Population Flag'	length = $1
		PPDFN	label = 'Pharmacodynamic Population Flag (N)'	length = 8
		PROTVERS label = 'Date of Protocol'	length = 8 */
		IEEXEMPT label = 'Exemption Granted?' length = $200 
		IEEXPLAN label = 'Explanation	text' length = $200 
		IEORRES	label = 'I/E Criterion Original Result' length = $1
		IETESTCD label = 'Inclusion/Exclusion Cieterion Short Name' length = $20
		IECAT label = 'Inclusion/Exclusion Criterion' length = $20
		INVNAM label = 'Investigator Name'	length = $20
		IEDT	label = 'Inclusion/Exclusion Date'	length = 8 Format = DATE9.
		ALLIEFL	label = 'All Criteria Flag'	length = $1
		ALLIEFN	label = 'All Criteria Flag (N)'	length = 8 ;
		
set ADSL_05;
run;



Data ADSL_07;
retain &varlist.;
set ADSL_06;
keep &varlist.;
run;

proc export data=work.ADSL_07
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADSL.xlsx'
  dbms=xlsx
  replace;
  sheet="ADSL";
run;



