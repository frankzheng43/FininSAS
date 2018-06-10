libname aa "D:\The Application of SAS in Financial Research\CH03\data";
data a;
   set aa.random;
run;
proc surveyselect data=a 
method=srs
/*
方法为 simple random sampling 间单随机抽样
*/
n=10
/*
抽出10个样本
*/
rep=2
/*
重复进行两次
*/
seed=1
/*
种子设为1 必为整数
设为0则每次都不固定
*/
out=b;
/*
将抽样结果输出产生为b这个table
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
/*要求抽出总样本的0.01也就是1%的样本*/
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


