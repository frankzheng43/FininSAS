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
/*�� ��  ��Ʊ���� ��Ʊ���� �ɽ��� �ɽ�ֵ ������ ��ֵ ����� �м۾�ֵ�� ��߼� ��ͼ�*/
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
/*CSV������ʽ
����Ҫdbms���﷨
�Ҹ�����Ҫ��ע�ڵ�����֮��  
foreign for csv.csv*/

out=event_csv
replace;
sheet="sheet1";
/*CSV ֻ��һ�������� ����Ҫ��sheet���﷨*/
run;

proc import datafile="D:\The Application of SAS in Financial Research\Raw data\event date\foreign"
dbms=xls
out=event2 (drop=f1-f255)
/*���ò�ͬ��ʽ���� ���ɵı�����λ�᲻һ��*/
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
/*�ڶ�ȡ����ʱ��ֻ�� y m d code ret �����ٶȽϿ�*/

data a(keep= y m d code ret);
set aa.d2002;
run;
/*��aa.d2002������ȡ��  ����y m d code ret �����ٶȽ���*/
