libname aa "D:\The Application of SAS in Financial Research\CH16\data";
data a;
   set aa.long;
run;
/* calandar time portfolio*/
proc sort data=a;by y m;
run;
/*制作一拥有所有时间的档案*/
data t;
   do y=1993 to 2006;
      do m=1 to 12;
         output;
      end;
   end;
run;
data t;
   set t;
      t=_n_;
run;
data a;
   merge a t;by y m;
      if code=. then delete;
run;
proc sort data=a;by code;
run;
/*取得所有股价*/
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data ret;
   set aa.price;
      keep y m code mv ret;
run;
proc sort data=ret;by code y m;
run;
/*要计算等值加权与市值加权 所以先抓出前一个月的市值*/
data ret;
   set ret;
      mv=lag(mv);
      if code^=lag(code) then mv=.;
run;

proc sort data=ret;by y m;
run;
data ret;
   merge ret t;by y m;
      if t=. then delete;
run;

%macro ctp(t);
   proc sql;
      create table event&t
      as select
         b.y as y,
         b.m as m,
         b.code as code,
         b.mv as mv,
         b.ret as ret
      from a a, ret b
      where a.t<b.t<=a.t+&t
            and a.code=b.code;
   quit;
   proc sort data=event&t nodupkey;by  y m code;
   run;
   proc means noprint data=event&t;
      var ret;
      weight mv;
      by y m;
      output out=vw(drop=_type_ _freq_) mean=vwret;
   run;
   proc means noprint data=event&t;
      var ret;
      by y m;
      output out=ew(drop=_type_ _freq_) mean=ewret;
   run;
   data event&t;
      merge vw ew;by y m;
   run;
   libname aa "D:\The Application of SAS in Financial Research\SAS data\four factor";
   data event&t;
      merge event&t aa.factor;by y m;
         vw=vwret-rf;
         ew=ewret-rf;
         rmrf=rm-rf;
         if vw=. or ew=. then delete;
   run;
   %macro model(model);
      model ew=rmrf smb hml mom/white ;
      model ew=rmrf /white;
      model ew=rmrf smb hml/white;
      model ew=rmrf smb hml mom/white;
      model vw=rmrf /white;
      model vw=rmrf smb hml/white;
      model vw=rmrf smb hml mom/white;
   %mend;
   %include "D:\The Application of SAS in Financial Research\CH11\program\reg.sas";
   %reg(event&t,,3);
   proc export data=ols
      outfile="D:\The Application of SAS in Financial Research\CH16\output\CTP"
      dbms=xlsx
      replace;
      sheet="&T";
      quit;
%mend;
%ctp(12);
%ctp(36);
