%macro probit(file,group,bit,outfile);
data Ian_reg;
   set &file;
   ian=1;
run;
proc sort data=ian_reg;by ian &group descending &y;
run;
proc probit data=ian_reg order=data;
   model &y=%model /d=logistic maxiter=100 ;
   by ian &group;
   ods output ParameterEstimates=esti  nobs=n; 
quit;
data esti;
   set esti;
      retain t 0;
         t=t+1;
      if probchisq<0.01 then sig=round(estimate,10**-&bit)||"***";
      else if 0.01<probchisq=<0.05 then sig=round(estimate,10**-&bit)||"**";
      else if 0.05<probchisq=<0.1 then sig=round(estimate,10**-&bit)||"*";
      else sig=round(estimate,10**-&bit)||"";
      tv="(" || left (  round(estimate/stderr,0.01)||")");
      tv2=(estimate/stderr)**2;
run;
data a1;
   set esti;
      model=left(sig);
      type=1;
      keep model t type Parameter &group;
run;
data a2;
   set esti;
      model=tv;
      type=2;
keep model t type parameter &group;
run;

data n;
   set n;
      model=left(NObsUsed||"");
      t=1000;
      type=1;
      Parameter="N";
      if _n_=2 then output;
      keep model t type Parameter &group;
run;
data final;
   set a1 a2 n;
run;
proc sort data=final out=&outfile(keep=&group t model Parameter type);by t type;
run;
%mend;
%macro probit_file(group,n,file);
   %do i=1 %to &n;
      data probit&i;
	     set probit&i;
		    model&i=model;
			%if &i^=1 %then %do;
			   drop t;
			%end;
	  run;
      proc sort data=probit&i;by &group parameter type;
	  run;
	  %if &i=1 %then %do;
	     data ian;
		    set probit&i;
		 run;
		 proc sort data=ian;by &group parameter type;
		 run;
	 %end;
	 %else %do;
	    data ian;
		   merge ian probit&i;by &group parameter type;
		run;
	 %end;
     proc delete data=probit&i;
	 quit;
    %end;
	 data ian;
	    set ian;
	       if type=2 then parameter='';
	       drop model model1;
	 run;
   proc sort data=ian out=&file(drop=t type);by &group t type;
   run;
   proc delete data=ian;
   quit;
%mend;
