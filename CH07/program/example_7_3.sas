/* Lottery sampling */
/*first, write a complete code that SAS the perform*/

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

/*put the code into %macro a;  %mend; ??*/
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
/*we choose to buy 10,15 ,20 ticket,
  so we add a macro variable num*/

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

/*rewriter rep=10 into rep=&num*/
%macro a(num);
   data a;
      do i=1 to 49;
         output;
      end;
   run;
   proc surveyselect data=a out=out noprint
   seed=0 n=6 rep=&num method=srs;
   /*we want to change how many tickets to buy*/
   run;
   proc transpose data=out out=out (drop=_name_);
   by replicate;
   run;
%mend;
%a(10);
%a(20)
/*we can change how many tickets want to buy*/

%macro a(num,a);
   data a;
      do i=1 to &a;
      /*change how many numbers you can choose*/
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
   /* change how many number you have to pick up*/
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
1.write a code thay can work
2.revise the variable into macro variable 
3.don't read same file until you have to
*/

