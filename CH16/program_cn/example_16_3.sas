DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data mv;
   set aa.price;
      if m=6 then output;
      keep y  code mv;
run;
proc sort data=mv;by y ;
run;
/* according to Fama and French (1993) 
    form size group in year t
    and classify bm portfolio in year t-1
*/
data pb;
   set aa.price;
      if m=12 then output;
      keep y  code pb;
run;
proc sort data=pb;by code y ;
run;
data pb;
   set pb;
      pb=lag(pb);
      if code^=lag(code) then delete;
run;
proc sort data=pb;by y;
run;
data bench;
   merge mv pb;by y ;
   if mv=. or pb=. then delete;
run;
proc rank data=bench out=bench groups=5;
   var mv;
   by y;
   ranks mvrank;
run;
proc sort data=bench;by y mvrank;
run;
/*according to DGTW(1997)
  we sort each size portfolion into five BM portfolio
*/
proc rank data=bench out=bench groups=5;
   var pb;
   by y mvrank;
   ranks mbrank;
run;
data bench;
   set bench;
      mvrank=mvrank+1;
      mbrank=mbrank+1;
      drop mv pb;
      do m=1 to 12;
         output;
      end;
run;
/* the rank in year t is use for   year t  July through year t+1 June */
data bench;
   set bench;
      if  m<=6 then  y=y+1;
run;
proc sort data=bench;by code y m;
run;
data ret;  
   set aa.price;
      ret=1+0.01*ret;
      keep code y m mv ret;
run;
proc sort data=ret;by code y m mv ret;
run;
data ret;
   set ret;
      mv=lag(mv);
      if code^=lag(code) then delete;
run;

data final;
   merge bench ret;by code y m;
      if mvrank=. or mbrank=. or ret=. then delete;
run;
proc sort data=final;by y m mvrank mbrank;
run;
proc means data=final noprint;
   var ret;
   weight mv;
   by y m mvrank mbrank;
   output out=benchret(drop=_type_ _freq_) mean=benchret;
run;
data benchret;
   set benchret;
      bench=mvrank||mbrank; 
      /*如果有超过2种分组组合，亦可采用相同的方式  如new=a||b||c; 就是结合3变项为1*/
run;
/*caculate buy and hold ret for bench portfolio and individual stock*/
%macro h(file,code,time,ret,p,h);
   proc sort data=&file(keep=&time) out=time nodupkey;by &time;
   run;
   data time;
      set time;
	     time=_n_;
   run;
   proc sort data=&file;by &time;
   run;
   data &file;
      merge &file time;by &time;
   run;
   proc sort data=&file;by &code descending time;
   /*
   revise 20150914
   因为时间需要降幂排序  如果有多个变项 无法使用多个descending
   */
   run;
   data &file;
      set &file;
         %do i=1 %to &h;
            r&i=lag&i(&ret);
            &p&i=(geomean(of r1-r&i)**n(of r1-r&i));
            if &code^=lag&i(&code) then &p&i=.;
         %end;
         drop r1-r&h time;
   run;
%mend;
%h(benchret, bench, y m, benchret, bhr,36);
%h(final,code,y m,ret,idiret,36);

/*match event and ret */
libname aa "D:\The Application of SAS in Financial Research\CH16\data";
data event;
   set aa.long;
      event=1;
run;
proc sort data=event;by code y m;
run;
proc sort data=final;by code y m;
run;
data event;
   merge event final;by code y m;
      if event=1 then output;
run;
proc sort data=event;by mvrank mbrank y m;
run;
proc sort data=benchret;by mvrank mbrank y m;
run;
data bhar;
   merge event benchret;by mvrank mbrank y m;
      if event=1 then output;
run;
%macro bhar(h);
   data bhartest;
      set bhar;
         %do i=1 %to &h;
            BHAR&i=(idiret&i-bhr&i)*100;
         %end;
         drop idiret1-idiret&h bhr1-bhr&h;
run;
%mend;
%bhar(36);
proc univariate data=bhartest ;
   var bhar12 bhar24 bhar36;
   ods output TestsForLocation=test 
              BasicMeasures =moment;
run;
data test;
   set test;
      if mod(_n_,3)=0 then delete;
      if pvalue<0.01 then sig="***";
      if 0.01<=pvalue<0.05 then sig="**";
      if 0.05<=pvalue<0.1 then sig="*";
      keep varname  sig;
run;
data moment;
   set moment;
      stat=round(LocValue,0.001);
      if 0<mod(_n_,4)<3 then output;
      keep varname locmeasure stat;
run;
data final;
   merge moment test;
run;

