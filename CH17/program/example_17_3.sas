option nonotes nolabel;
libname aa "D:\The Application of SAS in Financial Research\CH17\data";
data a;
   set aa.month_return;
run;
proc sort data=a;by stkcd year month;
run;
data a;
   set a;by stkcd;
      retain age 0;
         age=age+1;
      if first.stkcd then age=1;
      keep year month stkcd mv ret age;
run;
data mv;
   set a;
      if month=6  then output; 
      keep year stkcd mv;
run;
proc sort data=mv;by year stkcd;
run;
/*Fama and French 1993  require the compustat data must exist two year*/
proc sort data=aa.finance out=fin;by stkcd year;
run;
data fin;
   set fin;
      Inv=dif(asset)/lag(asset);
      book=sum(equity,-prefer_stk);
      if stkcd^=lag(stkcd) then inv=.;
      if dif(year)^=1 then inv=.;
      if book>0 and inv^=. and op^=.;
run;

proc sql;
   create table finance as select
      a.stkcd, a.year+1 as year,b.book/a.mv as BM,b.inv,b.op
     /*
      merge the financial statement in t-1 with the mv in t
     */
   from a, fin b
   where a.stkcd=b.stkcd and a.month=b.month and a.year=b.year and a.age>=24;
   create table final as select
      a.stkcd, a.year, a.mv,b.bm, b.op,b.inv
   from mv a,finance b
   where a.stkcd=b.stkcd and a.year=b.year
   order by a.year;
quit;
proc rank data=final out=final groups=10;
   var mv bm op inv;
   by year;
   ranks mvr bmr opr invr;
run;
data final;
   set final;
      bmr=bmr+1;
      mvr=mvr+1;
      opr=opr+1;
      invr=invr+1;
      if bmr<=3 then b="L";
      else if bmr<=7 then b="M";
      else b="H";
      if opr<=3 then R="W";
      else if opr<=7 then R="M";
      else R="R";
      if invr<=3 then C="C";
      else if invr<=7 then C="M";
      else C="A";
      if mvr<=5 then s="S";
      else s="B";
      SB=s||b;
      SC=s||c;
      SR=s||r;
   keep year stkcd   SB SC SR;
run;
data final;
   set final;
      do month=1 to 12;
         output;
      end;
run;
data final;
   set final;
      if month<=6 then year=year+1;
run;
proc sort data=final;by  stkcd year month;
run;

%macro mom;
   data mom;
      set a;
         ret=1+0.01*ret;
            %do i=2 %to 12;
               r&i=lag&i(ret);
            %end;
         pr=geomean(of r2-r12);
         if nmiss(of r2-r12)>0 then pr=.;
         if code^=lag12(code) then delete;
   run;
   proc sort data=mom;by year month;
   run;
   proc rank data=mom out=mom groups=10;
      var pr;
      ranks prr;
      by year month;
   run;
   proc sort data=mom;by stkcd year month;
   run;
   data mom;
      set mom;by stkcd;
         prr=lag(prr);
         if first.stkcd then prr=.;
         prr=prr+1;
         if prr<=3 then p="L";
         if prr>=8 then p="W";
         if p="" then delete;
         keep year month stkcd p;
   run;
%mend;
%mom;
%macro factor(firm,time,weight,in,out);
   proc sort data=&in out=ss;by &firm &time;
   run;
   data ss;
      set ss;by &firm;
         &weight=lag(&weight);
         if first.&firm then delete;
   run;
   data ss;
      merge ss final;by &firm year month;
   run;
   proc sort data=ss;by &time sb; 
   run;
   proc means noprint data=ss(where=(sb^=""));
      var ret;
      weight &weight;
      by &time sb;
      output out=sb(drop=_type_ _freq_) mean=ret;
   run;
   proc transpose data=sb out=sb;
      var ret;
      id sb;
      by &time;
   run;

   data sb;
      set sb;
	     /*revise  20150626*/
         SMB_BM=1/3*(sh+sm+sl-bh-bm-bl);
         HML=1/2*(sh+bh-sl-bl);
         keep &time SMB_BM hml;
         if SMB_BM=. then delete;
		 /*revise  20150626*/
   run;

   proc sort data=ss;by &time sr;
   run;
   proc means noprint data=ss(where=(sr^=""));
      var ret;
      weight &weight;
      by &time sr;
      output out=sr(drop=_type_ _freq_) mean=ret;
   run;
   proc transpose data=sr out=sr;
      var ret;
      id sr;
      by &time;
   run;
   data sr;
      set sr;
	     /*revise  20150626*/
	     SMB_OP=1/3*(sR+sm+sW-bR-bm-bW);
         RMW=1/2*(sr+br-sw-bw);
         keep &time SMB_OP RMW;
         if RMW=. then delete;
		  /*revise  20150626*/
   run;

   proc sort data=ss;by &time sc;
   run;
   proc means noprint data=ss(where=(sc^=""));
      var ret;
      weight &weight;
      by &time sc;
      output out=sc(drop=_type_ _freq_) mean=ret;
   run;
   proc transpose data=sc out=sc;
      var ret;
      id sc;
      by &time;
   run;
   data sc;
      set sc;
	  	 /*revise  20150626*/
	     SMB_INV=1/3*(sC+sm+sA-bC-bm-bA);
         CMA=1/2*(sc+bc-sa-ba);
         keep &time SMB_INV CMA;
         if CMA=. then delete;
		 /*revise  20150626*/
   run;

   proc sort data=&in out=ss;by &firm &time;
   run;
   data ss;
      merge ss mom;by &firm year month;
   run;
   proc sort data=ss;by &time p;
   run;
   proc means noprint data=ss;
      var ret;
      by &time p;
      output out=carhart mean=ret;
   run;
   proc transpose data=carhart out=carhart;
      var ret;
      id p;
      by &time;
   run;
   data carhart;
      set carhart;
         MOM=W-L;
         keep &time MOM;
   run;
   data &out;
      merge  sb sr sc   carhart;by &time;
	  	 /*revise  20150626*/
	     SMB=(SMB_bm+SMB_op+SMB_INV)/3;
         if nmiss(smb,hml,rmw,cma,mom)=0 then output;
		 DROP SMB_BM SMB_OP SMB_INV;
		 /*revise  20150626*/
   run;

%mend;
%factor(stkcd,year month,mv, a, six_month);
proc sort data=aa.mrmrf;by year month;
run;
data six_month;
   merge aa.mrmrf six_month;by year month;
      if hml=. then delete;
run;
data a;
   set aa.daily_return;
      keep stkcd year month day ret mv;
run;
%factor(stkcd,year month day,mv,a,six_daily);
proc sort data=aa.drmrf;by year month day;
run;
data six_daily;
   merge aa.drmrf six_daily;by year month day;
      if hml=. then delete;
run;
