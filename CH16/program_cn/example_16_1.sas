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
��Ҫʹ�������� ������ ����������ģ���������쳣�����ʼ춨
���ڴ˴������� SMB HML MOM �ȱ����ʺϲ�
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
             ����  stkcd ��Ʊ����
             com_date �����
             ann_date �¼�������
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
������Ҫ����  ����¼��������Ƿǽ�����
��Ҫ��ʱ���޸�Ϊ��һ��������

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
�˴����������޸�
est�ǹ����ڳ���
drop �ǹ��������¼���Ҫ�������
before���¼�������ǰ������
after���¼��������󿪼���
*/

PROC SQL;
   CREATE table a
   as select
      a.stkcd,
      a.event,
      b.ret,
      b.rm
/*
��Ҫ�������� ������ ����������
�������ץȡ��ر���
*/

   from event a, ret b
   where (a.stkcd=b.stkcd and
          a.t-&est-&drop-&before <=b.t<= a.t-&drop-&before-1)
   order by a.event,a.stkcd;
quit;

proc reg data=a adjrsq  outest=b noprint;
   model ret=rm;
/*
������߽����� �� ������ģ��
*/
   by event stkcd;
quit;
proc means noprint data=a;
   var ret; 
   by event stkcd;
   output out=c(drop=_type_ _freq_) mean=mean;
run;
/*�������ڵ��г�ģ���Լ����ɹ�ȥ��ƽ�������ʼ������*/
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
���ڴ˴��޸ĳ� ������ ������ �����ӽ����µ��쳣������
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
/*����  ֱ����������쳣������
AR1 �г�ģ���쳣������
AR2 ƽ���������쳣������
AR3 �г��������쳣������*/

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
if LocMeasure="��ֵ" then LocMeasure="Mean";
if LocMeasure="��λ��" then LocMeasure="Median";
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
����CSV���̽ϼѣ���Ϊ�쳣���������ݿ��ܻᳬ��65535��
��Ȼ������ΪSAS�ĵ��������
*/


