proc import 
    datafile='/home/u63665225/sasuser.v94/Rawdata/sdtm spec.xlsx'
    out = TA_TEST
    dbms = xlsx replace;
    sheet = 'TA';
    getnames = YES;
run;



