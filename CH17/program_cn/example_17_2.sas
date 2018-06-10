DM"LOG;CLEAR;OUT;CLEAR";
option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\SAS data\four factor";
libname bb "D:\The Application of SAS in Financial Research\SAS data\monthly price";
data a;
   set bb.price;
      mv=log(mv);
      mv2=mv**2;
      turn=turn*0.01;
      turn2=turn**2;
      mv_turn=mv*turn;
run;
proc sort data=a;by y m;
run;
proc rank groups=2 out=a;
var ret;
ranks retr;by y m;
run;
proc sort;by y m retr;
proc means noprint data=a;
var ret mv mv2 turn turn2 mv_turn;
by y m retr;
output out=a mean= ret mv mv2 turn turn2 mv_turn;
run;
data a;
   set a;
      if retr=. then delete;
      drop _type_ _freq_;
run;

proc reg data=a  ;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   model ret=mv ;
   model ret=turn;
   model ret=mv turn;
   model ret=mv turn mv2;
   model ret=mv turn turn2;
   model ret=mv turn mv_turn;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   ods output ParameterEstimates=reg;
quit;
proc surveyselect data=a out=boot noprint
method=urs rep=10000 rate=1 seed=1;
run;

proc reg data=boot noprint outest=b;
   model ret=mv  turn  mv2  turn2  mv_turn ;
   model ret=mv ;
   model ret=turn;
   model ret=mv turn;
   model ret=mv turn mv2;
   model ret=mv turn turn2;
   model ret=mv turn mv_turn; 
   model ret=mv  turn  mv2  turn2  mv_turn ;
   by replicate;
   freq numberhits;
quit;

proc sort data=b;by _model_;
run;
proc means noprint data=b;
var  intercept mv turn mv2  turn2 mv_turn ;
by _model_;
output out=b1 std= Intercept mv turn mv2  turn2 mv_turn ;
run;


%let bit=3;
data b1;
   set b1;
      model=_model_;
      drop _type_ _freq_ _model_;
run;
proc transpose data=b1 out=b2 ;
by model;
run;
data a;
   set reg;
      keep model variable estimate;
run;
data b;
   set b2;
      variable=_name_;
      if col1=. then delete;
   keep model variable col1;
run;
data a;
   merge a b;
      est=round(estimate,10**(-1*&bit));
      tvalue=round(estimate/col1,0.01);
      if abs(tvalue)>=2.58 then sig="***";
      if 2.58>abs(tvalue)>=1.96 then sig="**";
      if  1.96>abs(tvalue)>=1.65 then sig="*";
      a=")";
      esti=est||sig;
      tv="("||     left   (tvalue||a)    ;
   keep model variable esti tv;
run;

data t;
   set a;
      retain t 0;
         t=t+1;
      if model="MODEL1" then output;
      keep variable t;
run;
proc sort;by variable;
run;
proc sort data=a;by variable;
run;
data a;
   merge a t;by variable;
run;
proc sort data=a;by  t variable;
run;
proc transpose data=a out=boot_ols;
var   esti tv;
id model;
by t variable;
run;

data boot_ols;
   set boot_ols;
      if _name_="tv" then variable="";
      drop t type _name_ model1;
run;

proc export data=boot_ols
outfile="D:\The Application of SAS in Financial Research\CH17\output\boot"
dbms=xlsx
replace;
run;

