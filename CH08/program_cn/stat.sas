
/*write all the variable you want perform*/
%macro stat(file,bit,varlist);

proc univariate data=&file noprint;
   var &varlist;
   output out=mean mean= &varlist;
   output out=max max= &varlist;
   output out=q3  q3= &varlist;
   output out=median median= &varlist;
   output out=q1 q1= &varlist;
   output out=min min= &varlist;
   output out=var var=&varlist;
   output out=std std= &varlist;
   output out=skew skewness= &varlist;
   output out=kurt kurtosis= &varlist;
run;

%let bit1=&bit;
   %macro name(file);
       data &file;
	      length name $10.;
	      set &file;
	         name="&file";
	   run;
	   
	   proc transpose data=&file out=&file;
	   id name;
	   run;
	 
	   data &file;
	      set &file;
		  &file=round(&file,10**-&bit1);
	   run;
	  
       proc transpose data=&file out=&file;
	   var &file;
	   id _name_;
	   run; 
	   proc append base=final data=&file;
	   quit;
   %mend;
proc delete data=final;
quit;
%name(mean);
%name(std);
%name(min);
%name(q1);
%name(median);
%name(q3);
%name(max);
%name(skew);
%name(kurt);
option nolabel;
proc transpose data=final out=final1;
var &varlist;
id _name_;
run;
proc delete data=mean std min q1 median q3 max skew kurt;
quit;
%mend;


