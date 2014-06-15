* create temporary data set;
* join data set;
* calculate age in years;
* use proc univariate with plot to display distribution of age;

options nocenter nodate nonumber;
libname hw 'p:\bio113\hw';
data tem1;
infile 'g:\shared\bio113\dob.dat';
input id 1-6 dob mmddyy10.;
run;
proc sort;
by id;
run;
proc sort data=hw.ivh2;
by id;
run;
data hw.ivh3;
merge hw.ivh2 tem1;
by id;
age=round((mdy(10,20,2004)-dob)/365.25,1);
run;

title 'The distribution of ages in babies';
proc univariate plot;
var age;
run;

* make 3 temporary data set in one single data step;
* use proc freq to display 3 tables;

data baby91(keep=hosp race) baby92(keep=cs pih) baby93(keep=single medu);
set hw.ivh3;
if year(dob)=1991 then output baby91;
else if year(dob)=1992 then output baby92;
else if year(dob)=1993 then output baby93;
else delete;
run;

title 'Table 1: HOSP by RACE for babies born in 1991';
proc freq data=baby91;
tables hosp*race;
run;

title 'Table 2: CS by PIH for babies born in 1992';
proc freq data=baby92;
tables cs*pih;
run;

title 'Table 3: SINGLE-MEDU for babies born in 1993';
proc freq data=baby93;
tables single*medu;
run;

* create another temporary data set;
* join to the permanent data set ivh3;
* create new variables for data analysis;

title;
data tem2;
infile 'g:\shared\bio113\std.dat';
input ga sex meanbw stdbw meant4 stdt4;
run;
proc sort;
by ga sex;
run;
proc sort data=hw.ivh3;
by ga sex;
run;

data hw.ivh3;
merge hw.ivh3(in=in1) tem2;
by ga sex;
if in1;

bwz=round((bw-meanbw)/stdbw,1);
t4z=round((t4-meant4)/stdt4,1);

if .<mage<20 then mageg=1;
else if 20<=mage<=30 then mageg=2;
else if mage>30 then mageg=3;

if race>. then black=(race=2);
if ga>. then ga26=(.<ga<26);
if ga>. then ga28=(26<=ga<=28);
if acs>. then acs01=(acs=3);
if rom>. then rom01=(rom>=1);
if t4>. then t401=(t4<=5);

if .<map1<28 then map1cat=1;
else if 28<=map1<32 then map1cat=2;
else if 32<=map1<37 then map1cat=3;
else if map1>=37 then map1cat=4;
run;

proc format;
value sex 0='Female' 1='Male';
value mageg 1='below 20 years' 2='between 20-20 years' 3='above 30 years';
run;

* data analysis;

title 'Plot of Z-scores - ga';
proc plot;
plot (bwz t4z)* ga='*';
run;

title 'TTEST  Output';
proc ttest;
class sex;
format sex sex.;
var bwz;
run;

title 'NPAR1WAY  Output';
proc npar1way wilcoxon;
class mageg;
format mageg mageg.;
var labor;
run;

title 'Reggression  Output';
proc reg;
model cc2=map2;
run;

title 'GLM  Output';
proc glm;
class black acs labcat;
model t4z=black | acs | labcat;
run;

title 'LOGISTIC REG  Output';
proc logistic descending;
model ivh=hosp ga26 ga28 acs01 pih rom01 cs t401;
run;

title 'LIFETEST  Output';
proc lifetest notable plots=(s) data=hw.ivh3;
time los*dead(1);
strata map1cat;
run;


