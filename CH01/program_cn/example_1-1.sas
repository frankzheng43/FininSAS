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
/*年 月  股票代号 股票名称 成交量 成交值 报酬率 市值 本益比 市价净值比 最高价 最低价*/
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
/*CSV档案格式
不需要dbms的语法
且副档名要标注在档案名之后  
foreign for csv.csv*/

out=event_csv
replace;
sheet="sheet1";
/*CSV 只有一个工作表 不需要下sheet的语法*/
run;

proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign"
dbms=xls
out=event2 (drop=f1-f255)
/*采用不同格式运行 生成的变项栏位会不一样*/
replace;
sheet="sheet1";
run;
proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign for csv.csv"
out=event3 (keep=code date)
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
/*在读取数据时，只读 y m d code ret 运行速度较快*/

data a(keep= y m d code ret);
set aa.d2002;
run;
/*将aa.d2002完整读取后  保留y m d code ret 运行速度较慢*/
