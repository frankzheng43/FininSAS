libname aa "D:\The Application of SAS in Financial Research\CH08\data";
data a;
   set aa.sort;
run;
option nolabel;
proc means data=a;
   var ret turn mv;
run;
proc univariate data=a;
   var ret turn mv;
run;
proc means data=a n mean t probt max p99 p95 p90  q3 median  q1 p10 p5 p1 min  std stderr skewness kurtosis ;
   var ret turn mv;
run;

proc means data=a noprint;
   var ret turn mv;
   output out=b;
run;
proc transpose data=b out=c;
   var ret turn mv;
   id _stat_;
run;

proc univariate data=a noprint; /*proc means also can work*/
   var ret turn mv;
   output out=n n= ret turn mv;;
   output out=mean mean= ret turn mv;
   output out=t t= ret turn mv;
   output out=probt probt= ret turn mv;
   output out=max max= ret turn mv;
   output out=p99 p99= ret turn mv;
   output out=p95 p95= ret turn mv;
   output out=p90 p90= ret turn mv;
   output out=q3  q3= ret turn mv;
   output out=median median= ret turn mv;
   output out=q1 q1= ret turn mv;
   output out=p10 p10= ret turn mv;
   output out=p5 p5= ret turn mv;
   output out=p1 p1= ret turn mv;
   output out=min min= ret turn mv;
   output out=var var=ret turn mv;
   output out=std std= ret turn mv;
   output out=stderr stderr= ret turn mv;
   output out=skew skewness= ret turn mv;
   output out=kurt kurtosis= ret turn mv;
run;

data final;
   set n mean max p99 p95 p90 p10 p5 p1 min var std;
run;

data n;
   set n;
      name="n";
run;
data mean;
   set mean;
      name="mean";
run;

data final1;
   set n mean ;
run;

proc sort data=a;by y m;
run;
proc univariate data=a noprint;  /*proc means also can work*/
   var ret turn mv;
   output out=n n= ret turn mv;;
   output out=mean mean= ret turn mv;
   by y m;
run;
data n;
   set n;
      name="n";
run;
data mean;
   set mean;
      name="mean";
run;
data final1;
   set n mean ;
run;
proc export data=final1
   outfile="D:\The Application of SAS in Financial Research\CH08\output\stat"
   dbms=xlsx
   replace;
   sheet="stat";
run;
proc univariate data=a ;  /*proc means also can work*/
   var ret ;
   weight mv;
   by y m;
run;
proc means data=a;
   var ret;
   weight mv;
   by y m;
   output out=b;
run;
