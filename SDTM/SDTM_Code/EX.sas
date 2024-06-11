LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

DATA ADMIN;
SET SDTM.ADMIN;
RUN;

PROC SORT DATA = ADMIN;
BY PTNO VISIT;
RUN;


Data EX_temp;
merge sdtm.Ex WORK.admin;
by study centre ptno;
run;



Data EX_temp1(drop = STUDY CENTRE SUBJID SUBINIT AGE SEX DRUGYN DRUGYN_ sex_ DRUG DOSE EXSTDTC EXENDTC);
set Ex_temp(drop= sex);
STUDYID = STUDY;
Domain = 'EX';
USUBJID = catx('-', STUDY, CENTRE, PTNO);
EXTRT = DRUG;
EXDOSE = . ;
EXDOSTXT = Dose;
EXDOSU = 'mg';
EXDOSFRM = 'Tablet';
EXDOSFRQ = 'QD';
EXROUTE = 'Oral';
Run;


proc sort data = Ex_temp1;
by USUBJID VISIT;
run;

data EX_temp2;
  set EX_temp1;
  by USUBJID VISIT;
  if first.USUBJID then EXSEQ=1;
  else EXSEQ + 1;;
run;


proc sort data = Ex_temp2;
by ptno USUBJID VISIT;
run; 


data exstd;
set EX_temp2;
by PTNO visit;
if first.PTNO = 1 then exstdt = VISITDT;
format exstdt date9.;
if exstdt ne '';
keep PTNO VISIT USUBJID EXSTDT;
run;

data exend;
set EX_temp2;
by PTNO visit;
if last.PTNO = 1 then exendt = VISITDT;
format exendt date9.;
if exendt ne '';
keep PTNO VISIT USUBJID EXENDT;
run;

data EX_TEMP3;
merge EX_temp2 exstd exend;
by PTNO VISIT;
EXSTDTC = put(exstdt, IS8601DA.);
EXENDTC = put(exendt, IS8601DA.);
run;

Data EX_(drop = PTNO VISIT VISITDT EXSTDT EXENDT);
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label="Unique Subject Identifier" length= $18
		EXSEQ label = 'Sequence Number' length = 3
		EXTRT label = 'Name of Treatment'  length = $10
		EXDOSE label = 'Dose' length = 3
		EXDOSTXT label = 'Dose Description' length = $12
		EXDOSU label = 'Dose Units' length = $3
		EXDOSFRM label = 'Dose Form' length = $6
		EXDOSFRQ label = "Dosing Frequency per Interval" length = $2
		EXROUTE label = 'Route of Administration' length = $4
		EXSTDTC label = 'Start Date/Time of Treatment' length = $12 format=IS8601DA. 
		EXENDTC label = 'End Date/Time of Treatment' length = $12 format=IS8601DA.;
set EX_TEMP3;
run;

