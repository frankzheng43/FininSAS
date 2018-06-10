libname aa "D:\The Application of SAS in Financial Research\CH03\data";
data a;
   set aa.random;
run;
proc surveyselect data=a 
method=srs
/*
 simple random sampling 
*/
n=10
/*
get the 10 sample
*/
rep=2
/*
repeate 2 times
*/
seed=1
/*
use the seed number
0 will produce different result every time
*/
out=b;
/*
output the result into table b
*/
run;
proc surveyselect data=a noprint
method=srs
n=10
rep=2
seed=1
out=b;
run;
proc surveyselect data=a noprint
method=srs
rate=0.01
/*select 1% sample from population*/
rep=2
seed=1
out=c;
run;

option nolabel;
data b;
set b;
if replicate=1 then output;
keep code ind;
run;
proc surveyselect data=b noprint
method=urs
n=15
rep=2
seed=1
out=c;
run;
proc surveyselect data=b noprint
method=urs
rate=1
rep=2
seed=1
out=d;
run;

