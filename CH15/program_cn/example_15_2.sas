data a;
      input Hours Yrs_Ed Yrs_Exp @@;
      if Hours eq 0
         then Lower=.;
         else Lower=Hours;
   datalines;
   0 8 9 0 8 12 0 9 10 0 10 15 0 11 4 0 11 6
   1000 12 1 1960 12 29 0 13 3 2100 13 36
   3686 14 11 1920 14 38 0 15 14 1728 16 3
   1568 16 19 1316 17 7 0 17 15
   ;
   run;
%include "D:\The Application of SAS in Financial Research\CH15\program_cn\tobit.sas";
%tobit(lower,hours,Yrs_Ed Yrs_Exp,3);
proc export data=tobit
   outfile="D:\The Application of SAS in Financial Research\CH15\EXCELoutput\tobit"
   dbms=xlsx
   replace;
   sheet="model1";
quit;
data a;
   do i=1 to 15;
      x1=rannor(1);
      x2=rannor(2);
      y=2+3*x1+2*x2+rannor(3);
      output;
   end;
run;
data a;
   set a;
      if y<=1 then y=1;
      if y>=7 then y=7;
      if y=1 then lower=.;
      else lower=y;
      if y=7 then higher=.;
      else higher=y;
run;
%tobit(lower,y,x1 x2,3);
proc export data=tobit
   outfile="D:\The Application of SAS in Financial Research\CH15\EXCELoutput\tobit"
   dbms=xlsx
   replace;
   sheet="model2";
quit;
%tobit(y,higher,x1 x2,3);
proc export data=tobit
   outfile="D:\The Application of SAS in Financial Research\CH15\EXCELoutput\tobit"
   dbms=xlsx
   replace;
   sheet="model3";
quit;
%tobit(lower,higher,x1 x2,3);
proc export data=tobit
   outfile="D:\The Application of SAS in Financial Research\CH15\EXCELoutput\tobit"
   dbms=xlsx
   replace;
   sheet="model4";
quit;
