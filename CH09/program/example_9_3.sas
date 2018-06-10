option nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data a;
   set aa.price;
      if m=12  and  y>2000 then  output;
run;
proc sort data=a;by y;
run;
proc rank data=a out=a groups=2;
   var mv turn;
   ranks size turnr;
   by y;
run;

%inc "D:\The Application of SAS in Financial Research\CH09\program\ttest.sas";
%inc "D:\The Application of SAS in Financial Research\CH09\program\npar.sas";
%ttest(volum value ret turn pb,4,size,y turnr,a,b);
%ttest(volum value ret turn pb,2,size, turnr,a,c);
proc export data=b outfile="D:\The Application of SAS in Financial Research\CH09\output\parameter_test"
   dbms=xlsx
   replace;
   sheet="b";
quit;
proc export data=c outfile="D:\The Application of SAS in Financial Research\CH09\output\parameter_test"
   dbms=xlsx
   replace;
   sheet="c";
quit;
%npar(volum value ret turn pb,4,size,y pbr,a,b);
%npar(volum value ret turn pb,2,size, pbr,a,c);
proc export data=b outfile="D:\The Application of SAS in Financial Research\CH09\output\npar_test"
   dbms=xlsx
   replace;
   sheet="b";
quit;
proc export data=c outfile="D:\The Application of SAS in Financial Research\CH09\output\npar_test"
   dbms=xlsx
   replace;
   sheet="c";
quit;
