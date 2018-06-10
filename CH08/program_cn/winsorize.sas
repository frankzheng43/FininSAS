%macro winsorize_time(file,delete,var,time,low,high);
   proc sort data=&file;by &time;
   run;
   proc univariate data=&file noprint;
      var &var;
      by &time;
      output out=winsor pctlpts=&low &high pctlpre=limit_
             pctlname=low high;
   run;
   /*revise 20150728*/
   %if &delete=1 %then %do;
      data &file;
         merge &file winsor;by &time;
		    if &var^=. then do;
               if   limit_low<&var<limit_high then delete;
			end;
            drop limit_high limit_low;
      run;
   %end;
   %else %do;
      data &file;
         merge &file winsor;by &time;
		    if &var^=. then do;
               if &var<limit_low then &var=limit_low;
               if &var>limit_high then &var=limit_high;
			end;
            drop limit_high limit_low;
      run;
   %end;
   /*revise 20150728*/
   proc datasets noprint;
      delete winsor;
   quit;
%mend;
%macro winsorize(file,delete,var,low,high);

   proc univariate data=&file noprint;
      var &var;
      output out=winsor pctlpts=&low &high pctlpre=limit_
             pctlname=low high;
   run;
   /*revise 20150728*/
   %if &delete=1 %then %do;
      data &file;
         set &file;
            if _n_=1 then set winsor;
			if &var^=. then do;
               if   limit_low<&var<limit_high then delete;
			end;
            drop limit_high limit_low;
      run;
   %end;
   %else %do;
      data &file;
         set &file;
            if _n_=1 then set winsor;
			if &var ^=. then do;
               if &var<limit_low then &var=limit_low;
               if &var>limit_high then &var=limit_high;
            end;
            drop limit_high limit_low;
      run;
   %end;
   /*revise 20150728*/
   proc datasets noprint;
      delete winsor;
   quit;
%mend;
