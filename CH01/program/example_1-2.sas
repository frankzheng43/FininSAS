
option nonotes;
libname aa "D:\The Application of SAS in Financial Research\SAS data\daily data\";
data a;
set aa.d2002;
run;

proc export data=a
outfile="D:\The Application of SAS in Financial Research\CH01\output\a.txt"
replace;
run;

proc export data=a
outfile="D:\The Application of SAS in Financial Research\CH01\output\return"
dbms=xlsx
replace;
sheet="y2002";
/*
you need to write the name of the sheet or
SAS will replace it
*/
run;
/*
/*
the limit of observation for xls is 65,535 
                         for xlsx is more than millions
you can export to CSV format, it's similar to excel
*/


proc export data=a
outfile="D:\The Application of SAS in Financial Research\CH01\output\return.csv"
replace;
run;


data "D:\The Application of SAS in Financial Research\CH01\output\b";
set a;
run;
libname bb "D:\The Application of SAS in Financial Research\CH01\output";
data bb.a;
set a;
run;


