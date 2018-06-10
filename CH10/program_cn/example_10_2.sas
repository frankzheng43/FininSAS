option nonotes;
libname aa "D:\The Application of SAS in Financial Research\CH10\data";
data a;
   set aa.price;
      if  y=2006 then output;
      if y=2005 then output;
      keep y m code ret;
run;
proc sort data=a;by code y m;
run;
proc means noprint data=a;
   var ret;by code;
   output out=b(drop=_type_ _freq_) n=n;
run;
data a;
   merge a b;by code;
      if n=24 then output;
run;
data code;
   set a;
      d=1;
      if code=lag(code) then delete;
      keep code d;
run;
proc surveyselect data=code out=b noprint
   method=srs n=15 seed=1 rep=1;
run;
data ret;
   merge a b;by code;
      if d=. then delete;
run;
proc sort data=ret;by  y m code;
run;
proc transpose data=ret out=ret1;
   var ret;
   by y m;
run;
proc corr data=ret1 cov outp=b noprint;
   var col1-col15;
run;
data covariance mean ;
   set b;
      if _type_="COV" then output covariance;
      if _type_="MEAN" then output mean;
      drop _type_ _name_;
run; 

%macro efficient;
   %do i=101%to 150;
      proc iml;
         use covariance var _all_;
         read all into cov;
         use mean var _all_;
         read all into ret;
            return=&i*0.01;
            rp=return||1;
            r=(ret`)||repeat(1,nrow(cov),1);
            w=inv(cov)*r*inv(r`*inv(cov)*r)*rp`;
            var=(return || sqrt(w`*cov*w));
            varnames={ret std};
            create var from var [colname=varnames ]; 
            append from var;
      quit;
      proc append data=var base=eff force;
      quit;
	%end;
%mend efficient;
proc datasets noprint;
   delete eff;
quit;
%efficient;
goptions device=gif gsfname=gout xpixels=960 ypixels=720
ftext="Arial" htext=2 gunit=pct ctext=black csymbol=black;
filename gout "D:\The Application of SAS in Financial Research\CH10\output\efficient.gif";
proc gplot data=eff;
symbol interpol=j value=none;
   plot ret*std /  
                    hminor=1
                    vminor=1
                    lvref=1
                    cvref=black
                    caxis=black
                    ctext=black;
run;quit;

