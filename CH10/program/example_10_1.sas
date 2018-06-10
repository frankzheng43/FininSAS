option nonotes;
libname aa "D:\The Application of SAS in Financial Research\CH10\data";

data a;
   set aa.price;
      if  y=2006 then output;
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
      if n=12 then output;
run;
data code;
   set a;
      d=1;
      if code=lag(code) then delete;
      keep code d;
run;
%macro diver;
   %do i=1 %to 200;
      proc surveyselect data=code out=b noprint
      method=srs n=&i seed=0 rep=1;
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
      proc corr data=ret1 cov outp=cov noprint;
         var col1-col&i;
      run;
      data cov;
         set cov;
            n=_n_;
            v=sum(of col1-col&i);
            retain var 0;
            var=var+v; 
            std=((var)/n**2)**0.5;
            if _n_=&i then output;
            keep n std;
      run;
      proc append data=cov base=diver;
      run;
   %end;
%mend diver;

proc datasets noprint;
delete diver;
quit;
%diver;

goptions device=gif gsfname=gout xpixels=960 ypixels=720
ftext="Arial" htext=2 gunit=pct ctext=black csymbol=black;
axis order=(0 to 200 by 20) ;
filename gout "D:\The Application of SAS in Financial Research\CH10\output\portfolio.gif";

proc gplot data=diver;
symbol interpol=join value=dot;
   plot std*n /  
                    hminor=1
                    vminor=1
                    lvref=1
                    cvref=black
                    caxis=black
                    ctext=black;
run;
quit;


%macro diversify(k);
   proc datasets;
      delete diver;
   quit;
   %do l=1 %to &k;
      %diver;
   %end;
   proc sort data=diver;by n;
   run;
   proc means noprint data=diver;
      var std;by n;
      output out=diver mean=std;
   run;
   goptions device=gif gsfname=gout xpixels=960 ypixels=720
   ftext="Arial" htext=2 gunit=pct ctext=black csymbol=black;
   filename gout "D:\The Application of SAS in Financial Research\CH10\output\portfolio&k..gif";
   proc gplot data=diver;
   symbol interpol=join value=dot;
   plot std*n /  
                    hminor=1
                    vminor=1
                    lvref=1
                    cvref=black
                    caxis=black
                    ctext=black;
   run;
   quit;
%mend diversify;
%diversify(2);
%diversify(5);
%diversify(10);
%diversify(20);
%diversify(30);
%diversify(50);
%diversify(100);

