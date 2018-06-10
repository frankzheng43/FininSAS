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
outfile="D:\The Application of SAS in Financial Research\CH01\output\报酬率"
dbms=xlsx
replace;
sheet="y2002";
/*一定要指定输出的sheet
否则SAS以报酬率作为sheet取代掉
*/
run;
/*
/*
基本上 EXCEL2003文件有65535笔数据的限制
      EXCEL 2007文件大约有一百多万笔数据的限制
可以采用输出成CSV格式
其数据处理如同EXCEL文件 
*/


proc export data=a
outfile="D:\The Application of SAS in Financial Research\CH01\output\报酬率.csv"
replace;
run;


data "D:\The Application of SAS in Financial Research\CH01\output\b";
set a;
run;
libname bb "D:\The Application of SAS in Financial Research\CH01\output";
data bb.a;
set a;
run;

