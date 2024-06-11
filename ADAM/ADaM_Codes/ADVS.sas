/**********************************************
Name of file 		:	advs.sas
Title/Description	:	Program for ADVS Dataset
Location			:	'/home/u63665225/sasuser.v94/ADaM/Code/advs.sas'
Study				: 	ABC-1234-101
Dataset used		: 	study level
Macros used			:	Detailed within program
Output files		:	NA(study level)

Author				:
Date of completion	:

Reviewer			:
Date of Review		:

Comments			:

Modifications		:
Modification code	:
Modified by			:
Modified Date		:
Reason				:

****************************************************/

LIBNAME ADaM '/home/u63665225/sasuser.v94/ADaM';
Options nosymbolgen nomprint;


Proc datasets library=work kill;
quit;


PROC IMPORT OUT=ADSL1
    DATAFILE='/home/u63665225/sasuser.v94/ADaM/Datasets/ADSL.xlsx'
    Dbms = xlsx replace;
    getnames = yes;
  run;
 
 Data Test_ADSL;
 set ADSL1;
 *keep STUDYID USUBJID SUBJID SITEID TRT01P TRT01PN TRT01A TRT01AN AGE AGEU 
		SEX SEXN RACE RACEN ETHNIC ETHNICN SAFFL SAFFN TR01SDT TR01STM TR01SDTM 
		TR01EDT TR01ETM TR01EDTM;
run;

Proc sort data = ADAM.VS_1 out= Test_VS;
by USUBJID;
where vstestcd ne 'VSALL';
run;

%macro sort(dsname=, var=);
    PROC SORT data=&dsname; 
    by &var;
    Run;
%mend;

%sort(dsname=Test_ADSL,  var=USUBJID); 

data VS1;
merge Test_VS(in=a) Test_ADSL(in=b);
by USUBJID;
if a=1;
run;

Data VS2_;
set VS1;

	AVISIT = VISIT;
	AVISITN = VISITNUM;
	AVAL = VSSTRESN;
	AVALC = VSORRES;
	
	if length(vsdtc) = 10 then adt = input(vsdtc, yymmdd10.);
	if length(vsdtc) > 10 then adt = input(substr(vsdtc,1,10), yymmdd10.);
	if length(vsdtc) > 10 then do;
				atm = input(substr(vsdtc,12),Time5.);
				adtm = dhms(adt, hour(adt), minute(adt), second(adt));
	end;
	else if length(vsdtc) = 10 then do;
				atm = hms(0,0,0);
				adtm = dhms(adt, 0,0,0);
	end;
	
	ady = vsdy;
	
	If vstestcd in("DIABP", "SYSBP", "TEMP", "PULSE", "RESP") then do;	
			param = compbl(cat(compress(propcase(vspos)),compress(","), compbl(" "), vstest, 
					"(", compress(vsorresu),")"));
					
			if VSTESTCD = "DIABP" and VSPOS =  "STANDING" then PARAMCD = "DIABPSTAN";
			if VSTESTCD = "DIABP" and VSPOS = "SUPINE" then PARAMCD = "DIABPSUP";
			if VSTESTCD = "PULSE" and VSPOS = "STANDING" then PARAMCD = "PULSSTAN";
			if VSTESTCD = "PULSE" and VSPOS = "SUPINE" then PARAMCD = "PULSESUP";
			if VSTESTCD = "RESP" and VSPOS = "STANDING" then PARAMCD = "RESPSTAN";
			if VSTESTCD = "RESP" and VSPOS = "SUPINE" then PARAMCD = "RESPSUP";
			if VSTESTCD = "SYSBP" and VSPOS = "STANDING" then PARAMCD = "SYSBSTAN";
			if VSTESTCD = "SYSBP" and VSPOS = "SUPINE" then PARAMCD = "SYSBSUP";
			if VSTESTCD = "TEMP" and VSPOS = "STANDING" then PARAMCD = "TEMPSTAN";
			if VSTESTCD = "TEMP" and VSPOS = "SUPINE" then PARAMCD = "TEMPSUP";
	end;
	
	else if vstestcd not in("DIABP", "SYSBP", "TEMP", "PULSE", "RESP") then do;
		param = compbl(cat(vstest, "(", compress(vsorresu),")"));
		PARAMCD = VSTESTCD;
	end;
Format adt date9. atm time5. adtm datetime15.;
*keep USUBJID VISIT VISITNUM AVISIT AVISITN AVAL AVALC vsdtc adt atm adtm VSTEST VSTESTCD vsorresu VSPOS param PARAMCD  ;
run;


/**Deriving ortho variables**/
data ortho;
set VS2_;
	If PARAMCD in('DIABPSTAN', 'DIABPSUP', 'PULSSTAN', 'PULSESUP', 'SYSBSTAN', 'SYSBSUP') and
		aval ne .;
run;


data dstan dsup sstan ssup pstan psup;
set ortho;
	if paramcd = 'DIABPSTAN' then output dstan;
	if paramcd = 'DIABPSUP' then output dsup;
	if paramcd = 'PULSSTAN' then output pstan;
	if paramcd = 'PULSESUP' then output psup;
	if paramcd = 'SYSBSTAN' then output sstan;
	if paramcd = 'SYSBSUP' then output ssup;
run;
	
data dstan;
set dstan;
keep USUBJID aval avisit avisitn trt01a: trt01an adt vstpt;
rename aval= dstan;
run;

data sstan;
set sstan;
keep USUBJID aval avisit avisitn trt01a: trt01an adt vstpt;
rename aval= sstan;
run;

data pstan;
set pstan;
keep USUBJID aval avisit avisitn trt01a: trt01an adt vstpt;
rename aval= pstan;
run;

%sort(dsname=dstan,  var = trt01an USUBJID avisitn avisit adt vstpt); 
%sort(dsname=dsup,  var = trt01an USUBJID avisitn avisit adt vstpt); 
%sort(dsname=sstan,  var = trt01an USUBJID avisitn avisit adt vstpt); 
%sort(dsname=ssup,  var = trt01an USUBJID avisitn avisit adt vstpt); 
%sort(dsname=pstan,  var = trt01an USUBJID avisitn avisit adt vstpt); 
%sort(dsname=psup,  var = trt01an USUBJID avisitn avisit adt vstpt); 

	
	**** DIABP ORTHO****;
Data dia1;
	merge dsup(in=a) dstan(in=b);
	by trt01an USUBJID avisitn avisit adt vstpt;
	if a=1 and b=1;
run;

Data dia2;
set dia1;
	aval_ = dstan-aval;
	avalc = strip(put(aval_,best.));
	length txt $200. dtype $200.;
	txt ='Ortho Diastolic Blood Pressure';
	param = compbl(cat(compbl(propcase(txt)), compbl(' '), '(',compress(vsorresu),strip(')')));
	paramcd = "ODIABP";
	VSPOS = "ORTHO";
	vsorres ='';
	vsstresc = '';
	vsorres ='';
	vsstresc='';
	VSSTRESN=.;
	AVALC =STRIP(PUT(AVAL_,BEST.));
	ATM = .;
	ADTM = .;
	DTYPE ="Standing - Supine";
	drop aval;
	rename aval_ = aval;
run;

	**** SYSBP ORTHO****;
Data sys1;
	merge ssup(in=a) sstan(in=b);
	by trt01an USUBJID avisitn avisit adt vstpt;
	if a=1 and b=1;
run;

Data sys2;
set sys1;
	length txt $200. dtype $200.;
	aval_ = sstan-aval;
	avalc = strip(put(aval_,best.));
	
	txt ='Ortho Systolic Blood Pressure';
	param = compbl(cat(compbl(propcase(txt)), compbl(' '), '(',compress(vsorresu),strip(')')));
	paramcd = "OSYSBP";
	VSPOS = "ORTHO";
	vsorres ='';
	vsstresc = '';
	vsorres ='';
	vsstresc='';
	VSSTRESN=.;
	AVALC =STRIP(PUT(AVAL_,BEST.));
	ATM = .;
	ADTM = .;
	DTYPE ="Standing - Supine";
	drop aval;
	rename aval_ = aval;
run;

	**** PULSE ORTHO****;
Data pul1;
	merge psup(in=a) pstan(in=b);
	by trt01an USUBJID avisitn avisit adt vstpt;
	if a=1 and b=1;
run;

Data pul2;
set pul1;
	length txt $200. dtype $200.;
	aval_ = pstan-aval;
	avalc = strip(put(aval_,best.));
	
	txt ='Ortho SPulse Rate';
	param = compbl(cat(compbl(propcase(txt)), compbl(' '), '(',compress(vsorresu),strip(')')));
	paramcd = "OPULSE";
	VSPOS = "ORTHO";
	vsorres ='';
	vsstresc = '';
	vsorres ='';
	vsstresc='';
	VSSTRESN=.;
	AVALC =STRIP(PUT(AVAL_,BEST.));
	ATM = .;
	ADTM = .;
	DTYPE ="Standing - Supine";
	drop aval;
	rename aval_ = aval;
run;

Data Ortho2;
set dia2 sys2 pul2;
run;

Data VS2;
set VS2_ ortho2;
run;


***** Deriving the baseline value*****;
Data base1;
set VS2;
if visit = 'Day 1' and vstpt = 'PREDOSE';
keep USUBJID PARAM: aval;
run;

				%sort(dsname=base1,  var = USUBJID PARAM:); 

Data base2(drop=aval);
set base1;
by USUBJID PARAM:;
base = aval;
if last.param;
run;

			%sort(dsname=vs2,  var = USUBJID PARAM); 

***Merging back the baseline value to the main dataset*****;

Data VS3;
	merge vs2(in=a) base2(in=b);
by USUBJID param;
if a=1;
run;

Data VS4;
set VS3;
by USUBJID PARAM;
run;


Data VS5;
set VS4;
if visit = 'Day 1' and vstpt = 'PREDOSE' then do;
		ablfl = 'Y';
		ablfn = 1;
	end;
run;

Data VS6;
set VS5;
	if aval ne . and base ne . then chg = (aval - base);
	if aval ne . and base ne . and change ne 0 and base ne 0 then pchg = (chg/base)*100;
	if aval eq . then do;
		chg = . ;
		pchg = . ;
	end;
	
	if abfl ='Y' then do;
		chg = . ;
		pchg = . ;
	end;
	
	If paramcd = 'DIABPSTAN' then paramcd = 'DIABPSTN';
	if avisit in('Screening', 'Baseline, Day -1', '	Repeat, Day -1') then do;
			chg = . ;
			pchg = . ;
	end;
	

Proc SQL noprint;
	Create table VS7 as (Select * from VS6 group by USUBJID, param, avisit, 
							vstpt having count(*) > 1);
	Create table VS8 as(select studyid, domain, avg(aval) as aval, 
				strip(put(calculated aval,best.)) as avalc,
				base, usubjid, param, paramcd, vstest, vstestcd, vspos, 
				siteid, subjid, visit, visitnum, avisitn, vsstresu, avisit, vstpt, 
				vstptnum, trt01pn, trt01an, trt01p, trt01a,
				"Average" as Dtype, 'Y' as ANL01FL, 1 as ANL01FN from VS7 
	group by usubjid, param, avisit, vstpt);
quit;

data VS8;
set VS8;
	if aval ne . and base ne . then chg = (aval-base);
	if aval ne . and base ne . then pchg = (chg/base)*100;
run;

proc sort data = VS8 nodupkey dupout=dup;
	by usubjid paramcd avisitn paramcd descending dtype;
	run;

data vs6;
set vs6;
	if avist ne "Baseline, Day -1" then do;
		ANL01FL = 'Y';
		ANL01FN = 1;
	end;
run;


******** Final data setting both the records ******;
data vs9;
	set vs6 vs8;
drop siteid arm armn trt01p trt01pn trt01a trt01an tr01sdt tr01stm tr01sdtm tr01edt tr01etm
	tr01edtm ARFSTDT ARFSTTM ARFSTDTM ARFENDT ARFENTM ARFENDTM FSTDOSE BRTHDT CONSDT COMPDT 
	DISCDT AGE AGEU SEX SEXN ASEX RACE RACEN ETHNIC ETHNICN REASNOT OTHREASN DOSEDFN DOSEDFL 
	SAFFN SAFFL COMPLFN COMPLFL DTHDT DTHFN DTHFL SUBJSTAT DCREASCD WEIGHTBL HEIGHTBL
	BMIBL MRISCRN ENRLFL ENRLFN ALENLFT ALENRIT ALENDTC ALCMNT SCRNFL SCRNFLN  WTHDFL WTHDFN 
	COMPDY DISCDY INCNOFL EXCNOFL INCRIT EXCRIT PKFL PKFN PPDFL PPDFN PROTVERS IEEXEMPT 
	IEEXPLAN IEORRES;
RUN;

	%sort(dsname=vs9,  var = USUBJID); 
	%sort(dsname=Test_ADSL,  var = USUBJID); 
	
DATA VS10;
	MERGE VS9(IN=A) Test_ADSL;
	BY USUBJID;
	IF A;
RUN;

PROC SORT DATA = VS10;
	BY USUBJID PARAMCD AVISITN descending adt descending dtype;
run;

Data VS11;
retain aseq 1;
set VS10;
by usubjid paramcd avisitn;
if first.paramcd then aseq = 1;
else aseq = aseq+1;
run;


data vs12;
set vs11;
	if avisitn < 5 then do;
		chg =.;
		pchg = .;
	end;
	if index(upcase(avisit), 'UNS')>0 then do;
		ANL01FL = '';
		ANL01FN = .;
	end;
	
	if avisit in('Final Dose/PET Visit', 'Repeat, Day -1', 'Event Dosing 1', 
					'Early Termination') then do;
		ANL01FL = '';
		ANL01FN = .;
	end;
run;

proc sort data = vs12 out = VS13;
	by usubjid paramcd avisitn aseq;
run;

%let varlist = STUDYID USUBJID SUBJID SITEID TRT01A TRT01AN TRT01P TRT01PN AGE SEX SEXN RACEN ETHNIC ETHNICN 
				SAFFN SAFFL TR01SDT TR01STM TR01SDTM TR01EDT TR01ETM TR01EDTM 
				PARAM PARAMCD VISIT VISITNUM AVISIT AVISITN AVAL AVALC ABLFL ABLFN ADT ATM ADTM BASE
				CHG PCHG ADY VSTPT VSTPTNUM VSPOS VSTESTCD VSTEST VSORRES VSORRESU VSSTRESU VSSEQ ANL01FL 
				ANL01FN DTYPE ASEQ;

/*Create variables/assign Values to existing variables which are dependent on other variables;*/
Data ADVS(keep = &varlist.);

Attrib STUDYID label = 'Study Identifier' length = $15
		USUBJID label= "Unique Subject Identifier" length= $22
		SUBJID label = 'Subject Identifier for the Study' length= $10
		SITEID label = 'Study Site Identifier'	length = $5
		TRT01A	label = 'Actual Treatment for Period 01'	length = $40
		TRT01AN label = 'Actual Treatment for Period 01 (N)' length = 8
		TRT01P label = 'Planned Treatment for Period 01' length = $40
		TRT01PN	label = 'Planned Treatment for Period 01 (N)'	length = 8
		AGE label = 'Age'  length = 8
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
		PARAM	label = 'Parameter'	length =$100
		PARAMCD	label = 'Parameter Code'	length =$100
		VISIT	label = 'Visit Name'	length =$60
		VISITNUM	label = 'Visit Number'	length =8
		AVISIT	label = 'Analysis Visit'	length =$100
		AVISITN	label = 'Analysis Visit (N)'	length =8
		AVAL	label = 'Analysis Value' 	length =8
		AVALC	label = 'Analysis Value (C)'	length =$100
		ABLFL	label = 'Baseline Record Flag'	length =$1 
		ABLFN	label = 'Baseline Record Flag (N)'	length =8
		ADT		label = 'Analysis Date'		length =8
		ATM		label = 'Analysis Time'		length =8
		ADTM	label = 'Analysis Datetime'		length =8
		BASE	label = 'Baseline Value'		length =8
		CHG		label =  'Change from Baseline'		length =8
		PCHG	label = 'Percent Change from Baseline'		length =8
		ADY		label = 'Analysis Relative Day'		length =8
		VSTPT	label = 'Planned Time Point Name'		length =$100 
		VSTPTNUM	label = 'Planned Time Point Number'		length =8
		VSPOS	label = 'Vital Signs Position of Subject' 	length =$100 
		VSTESTCD	label = 'Vital Signs Test Short Name'		length =$100 
		VSTEST	label = 'Vital Signs Test Name'		length =$100 
		VSORRES	label = 'Result or Finding in Original Units'	length =$100 
		VSORRESU	label = 'Original Units'	length =$100 
		VSSTRESU	label = 'Standard Units'	length =$40
		VSSEQ	label = 'Sequence Number'	length =8
		ANL01FL	label = 'Analysis Flag 01'	length =$1
		ANL01FN	label = 'Analysis Flag 01 (N)'	length =8
		DTYPE	label = 'Derivation Type'	length =$20
		ASEQ	label = 'Analysis Sequence Number'		length =8
	;	
set VS13;
run;

Data VS14;
retain &varlist.;
set VS13;
keep &varlist.;
run;

proc export data=WORK.VS14
  outfile='/home/u63665225/sasuser.v94/ADaM/Datasets/ADVS.xlsx'
  dbms=xlsx
  replace;
  sheet="ADVS";
run;





