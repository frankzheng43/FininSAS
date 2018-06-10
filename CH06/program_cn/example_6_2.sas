proc sql;
create  table    tablename  as 
select         variable
from               sorcefile
where             condition
group  by        variable
order by          variabe
;
quit;

proc sql;
create  table    tablename 
as select         variable
from               sorcefile
where             condition
group  by        variable
order by          variabe
;
quit;


proc import datafile="D:\The Application of SAS in Financial Research\CH06\data\sql\event"
   dbms=xlsx
   out=a
   replace;
quit;

proc sort nodupkey data=a;by event;
/* ����¼����ͽ��з�����������������ͬ��˾����ͬ�����¼�*/
run;

/*���ԱȽ�new1  �Լ�new2 �Ĳ���*/
proc sql;
create table  new1 
as select 
y as year,
m as month,
d as day,
y*10000+m*100+d as date,
stkcd_nm as stkcd,
event as event_type
from a
where  event contains "�ֽ��Ϣ"
order by event;
quit;

proc sql;
create table  new2 
as select 
y,
m,
d,
y*10000+m*100+d as date,
stkcd_nm,
event
from a
where  event contains "�ֽ��Ϣ"
order by event;
quit;
/* ���߲���  as  ���﷨  ���������Щ��ͬ*/
data newb;
   set a;
      if event="�Ϻ��ֽ��Ϣ" then output;
      if event="�����ֽ��Ϣ" then output;
      if event="�����ֽ��Ϣ" then output;
run;

/*�޷�˳�����е��﷨*/
data newb;
   set a;
      if event="�ֽ��Ϣ" then output;
run;

data price;
length stkcd $6.;
length nm $10.;
/*
�������� stkcd�����ֱ��� ����Ϊ6
        nm�����ֱ���     ����Ϊ10
*/
infile "D:\The Application of SAS in Financial Research\CH06\data\sql\price.txt" dlm="09"x firstobs=2 missover;
/*
dlm�Ǹ���SAS���ݵķָ������ǲ���ʲô��ʽ
"09"x �Ǳ�ʾ���ݼ���ʹ��tab���ָ���
*/
input stkcd $ nm $  date ret turnover mv;
/*��Ʊ���� ����  ����  �ر��� ������ ��ֵ*/
y=int(date/10000);
m=mod(int(date/100),100);
drop nm;
/*�ڷ��������� ֻ��Ҫ��Ʊ���ţ�����Ҫ��Ʊ����*/
run;
data new2;
set new2;
stkcd=substr(stkcd_nm,1,6);
/*Ϊ�˴���ɼ۵�����stkcd ���������ִ����ǰ����*/
run;

proc sql;
create table a as select * 
from price
where stkcd in 
(select stkcd from new2);
quit;


proc sql;
create table b as select  y , m,  stkcd, ret, mv
from price
where stkcd in 
(select stkcd from new2);
quit;


proc sql;
create table c as select  y , m,  stkcd, ret, mv
from price
where stkcd  in (select stkcd from new2) and 
y in (select  y from new2) and
m in (select  m from new2) ;
quit;

proc sql;
create table c as select  y , m,  stkcd, ret, mv
from price
where stkcd  in (select stkcd from new2) and 
y in (select  y from new2) and
m in (select  m from new2) ;
create table c1 as select *
from c, new2
where c.stkcd=new2.stkcd and c.y=new2.y and c.m=new2.m;
quit;
proc sql;
create table nb as select  y , m,  stkcd, ret, mv
from price
where stkcd not in 
(select stkcd from new2);
quit;

proc sql;
create table d as select  y , m,  stkcd, ret, mv,/*�˴����˶���*/
case 
when ret>5 then 1
when   5>=ret>0 then 2
when 0>=ret>-5 then 3
else 4
end as aa /*�˴�δ�Ӷ��� ����Ϊ���һ������*/
from price
where stkcd not in 
(select stkcd from new2);
quit;
data a;
set a;
if ret>5 then aa=1;
else if  5>=ret>0 then aa=2;
else if 0>=ret>-5 then aa=3;
else aa=4;
run;
proc sql;
create table e as select  y , m,  stkcd, ret, mv,/*�˴����˶���*/
case 
when ret>5 then 1
when   5>=ret>0 then 2
when 0>=ret>-5 then 3
else 4
end as aa, /*�˴����˶���*/
case 
when y<2010 then "y2009"
else "y2010"
end as y2009 /*�˴�δ�Ӷ��� ����Ϊ���һ������*/
from price
where stkcd not in 
(select stkcd from new2);
quit;

proc sql;
create table f
as select  
a.y as y,
a.m as m,
a.ret as ret,
a.stkcd as stkcd,
b.event as event
from price a ,new2 b
/*revise 20150628*/
where a.stkcd=b.stkcd and
/*revise 20150628*/
a.y=b.y and 
a.m=b.m;
quit;

proc sql;
create table g
as select  a.y, a.m, a.ret, a.stkcd, b.event
from price a, new2 b
where a.stkcd=b.stkcd and
a.y=b.y and
a.m=b.m;
quit;




data a;
do i= 1 to 100;
do j=1 to 10;
a=rannor(1);
output;
end;
end;
run;
proc sort data=a;by j;
run;
proc transpose data=a out=b;
var a;
by j;
run;
data b;
set b;
a=mean(of  col1-col100);
keep j a;
run;
proc sql;
create table c
as select i,j, a,
mean(a) as meana
from a
group by j;
quit;

proc sql;
create table d
as select i,j, a,
a-mean(a) as adj
from a
group by j;
quit;
proc sql;
create table e
as select  j,
mean(a) as mean,
std(a) as std,
min(a) as min,
max(a) as max
from a
group by j;
quit;


proc sql;
create table f
as select j,
(exp (mean (log(1+0.01*a)))-1)*100 as geomean,
(exp(sum(log(1+0.01*a)))-1)*100 as BHR
from a
group by j;
quit;
proc sql;
create table g
as select *
from a
order by j,a;
quit;
proc sql;
create table h
as select *
from a
order by j desc,a desc;
quit;
