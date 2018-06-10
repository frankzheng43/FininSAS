DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\event date";

data a;
   set aa.event;
      event=1;
      /*set the variable to compare the firm without the event*/
      y=y-1;
      /*we use the accounting data in year t-1 to predicted reduce capital in year t*/
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
/*conditional logistic regression*/
proc sort data=a;by id;
run;
proc logistic data=a desc;
   model event=d1-d3/ maxiter=100;
   strata id;
quit;


proc logistic data=a desc ;
   model event=d1-d3 /maxiter=100 rsquare;
   strata id;
   ods output ParameterEstimates=esti  rsquare=rsq nobs=n; 
quit;

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
proc sort data=final out=final(keep=model variable);by t type;
run;
