/* ��͸�����﷨*/
/*��׫д��һ��������ִ�е�SAS�﷨*/

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

/*��㽫׫д�ҿ���ִ�е��﷨ ����%macro a;  %mend; ����*/
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
/*��Ϊ��Ҫ�����10�顢20�����15��  ���ʾ��������һ������Ҫ����
��˿�������������*/

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

/*��rep=10 �ĳ�rep=&num*/
%macro a(num);
   data a;
      do i=1 to 49;
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint
   seed=0 n=6 rep=&num method=srs;
   /*��Ϊ�������ȡ���飬�����ڴ��޸�*/
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a(10);
%a(20)
/*��������ָ����ȡ������͸����*/

%macro a(num,a);
   data a;
      do i=1 to &a;
      /*�޸�Ҫ������������*/
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
   /* �޸�ÿ��Ҫ�����������*/
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
1.������ܹ������Ļ�����ʽ
2.���޸����еı���
3.�ر�ע��  �ܲ��ظ���ȡ���ݾͱ����ȡ����
*/

