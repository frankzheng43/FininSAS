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
��ʵ���Բ�����������������ǻᵣ�Ĳ�С�ĸ���ԭʼ����
���Խ��鶼�ȶ�ȡ������ �ڽ����������
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
/*ע���һ��ģ��  ��Ȼ����������ģ��
 ��ʵ������  2~4��ģ���е����н��ͱ���
 ��ģ��˳�� �����������ʱ��˳��
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
�м�  fit nobs �Լ�para����������
*/

/*���´�����  OLS�ĺ��﷨  bitָ����  ϵ������Ҫ��С�����λ  white=1��ʾ���white�춨 

  ���� ���ʾ�����ͨ��С���˷�*/
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
         if label='ʹ�õĹ۲���' then output;
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

/*��װ��ʹ��
�ر� SAS��  ���¿���
ȷ�� SASδ��¼ ols���﷨
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
����׫д����Ҫ�ܻع��ģ��
*/
 %reg(a,y,4);  
/*
a Ϊ������Դ����
y ΪҪ��SAS����y���лع�
4 Ϊ��λ��С�����4λ
��������ع� ��  %a(a,,4);

�ع������� reg_ols �Լ� reg_white
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

