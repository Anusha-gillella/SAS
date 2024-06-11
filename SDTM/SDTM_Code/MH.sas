LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

Data MH_test(Keep= PTNO VISIT STUDYID DOMAIN USUBJID MHTERM MHDTC MHSTDTC);
set SDTM.Demo;
STUDYID = STUDY;
DOMAIN = 'MH';
USUBJID = catx ('-', STUDY, CENTRE, PTNO);
MHTERM = "HYPERTENSION";
MHDTC = PUT(VISITDT, IS8601DA.);
MHSTDTC = PUT(HISTDT, IS8601DA.);
run;


Data MH_test1(drop = VISIT PTNO);
set MH_test;
by PTNO VISIT;
		IF first.ptno = 1 then MHSEQ = 1;
		else MHSEQ+1;
run;


Data MH;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label="Unique Subject Identifier" length= $18
		MHSEQ label = 'Sequence Number' length = 3
		MHTERM label = "Reported Term for the Medical History" length = $12
		MHDTC label = "Date/Time of History Collection" length = $12 Format = IS8601DA.
		MHSTDTC label = "Start Date/Time of Medical History Event" length = $12 Format = IS8601DA.;
set MH_test1;
run;


