%macro tab(data, var1, var2);

proc freq data=&data;
 tables &var1*&var2;
 ods output crosstabfreqs=one;
 run;
 
 proc sort; by &var1;run;
  
 proc transpose data=one out=tmp; by &var1; 
 var &var2 frequency ColPercent rowpercent;
 run;
 

 data _null_;
    set tmp;
    if _n_=2 then do;
        call symput("n1", compress(col1));
        call symput("n2", compress(col2));
        call symput("n3", compress(col3));
        call symput("n4", compress(col4));
        call symput("n5", compress(col5));    
     end;
 run;
 
 %let n=%eval(&n1+&n2+&n3+&n4+&n5);


 data surg;
    merge tmp(where=(_name_='Frequency')) 
          tmp(where=(_name_='ColPercent') rename=(col1=cp1 col2=cp2 col3=cp3 col4=cp4 col5=cp5)) 
          tmp(where=(_name_='RowPercent') rename=(col1=rp1 col2=rp2 col3=rp3 col4=rp4 col5=rp5)) ; 
          by surg;
          col6=sum(of col1-col5);
          cp6=col6/&n*100;
          drop _NAME_   _LABEL_  ;
          c1=col1||"("||compress(put(cp1,4.1))||"%)";
          c2=col2||"("||compress(put(cp2,4.1))||"%)";
          c3=col3||"("||compress(put(cp3,4.1))||"%)";
          c4=col4||"("||compress(put(cp4,4.1))||"%)";
          c5=col5||"("||compress(put(cp5,4.1))||"%)";
          c6=col6||"("||compress(put(cp6,4.1))||"%)";
          if surg=" " then delete;
 run;

ods rtf file="surg.rtf" style=journal bodytitle;
proc print data=surg noobs label split="*" style(header) = [just=center];
title "Table1: Baseline Demographic and Clinical Characteristics by Treatment";
Var surg /style(data)=[cellwidth=1.5in just=left];
var c1-c6 /style(data) = [cellwidth=0.8in just=center] ;
label  surg="."
       c1="Emory*(n=&n1)"   
       c2="Miriam*(n=&n2)"
       c3="Colorado*(n=&n3)"
       c4="Vanderbilt*(n=&n4)"
       c5="Wisconsin*(n=&n5)"
       c6="Total*(n=&n)"
		;
run;

ods rtf close;
 
%mend tab;
