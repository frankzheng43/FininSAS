DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\event date";

data a1;
   set aa.div_event;
   /*cash dividend*/
      event=1;
      y=y-1;
      drop m d;
run;
data a2;
   set aa.repurchase_event;
   /*repurchase*/
      event=2;
      y=y-1;
      drop m d;
run;
data a3;
   set aa.event;
   /*¼õ×ÊÑù±¾*/
      event=3;
      y=y-1;
      drop m d;
run;
data a;
   set a1 a2 a3;
run;
proc sort data=a nodup;by code y;
run;
libname aa "D:\The Application of SAS in Financial Research\SAS data\financial";
data b;
   set aa.financial;
      if y<1990 then delete;
run;
proc sort data=b;by code y;
run;
data a;
   merge a b;by code y;
      d1=liqidasset/liqiddebt;
      d2=longinvestment/totalasset;
      d3=longdebt/totalasset;
      if d3>1 or d1=. or d2=. or d3=. or event=. then delete;
      keep event y d1-d3;
run;

%inc "D:\The Application of SAS in Financial Research\CH14\program\probit.sas";
%let y=event;
%macro model;
d1 d2 d3
%mend;
%probit(a,,4,probit1);
%macro model;
d1 
%mend;
%probit(a,,4,probit2);
%macro model;
d2 
%mend;
%probit(a,,4,probit3);
%macro model;
d1 d2 
%mend;
%probit(a,,4,probit4);
%macro model;
d1 d3
%mend;
%probit(a,,4,probit5);
%macro model;
d2 d3
%mend;
%probit(a,,4,probit6);
%macro model;
d1 d2 d3
%mend;
%probit(a,,4,probit7);
%probit_file(,7,probit_result);
