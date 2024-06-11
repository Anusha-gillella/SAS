proc import 
    datafile='/home/u63665225/sasuser.v94/Rawdata/sdtm spec.xlsx'
    out = TV_TEST
    dbms = xlsx replace;
    sheet = 'TV';
    getnames = YES;
run;

Data TV;
attrib STUDYID label = "Study Identifier" length = $12
		DOMAIN label = "Domain Abbreviation" length = $2
		VISITNUM label = "Visit Number" length = 3
		VISIT label ="Visit Name" length = $6
		ARM label = "Description of Planned Arm" length = $21
		ARMCD label = "Planned Arm Code" length = $16
		TVSTRL label = "Visit Start Rule" length = $30
		TVENRL label = "Visit End Rule" length = $25;
set TV_TEST;
run;





