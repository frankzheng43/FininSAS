DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\event date";

data a1;
   set aa.div_event;
   /*现金股利样本*/
      event=1;
      y=y-1;
      drop m d;
run;
data a2;
   set aa.repurchase_event;
   /*股票回购样本*/
      event=2;
      y=y-1;
      drop m d;
run;
data a3;
   set aa.event;
   /*减资样本*/
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
      keep event d1-d3;
run;
/*multinomial logistic regression*/
proc logistic data=a ;
   model event(ref="1")=d1-d3/ maxiter=100 link=glogit;
quit;
data a1;
   set a;
      if event=3 then delete;
run;
proc logistic data=a1 desc;
   model event=d1-d3/ maxiter=100;
quit;

%macro multi_logit;
   %do i=1 %to 3;
   /*根据自己的研究 可变更 3的数字*/
      proc logistic data=a desc ;
         model event(ref="&i")=d1-d3 /maxiter=100  link=glogit;
               /*根据自己的研究变更Y 以及后面的解释变量*/
         ods output ParameterEstimates=esti  ; 
      quit;
      data esti;
         set esti;
            retain t 0;
               if variable^=lag(variable) then t=t+1;
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
            keep response model t type variable;
      run;
      data a2;
         set esti;
            model=tv;
            type=2;
            keep  response model t type ;
      run;
      data final;
         set a1 a2 ;
      run;
      proc sort data=final out=final;by  t type variable;
      run;
      proc transpose data=final out=ref&i (drop=t type _name_);
         var model;
         id response;
      by t type variable;
      quit;
   %end;
%mend;
%multi_logit;



