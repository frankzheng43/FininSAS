libname aa "D:\The Application of SAS in Financial Research\SAS data\monthly price";

data a;
   set aa.price;
      month=y*100+m;
      date=mdy(m,1,y);
      format date yymon6.;
      if y<2000 then delete;
      if code=1101 or code=1102 or  code=2002 or code=2006 or code=2303 or code=2330 
      or code=2608 or code=2609 then output;
run;
proc sgpanel data=a;
   title "The pattern of return";
   panelby code ;
   series x=month y=ret;
run;
proc sgpanel data=a;
   title "The pattern of return";
   panelby code ;
   series x=date y=ret;
run;
proc sgpanel data=a;
   title "The pattern of return";
   panelby code /columns=4;
   series x=date y=ret;
run;
proc sgpanel data=a;
   title "The pattern of return";
   panelby code /columns=3 rows=3;
   series x=date y=ret;
run;
proc sgpanel data=a;
   title "The pattern of return";
   panelby code /columns=2 rows=4;
   series x=date y=ret;
run;

proc sgpanel data=a;
   title "The pattern of return";
   panelby code / columns=3 rows=3;
   series x=date y=ret;
   series x=date y=turn;
run;

data a1;
   set a;
      if y=2001 then output;
run;
proc sgplot data=a1;
   title "The pattern of return";
   series x=date y=ret/ group=code;
run;
proc sgplot data=a;
   title "The pattern of return";
   series x=date y=ret/ group=code;
run;



proc means data=a noprint;
   var mv turn;
   by code ;
   output out=b(drop=_type_ _freq_) mean=size turnover;
run;
proc rank data=b out=b groups=2;
   var size;
   ranks sizerank;
run;
proc sort data=b;by sizerank;
run;
proc rank data=b out=b groups=2;
   var turnover;
   ranks turnrank;
   by sizerank;
run;

proc sort data=b;by code;
run;
proc sort data=a;by code;
run;
data a;
   merge a b;by code;
run;
proc sgpanel data=a;
   panelby sizerank turnrank ;
   series x=date y=ret/group=code;
run;

proc format;
   value size 0="Small firm"
              1="Large Firm";
   value turn 0="Low Turnover"
		      1="High Turnover";
run; 
data a;
   set a;
      format sizerank size.; 
      format turnrank turn.;
run;
proc sgpanel data=a;
   panelby sizerank turnrank ;
   series x=date y=ret/group=code;
run;
options label;
data a;
   set a;
      label sizerank="Size";
      label turnrank="Volume";
      label date="date";
      label ret="Return (%)";
run;
proc sgpanel data=a;
   panelby sizerank turnrank ;
   series x=date y=ret/group=code;
run;

ods listing style=journal;
proc sgpanel data=a;
   panelby sizerank turnrank ;
   series x=date y=ret/group=code;
run;
