libname aa "D:\The Application of SAS in Financial Research\CH08\data";
data a;
   set aa.sort;
run;
%include "D:\The Application of SAS in Financial Research\CH08\program_cn\corr.sas";
%correlation(a,4,ret mv turn);
/*
a 为要检定相关系数表的档案
4 为小数点位数
ret mv turn 为要检定的变量
会产生 pearson 以及spearman两个档案
*/
%inc 'D:\The Application of SAS in Financial Research\CH08\program_cn\stat.sas';
%stat(a,4,ret mv turn);
/*
a 可改为要检定的档案
4 为小数点位数
ret mv turn 为要计算叙述统计量的变量
会产生 final final1两个档案*/

