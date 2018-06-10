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
outfile="D:\The Application of SAS in Financial Research\CH01\output\������"
dbms=xlsx
replace;
sheet="y2002";
/*һ��Ҫָ�������sheet
����SAS�Ա�������Ϊsheetȡ����
*/
run;
/*
/*
������ EXCEL2003�ļ���65535�����ݵ�����
      EXCEL 2007�ļ���Լ��һ�ٶ�������ݵ�����
���Բ��������CSV��ʽ
�����ݴ�����ͬEXCEL�ļ� 
*/


proc export data=a
outfile="D:\The Application of SAS in Financial Research\CH01\output\������.csv"
replace;
run;


data "D:\The Application of SAS in Financial Research\CH01\output\b";
set a;
run;
libname bb "D:\The Application of SAS in Financial Research\CH01\output";
data bb.a;
set a;
run;

