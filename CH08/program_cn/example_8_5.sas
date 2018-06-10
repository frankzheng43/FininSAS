libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";

data a;
   set aa.price;
run;

proc univariate data=a noprint;
   var mv;
   output out=winsor pctlpts=1 99 pctlpre=limit_
          pctlname=low high;
		  /*pctlpts  Ҫ������ñ���ĵڼ��ٷ�λ������ֵ
            pctlpre �������ֵ�ı�����Ҫ��ǰ������
		    pctlname �������ֵ������
            ����Ҫ����ǰ���������������ͱ�Ϊ  limit_low limit_high
		  */
run;
data a_delete;
   set a;
      if _n_=1 then set winsor;
/*����һ����Ȥ���﷨  ���۲�ֵΪһʱ ��ȡwinsor������
  ����SAS�ͻ��ڶ���a��������� �����ڶ�ȡwinsor������
  ���ҷ�������
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
���� ͬʱ�����ɾ�����Լ�ȡ������winsorize�﷨
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
ע�� �˴���&file._
����       &file_
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
winsor�Ѿ�ʹ����� ����ɾ��֮����ռ��Ӳ�̿ռ�
*/
%mend;
%winsorize(a,mv,2.5,97.5);
%winsorize(a,ret,0.5,99.5);
/*ʹ����  ����ǶԳƵ�*/


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
/*ʹ����  ����ǶԳƵ�
  �ر�ע��  &file._delete�ĵ���  �������Ѿ���ɾ����
  ���Ա����ɾ��˳��ͬ ��Ӱ�쵽���յ����Ľ��
*/

%inc "D:\The Application of SAS in Financial Research\CH08\program_cn\winsorize.sas";
%winsorize(a,0,ret, 2.5,97.5);
%winsorize_time(a,0,turn,y m, 2.5,97.5);
