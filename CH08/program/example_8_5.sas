libname aa 'D:\The Application of SAS in Financial Research\SAS data\monthly price';

data a;
   set aa.price;
run;

proc univariate data=a noprint;
   var mv;
   output out=winsor pctlpts=1 99 pctlpre=limit_
          pctlname=low high;
		  /*pctlpts produce the percentile 1 99
            pctlpre produce the prename  limit_
		    pctlname produce the name afterprname
            combine the pctlpre pctlname the result   limit_low limit_high
		  */
run;
data a_delete;
   set a;
      if _n_=1 then set winsor;
/* when observation is on the read the winsor
  then the sas will read all the winsor with all the observation repeatedly
*/
      if   limit_low<mv<limit_high then output;
      drop limit_high limit_low;
run;
data a_replace;
   set a;
      if _n_=1 then set winsor;
      if mv<limit_low then mv=limit_low;
      if mv>limit_high then mv=limit_high;
      drop limit_high limit_low;
run;
/*
we complete the delete and replace coding
*/

/**/


%macro winsorize(file,var,low,high);
   proc univariate data=&file noprint;
      var &var;
      output out=winsor pctlpts=&low &high pctlpre=limit_
             pctlname=low high;
   run;
   data &file._delete;
/*
notice it's   &file._
not           &file_
*/
      set &file;
         if _n_=1 then set winsor;
         if   limit_low<&var<limit_high then delete;
         drop limit_high limit_low;
   run;
   data &file._replace;
      set &file;
         if _n_=1 then set winsor;
         if &var<limit_low then &var=limit_low;
         if &var>limit_high then &var=limit_high;
         drop limit_high limit_low;
   run;
   proc datasets noprint;
      delete winsor;
   quit;
/*
we delete the file winsor
*/
%mend;
%winsorize(a,mv,2.5,97.5);
%winsorize(a,ret,0.5,99.5);
/* the best way fot lower and higher is symmetry*/

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
            if   limit_low<&var<limit_high then delete;
            drop limit_high limit_low;
      run;
   %end;
   %else %do;
      data &file;
         merge &file winsor;by &time;
            if &var<limit_low then &var=limit_low;
            if &var>limit_high then &var=limit_high;
            drop limit_high limit_low;
      run;
   %end;
   /*revise 20150728*/
   proc datasets noprint;
      delete winsor;
   quit;
%mend;
%winsorize_time(a,0,mv,y m, 2.5,97.5);
%winsorize_time(a,0,ret,y m,0.5,99.5);

%inc "D:\The Application of SAS in Financial Research\CH08\program\winsorize.sas";
%winsorize(a,0,ret, 2.5,97.5);
%winsorize_time(a,0,turn,y m, 2.5,97.5);

