proc import 
    datafile='/home/u63665225/sasuser.v94/Rawdata/sdtm spec.xlsx'
    out = TE_TEST
    dbms = xlsx replace;
    sheet = 'TE';
    getnames = YES;
run;



