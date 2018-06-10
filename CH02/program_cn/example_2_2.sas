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
      format  month yymon7.   /*yymonw. w�ĳ�����5 7  ���д��monyyw.*/ 
              yyq yyq.  /* yyqw. w�ĳ��ȿ�����4  5  6  10*/;

run; 
data a;
   set a;
      format  date yymmddd8.;
run;
 /* yymmddxw    mmddyyxw    ddmmyyxw    �����տ��������ְڷ�
     x����������ڵ������ʽ  ��  B C D N P S
     wΪ������󳤶ȸ��ݲ�ͬ�������ʽ��2-10
     ���ǲ���Ϊ�е������ʽ�������2-10λ
*/

/*�Ȳ���һ���ض�������*/
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
	  /*�ڴ˴�  SAS���Ա��� year qtr month week�ĵ���
        ����qtr Qtr qTr qtR QTr qTR Qtr QTR ���ܱ���Ϊ��
	  */
run;



