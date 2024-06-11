LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

Data Test(drop = STUDY CENTRE  SUBINIT VISITDT  AGE SEX SEX_ ICFDTC COMPLETE POSTSTDY F13) ;
Set sdtm.complete;
if nmiss( of _numeric_ ) and cmiss(of _character_) then delete ;
STUDYID = STUDY;
Domain = 'DS';
USUBJID = catx('-',STUDY, CENTRE, PTNO);
DSTERM = 'COMPLETED';
DSDECOD = 'COMPLETED';
DSCAT = 'DISPOSITION EVENT';
EPOCH = 'Followup';
DSDTDTC = put(VISITDT, IS8601DA.);
run;

Proc sort data = Test;
by PTNO VISIT; run;

Data DS_Test2(Drop= PTNO VISIT);
set Test;
by PTNO VISIT;
	if first.ptno then DSSEQ = 1;
	else DSSEQ + 1;
run;

Data DS;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label="Unique Subject Identifier" length= $18
		DSSEQ label = 'Sequence Number' length = 3
		DSTERM label = "Reported Term for the Disposition Event" length = $9
		DSDECOD label = "Standardized Disposition Term" length = $9
		DSCAT label = "category for disposition event" length = $17
		EPOCH label = "Epoch" length = $8
		DSDTDTC label = "Start Date/Time of Disposition Event" length = $12 Format = IS8601DA.;
set DS_Test2;
run;


