data a;
   do i=1 to 3;
      a=ranuni(1);
      do j=1 to 10;
         b=rannor(1);
         do k=1 to 10;
            c=5+3*a+b**(-3)+rannor(2);
            output;
         end;
      end;
   end;
run; 
data b;
   set a;
      drop a b;
run;
data c;
   set a;
      keep i j k c;
run;
data a;
   do i=1 to 3;
      a=ranuni(1);
      do j=1 to 10;
         b=rannor(1);
         do k=1 to 10;
            c=5+3*a+b**(-3)+rannor(2);
            drop a b;
/*  keep i j k c; 
    also produce the same result*/
            output;
         end;
      end;
   end;
run;
data a1;
   set a nobs=x;
      if _n_/x<=1/2 then output;
run;
data a2;
   set a nobs=x;
      if _n_/x>1/2 then delete;
run;
data b1 b2;
   set a nobs=x;
      if _n_/x<=1/2 then output b1;
      else output b2;
run;
data c1 c2 c3;
   set a nobs=x;
      if  _n_/x<=0.2 then output c1;
      else if 0.2<_n_/x<=0.5 then output c2;
      else output c3;
run;
data d1 d2 d3;
   set a nobs=x;
      if  _n_/x<=0.2 then output d1;
      if 0.1<_n_/x<=0.5 then output d2;
      if _n_/x>0.5 then  output d3;
run;

data e1;
   set a nobs=x;
      if _n_/x<=0.5 and c>0 then output;
run;
data e2;
   set a nobs=x;
      if _n_/x<=0.5 or c>0 or i=2 then output;
run;
data e3;
   set a nobs=x;
      if _n_/x<=0.5 or c>0 and i^=2 then output;
run;
data e4;
   set a nobs=x;
      if _n_/x<=0.5 and c>0 or i^=2 then output;
run;

data f;
   set a;
      if c<0 then d=1;else d=0;
run;