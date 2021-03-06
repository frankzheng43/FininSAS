DM'LOG;CLEAR;OUT;CLEAR';
option notes nolabel;
libname aa 'D:\The Application of SAS in Financial Research\SAS data\monthly price';
data a;
   set aa.price;
      if nmiss(ret,pb,turn)^=0 then delete;
      month=y*100+m;
      if y=2006 and int(code/100)=11 then output;
      keep code month ret pb turn;
run;
proc sort data=a out=month(keep=month) nodupkey;by month;
run;
proc sort data=a;by code;
run;
proc means noprint data=a;
   var ret;
   output out=b(keep=code n) n=n;
   by code;
run;
data final;
   merge a b;by code;
      if n^=12 then delete;
run;
proc sort data=final out=code(keep=code) nodupkey;by code;
run;
%macro dummy(file,name,n);
   data &file;
      set &file;
         %do i=1 %to &n;
            if _n_=&i then &name&i=1;else &name&i=0;
         %end;
   run;
%mend;
%dummy(month,month,12);
%dummy(code,code,7);
data final;
   merge final code;by code;
run;
proc sort data=final;by month;
run;
data final;
   merge final month;by month;
run;
proc reg data=final;
   model ret=turn pb;
   model ret=turn pb code1-code7;
   model ret=turn pb month1-month12;
   model ret=turn pb code1-code7 month1-month12;
quit;

/*proc panel */
proc sort data=a;by code ;
run;
proc panel data=a;
   model ret=turn pb/fixone;
   id code month;
run;

proc panel data=a;
   model ret=turn pb/fixtwo;
   id code month;
run;

/* SAS 9.2 release the proc panel
    SAS 9.1 can use the  proc tscsreg to perform Pandel data*/
proc tscsreg data=a;
   model ret=turn pb/fixone;
   id code month;
run;
proc tscsreg data=a;
   model ret=turn pb/fixtwo;
   id code month;
run;

proc panel data=a ;
   model ret=turn pb/ranone;
   id code month;
run;
proc panel data=a ;
   model ret=turn pb/rantwo;
   id code month;
run;
