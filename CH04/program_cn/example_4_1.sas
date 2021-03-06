libname aa "D:\The Application of SAS in Financial Research\CH04\data";
data a;
   set aa.sort;
run;
proc sort data=a;by  mv;
run;
proc sort data=a out=b;by y m descending mv;
run;
proc sort data=a out=b;by y descending m descending mv;
run;
data a;
   set a ;
      do i=1 to 2;
         output;
      end;
      drop i;
run;
proc sort data=a noduprecs;by y;
/*只是要删数据的话，可以by 任意变量*/
run;
proc sort data=a nodupkey; by y m;
/*要求SAS删除掉by 之后重复的笔数*/
run;
proc sort data=a nodupkey out=a1; by y ;
run;



data b;
   set b;
      if _n_<=20 then output;
run;

option label;
proc rank data=b out=b groups=5;
   var mv;
   ranks mvrank;
run;
option nolabel;

proc rank data=b out=b groups=5 descending;
   var  mv;
   ranks mvrank;
run;
data b;
   set b;
      drop y m;
run;
proc rank data=b out=b groups=5 ;
   var  mv turn ret;
   ranks mvrank turnrank retrank;
run;

proc sort data=b;by mvrank;
run;


proc rank data=b out=c groups=4 ;
   var   turn ret;
   ranks turnrank retrank;
   by mvrank;
run;

