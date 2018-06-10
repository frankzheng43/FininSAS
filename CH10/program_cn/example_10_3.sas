option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\CH10\data";
data a;
   set aa.price;
      if mv=. then delete;
      if ret=. then delete;
      ret=1+0.01*ret;
      month=y*100+m;
      keep  code ret mv month;
run;
%macro ret(file, firm,ret,time,J,group);
   proc sort data=&file;by &firm &time;
   run;
   %do i=1 %to &j;
      data &file;
         set &file;
            r&i=lag&i(ret);
            j&i=(geomean(of r1-r&j)-1)*100;
            if &firm^=lag&i(&firm) then j&i=.;
      run;
   %end;
      proc sort data=&file out=&file(drop=r1-r&j) ;by &time;
      run;
      proc rank data=&file out=&file groups=&group;
         var j1-j&j;
         ranks Jrank1-Jrank&j;
         by &time;
      run;
%mend;
%ret(a,code, ret, month, 12,10);
data ret;
   set a;
      keep month code ret mv;
run;
proc sort data=ret;by code month;
run;
data ret;
   set ret;
      mv1=mv;
      mv=lag(mv);
      if code^=lag(code) then mv=.;
run;
proc sort data=ret;by code descending month;
run;
data ret;
   set ret;
      ret1=lag(ret);
      if code^=lag(code) then ret1=.;
run;
proc sort data=ret out=month(keep=month) nodupkey;by month;
run;
proc sort data=ret;by month;
run;
data month;
   set month;
      t=_n_;
run;
data ret;
   merge ret month;by month;
run;
data ret;
   set ret;
      do i=1 to t;
         if t-59<=i<=t then output;
         h=t-i;
         drop t;
      end;
run;
proc sort data=ret;by i code;
run;
data month;
   set month;
      rename t=i;
run;
data a;
   merge a month;by month;
      drop ret;
run;
proc sort data=a;by i code;
run;
data final;
   merge a ret;by i code;
      if h=. then delete;
run;
%macro hold(file,j,group,bit);
   proc sort data=&file;by jrank&j i h;
   run;
   proc means noprint data=&file;
      var ret ret1;
      by jrank&j i h;
      output out=ew(drop=_type_ _freq_) mean=ewr ewr1;
   run;
   proc means noprint data=&file;
      var ret ;
      weight mv;
      by jrank&j i h;
      output out=vw(drop=_type_ _freq_) mean=vwr ;
   run;
   proc means noprint data=&file;
      var ret1 ;
      weight mv1;
      by jrank&j i h;
      output out=vw1(drop=_type_ _freq_) mean=vwr1 ;
   run;
   proc transpose data=ew out=ewr;
      var ewr;
      id h;
      by jrank&j i ;
   run;
   proc transpose data=ew out=ewr1;
      var ewr1;
      id h;
      by jrank&j i ;
   run;
   proc transpose data=vw out=vwr;
      var vwr;
      id h;
      by jrank&j i ;
   run;
   proc transpose data=vw1 out=vwr1;
      var vwr1;
      id h;
      by jrank&j i ;
   run;
   data hold;
      set ewr ewr1 vwr vwr1;
         if jrank&j=. then delete;
         j=jrank&j+1; 
         k1=(_1-1)*100;
         if nmiss(of _1-_3)=0 then k3=(geomean(of _1-_3)-1)*100;
         if nmiss(of _1-_6)=0 then k6=(geomean(of _1-_6)-1)*100;
         if nmiss(of _1-_9)=0 then k9=(geomean(of _1-_9)-1)*100;
         if nmiss(of _1-_12)=0 then y1=(geomean(of _1-_12)-1)*100;
         if nmiss(of _13-_24)=0 then y2=(geomean(of _13-_24)-1)*100;
         if nmiss(of _25-_36)=0 then y3=(geomean(of _25-_36)-1)*100;
         if nmiss(of _37-_48)=0 then y4=(geomean(of _37-_48)-1)*100;
         if nmiss(of _49-_60)=0 then y5=(geomean(of _49-_60)-1)*100;
         if nmiss(of _13-_60)=0 then yh4=(geomean(of _13-_60)-1)*100;
         return=_name_;
         portfolio="p"|| left(j);
   run;
   proc sort data=hold;by i return;
   run;
   proc transpose data=hold out=h;
      var k1 k3 k6 k9  y1-y5 yh4;
      id portfolio;
      by i return;
   run;
   data h;
      set h;
         mom=p&group-p1;
         k=_name_;
   run;
   proc sort data=h;by return k;
   proc means noprint data=h;
      var p1-P&group mom;
      by return k;
      output out=b;
   run;
   proc transpose data=b out=b;
      var p1-p&group mom;
      by return k;
      id _stat_;
   run;
   data b;
      set b;
         t=mean/(std/(n)**0.5);
         tvalue="("||left(round(t,0.01)||")");
         if abs(t)>2.58 then r=round(mean, 10**-&bit)||"***";
         else if 2.58>=abs(t)>1.96 then r=round(mean, 10**-&bit)||"**";
         else if 1.96>=abs(t)>1.65 then r=round(mean, 10**-&bit)||"*";
         else r=round(mean, 10**-&bit)||"";
   run;
   proc sort data=b;by return k;
   run;
   proc transpose data=b out=mean(drop=_name_);
      var r;
      by return k;
   run;
   proc transpose data=b out=tvalue(drop=_name_);
      var tvalue;
      by return k;
   run;
   proc transpose data=mean out=mean;
      var p1-p&group mom;
      by return;
      id k;
   run;
   proc transpose data=tvalue out=tvalue;
      var p1-p&group mom;
      by return;
      id k;
   run;
   data mean;
      set mean;
         retain t 0;
         t=t+1;
         type=1;
   run;
   data tvalue;
      set tvalue;
         retain t 0;
         t=t+1;
         type=2;
   run;
   data j&j;
      set mean tvalue;by t type;
         if type=2 then _name_="";
         drop t type;
   run;
%mend;
%hold(final,3,10,3);
%hold(final,6,10,3);
%hold(final,9,10,3);
%hold(final,12,10,3);
