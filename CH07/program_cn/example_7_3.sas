/* 乐透抽样语法*/
/*先撰写出一个完整可执行的SAS语法*/

data a;
   do i=1 to 49;
      output;
   end;
run;
proc surveyselect data=a out=out noprint
seed=0 n=6 rep=10 method=srs;
run;
proc transpose data=out out=out (drop=_name_);
by replicate;
run;

/*随便将撰写且可以执行的语法 塞到%macro a;  %mend; 里面*/
%macro a;
   data a;
      do i=1 to 49;
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint 
   seed=0 n=6 rep=10 method=srs;
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a;
/*因为想要任意抽10组、20组或者15组  这表示宏里面有一个变项要考虑
因此可以先新增变项*/

%macro a(num);
   data a;
      do i=1 to 49;
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint
   seed=0 n=6 rep=10 method=srs;
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a;

/*将rep=10 改成rep=&num*/
%macro a(num);
   data a;
      do i=1 to 49;
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint
   seed=0 n=6 rep=&num method=srs;
   /*因为是任意抽取几组，所以在此修改*/
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a(10);
%a(20)
/*可以自由指定抽取几组乐透彩了*/

%macro a(num,a);
   data a;
      do i=1 to &a;
      /*修改要产生几个号码*/
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint
   seed=0 n=6 rep=&num method=srs;
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a(10,49);
%a(10.70);

%macro a(num,a,b);
   data a;
      do i=1 to &a;
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint
   seed=0 n=&b rep=&num method=srs;
   /* 修改每张要抽出几个号码*/
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a(10,49,6);
%a(10.70,5);

data a;
   do i=1 to 1000;
      output;
   end;
run;
%macro a;
   %do i=1 %to 1000;
      data a;
         set a;
            d&i=_n_=&i;
      run;
%end;
%mend;
%a;
data a;
   do i=1 to 1000;
      output;
   end;
run;
%macro a;
   data a;
      set a;
         %do i=1 %to 1000;
            d&i=_n_=&i;
         %end;
   run;
%mend;
%a;
/*
1.先完成能够运作的基础程式
2.逐步修改其中的变项
3.特别注意  能不重复读取数据就避免读取数据
*/

