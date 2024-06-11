LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;


Data SU_TEST (KEEP = STUDYID DOMAIN USUBJID SUSEQ SUTRT SUCAT SUSTDTC);
set sdtm.smoke;
by PTNO;
if missing(cats(of _all_)) then delete;
STUDYID = STUDY;
DOMAIN = "SU";
USUBJID = CATX('-', STUDY, CENTRE, PTNO);
if first.PTNO then SUSEQ=1;
else SUSEQ + 1;;
If SMOKE = 1 then SUTRT = 'CIGARETTES'; else SUTRT = 'No';
If SMOKE = 1 then SUCAT = 'TOBACCO'; else SUCAT = 'No';
SUSTDTC = put(visitdt, IS8601DA.);
run;


DATA SU;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label= "Unique Subject Identifier" length= $18
		SUSEQ label = 'Sequence Number' length = 3
		SUTRT label = 'Reported Name of Substance'  length = $10
		SUCAT label = 'Category for Substance Use' length = $10
		SUSTDTC label = 'Start Date/Time of Substance Use' length = $12 format=IS8601DA.;
SET SU_TEST;
Run;
		



/* Tried in SQL 
PROC SQL;
     ALTER TABLE SU_TEST 
        ADD STUDYID char(12), 
            DOMAIN char(2), 
            USUBJID char(18)
   DROP SUBINIT, SEX, SEX_, AGE, F12, F13, F14, F15, F16;
    UPDATE SU_TEST 
        SET STUDYID = STUDY, 
            DOMAIN = "SU", 
            USUBJID = CATX('-', STUDY, CENTRE, PTNO);
    SELECT *, 
        (CASE WHEN SMOKE = 1 THEN 'CIGARETTES' ELSE 'NO' END) AS SUTRT,
        (CASE WHEN SMOKE = 1 THEN 'TOBACCO' ELSE 'NO' END) AS SUCAT
    FROM SU_TEST;
QUIT;
*/

