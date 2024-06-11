LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

Data SC_TEST(keep = STUDYID DOMAIN USUBJID SCSEQ SCTESTCD SCTEST SCORRES SCDTC);
set SDTM.DEMO;
by PTNO;
STUDYID = STUDY;
DOMAIN = "SC";
USUBJID = CATX('-', STUDY, CENTRE, PTNO);
if first.PTNO then SCSEQ=1;
else SCSEQ + 1;
SCTESTCD = SUBINIT;
SCTEST = SUBINIT;
SCORRES = SUBINIT;
SCSTRESC = 'NA';
SCDTC = put(VISITDT, IS8601DA.);
Run;

DATA SC;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label= "Unique Subject Identifier" length= $18
		SCSEQ label = 'Sequence Number' length = 3
		SCTESTCD label = 'Subject Characteristic Short Name'  length = $3
		SCTEST label = 'Subject Characteristic' length = $3
		SCORRES label = 'Result or Finding in Original Units' length = $3
		SCSTRESC label = 'Character Result/Finding in Std Format' length = $2
		SCDTC label = 'Date/Time of Collection' length = $12 format=IS8601DA.;
SET SC_TEST;
Run;