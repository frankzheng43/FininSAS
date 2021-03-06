libname aa 'D:\The Application of SAS in Financial Research\CH02\data';
data a;
   set aa.a;
run;
data b;
   set a;
      d=a+b;
      e=c-b;
      f=a*b;
      g=b/d;
      h=b**2;
      i=4;
      j=i**(0.5);
run;
data c;
   set b;
      a1=int(g);
      a2=mod(f,10);
      a3=round(g,0.01);
      a4=abs(g);
      a5=round(abs(g),0.01);
      a6=exp(f);
      a7=log(10);
      a8=log10(10);
      a9=lag(a);
      a10=lag2(a);
      a11=dif(a);
      a12=dif2(a);
run;

data a;
   set aa.b;
      a1=mean(col1,col2,col3,col4,col5)-1;
      a2=mean(of col1-col4)-1 ;
      a3=median(of col1-col4);
      a4=var(of col1-col4);
      a5=std(of col1-col4);
      a6=stderr(of col1-col4);
      a7=geomean(of col1-col3)-1;
      a8=(col1*col2*col3)**(1/3)-1;
      drop col1-col12	;
run;

data a;
   set aa.b;
      a1=n(of col1-col12);
      a2=nmiss(of col1-col12);
      a3=min(of col1-col4);
      a4=max(of col1-col4);
      a5=skewness(of col1-col4);
      a6=kurtosis(of col1-col12);
      a7=sum(of col1-col4);
      a8=n(of col1-col4);
      a9=a7/a8;
      drop col1-col12;
run;
