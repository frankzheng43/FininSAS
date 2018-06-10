DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
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
data a;
   merge a b;by code y;
      if event=. then event=0;
      d1=liqidasset/liqiddebt;
      d2=longinvestment/totalasset;
      d3=longdebt/totalasset;
      if d3>1 or d1=. or d2=. or d3=. then delete;
      keep event d1-d3 y;
run;

proc logistic data=a ;
   model event=d1-d3/ maxiter=100;
quit;
proc logistic data=a desc ;
   model event=d1-d3 /maxiter=100;
   model event=d1-d2 /maxiter=100;
quit;
proc logistic data=a desc ;
   model event=d1-d3 /maxiter=100 rsquare;
   ods output ParameterEstimates=esti  rsquare=rsq nobs=n; 
quit;
%macro logit(outfile);
data esti;
   set esti;
      retain t 0;
         t=t+1;
      if probchisq<0.01 then sig=round(estimate,0.01)||"***";
      else if 0.01<probchisq=<0.05 then sig=round(estimate,0.01)||"**";
      else if 0.05<probchisq=<0.1 then sig=round(estimate,0.01)||"*";
      else sig=round(estimate,0.01)||"";
      tv="(" || left (  round(estimate/stderr,0.01)||")");
      tv2=(estimate/stderr)**2;
run;
data a1;
   set esti;
      model=left(sig);
      type=1;
      keep model t type variable;
run;
data a2;
   set esti;
      model=tv;
      type=2;
keep model t type ;
run;
data rsq;
   set rsq;
      model=left(round(nvalue1*100,0.01)||"%");
      t=100;
      type=1;
      variable="R2";
      keep model t type variable;
run;
data n;
   set n;
      model=left(NObsUsed||"");
      t=1000;
      type=1;
      variable="N";
      if _n_=2 then output;
      keep model t type variable;
run;
data final;
   set a1 a2 rsq n;
run;
proc sort data=final out=&outfile(keep=model variable);by t type;
run;
%mend;

%inc "D:\The Application of SAS in Financial Research\CH14\program_cn\logit.sas";

%macro model;
event=d1 d2 d3
%mend;
%logit(a,y,4,logit1);
%macro model;
event=d1 
%mend;
%logit(a,y,4,logit2);
%macro model;
event=d2 
%mend;
%logit(a,y,4,logit3);
%macro model;
event=d3
%mend;
%logit(a,y,4,logit4);
%macro model;
event=d1 d2
%mend;
%logit(a,y,4,logit5);
%macro model;
event=d1 d3
%mend;
%logit(a,y,4,logit6);

%macro model;
event=d1 d2 d3
%mend;
%logit(a,y,4,logit7);
%logit_file(y,7,logit_result);

