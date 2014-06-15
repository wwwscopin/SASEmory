/* line plots */

* turn macros on;
 proc options option = macro;  
 run;


%include "&include/annual_toc.sas";

*%include "style.sas";

libname cmv_rep "/ttcmv/sas/programs/reporting";


proc format;

value visit
1='1'
2='4'
3 ='7'
4='14'
5='21'
6='28'
7='40'
8=''
;

run;



data review; set cmv.med_review;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;



data review; set review;
if dfseq=1 then visit=1;
if dfseq=4 then visit=2;
if dfseq=7 then visit =3;
if dfseq=14 then visit =4;
if dfseq=21 then visit=5;
if dfseq = 28 then visit=6;
if dfseq=40 then visit=7;

label Hb="Hb" Weight="Weight"  HeadCircum="Head Circum" HtLength="Height/Length";
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 
data review2; 
set review; 
output; 
center = 0; 
output; 
run; 

proc greplay    igout= cmv_rep.graphs  nofs; 
delete _all_; 
run; 


* turn macros on;
 proc options option = macro;  
 run;



goptions reset = all;
%macro line_plot (data= ,var = , label = , studygroup=, orderlow=, orderhigh=,orderby=,n=); 
%do out=1 %to 1;
proc sql; 
select max(&var) into : max from &data ; 
select min(&var) into : min from &data ; 
run;quit; 
%let max1 = &max; 
%let min1 = %sysevalf(&min -1 , int); 
%let y =&max1-&min1; 
%let y =%sysevalf(&max1 + 1, int); 

%let byvalue1 = %sysevalf(&y) ; 
%let x= 10; 
%let byvalue3 = %sysevalf(&byvalue1/&x); 
%if &out = 1 %then %let study="Overall"; 
%else %if &out = 2 %then %let study="Intervention (LPV/r + RAL)"; 

ods pdf file = "/ttcmv/sas/progams/reporting/neeta.pdf";
goptions reset = all; 



goptions gunit=pct htitle=5 htext=3   ftitle=swissb ftext= swissb;
goptions border;





 axis1 order=(0 to 8 by 1) value=(    "" "1" "4" "7" "14" "21" "28" "40"  "") label=(  j=center  "Age ( days )"  ) minor=none offset=(0,0)  major=none split="_";
axis2 order=(&orderlow to &orderhigh by &orderby) minor=none offset=(0,0) label=(  j=center a=90 "&label"  ) major=(height=.7) minor=(number=2 h=1);

symbol1 value = dot h=1.0 i=join repeat = 200; 

title1 ls=1.5  "&label over time";
title2 h=8 " ";

title3 a=90 h=1pct "";
title4 a=-90 h=18pct " ";

footnote h=17pct " ";

proc gplot data=&data   gout= cmv_rep.graphs; 

plot &var*visit=id / name ="&n&out" nolegend noframe haxis=axis1 vaxis=axis2  /* annotate=linetext*/;
format visit visit.;

run;
ods pdf close;
quit; 
%end;
%mend;



 
%line_plot(data=review ,var=hb, label=Hb (mg/dL) , studygroup=1, orderlow=5, orderhigh=50,orderby=5, n=Hb); 



