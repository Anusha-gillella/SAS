LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

Data VS_Test(rename=(study=STUDYID));
set sdtm.VS;
rename StudyID = Study;
run;

Proc SQL;
create table VS_Test1 as 
	select a.*, b.RFSTDTC from work.VS_Test as a 
			left join work.dm as b
			on a.USUBJID = b.USUBJID
	order by USUBJID, VSSEQ;
Quit;

Data VS_Test2(drop=RFSTDTC VSDT RFSTDT);
set VS_Test1;
VSDT = input(VSDTC, anydtdte10.);
RFSTDT = input(RFSTDTC, anydtdte10.);
IF VSDT < RFSTDT then VSBLFL  = 'Y'; 
else VSBLFL='N';
if VSSTRESU = "BEAT" then VSSTRESU="bpm";
Run;

proc contents data=VS_Test2;
run;

Data VS;
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label= "Unique Subject Identifier" length= $18
		VSSEQ label = 'Sequence Number' length = 3
		VSTESTCD label = 'vital sign test short name' length = $8
		VSTEST label = 'VITAL SIGN TEST NAME' length = $24
		VSPOS label = 'VITALSIGN POSITION OF SUBJECT' length = $7
		VSORRES  label = "Result or Finding in Original Units" length = $3
		VSORRESU  label = "Original Units" length = $5
		VSSTRESC  label = "Character Result/Finding in Standard Format" length = $4
		VSSTRESN  label = "Numeric Result/Finding in Standard Units" length = 4
		VSSTRESU label = "Standard Units" length = $4
		VSBLFL label = "Baseline Flag" length = $2
		VISITNUM label = "VISIT NUMBER" length = 3
		VSDTC label = "Date/Time of Measurements" length = $12 format = IS8601DA.;
set VS_Test2;
