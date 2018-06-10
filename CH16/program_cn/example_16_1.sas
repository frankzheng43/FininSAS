libname aa 'D:\The Application of SAS in Financial Research\CH16\data';

data ret;
   set aa.daily_return;
run;
proc sort data=ret;by year month day;
run;
data a; 
   set aa.drmrf;
run;
/*
若要使用三因子 四因子 甚至五因子模型来进行异常报酬率检定
则在此处可以与 SMB HML MOM 等报酬率合并
*/

proc sort data=a nodupkey; by year month day;
run;
data a;
   set a;
      t=_n_;
run;
data t;
   set a;
      if t=lag(t) then delete;
      keep year month day t;
run;
data ret;
   merge ret a;by year month day;
      if t=. then delete;
      keep year month day ret stkcd rm t;
run;

data event;
   length stknm $30. stkcd $6. com_date 8. ann_date 8.;
   infile 'D:\The Application of SAS in Financial Research\CH16\data\event.txt' firstobs=2 dlm='09'x missover;
      input type $ dec $ cur sn stknm $  com_date ann_date;
         year=int(ann_date/10000);
         month=mod(int(ann_date/100),100);
         day=mod(ann_date,100);
         stkcd=substr(stknm,1,6);
         if ann_date^=.;
         keep stkcd com_date ann_date year month day;
          /*
             保留  stkcd 股票代号
             com_date 完成日
             ann_date 事件宣告日
             year 
             month
             day
           */
run;
proc sort data=event;by  year  month day;
run;
data event;
   merge event t;by year month day;
run;
/*
接下来要修正  如果事件宣告日是非交易日
就要将时间修改为下一个交易日

*/

proc sort data=event;by descending year descending month descending day;
run;
data event;
   set event;
      retain nt 0;
         if t^=. then nt=t;
      t=nt;
      if stkcd='' then delete;
      drop nt;
run;
data event ;
   set event;
      event=_n_;
run;


%let est=50;
%let drop=0;
%let before=10;
%let after=10;

/*
此处可以自行修改
est是估计期长短
drop 是估计期与事件期要间隔几天
before是事件窗口往前开几天
after是事件窗口往后开几天
*/

PROC SQL;
   CREATE table a
   as select
      a.stkcd,
      a.event,
      b.ret,
      b.rm
/*
若要用三因子 四因子 甚至五因子
可在这边抓取相关变项
*/

   from event a, ret b
   where (a.stkcd=b.stkcd and
          a.t-&est-&drop-&before <=b.t<= a.t-&drop-&before-1)
   order by a.event,a.stkcd;
quit;

proc reg data=a adjrsq  outest=b noprint;
   model ret=rm;
/*
可在这边建构三 四 五因子模型
*/
   by event stkcd;
quit;
proc means noprint data=a;
   var ret; 
   by event stkcd;
   output out=c(drop=_type_ _freq_) mean=mean;
run;
/*将估计期的市场模型以及个股过去的平均报酬率计算出来*/
data a;
   merge b c;by event stkcd;
      if _p_+_edf_=&est then output;
run;

data newevent;
   merge event a;by event stkcd;
   if mean=. then delete;
run;

PROC SQL;
   CREATE table b
   as select
      a.stkcd,
      a.event,
      b.t-a.t as t,
      b.ret-a.intercept-b.rm*a.rm as AR1,
/*
可在此处修改成 三因子 四因子 五因子建构下的异常报酬率
*/
      b.ret-a.mean as AR2,
      b.ret-b.rm as AR3
   from newevent a, ret b
   where (a.stkcd=b.stkcd 
          and a.t-&before  <=b.t <= a.t+&after)
   order by b.t;
quit;
proc sort data=b;by t;
run;
/*至此  直接算出三种异常报酬率
AR1 市场模型异常报酬率
AR2 平均调整后异常报酬率
AR3 市场调整后异常报酬率*/

proc univariate data=b  ;
   var AR1-AR3;
   by t;
   ods output TestsForLocation=test BasicMeasures=basic;
run;

data basic;
   set basic;
      if VarName='AR3' then model='Market Adjusted Model';
      if VarName='AR2' then model='Mean Adjusted  Model';
      if VarName='AR1' then model='Market Model';
      drop varmeasure varvalue;
      if 1<=mod(_n_,4)<=2 then output;
run;
data test;
   set test;
      if 1<=mod(_n_,3)<=2 then output;
      drop testlab ptype mu0 test;
run;
data test;
   merge basic test;
      if pvalue<0.01 then value=round(locvalue,0.001)||'***';
      else if pvalue<0.05 then value=round(locvalue,0.001)||'**';
      else if pvalue<0.1 then value=round(locvalue,0.001)||'*';
      else value=round(locvalue,0.001)||'';
run;
proc sort data=test;by varname model t;
run;
/*add 20150630*/
data test;
set test;
if LocMeasure="均值" then LocMeasure="Mean";
if LocMeasure="中位数" then LocMeasure="Median";
run;
/*add 20150630*/
proc transpose data=test out=test(drop=varname _name_);
   var value;
   id LocMeasure;
   by varname model t;
run;
proc sort data=basic;by model t;
run;
data basic;
   set basic;
      if mod(_n_,2)=1 then output;
run;
data basic;
   set basic;
      retain CAR 0;
         CAR=CAR+locvalue;
      if model^=lag(model) then CAR=Locvalue;
run;

proc sgplot data=basic;
   title "The CAR during the event date";
   series x=t y=CAR/ group=model;
run;

proc export data=b
   outfile="D:\The Application of SAS in Financial Research\CH16\output\data_ar.csv"
   replace;
run;
proc export data=test
   outfile="D:\The Application of SAS in Financial Research\CH16\output\test_ar.csv"
   replace;
run;
/*
采用CSV存盘较佳，因为异常报酬率数据可能会超过65535笔
当然，保留为SAS的档案会更好
*/


