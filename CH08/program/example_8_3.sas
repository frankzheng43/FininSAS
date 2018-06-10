libname aa "D:\The Application of SAS in Financial Research\CH08\data";
data a;
   set aa.sort;
run;



%include "D:\The Application of SAS in Financial Research\CH08\program\corr.sas";

%correlation(a,4,ret mv turn);

/*
a the file you want to test
4  how many digits after decimal point
ret mv turn: the variable list

the file will output pearson and spearman
*/

%inc 'D:\The Application of SAS in Financial Research\CH08\program\stat.sas';
%stat(a,4,ret mv turn);
/*
a the file you want to test
4  how many digits after decimal point
ret mv turn: the variable list
the file will output final and final1"*/
