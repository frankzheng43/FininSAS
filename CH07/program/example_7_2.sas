
libname aa "D:\The Application of SAS in Financial Research\SAS data\daily data";
%macro a(a);
   %do i=2002 %to 2006;
      proc append base=&a data=aa.d&i;
      quit;
   %end;
%mend;
%a(price);

%macro b(b);
   proc datasets noprint;
      delete &b;
   quit;
   %do i=2002 %to 2006;
      proc append base=&b data=aa.d&i;
      quit;
   %end;
%mend;
%b(price);

%macro c(ys,ye,c);
   proc datasets noprint;
      delete &c;
   quit;
   %do i=&ys %to &ye;
      proc append base=&c data=aa.d&i;
      quit;
   %end;
%mend;
%c(2001,2003,price);

data a b c d e f i j k;
   do i=1 to 100;
      a=rannor(20);
      output;
   end;
run;

data final;
   set a b c d e f i j k;
run;


proc datasets noprint;
   delete final file;
quit;
proc contents data=work._all_ noprint out=file;
/*  libname._all_  means check all the content in libname
   work._all_   all the file in work library
   aa._all_     all the file in  aa library
*/
quit;

proc sort data=file(keep=memname) nodupkey;by memname;
run;

%macro d(final,n);
   proc datasets noprint;
   delete &final;
   quit;
   %do i=1 %to &n;
      data _null_;
         set file;
            if _n_=&i then do;
               call symput("ss", memname);
            end;
      run;
      proc append base=&final data=&ss;
      quit;
   %end;
%mend;
%d(final,9);
%macro d1(final,n);
   proc datasets noprint;
      delete &final;
   quit;
   %do i=1 %to &n;
      data _null_;
         set file;
            if _n_=&i then do;
               call symput("ss", memname);
            end;
      run;
      data &ss;
         set &ss;
            file1="&ss";
            file2='&ss';
            /* notice the difference between   "  and '*/
      proc append base=&final data=&ss;
      quit;
   %end;
%mend;
%d1(final2,9);
%macro sort(sort,file);
   proc sort data=&file;by &sort;
   run;
%mend;
%sort(y m d,price);
%macro transpose(sort,file,var);
   proc transpose data=&file out=&var;
      var &var;
   by &sort;
run;
%mend;
%sort(code,price);
%transpose(code,price, ret);
%transpose(code,price,mv);
%transpose(code,price,turnover);

%macro ranks(sort,file, var,groups);
   proc rank data=&file out=&file groups=&groups;
      var &var;
      ranks rank_&var;
      by &sort;
   run;
%mend;
%ranks(  , price, turnover,5);

/* the way to dependent sort  */
%sort(rank_turnover,price);
%ranks(rank_turnover , price, mv,5);

/*the way to independent sort*/
%ranks(  , price, turnover,5);
%ranks(  , price, mv,5);



%include "D:\The Application of SAS in Financial Research\CH07\program\special macro.sas";
libname aa "D:\The Application of SAS in Financial Research\SAS data\daily data";
%c(2001,2003,price);
%sort(y m d,price);
%ranks(  , price, turnover,5);
/*dependent sort  */
%sort(rank_turnover,price);
%ranks(rank_turnover , price, mv,5);
/*independent sort*/
%ranks(  , price, turnover,5);
%ranks(  , price, mv,5);


libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data a;
   set aa.price;
run;
%include "D:\The Application of SAS in Financial Research\CH07\program\special macro.sas";
%sort(code y m,a);
data a;
   set a;
      r1=lag1(ret);
      r2=lag2(ret);
      r3=lag3(ret);
      if code^=lag1(code) then r1=.;
      if code^=lag2(code) then r2=.;
      if code^=lag3(code) then r3=.;
run;

%macro lag(file,code,var1,var2,n);
   %do i=1 %to &n;
      data &file;
         set &file;
            &var2&i=lag&i(&var1);
            if &code^=lag&i(&code) then &var2&i=.;
      run;
   %end;
%mend;
%lag(a,code,ret, r, 20);
%macro lag2(file,code,var1,var2,n);
   data &file;
      set &file;
		 %do i=1 %to &n;
            &var2&i=lag&i(&var1);
            if &code^=lag&i(&code) then &var2&i=.;
         %end;
      run;
%mend;
%lag2(a,code,ret, r, 20);

proc sort data=a nodupkey out=b(keep=code) ;by code;
run;
%macro dummy1(file,code,dummy,n);
   %do i=1 %to &n;
      data  &file;
         set &file ;
            &dummy&i=_n_=&i;
      run;
   %end;
%mend;
%dummy1(b,code,firm,1009);
%macro dummy2(file,code,dummy,n);
   data  &file;
      set &file ;
	     %do i=1 %to &n;
            &dummy&i=_n_=&i;
		 %end;
      run;
%mend;
%dummy2(b,code,firm,1009);

%macro a;
   %do i=1 %to 10;
      data data&i;
         do i=1 to 10;
            a&i=rannor(&i);
            output;
         end;
      run;
   %end;
%mend a;
%a;
%macro aa;
   %do i=1 %to 9;
      data newa&i;
         merge data&i data&i+1;
      run;
   %end;
%mend;
%aa;

%MACRO aa;
   %DO i=1 %to 9;
      DATA NEW&i;
         merge DATA&i  DATA%eval(&i+1);
      RUN;
   %end;
%MEND;
%aa;

