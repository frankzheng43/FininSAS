libname aa "D:\The Application of SAS in Financial Research\CH03\data";
data a;
   set aa.random;
run;
proc surveyselect data=a 
method=srs
/*
����Ϊ simple random sampling �䵥�������
*/
n=10
/*
���10������
*/
rep=2
/*
�ظ���������
*/
seed=1
/*
������Ϊ1 ��Ϊ����
��Ϊ0��ÿ�ζ����̶�
*/
out=b;
/*
����������������Ϊb���table
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
/*Ҫ������������0.01Ҳ����1%������*/
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


