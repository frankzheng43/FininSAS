DM'LOG;CLEAR;OUT;CLEAR';
option notes nolabel;
libname aa 'D:\The Application of SAS in Financial Research\SAS data\four factor';
libname bb 'D:\The Application of SAS in Financial Research\SAS data\monthly price';
data a;
   set aa.factor;
run;
data b;
   set bb.price;
run;
proc sort data=a;by y m;
run;
proc sort data=b;by y m;
run;
/*
其实可以不用另外读档案，但是会担心不小心改了原始档案
所以建议都先读取档案后 在进行整理分析
*/
data a;
   merge a b;by y m;
      rirf=ret-rf;
      rmrf=rm-rf;
      if smb=. then delete;
run;
proc reg data=a;
   model rirf=rmrf ;
   model rirf=rmrf smb hml;
   model rirf=rmrf smb hml mom;
quit;

proc reg data=a ;
   model rirf=rmrf smb hml mom ;
   model rirf=rmrf ;
   model rirf=rmrf smb hml;
   model rirf=rmrf smb hml mom;
quit;
proc reg data=a ;
   model rirf=rmrf /white;
   model rirf=rmrf smb hml/white;
   model rirf=rmrf smb hml mom/white;
quit;
/*注意第一个模型  虽然就是四因子模型
 但实际上是  2~4个模型中的所有解释变数
 该模型顺序 就是我们输出时的顺序
*/
proc reg data=a ;
   model rirf=rmrf smb hml mom/white ;
   model rirf=rmrf /white;
   model rirf=rmrf smb hml/white;
   model rirf=rmrf smb hml mom/white;
   ods output FitStatistics=fit;
   ods output NObs=nobs;
   ods output ParameterEstimates=para;
quit;

/*
切记  fit nobs 以及para都保留起来
*/

/*以下创作了  OLS的宏语法  bit指的是  系数估计要到小数点后几位  white=1表示输出white检定 

  其他 则表示输出普通最小二乘法*/
%macro OLS(bit,White);
   %if &white=1 %then %do;
      data reg;
         set para;			  
             if HCprobt<0.01 then sig='***';
             else if HCprobt<0.05 then sig='**';
             else if Hcprobt<0.1 then sig='*';
             else sig='';
             est=round(estimate,10**(-1*&bit))||sig;
             tv='('||left(round(HCtvalue,0.01)||')');
      run;
   %end;
   %else %do;
      data reg;
         set para;			  
            if probt<0.01 then sig='***';
            else if probt<0.05 then sig='**';
            else if probt<0.1 then sig='*';
            else sig='';
            est=round(estimate,10**(-1*&bit))||sig;
            tv='('||left(round(tvalue,0.01)||')');
      run;
   %end; 
   data rsq;
      set fit;
         rsq=round(nvalue2*100,0.01)||'%';
         if label2='' then delete;
         variable=label2;
         keep model variable rsq;
   run;
   data n;
      set nobs;
         variable='N';
         nobs=''||nobsused;
         if label='使用的观测数' then output;
   run;
   data t;
      set reg;
         t=_n_;
         if model='MODEL1' then output;
         keep variable t;
   proc sort data=t;by variable;
   run;
   proc sort data=reg;by variable;
   run;
   data reg;
      merge reg t;by variable;
   run;
   proc sort data=reg;by t variable;
   run;
   proc transpose data=reg out=est;
      var est;
      by t variable;
      id model;
   run;
   proc transpose data=reg out=tvalue;
      var tv;
      by t variable;
      id model;
   run;
   data OLS;
      set est tvalue;by t _name_;
         if _name_='tv' then variable='';
         drop t _name_;
   run;
   proc sort data=rsq;by variable;
   run;
   proc transpose data=rsq out=rsq;
      var rsq;
      by variable;
      id model;
   run;
   proc transpose data=n out=n;
      var nobs;
      by variable;
      id model;
   run;
   data OLS;
      set OLS rsq n;
         %if &white=1 %then %do;
            tvalue='white';
         %end;
         %else %do;
            tvalue='OLS';
         %end;
         drop model1 _name_;
   run;
%mend;
%ols(3,1);
proc export data=ols
   outfile='D:\The Application of SAS in Financial Research\CH11\EXCELoutput\ols_result'
   dbms=xlsx
   replace;
   sheet="white";
run;
%ols(3);
proc export data=ols
   outfile='D:\The Application of SAS in Financial Research\CH11\EXCELoutput\ols_result'
   dbms=xlsx
   replace;
   sheet="ols";
run;

/*套装化使用
关闭 SAS都  重新开启
确保 SAS未记录 ols宏语法
*/
libname aa 'D:\The Application of SAS in Financial Research\SAS data\four factor';
libname bb 'D:\The Application of SAS in Financial Research\SAS data\monthly price';
data a;
   set aa.factor;
run;
data b;
   set bb.price;
run;
proc sort data=a;by y m;
run;
proc sort data=b;by y m;
run;

data a;
   merge a b;by y m;
      rirf=ret-rf;
      rmrf=rm-rf;
      if smb=. then delete;
run;

%include 'D:\The Application of SAS in Financial Research\CH11\program_cn\reg.sas';
%macro model(model);
   model rirf=rmrf smb hml mom /white;
   model rirf=rmrf /white;
   model rirf=rmrf smb hml /white;
   model rirf=rmrf smb hml mom/white;
%mend;
/*
以上撰写所有要跑回归的模型
*/
 %reg(a,y,4);  
/*
a 为资料来源档案
y 为要求SAS依照y进行回归
4 为进位到小数点后4位
若不分组回归 则  %a(a,,4);

回归结果产生 reg_ols 以及 reg_white
 */

proc export data=reg_ols
   outfile='D:\The Application of SAS in Financial Research\CH11\EXCELoutput\reg_result'
   dbms=xlsx
   replace;
   sheet="reg";
run;
proc export data=reg_white
   outfile='D:\The Application of SAS in Financial Research\CH11\EXCELoutput\reg_result'
   dbms=xlsx
   replace;
   sheet="white";
run;

