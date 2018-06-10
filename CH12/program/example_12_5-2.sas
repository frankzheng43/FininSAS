data a;
   do t=1 to 100;
      x=rannor(1);
      y=2+3*x+rannor(2);
      output;
   end;
run;
data a;
   set a;
      do i=2 to 99;
         if i<=t then change=1;else change=0;
         output;
      end;
run;
proc sort data=a;by i;
run;
proc reg data=a noprint adjrsq outest=k(keep=i _p_);
   model y=x;
   by i;
   output out=a r=r1;
quit;
proc reg data=a noprint adjrsq;
   model y=x;
   by i change;
   output out=a r=r2;
quit;
data a;
   set a;
      ESS1=r1**2;
      ESS2=r2**2;
run;
proc means noprint;
   var ESS1 ESS2;
   by i;
   output out=b(drop=_type_ _freq_) sum=ESS1 ESS2 n=N;
run;
data b;
   merge b k;by i;
      Chow=(((ESS1-ESS2)/_p_)/(ESS2/(N-2*_p_)));  
      ProbF=1-probf(Chow,_p_,N-2*_p_);
      if probf<0.1 then output;
      keep i Chow ProbF;
run;
proc print data=b;
quit;
