libname aa "D:\The Application of SAS in Financial Research\CH04\data";
data a;
   set aa.random;
run;
proc surveyselect data=a out=b noprint
   method=srs
   seed=1
   rep=5
   n=5;
run;
proc transpose data=b out=c;
   var code;
   by replicate;
run;

data a;
   set aa.transpose;
run;
proc transpose data=a out=c;
   by code;
run;
proc transpose data=a out=c;
   var variable data;
   by code;
run;
proc transpose data=a out=c;
   id variable;
   by code;
run;
proc transpose data=a out=c(drop=_name_ _label_);
   id variable;
   by code;
run;
