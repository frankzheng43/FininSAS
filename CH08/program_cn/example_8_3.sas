libname aa "D:\The Application of SAS in Financial Research\CH08\data";
data a;
   set aa.sort;
run;
%include "D:\The Application of SAS in Financial Research\CH08\program_cn\corr.sas";
%correlation(a,4,ret mv turn);
/*
a ΪҪ�춨���ϵ����ĵ���
4 ΪС����λ��
ret mv turn ΪҪ�춨�ı���
����� pearson �Լ�spearman��������
*/
%inc 'D:\The Application of SAS in Financial Research\CH08\program_cn\stat.sas';
%stat(a,4,ret mv turn);
/*
a �ɸ�ΪҪ�춨�ĵ���
4 ΪС����λ��
ret mv turn ΪҪ��������ͳ�����ı���
����� final final1��������*/

