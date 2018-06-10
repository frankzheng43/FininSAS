DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data a;
   set aa.price;
      if nmiss(ret,pb,turn,volum)^=0 then delete;
      month=y*100+m;
      if y=2006 then output;
      keep code month ret pb turn volum;
run;
proc sort data=a;by code;
run;
proc means noprint data=a;
   var ret;by code;
   output out=code n=n;
run;
data a;
   merge a code;by code;
run;

%include "D:\The Application of SAS in Financial Research\CH13\program_cn\Panel.sas";
%panel(a,ret,pb turn,code,month,2);
proc export data=panel_data
   outfile="D:\The Application of SAS in Financial Research\CH13\EXCELoutput\Panel"
   dbms=xlsx
   replace;
   sheet="model1";
run;
%panel(a,ret,pb turn volum,code,month,3);
proc export data=panel_data
   outfile="D:\The Application of SAS in Financial Research\CH13\EXCELoutput\Panel"
   dbms=xlsx
   replace;
   sheet="model2";
run;
/*
%panel(file,y,x,firm,tim,bit);
file 请输入要进行分析的档案
y    输入被解释变项
x    输入解释变项"串"
firm 输入公司变项
time 输入时间变项
bit  输入系数的最大位数
*/
