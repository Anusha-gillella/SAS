LIBNAME SDTM '/home/u63665225/sasuser.v94/Rawdata'; run;

data dm_test(drop = sex_);
set SDTM.DEMO(DROP= SEX SMOKE SMOKE_);
Domain = 'DM';
SITEID = put(centre,4.);
SUBJID = put(ptno,3.);
USUBJID = catx('-',STUDY,SITEID,SUBJID);
AgeU = 'Years';
sex = substr(sex_,1,1);
Race = '.';
ARMCD = 'VAH';
ARM = "Valsartan Hyderochloro thiazide";
COUNTRY = "IND";
DMDTC = put(visitdt, IS8601DA.);
run;

data ex1;
set sdtm.ex;
by ptno visit;
if first.ptno = 1 then exstdt = EXSTDTC;
format exstdt date9.;
if exstdt ne '';
keep study centre ptno exstdt;
run;

data ex2;
set sdtm.ex;
by ptno visit;
if last.ptno = 1 then exendt = EXENDTC;
format exendt date9.;
if exendt ne '';
keep study centre ptno exendt;
run;

data dm_1(drop = exstdt exendt);
merge dm_test ex1 ex2;
by study centre ptno;
RFSTDTC = put(exstdt, IS8601DA.);
RFENDTC = put(exendt, IS8601DA.);
RFXSTDTC = RFSTDTC;
RFXENDTC = RFENDTC;
DMDY = visitdt - exstdt;
STUDYID = study;
run;


Data DM(DROP= PTNO SUBINIT VISITDT VISIT WEIGHT HEIGHT HISTDT STUDY CENTRE);
attrib STUDYID label="Study Identifier" length= $12
		DOMAIN label="Domain Abbreviation" length= $2
		USUBJID label="Unique Subject Identifier" length= $18
		SUBJID label="Subject Identifier for the Study" length= $3
		RFSTDTC label="Subject Reference Start Date/Time" length= $12 format=IS8601DA.
		RFENDTC label="Subject Reference End Date/Time" length= $12 format=IS8601DA.
		RFXSTDTC label="Date/Time of First Study Treatment" length= $12 format=IS8601DA.
		RFXENDTC label="Date/Time of Last Study Treatment" length= $12 format=IS8601DA.
		SITEID label = "Study Site Char Identifier" length = $4
		AGE label = "Age" LENGTH = 3
		AGEU label = "Age Units"  length = $6
		SEX label= "Sex" length = $1
		Race label = 'Race' length = $8
		ARMCD label="Planned Arm Code"
		ARM label ="Description of Planned Arm"
		COUNTRY label = "Country"
		DMDTC  label = "Date/Time of Collection" length = $12 format=IS8601DA.
		DMDY label = "Study Day of Collection";
set dm_1;
run;
















