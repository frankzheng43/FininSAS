
libname aa 'D:\The Application of SAS in Financial Research\CH02\data';
data aa.a;
do i=1 to 20;
a=rannor(1);
b=rannor(2);
c=rannor(3);
retain r1 0;
retain r2 0;
retain r3 0;
r1=1+a;
r2=a+b;
r3=a+b*c;
a=int(10*r1);
b=int(10*r2);
c=int(10*r3);
output;
keep a b c;
end;
run;

