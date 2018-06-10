libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";

data a;
   set aa.price;
run;

proc univariate data=a noprint;
   var mv;
   output out=winsor pctlpts=1 99 pctlpre=limit_
          pctlname=low high;
		  /*pctlpts  要求输出该变项的第几百分位数的数值
            pctlpre 输出的数值的变项名要求前导名称
		    pctlname 输出的数值的命名
            由于要求有前导名称所以命名就变为  limit_low limit_high
		  */
run;
data a_delete;
   set a;
      if _n_=1 then set winsor;
/*这是一个有趣的语法  当观察值为一时 读取winsor的数据
  所以SAS就会在读完a这个档案后 重新在读取winsor的数据
  并且反覆读完
*/
      if   limit_low<mv<limit_high then output;
      drop limit_high limit_low;
run;
data a_replace;
   set a;
      if _n_=1 then set winsor;
      if mv<limit_low then mv=limit_low;
      if mv>limit_high then mv=limit_high;
      drop limit_high limit_low;
run;
/*
这样 同时就完成删除掉以及取代掉的winsorize语法
*/

/**/


%macro winsorize(file,var,low,high);
   proc univariate data=&file noprint;
      var &var;
      output out=winsor pctlpts=&low &high pctlpre=limit_
             pctlname=low high;
   run;
   data &file._delete;
/*
注意 此处是&file._
而非       &file_
*/
      set &file;
         if _n_=1 then set winsor;
         if   limit_low<&var<limit_high then delete;
         drop limit_high limit_low;
   run;
   data &file._replace;
      set &file;
         if _n_=1 then set winsor;
         if &var<limit_low then &var=limit_low;
         if &var>limit_high then &var=limit_high;
         drop limit_high limit_low;
   run;
   proc datasets noprint;
      delete winsor;
   quit;
/*
winsor已经使用完毕 所以删除之避免占据硬盘空间
*/
%mend;
%winsorize(a,mv,2.5,97.5);
%winsorize(a,ret,0.5,99.5);
/*使用上  最好是对称的*/


%macro winsorize_time(file,delete,var,time,low,high);
   proc sort data=&file;by &time;
   run;
   proc univariate data=&file noprint;
      var &var;
      by &time;
      output out=winsor pctlpts=&low &high pctlpre=limit_
             pctlname=low high;
   run;
   /*revise 20150728*/
   %if &delete=1 %then %do;
      data &file;
         merge &file winsor;by &time;
            if   limit_low<&var<limit_high then delete;
            drop limit_high limit_low;
      run;
   %end;
   %else %do;
      data &file;
         merge &file winsor;by &time;
            if &var<limit_low then &var=limit_low;
            if &var>limit_high then &var=limit_high;
            drop limit_high limit_low;
      run;
   %end;
   /*revise 20150728*/
   proc datasets noprint;
      delete winsor;
   quit;
%mend;

%winsorize_time(a,0,mv,y m, 2.5,97.5);
%winsorize_time(a,0,ret,y m,0.5,99.5);
/*使用上  最好是对称的
  特别注意  &file._delete的档案  其数据已经被删除掉
  所以变项的删除顺序不同 会影响到最终档案的结果
*/

%inc "D:\The Application of SAS in Financial Research\CH08\program_cn\winsorize.sas";
%winsorize(a,0,ret, 2.5,97.5);
%winsorize_time(a,0,turn,y m, 2.5,97.5);
