data subset;
      input Hours Yrs_Ed Yrs_Exp @@;
      if Hours eq 0
         then Lower=.;
         else Lower=Hours;
   datalines;
   0 8 9 0 8 12 0 9 10 0 10 15 0 11 4 0 11 6
   1000 12 1 1960 12 29 0 13 3 2100 13 36
   3686 14 11 1920 14 38 0 15 14 1728 16 3
   1568 16 19 1316 17 7 0 17 15
   ;
   run;
proc lifereg data=subset ;
   model (lower, hours) = yrs_ed yrs_exp / d=normal;
quit;

proc lifereg data=subset noprint outest=outest(keep=_scale_);
   model (lower, hours) = yrs_ed yrs_exp / d=normal;
   output out=a(drop=censor _prob_) xbeta=xbeta;
quit;
data a;
   set a;
   if _n_=1 then set outest;
      lambda = pdf("NORMAL",Xbeta/_scale_)/ cdf("NORMAL",Xbeta/_scale_);
      Predict = cdf("NORMAL", Xbeta/_scale_)* (Xbeta + _scale_*lambda);
         label Xbeta="MEAN OF UNCENSORED VARIABLE"
               Predict = "MEAN OF CENSORED VARIABLE";
      drop lambda _scale_;
run;

data a;
   do i=1 to 15;
      x1=rannor(1);
      x2=rannor(2);
      y=2+3*x1+2*x2+rannor(3);
      output;
   end;
run;
/*the limit of left(lower) is 1, and limit of right(higher) is 7*/
data a;
   set a;
      if y<=1 then y=1;
      if y>=7 then y=7;
      if y=1 then lower=.;
      else lower=y;
      /*produce the lower limit*/
      if y=7 then higher=.;
      else higher=y;
      /*produce the higher limit*/
run;

proc lifereg data=a outest=outest(keep=_scale_);
   model (y,lower)=x1 x2/d=normal;
   output out=a(drop=censor _prob_) xbeta=xbeta;
quit;
data a;
   set a;
      if _n_=1 then set outest;
      lambda = pdf("NORMAL",Xbeta/_scale_)/ cdf("NORMAL",Xbeta/_scale_);
      Predict = cdf("NORMAL", Xbeta/_scale_)* (Xbeta + _scale_*lambda);
      label Xbeta="MEAN OF UNCENSORED VARIABLE"
            Predict = "MEAN OF CENSORED VARIABLE";
      drop lambda _scale_;
run;
data a;
   set a;
      keep i y x1 x2 higher lower;
run;
proc lifereg data=a outest=outest(keep=_scale_);
   model (lower,y)=x1 x2/d=normal;
   output out=a(drop=censor _prob_) xbeta=xbeta;
quit;
data a;
   set a;
      if _n_=1 then set outest;
      lambda = pdf("NORMAL",Xbeta/_scale_)/ cdf("NORMAL",Xbeta/_scale_);
      Predict = cdf("NORMAL", Xbeta/_scale_)* (Xbeta + _scale_*lambda);
      label Xbeta="MEAN OF UNCENSORED VARIABLE"
            Predict = "MEAN OF CENSORED VARIABLE";
      drop lambda _scale_;
run;
proc lifereg data=a ;
   model (lower,higher)=x1 x2/d=normal;
quit;

