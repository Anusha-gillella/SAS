LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

DATA SV_TEST;
	KEEP STUDYID DOMAIN USUBJID VISITNUM VISIT SVSTDTC;
SET SDTM.ADMIN;
STUDYID = STUDY;
DOMAIN = 'SV' ;
USUBJID = catx ('-', STUDY, CENTRE, PTNO);
VISITNUM = input(SUBSTR(VISIT,6,1));
SVSTDTC = PUT(VISITDT, IS8601DA.);
RUN;

PROC SORT DATA = SV_TEST;
BY USUBJID;
RUN;

PROC SQL;
CREATE TABLE SV_TEST1 AS 
	SELECT A.*, B.EXENDTC FROM WORK.SV_TEST AS A 
	LEFT JOIN WORK.EX_ AS B
	ON A.USUBJID = B.USUBJID
	ORDER BY USUBJID;
QUIT;

Data SV(drop = EXENDTC);
attrib STUDYID label="Study Identifier" length= $12 
		DOMAIN label="Domain Abbreviation" length= $2 
		USUBJID label="Unique Subject Identifier" length= $18 
		VISITNUM label = 'Visit Number' length = $3 
		VISIT label = "Visit Name" length = $6
		SVSTDTC label = "Start Date/Time of Observation" length = $12 Format = IS8601DA.
		SVENDTC label = "End Date/Time of Observation" length = $12 Format = IS8601DA.;
set SV_TEST1;
SVENDTC = EXENDTC;
run;


