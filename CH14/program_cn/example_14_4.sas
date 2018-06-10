DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\event date";

data a;
   set aa.event
      event=1;
      /*要与未发生事件的样本区分*/
      y=y-1;
      /*因为要以前一年的数据预测未来是否会减资，所以在处理上先减1*/
run;
proc sort data=a nodupkey;by code y;
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
      if event=. then event=0;
      d1=liqidasset/liqiddebt;
      d2=longinvestment/totalasset;
      d3=longdebt/totalasset;
      if d3>1 or d1=. or d2=. or d3=. then delete;
      keep event d1-d3;
run;
proc logistic data=a noprint;
   model event=d1-d3/ maxiter=100;
   output out=b predprobs=(i);
quit;
data b;
   set b;
      if _from_=_into_ then hit=1;else hit=0;
run;
proc means mean;
   var hit;
run;
proc means mean;
   var hit;
   class _from_;
run;

libname aa "D:\The Application of SAS in Financial Research\SAS data\event date";

data a;
   set aa.event;
      event=1;
      /*要与未发生事件的样本区分*/
      y=y-1;
      /*因为要以前一年的数据预测未来是否会减资，所以在处理上先减1*/
run;
proc sort data=a nodupkey;by code y;
run;

libname aa "D:\The Application of SAS in Financial Research\SAS data\financial";
data b;
   set aa.financial;
      if y<1990 then delete;
run;
proc sort data=b;by code y;
run;
data a1 a2;
   merge a b;by code y;
      if event=. then event=0;
      d1=liqidasset/liqiddebt;
      d2=longinvestment/totalasset;
      d3=longdebt/totalasset;
      if d3>1 or d1=. or d2=. or d3=. then delete;
      keep event d1-d3;
      if event=1 then output a1 ;else output a2;
run;

proc surveyselect data=a2 out=a2 noprint
   method=srs
   seed=1
   n=225;
run;
data a1;
   set a1;
      retain id 0;
         id=id+1;
run;
data a2;
   set a2;
      retain id 0;
         id=id+1;
run;
data a;
   set a1 a2;
run;
proc logistic data=a noprint;
   model event=d1-d3/ maxiter=100;
   output out=b predprobs=(i);
quit;
data b;
   set b;
      if _from_=_into_ then hit=1;else hit=0;
run;
proc means mean;
   var hit;
run;
proc means mean;
   var hit;
   class _from_;
run;

proc logistic data=a  desc noprint;
   model event=d1-d3/ maxiter=100;
   output out=b xbeta=xbeta pred=p;
quit; 
data b;
   set b;
      prob=exp(xbeta)/(1+exp(xbeta));
run;

