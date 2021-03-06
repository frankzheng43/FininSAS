option nolabel;
data a;
   do t=1 to 100;
      a=rannor(1);
      retain y ;
      y=0.8*y1+0.2*y2+a;
      if t=1 then do;
         y=a;
         y1=0;
      end;
      if t<=2 then do;
         y2=0;
      end;
      output;
      y1=y;
      y2=y1;
   end;
run;
proc sort data=a;by t;
run;
proc transpose data=a out=b;
   var y y1 y2;
   by t;
run;
proc sort data=b;by _name_ t;
run;
%let lag=2;
PROC MODEL data=b;
   PARMS a;
   col1 = a;
   FIT col1 /GMM KERNEL=(BART,%eval(&lag+1),0);
   INSTRUMENTS a;
   by _name_;
   ods output parameterestimates=param1;
quit;
proc means data=b mean stderr t probt;
   var col1;
   class _name_;
run;
data b;
   set param1;
      if probt<0.01 then e=round(estimate,0.001)||"***";
      else if probt<0.05 then e=round(estimate,0.001)||"**";
      else if probt<0.1 then e=round(estimate,0.001)||"*";
      else e=round(estimate,0.001)||"";
      tv="("||left(round(tvalue,0.01)||")");
run;
proc transpose data=b out=b;
   var e tv;
   id _name_;
run;
data b;
   set b;
      lag=&lag;
run;
data a;
   do t=1 to 200;
      a=rannor(1);
      retain y ;
      y=0.8*y1+0.2*y2+a;
      if t=1 then do;
         y=a;
         y1=0;
      end;
      if t<=2 then do;
         y2=0;
      end;
      output;
      y1=y;
      y2=y1;
   end;
run;
data a;
   set a;
      yy=int(t/10);
      m=mod(t,10);
run;
%include "D:\The Application of SAS in Financial Research\CH10\program\neweywest.sas";
%neweywest(a,b1,y y1 y2,yy m,2);
%neweywest(a,b2,y y1 y2,t,2);
