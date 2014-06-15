*1--add 8 new variables;

options nocenter nodate nonumber;
libname hw 'p:\bio113\hw';
data hw.ivh2;
set hw.ivh1;
drop i;
array mdif(2,3) ccdif1-ccdif3 wtdif1-wtdif3;
array mcab(2,4) cc1-cc4 pctwt1-pctwt4;

do i=1 to 3;
mdif(1,i)=mcab(1,i)-mcab(1,i+1);
mdif(2,i)=mcab(2,i)-mcab(2,i+1);
end;

if .<ga<26 then gacat=1;
else if 26<=ga<=28 then gacat=2;
else if ga>28 then gacat=3;

id1=mod(id,10);
run;

*2--use 2 proc means;

proc sort data=hw.ivh2;
by gacat;
run;
proc means data=hw.ivh2 mean min max n t prt maxdec=3;
var ccdif1-ccdif3 wtdif1-wtdif3;
by gacat;
where gacat>.;
run;

proc sort data=hw.ivh2;
by id1;
run;
proc means data=hw.ivh2  maxdec=3 ;
var bw t4 apgrat lpco hpco;
by id1;
run;

*3--create temporary dataset to change the shape of data set and use proc means to see;

data w1;
set hw.ivh2;
keep wt map pco2 day;
array new(4,4) wt map pco2 day wt1-wt4 map1-map4 pco2_1-pco2_4;
do i=1 to 4;
 new(1,1)=new(2,i);
 new(1,2)=new(3,i);
 new(1,3)=new(4,i);
 new(1,4)=i;
 output;
end;
run;
proc sort;
by day;
run;
proc means;
var wt map pco2;
by day;
run;

*4--create another temporary dataset and make a report;

options nocenter nodate nonumber;
data w2;
set hw.ivh2;
if .<apg1<2 and ivh=1;
run;
proc sort data=w2;
by cs ga bw labor los;
* by cs ga bw sex descending acs(it also does work);
run;
proc format;
 value sex 0='F' 1='M';
 value acs 1='None' 2='Partial' 3='Complete';
 value cs  1='Yes' 0='No';
run;
proc print data=w2 label;
 var id sex ga bw acs labor los;
 by cs;
 id id;
 sum los;
 label ga='Gestational age' bw='Birth weight' acs='Antenatal corticosteroid' 
       labor='Duration of labor' los='Length of stay' cs='Caesarian delivery';
 format sex sex. acs acs. cs cs.;
 
 title 'Babies with 1 minute Agpar <2 and IVH';
 footnote 'DEN Study Data';
 run;

*5--use proc format and proc freq to make 3-way table;

proc format ;
 value pih 0='No' 1='Yes';
 value hosp 1='St. Elsewhere' 2='Chicargo Hope';
 value acs 1='None' 2='Partial' 3='Complete';
run; 

title;
footnote;
proc freq data=hw.ivh2;
 tables pih*hosp*acs/cmh;
 format pih pih. hosp hosp. acs acs.;
run; 

*6--use proc plot or proc gplot for the plots;
proc format;
 value ivh 1='#' 0='.';
run;
proc plot data=hw.ivh2;
 plot fluid2*pctwt2/href=0;
 plot los*bw=ivh;
 format ivh ivh.;
run;


 


 

