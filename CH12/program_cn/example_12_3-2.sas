DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
libname bb "D:\The Application of SAS in Financial Research\SAS data\four factor";
data a;
   set aa.price(keep=code y m ret);
run;
data rm;
   set bb.factor;
      tt=_n_;
run;
proc sort data=rm;by decending tt;
data rm;
   set rm;
      t=_n_;
run;
proc sort data=rm;by y m;
run;
proc sort data=a;by y m;
run;
data a;
   merge a rm;by y m;
      rmrf=rm-rf;
      rirf=ret-rf;
      if t=. then delete;
      keep code y m t rirf rmrf smb hml mom;
run;
data b;
   set a;
      do i=1 to t;
         output;
      end;
run;
proc sort data=b;by code i;
run;
proc reg data=b outest=b adjrsq noprint;
   model rirf=rmrf;
   model rirf=rmrf smb hml;
   model rirf=rmrf smb hml mom;
   by code i;
quit;
data b;
   set b;
      t=i;
      if _p_+_edf_>=24 then output;
      keep code t _model_ intercept rmrf smb hml mom;
run;
proc sort data=b;by t;
run;
data t;
   set rm;
      keep y m t;
run;
proc sort data=t;by t;
run;
data final;
   merge b t;by t;
      if t<60 then delete;
run;
data final66;
   set final;
      if m=6 then output;
run;

