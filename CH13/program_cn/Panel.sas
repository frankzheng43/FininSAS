%macro panel(file,y,x,firm,time,bit);
   proc sort data=&file;by   &firm &time;
   run;
   proc sql;
      create table n as select
      &firm,count(&y) as n
      from &file
      group by &firm;
   quit;
   data &file;
      merge &file n;by &firm;
   run;
   proc reg data=&file(where=(n>1)) adjrsq;
      model &y=&x;
      ods output
      ParameterEstimates=OLS
      FitStatistics=rols;
   run;
   data ols;
      set ols;
         method='Pooled OLS';
         varname=variable;
         drop dependent variable;
   run;
   data rols;
      set rols;
         method='Pooled OLS';
         varname=label2; 
         rsq=round(nvalue2*100,0.01)||'%';
         keep method varname rsq;
         if varname='R ��' then output;
   run;

   proc panel data=&file (where=(n>1)) ;
      model &y=&x/ ranone rantwo  bp2;
      id &firm &time;
      ods output 
      ParameterEstimates=ran
      RandomEffectsTest=random
      BreuschPaganTest2=BP2
      FitStatistics=rran;
   run;
   data rran;
      set rran;
         varname=label1;
         rsq=round(nvalue1*100,0.01)||'%';
         keep method varname rsq;
         if varname='R ��' then output;
   run;

   proc panel data=&file (where=(n>1)) ;
      model &y=&x/ fixone fixtwo;
      id &firm &time;
      ods output 
      ParameterEstimates=fix
      FitStatistics=rfix;
   run;
   data fix;
      set fix;
         if label='Intercept' or label='' then output;
         drop label;
   run;
   data rfix;
      set rfix;
         varname=label1;
         rsq=round(nvalue1*100,0.01)||'%';
         keep method varname rsq;
         if varname='R ��' then output;
   run;
   proc sort data=&file;by &time &firm;
   run;
   proc panel data=&file (where=(n>1)) ;
      model &y=&x/ fixone;
      id  &time &firm;
      ods output 
      ParameterEstimates=fixtime
      FitStatistics=rtime;
   run;
   data fixtime;
      set fixtime;
         method='Fixtime';
         if label='Intercept' or label='' then output;
         drop label;
   run;
   data rtime;
      set rtime;
         method='Fixtime';
         varname=label1;
         rsq=round(nvalue1*100,0.01)||'%';
         keep method varname rsq;
         if varname='R ��' then output;
   run;
   data par;
      set ols ran fix fixtime;
   run;
   proc sort data=par;by df;
   run;
   data bp2;
      set bp2;
         df=1;
         bp=mvalue;
         prob_bp=prob;
         keep df bp prob_bp;
         if _n_=1 then output;
   run;
   data random;
      set random;
         df=1;
         drop model method;
   run;
   data par;
      merge par bp2 random;by df;
         retain n 0;
         n=n+1;
         if method^=lag(method) then n=1;
         if probt<=0.01 then esti=round(estimate,10**-&bit)||'***';
         else if 0.01<probt<=0.05 then esti=round(estimate,10**-&bit)||'**';
         else if 0.05<probt<=0.1 then esti=round(estimate,10**-&bit)||'*';
         else esti=round(estimate,10**-&bit)||'';
         if prob_bp<=0.01 then LM=round(bp,10**-2)||'***';
         else if 0.01<prob_bp<=0.05 then LM=round(bp,10**-2)||'**';
         else if 0.05<prob_bp<=0.1 then LM=round(bp,10**-2)||'*';
         else LM=round(bp,10**-2)||'';
         if prob<=0.01 then Hausman=round(mvalue,10**-2)||'***';
         else if 0.01<prob<=0.05 then Hausman=round(mvalue,10**-2)||'**';
         else if 0.05<prob<=0.1 then Hausman=round(mvalue,10**-2)||'*';
         else Hausman=round(mvalue,10**-2)||'';
         t='('||left(round(tvalue,0.01)||')');
         if prob_bp>0.05 then select='OLS';
         if prob_bp<=0.05 and prob>0.05 then select='Ran';
         if prob_bp<=0.05 and prob<=0.05  then select='Fix';
   run; 
   proc sort data=par;by n varname method;
   run;
   proc sort data=par out=pp nodupkey;by method;
   run;
   proc transpose data=par out=esti;
      var esti;
      id method;
      by n varname;
   run;
   proc transpose data=par out=tvalue;
      var t;
      id method;
      by n varname;
   run;
   proc transpose data=pp out=select;
      var lm hausman select;
      id method;
   run;
   data select;
      set select;
         varname=_name_;
   run;
   proc format;
      value fixed 1='YES' 0='NO';
   run;
   data rsq;
      set rols rfix rtime rran;
      if method='Pooled OLS' then firm=0;
      if method='FixOne' then firm=1;
      if method='FixTwo' then firm=1;
      if method='Fixtime' then firm=0;
      if method='RanOne' then firm=1;
      if method='RanTwo' then firm=1;
      if method='Pooled OLS' then time=0;
      if method='FixOne' then time=0;
      if method='FixTwo' then time=1;
      if method='Fixtime' then time=1;
      if method='RanOne' then time=0;
      if method='RanTwo' then time=1;
      format firm fixed. time fixed.;
   run;
   proc transpose data=rsq out=rsq;
      var firm time  rsq;
      id method;
   run;
   data rsq;
      set rsq;
      varname=_name_;
   run;
   data esti;
      set esti;
         type=1;
   run;
   data tvalue;
      set tvalue;
         type=2;
   run;
   data esti;
      set esti tvalue;by n type;
   run;
   data Panel_data;
      set esti rsq select;
         if type=2 then varname='';
         drop n type _name_;
   run;
   proc delete data=ran random fix fixtime esti tvalue rsq select rols rfix rtime rran format par pp bp2 ;
   quit;
%mend;
