DM'LOG;CLEAR;OUT;CLEAR';
option nonotes nolabel;
libname aa 'D:\The Application of SAS in Financial Research\SAS data\monthly price';
data a;
   set aa.price;
   keep code y m ret turn;
run;
proc reg data=a;
   model ret=turn;
quit;
proc sort data=a;by code y m;
run;
data b;
   set a;by code;
      turn1=lag(turn);
      if first.code then turn1=.;
      if first.code then delete;
run;
proc reg data=b;
   model ret=turn;
   model ret= turn1 turn;
quit;
data b;
   set a;by code;
      ret1=lag(ret);
      if first.code then delete;
run;
proc reg data=b noprint;
   model turn= ret1;
   output out=b p=pre r=res;
  /*ȡ�ûع�ģ�͵�Ԥ��ֵ�Լ��в�ֵ �ֱ�����Ϊ pre res*/
quit;
data b;
   set b;
      res1=lag(res);
      if first.code then delete;
run;
proc reg data=b;
   model ret= res1 res;
   output out=b r=ress;
quit;

proc reg data=b;
   model ret= res1 res/noint;
/*Ҫ��SAS����û�нؾ���Ļع�ģ��*/
quit;
proc sort data=b;by m;
run;
proc reg data=b noprint outest=c;
   model ret= res1 res;
   by m;
quit;

proc reg data=b noprint outest=c tableout adjrsq;
   model ret=res1 res;
quit;
proc reg data=b;
   model ret=res1 res;
      test res1+res=1;
      test res1=1;
      test res1=-res;
      test res1=-0.23;
quit;

data a;
   do i=1 to 100;
      x1=rannor(1);
      x2=rannor(2);
      x3=rannor(2);
      y1=3+2*x1+x2+3*x3+rannor(4);
      y2=3+2*x1+x2+3*x3+rannor(5);
      y3=2*x1+x2+3*x3+rannor(4);
      output;
   end;
run;
proc reg data=a;
   model y1 y2 y3=x1 x2 x3;
      mtest x1,x2; /*ע���Ƕ���*/
      mtest x1=2,x2=1,x3=3;
      mtest y1-y2, y2 -y3, x1;
      mtest y1-y2, y2 -y3, x1,x2;
      mtest y1-y2;
      mtest intercept;
quit;
