
data a;
input a $ 1-8 b $ 1-6;
datalines;
123456ab
1234abac
2ds12348
;
run;
data a;
   set a;
      a1=substr(a,1,6);
      a2=substr(a,6);
      a3=substr(a,7,2);
run;

data a;
input a $ 1-12 b $ 1-6;
datalines;
12345612    
12341111    
2ds12348    
;
run;
data a;
   set a;
      a=right(a);
run;
data a;
   set a;
      a1=substr(a,1,6);
      a2=substr(a,6);
      a3=substr(a,7,2);
run;
data a;
   set a;
      a1=left(a);
      a2=substr(a1,1,6);
run;

data a;
input a b;
datalines;
12 34
56 78
;
run;
data a;
   set a;
      c=a||b;
run;
data a;
   set a;
      c=b||"";
      d=left(c);
run;
data a;
   set a;
      c=a||d;
run;
data a;
   set a;
      c=left(a||left(b||""));
run;
