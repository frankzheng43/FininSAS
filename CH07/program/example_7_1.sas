
data a;
   do i=1 to 100;
      a=rannor(1);
      b=ranuni(1);
      output;
   end;
run;

%macro a;
   data a;
      set a;
         c=a+b;
   run;
%mend;
%a;

data a;
   a=2;
   b=3;
run;
%a;

%macro b(in,out);
   data &out;
      set &in;
         c=a+b;
   run;
%mend;

data dd;
   a=100;
   do i=1 to 100;
      b=rannor(1);
      output;
   end;
run;
%b(dd,b);

