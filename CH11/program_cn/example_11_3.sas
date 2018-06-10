DM'LOG;CLEAR;OUT;CLEAR';
option nonotes;
libname aa 'D:\The Application of SAS in Financial Research\SAS data\four factor';
libname bb 'D:\The Application of SAS in Financial Research\SAS data\monthly price';
data a;
   set bb.price;
      mv=log(mv);
      mv2=mv**2;
      turn2=turn**2;
      mv_turn=mv*turn;
run;
proc sort data=a;by y m;
run;
proc reg noprint adjrsq data=a outest=b ;
   model ret=mv  turn  mv2  turn2  mv_turn ;
/*
第一个模型要放入所有的变项
*/
   model ret=mv ;
   model ret=turn;
   model ret=mv turn;
   model ret=mv turn mv2;
   model ret=mv turn turn2;
   model ret=mv turn mv_turn;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   by y m;
run;
quit;
proc sort data=b;by _model_;
run;
proc means noprint data=b ;
   var  intercept mv turn mv2  turn2 mv_turn _adjrsq_;
   by _model_;
   output out=mean(drop=_type_ _freq_);
run;

%macro FM(bit);
   proc transpose data=mean out=b;
      by _model_;
      id _stat_;
   run;
   data b;
      set b;
         t=mean/(std / (n**0.5) );
         if t^=. then tvalue='('||left(round(t,0.01)||')');
         if mean^=. then do;
            if _name_^='_ADJRSQ_' then do;
               if abs(t)>2.58 then esti=round(mean,10**-&bit)||'***';
               else if 2.58>=abs(t)>1.96 then esti=round(mean,10**-&bit)||'**';
               else if 1.96>=abs(t)>1.65 then esti=round(mean,10**-&bit)||'*';
               else esti=round(mean,10**-&bit)||'';
            end;
            else do;
               esti=round(mean*100,0.01)||'%';
            end;
        end;
        else do;
           delete;
        end;
        keep _model_ _name_ esti tvalue;
   run; 
   data t;
      set b;
         t=_n_;
         if _model_='MODEL1' then output;
         keep _name_ t;
   run;
   proc sort data=t;by _name_;
   run;
   proc sort data=b;by _name_;
   run;
   data b;
      merge b t;by _name_;
   run;
   proc sort data=b;by t _name_;
   run;
   proc transpose data=b out=esti;
      var esti;
      id _model_;
      by t _name_;
   run;
   proc transpose data=b out=tvalue;
      var tvalue;
      id _model_;
      by t _name_;
   run;
   data esti;
      set esti;
         type=1;
   run;
   data tvalue;
      set tvalue nobs=x;
      if t=x then delete;
      type=2;
      _name_='';
   run;
   data FM;
      set esti tvalue;by t type;
      drop t type model1;
   run;
%mend;
%fm(4);
proc export data=FM
   outfile='D:\The Application of SAS in Financial Research\CH11\EXCELoutput\FM'
   dbms=xlsx
   replace;
run;



proc reg noprint adjrsq data=a outest=b ;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   model ret=mv ;
   model ret=turn;
   model ret=mv turn;
   model ret=mv turn mv2;
   model ret=mv turn turn2;
   model ret=mv turn mv_turn;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   by y m;
quit;
proc sort data=b;by _model_;
run;
proc means noprint data=b ;
   var  intercept mv turn mv2  turn2 mv_turn _adjrsq_;
   by _model_;
   output out=mean(drop=_type_ _freq_);
run;

%include 'D:\The Application of SAS in Financial Research\CH11\program_cn\FM.sas';

%fm(4);
proc export data=FM
   outfile='D:\The Application of SAS in Financial Research\CH11\EXCELoutput\FM2'
   dbms=xlsx
   replace;
run;
