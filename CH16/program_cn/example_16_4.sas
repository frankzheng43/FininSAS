option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data mv;
   set aa.price;
      if m=6 then output;
      keep y  code mv;
run;
proc sort data=mv;by y ;
run;
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
data bench;
   set bench;
      do m=1 to 12;
         output;
      end;
run;
data bench;
   set bench;
      if  m<=6 then  y=y+1;
run;
proc sort data=bench;by code y m;
run;
data ret;
   set aa.price;
      keep code y m mv ret;
run;
proc sort data=ret;by code y m;
run;
data ret;
   set ret;by code;
      weight=lag(mv);
      if first.code then delete;
      drop mv;
run;
data bench;
   merge bench ret;by code y m;
run;
proc sort data=bench;by y m;
run;
proc sort data=ret nodupkey out=time(keep=y m);by y m;
run;
data time;
   set time;
      t=_n_;
run;
data bench;
   merge bench time;by y m;
run;
proc sort data=bench;by code y m;
run;
libname aa "D:\The Application of SAS in Financial Research\CH16\data";
data event;
   set aa.long;
      event=1;
   run;
proc sort data=event nodupkey out=code (keep=code event);by code;
run;
data control;
   merge code bench;by code ;
      if event=1 then delete;
      if mv=. or pb=. then delete;
      drop event;
run;


data event;
   merge event bench;by code y m;
      if mv=. or pb=. then delete;
      if event=1 then output;
      drop event;
run;

data event;
   set event;
      event=_n_;
run;
%let percent=0.3;
proc sql;
   create table final
   as select
      a.code as event_code,
      a.event as event,
      b.code as control_code,
      a.t as t
   from event a,control b
   where 
      a.t=b.t and 
      a.mv*(1-&percent)<=b.mv<=a.mv*(1+&percent) and
      a.pb*(1-&percent)<=b.pb<=a.pb*(1+&percent);
quit;
proc sort data=final;by event;
run;
proc sort data=final out=final1(keep=event_code event t) nodupkey;by event;
run;
proc surveyselect data=final 
   out=final2(keep=control_code event t replicate) noprint
   seed=1
   n=1
   rep=1000
   method=srs;
   strata event;
run;
%macro Bhar(t);
   proc sql;
      create table event_ret
      as select
         a.event as event,
         b.ret/100+1 as ret,
         b.weight as mv,
         b.t-a.t as t
         from final1 a,bench b
      where 
         a.t+1<=b.t<=a.t+&t and 
         a.event_code=b.code;
   quit;
   proc sort data=event_ret;by t;
   proc sql;
      create table control_ret
      as select
         a.event as event,
         a.replicate as replicate,
         b.ret/100+1 as ret,
         b.weight as mv,
         b.t-a.t as t
      from final2 a,bench b
      where 
         a.t+1<=b.t<=a.t+&t and 
         a.control_code=b.code;
   quit;
   proc sort data=control_ret;by  replicate t;
   run;
%mend;
%Bhar(36);
proc means data=event_ret noprint;
   var ret;
   by t;
   weight mv;
   output out=event(keep=ret t) mean=ret;
run;
proc transpose data=event out=event;
   var ret;
run;
proc means data=control_ret noprint;
   var ret;
   weight mv;
   by replicate t;
   output out=control(keep=replicate t ret) mean=ret;
run;
proc transpose data=control out=control;
   var ret;
   by replicate;
run;
%macro hold_return(file,h);
   data &file;
      set &file;
         %do i=1 %to &h;
            hold&i=(geomean(of col1-col&i)**n(of col1-col&i)-1)*100;
         %end; 
         keep hold1-hold&h;
   run;
%mend;
%hold_return(event,36);
%hold_return(control,36);
proc transpose data=control out=a(drop=_name_);
   var hold1-hold36;
run;
data a;
   set a;
      t=_n_;
run;
proc transpose data=a out=a;
   var col1-col1000;
   by t;
run;
proc univariate data=a noprint;
   var col1;
   by t;
   output out=Pctls pctlpts  = 0.5 2.5 5 95 97.5 99.5
                           pctlpre  = p;
   output out=ref mean=reference;
run;
proc transpose data=event out=b;
run;

data final;
   merge b ref;
      event_return=round(col1,0.001);
      ref_return=round(reference,0.001);
      dif_return=event_return-ref_return;
      keep _name_  event_return ref_return dif_return;
run;
data final;
   merge final pctls;
      drop t;
      if event_return<P0_5 then do;
         sign="-";sig="***";
      end;
      else if event_return<P2_5 then do;
         sign="-";sig="**";
      end;
      else if event_return<P5 then do;
         sign="-";sig="*";
      end;
      else if event_return>P99_5 then do;
         sign="+";sig="***";
      end;
      else if event_return>P97_5 then do;
         sign="+";sig="**";
      end;
      else if event_return>P95 then do;
         sign="+";sig="*";
      end;
      else do;
         sign="";sig="";
      end;
      keep _name_ event_return ref_return  dif_return sign sig;
run;
