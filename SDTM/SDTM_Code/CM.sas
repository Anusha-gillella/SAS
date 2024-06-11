LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;


options missing = ' ';
Data CM_test(Keep= PTNO VISIT STUDYID DOMAIN USUBJID CMSEQ CMTRT CMINDC CMSTDTC ONGOING);
set SDTM.CONMED;
if missing(cats(of _all_)) then delete;
STUDYID = STUDY;
DOMAIN = 'CM';
USUBJID = catx ('-', STUDY, CENTRE, PTNO);
CMTRT = Therapy;
CMINDC = REASON;
CMSTDTC = PUT(STDT, IS8601DA.);
if CMSTDTC = '' then CMSTDTC = 'NA';
RUN;

Proc sort data = CM_TEST;
by PTNO Visit; run;


Proc SQL;
create table CM_TEST1 as 
	(select *, 
		case when  ONGOING = 'Yes' then  'ONGOING'
			else  'NA'
			End as CMENRF
	from CM_test);
quit;

Data CM_test2(drop = VISIT PTNO ONGOING);
set CM_TEST1;
by PTNO VISIT;
		IF first.ptno = 1 then CMSEQ = 1;
		else CMSEQ+1;
run;

Data CM;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label="Unique Subject Identifier" length= $18
		CMSEQ label = 'Sequence Number' length = 3
		CMTRT label = "Reported Name of Drug, Med, or Therapy" length = $26
		CMINDC label = "Indication" length = $10
		CMSTDTC label = "Start Date/Time of Medication" length = $12 Format = IS8601DA.
		CMENRF label = "End Relative to Reference Period" length = $7;
set CM_test2;
run;





