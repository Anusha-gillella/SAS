proc import 
    datafile='/home/u63665225/sasuser.v94/Rawdata/sdtm spec.xlsx'
    out = TI_TEST
    dbms = xlsx replace;
    sheet = 'TI';
    getnames = YES;
run;



