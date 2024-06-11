LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

Data AE_TEST(rename=(Study=STUDYID SEV_=AESEV EVENT = AETERM));
set SDTM.ADVERSE;
Domain = 'AE';
USUBJID = catx('-',Study, CENTRE, PTNO);
AELLTCD = 'NA';
AEDECOD = 'NA';
IF AEYN="NO" THEN AESER="N"; 
else AESER="Y";
IF ACTION_="No action taken" THEN AEACN= "NOT APPLICABLE";        
else if ACTION_="DOSE ADJUSTMENT" THEN AEACN="DOSE REDUCED";
else AEACN='';
IF RELATION_="Not suspected" THEN AEREL="NOT RELATED";
else if RELATION_="suspected" THEN AEREL="RELATED";
else AEREL='';
AESTDTC = PUT(STDT, date9.);
AEENDTC = PUT(ENDT, date9.);
Run;


Proc sort data = AE_TEST;
by PTNO USUBJID VISIT;
run;

Data AE_TEST1(Keep = STUDYID Domain USUBJID AESEQ AETERM AELLTCD AEDECOD AESEV AESER AEACN
			AEREL AESTDTC AEENDTC AEENRF);
set AE_TEST;
by PTNO USUBJID VISIT;
IF first.ptno then AESEQ = 1;
else AESEQ+1;
IF ONGOING=" " THEN AEENRF = "ONGOING"; 
else AEENRF ='.';
run;

DATA AE;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label= "Unique Subject Identifier" length= $18
		AESEQ label = 'Sequence Number' length = 3
		AETERM label = 'Reported Term for the Adverse Event'  length = $11
		AELLTCD label = 'Lowest Level Term Code' length = $2
		AEDECOD label = 'Dictionary-Derived Term' length = $2
		AESEV label = 'Severity/Intensity' length = $8
		AESER label = 'Serious Event' length = $1
		AEACN label = 'Action Taken with Study Treatment' length = $14
		AEREL label = 'Causality' length = $11
		AESTDTC label = 'Start Date/Time of Adverse Event' length = $12 format=IS8601DA.
		AEENDTC label = 'END Date/Time of Adverse Event' length = $12 format=IS8601DA.
		AEENRF label = 'End Relative to ReferencePeriod' length = $7;
SET AE_TEST1;
Run;
