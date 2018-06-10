libname aa "D:\The Application of SAS in Financial Research\CH08\data";
data a;
   set aa.sort;
run;
proc corr data=a;
   var ret turn mv;
run;

proc corr data=a  spearman;
   var ret turn mv;
run;

proc corr data=a outp=p outs=s cov noprint;
var ret turn mv;
run;

proc corr data=a  spearman cov outp=cov; 
   var ret turn mv;
   ods output pearsoncorr=pear;
   ods output simplestats=d;
   ods output spearmancorr=spear;
run;

%let de=3;
/*
这边说明总共算了几个变项的相关系数
*/
%let bit=4;
/*
此处说明 相关系数表格的结果四舍五入到小数点后几位
*/
%macro corr (file,file2);
   %do j=1 %to &de;
      data _null_;
         set &file;
            if _n_=&j then do;
               call symput("ss", variable); 
            end;
      run;
	  data a&j;
	     set &file;
		    b=round(&ss,10**(-1*&bit));
	        if 0<p&ss<0.01 then c="***";
	        if 0.01<=p&ss<0.05 then c="**";
			if 0.05<=p&ss<0.1 then c="*";
			if 0.1<=p&ss then c="";
			a&j=b||c;
			if _n_<&j then a&j="";
			keep variable a&j;
      run;
	  data a&j;
	     set a&j;
		    &ss=a&j;
		    keep variable &ss ;
	  run;
   %end;
   data &file2;
      set a1;
   run;
   %do k=2 %to &de;
      data &file2;
	     merge &file2 a&k;
	  run;
   %end;
%mend corr;
%corr (pear,pearson);
%corr (spear,spearman);
