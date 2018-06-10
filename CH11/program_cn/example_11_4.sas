DM'LOG;CLEAR;OUT;CLEAR';
option nonotes nolabel;
libname aa 'D:\The Application of SAS in Financial Research\SAS data\four factor';
libname bb 'D:\The Application of SAS in Financial Research\SAS data\monthly price';
data a;
   set bb.price;
      mv=log(mv);
      mv2=mv**2;
      turn2=turn**2;
      mv_turn=mv*turn;
run;
proc sort data=a;by y m;
run;
proc reg noprint adjrsq data=a outest=b ;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   model ret=mv ;
   model ret=turn;
   model ret=mv turn;
   model ret=mv turn mv2;
   model ret=mv turn turn2;
   model ret=mv turn mv_turn;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   by y m;
quit;

%include "D:\The Application of SAS in Financial Research\CH11\program_cn\FMneweywest.sas";
%fmneweywest(b,a, intercept mv turn mv2 turn2 mv_turn, y m,4,2);
%fmneweywest(in,out, x, time,bit,lag);
/*
in 指的是要进行  neweywest的档案
out指的是要输出的档案名称
x 指的是所有的变项名称 包含截距项
time 指的是时间变项
bit 指的是四舍五入到小数点后几位
lag 指的是要考虑多少及的滞后项 若为0 就是一般的white调整

*/


