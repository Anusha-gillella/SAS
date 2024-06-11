LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

DATA QS_TEST;
SET SDTM.QS; RUN;

PROC SORT DATA = QS_TEST; BY USUBJID QSSEQ; RUN;
PROC SORT DATA = Work.DM; BY USUBJID; RUN;

PROC SQL;
CREATE TABLE QS_TEST1 AS 
	SELECT A.*, B.RFSTDTC FROM WORK.QS_TEST AS A 
	LEFT JOIN WORK.DM AS B
	ON A.USUBJID = B.USUBJID
	ORDER BY USUBJID;
QUIT;

Data QS_TEST2(drop=RFSTDTC QSDT RFSTDT);
set QS_TEST1;
QSDT = input(QSDTC, anydtdte10.);
RFSTDT = input(RFSTDTC, anydtdte10.);
IF QSDT < RFSTDT then QSBLFL  = 'Y'; 
else QSBLFL='N';
Run;

Data QS;
attrib STUDYID label="Study Identifier" length= $12 
		DOMAIN label="Domain Abbreviation" length= $2 
		USUBJID label="Unique Subject Identifier" length= $18 
		QSSEQ label = 'Sequence Number' length = 3 
		QSTESTCD label = "Question Short Name" length = $10 
		QSTEST label = "Question Name" length = $21 
		QSCAT label = "Category of Question" length = $17 
		QSSCAT label = "Subcategory for Question" length = $12 
		QSORRES label = "Finding in Original Units" length = $9
		QSSTRESC label = "Character Result/Finding in Std Format" length = $9
		QSBLFL label = "Baseline Flag" length = $1 
		VISITNUM label = "Visit Number" length = 3
		QSDTC label = "Date/Time of Finding" length = $12 Format = IS8601DA.;
set QS_TEST2;
run;





