data date;
   infile "D:\The Application of SAS in Financial Research\CH02\data\date.txt" firstobs=2;
       input date  yymmddn8. ;
run;


data a;
   set date;
      y=year(date);
      m=month(date);
      d=day(date);
      q=qtr(date);
      w=week(date);
      wday=weekday(date);
      yyq=yyq(y,q);
      newdate=mdy(m,d,y);
      month=mdy(m,1,y);
run;

data a;
   set a;
      format  month yymon7.   /*yymonw. w的长度是5 7  亦可写成monyyw.*/ 
              yyq yyq.  /* yyqw. w的长度可以是4  5  6  10*/;

run; 
data a;
   set a;
      format  date yymmddd8.;
run;
 /* yymmddxw    mmddyyxw    ddmmyyxw    年月日可以有三种摆法
     x代表的是日期的输出格式  有  B C D N P S
     w为变项最后长度根据不同的输出格式有2-10
     但是并非为有的输出格式都能输出2-10位
*/

/*先产生一个特定的生日*/
data a;
   do m=1 to 12;
      do d=1 to 5;
         birthday=mdy(2,1,1980);
         date=mdy(m,d,1990);
         if date^=. then output;
      end;
   end;
run;

data a;
   set a;
      age=intck("year",birthday,date);
      qtr=intck("qtr",birthday,date);
	  qtr1=intck("Qtr",birthday,date);
	  qtr2=intck("qTr",birthday,date);
	  qtr3=intck("qtR",birthday,date);
      month=intck("month",birthday,date);
      week=intck("week",birthday,date);
      day=date-birthday;
	  /*在此处  SAS可以辨认 year qtr month week的单词
        例如qtr Qtr qTr qtR QTr qTR Qtr QTR 都能辨认为季
	  */
run;



