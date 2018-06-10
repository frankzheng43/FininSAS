data a;
input id a $ b c;
datalines;
1101 a 2 3
1102 b 3 4
1103 d 2 4
;
run;

data a;
input id a $ b c;
datalines;
1101 a 2 3
1102 b 3 4
1103 d 2 4;
run;

data a;
input id 1-4 a $ 5 b 6 c 7;
datalines;
1101a23
1102b34
1103d24
;
run;
data a;
input y 1-4 m id  a $  b  c ;
datalines;
199601 1101 a 2 3
199602 1102 b 3 4
199603 1103 d 2 4
;
run;
data a;
input y 1-4 m   id   month 1-6  a $  b  c  ;
datalines;
199601 1101 a 2 3
199602 1102 b 3 4
199603 1103 d 2 4
;
run;
data a;
input y 1-4 m id  a $  b  c  month 1-6;
datalines;
199601 1101 a 2 3
199602 1102 b 3 4
199603 1103 d 2 4
;
run;
data a;
input y 1-4 m month 1-6 id  a $  b  c;
datalines;
199601 1101 a 2 3
199602 1102 b 3 4
199603 1103 d 2 4
;
run;
data price;
infile "D:\The Application of SAS in Financial Research\Raw data\monthly price\d2007" firstobs=3;
input y 1-8 m code name $ volum value ret turn mv PE PB high low;
/*input the variable from d2007*/
run;

proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign"
dbms=xls
out=event
replace;
sheet="sheet1";
run;
proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign for xlsx"
dbms=xlsx
out=event_xlsx
replace;
sheet="sheet1";
run;
proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign for csv.csv"
/*CSV format file
you can delete the dbms and add the .csv 
foreign for csv.csv*/

out=event_csv
replace;
/* sheet="sheet1";
CSV only has one sheet, so we don't need the sheet*/
run;

proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign"
dbms=xls
out=event2 (drop=f1-f255)
/*if we use the different SAS edition,
the variables that sas auto-produces would be different 
*/
replace;
sheet="sheet1";
run;
proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign for csv.csv"
out=event3 (keep=code date)
/*
we recommend use the keep
*/
replace;
run;


data a;
set "D:\The Application of SAS in Financial Research\SAS data\daily data\d2002";
run;


libname aa "D:\The Application of SAS in Financial Research\SAS data\daily data";
data a;
set aa.d2002;
run;

data a;
set aa.d2002(keep= y m d code ret);
run;
/*SAS only reads the variables of y, m, d,code and ret from aa.d2002*/

data a(keep= y m d code ret);
set aa.d2002;
run;
/* the file A will keep y m d code ret after SAS reading all the data from aa.d2002*/

