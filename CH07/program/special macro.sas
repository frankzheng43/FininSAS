%macro c(ys,ye,c);
   proc datasets;
   delete &c;
   quit;
   %do i=&ys %to &ye;
      proc append base=&c data=aa.d&i;
      quit;
   %end;
%mend;
%macro sort(sort,file);
   proc sort data=&file;by &sort;
   run;
%mend;
%macro transpose(sort,file,var);
   proc transpose data=&file out=&var;
   var &var;
   by &sort;
   run;
%mend;
%macro ranks(sort,file, var,groups);
   proc rank data=&file out=&file groups=&groups;
   var &var;
   ranks rank_&var;
   by &sort;
   run;
%mend;