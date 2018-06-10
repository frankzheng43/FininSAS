
%macro tobit(lower,higher,x,bit);
   data a;
      set a;
         drop xbeta predict lambda;
      run;
   proc lifereg data=a outest=b(keep=_scale_);
      model (&lower, &higher) = &x / d=normal maxiter=2000;
      output out=a(drop=censor _prob_) xbeta=xbeta;
      ods output ParameterEstimates=para
   quit;
   data a;
      set a;
         if _n_=1 then set b;
         lambda = pdf('NORMAL',Xbeta/_scale_)/ cdf('NORMAL',Xbeta/_scale_);
         Predict = cdf('NORMAL', Xbeta/_scale_)* (Xbeta + _scale_*lambda);
         drop  _scale_ ;
   run;
   data para;
      set para;
         retain t 0;
            t=t+1;
         model='Model';
         if ProbChiSq<=0.01 then par=round(estimate,10**-&bit)||'***';
         else if 0.01<ProbChiSq<=0.05 then par=round(estimate,10**-&bit)||'**';
         else if 0.05<ProbChiSq<=0.1 then par=round(estimate,10**-&bit)||'*';
         else  par=round(estimate,10*-&bit)||'';
         tvalue='('||left(round(estimate/stderr,0.01)||')');
         if parameter='Scale' then delete;
   run;
   proc transpose data=para out=esti;
      var par ;
      by t parameter;
      id model;
   run;
   proc transpose data=para out=tvalue;
      var tvalue ;
      by t parameter;
      id model;
   run;
   data tobit;
      set esti tvalue;by t _name_;
         if _name_='tvalue' then parameter='';
         drop t _name_;
   run;
%mend;




