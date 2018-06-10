DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
libname bb "D:\The Application of SAS in Financial Research\SAS data\four factor";

data a;
   set aa.price;
      keep code y m ret ;
run;
data rm;
   set bb.factor;
      t=_n_;
run;
proc sort data=a;by y m;
run;
data a;
   merge a rm;by y m;
      rmrf=rm-rf;
      rirf=ret-rf;
      keep code y m t rirf rmrf smb hml mom;
run;

%macro moving_window;
   proc datasets noprint;
      delete final;
   run;
   %do i=60 %to 306;
      data b;
         set a;
            if   &i-59<=t<=&i then output;
      run;
      proc sort data=b;by code;
      run;
      proc reg data=b outest=b adjrsq noprint;
         model rirf=rmrf;
         model rirf=rmrf smb hml;
         model rirf=rmrf smb hml mom;
         by code ;
      quit;
      data b;
         set b;
            t=&i;
            if _p_+_edf_>=24 then output;/*要求至少存在24个月*/
            keep code t _model_ intercept rmrf smb hml mom;
      run;
      proc append base=final data=b;
      quit;
   %end;
   data t;
      set rm; 
         keep y m t;
   run;
   data final;
      merge final t;by t;
         if t<60 then delete;
   run;
%mend moving_window;
%moving_window;

proc sort data=a out=code (keep=code t);by code descending t;
run;
data code;
   set code; by code;
      endt=t;
      if first.code then output;
      drop t;
run;
proc sort data=final;by code;
run;
data final;
   merge final code;by code;
      if t=. then delete;
      if t<=endt then output;
      drop t endt;
run;
data final66;
   set final;
      if m=6 then output;
run;
