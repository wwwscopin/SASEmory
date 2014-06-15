options orientation=portrait nodate nonumber nofmterr;
libname xxx "H:\SAS_Emory\Consulting\Joseph";

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Joseph\kslice saved and sorted data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'master all$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents data=tmp short varnum;run;

data master;
	set tmp(rename=(gender=gender0));
	if gender0="f" then gender=0; else gender=1;
	if L_or_R="L" then LR=0; else LR=1;

	rfpe=Femur_volume_physis/Femur_volume_epiphysis;
	rfmle=Volume_Medial_Epiphysis_of_Femur/Volume_Lateral_Epiphysis_of_Femu;
	rtpe=Tibial_physis_volume/Tibial_Epiphysis_Volume;
	rtmle=Medial_tibial_epiphyseal_volume/Lateral_tibial_epiphyseal_volume;
	rce=Femur_Cartilage_width/Width_of_Femur_epiphysis;
	rtce=Tibial_Cartilage_width/Tibial_epiphysis_width;
	rftc=Femur_Cartilage_volume/Tibial_Cartilage_Cap;
	rfce=Femur_Cartilage_volume/Femur_volume_epiphysis;
	rtcev=Tibial_Cartilage_Cap/Tibial_Epiphysis_Volume;


	rename  Femur_Cartilage_volume=fcv   Femur_Cartilage_width=fcw    Femur_M_L_epiphysis=fmle   Femur_Physis_Epiphysis=fpe
			Femur_volume_epiphysis=fve   Femur_volume_physis=fvp      Lateral_tibial_epiphyseal_volume=ltev  Medial_tibial_epiphyseal_volume=mtev
			Tibial_Cartilage_Cap=tcc	 Tibial_Cartilage_width=tcw   Tibial_Cartilagewidth_epiphyseal=tce   Tibial_Epiphysis_Volume=tev
 			Tibial_epiphysis_width=tew   Tibial_physis_epiphysis=tpe  Tibial_physis_volume=tpv   Volume_Lateral_Epiphysis_of_Femu=vlef
			Volume_Medial_Epiphysis_of_Femur=vmef  Width_of_Femur_epiphysis=wfe  _CartilageCapToEpiphysisXRatioF_=ratio  tibial_epiphysis_M_L=teml;

	drop gender0 l_or_r ;
	if age=. then delete;
	age_square=age*age;
run;
proc sort data=master; by gender age;run;

ods listing;
*ods trace on/label listing;
proc means data=master n;
class gender age;
ods output means.summary=wbh(keep=gender age nobs);
*output out=wbh n(age)=n;
run;
*ods trace off;

data master; 
	merge master wbh; by gender age; 
	if age<5 then nw=50; else nw=100;
run;


proc format; 

value item 
	1="Ratio of Femur Physis to Epiphysis"
	2="Ratio of Femur M:L Epiphysis"
	3="Ratio of Tibial Physis to Epiphysis"
	4="Ratio of Tibial M:L Epiphysis"
	5="Ratio of CartilageCap to Epiphysis"
	6="Ratio of Tibial Cartilage width to Epiphyseal width"
	7="Ratio of Femur Cartilage volume to Tibial Cartilage Cap"
	8="Ratio of Femur Cartilage volume to Femur volume epiphysis"
	9="Ratio of Tibial Cartilage Cap to Tibial Epiphysis Volume"
;

value gender 0="Female" 1="Male";
value LR 0="Left" 1="Right";
run;


%macro mixed(data, gp, varlist);


%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );


%if &var=rfpe  %then %do; %let text=Ratio of Femur Physis to Epiphysis; %end;
%if &var=rfmle %then %do; %let text=Ratio of Femur M:L Epiphysis; %end;
%if &var=rtpe  %then %do; %let text=Ratio of Tibial Physis to Epiphysis; %end;
%if &var=rtmle %then %do; %let text=Ratio of Tibial M:L Epiphysis; %end;
%if &var=rce   %then %do; %let text=Ratio of CartilageCap to Epiphysis; %end;
%if &var=rtce  %then %do; %let text=Ratio of Tibial Cartilage width to Epiphyseal width; %end;
%if &var=rftc  %then %do; %let text=Ratio of Femur Cartilage volume to Tibial Cartilage Cap; %end;
%if &var=rfce  %then %do; %let text=Ratio of Femur Cartilage volume to Femur volume epiphysis; %end;
%if &var=rtcev %then %do; %let text=Ratio of Tibial Cartilage Cap to Tibial Epiphysis Volume; %end;

proc mixed data =&data covtest;
	*weight nobs;
	weight nw;
	class &gp age ; 
	model &var= &gp age &gp*age/ solution ; 
	*repeated age / type = cs;
	lsmeans &gp*age &gp/ /*pdiff*/ cl ;

	*estimate "line trend0" age -5 -3 3 5 -1 1 	&gp*age -5 -3 3 5 -1 1 0 0 0 0 0 0 0 0 0 0 0 0/e;
	*estimate "line trend1" age -5 -3 3 5 -1 1 	&gp*age 0 0 0 0 0 0 -5 -3 3 5 -1 1 0 0 0 0 0 0/e;

	ods output lsmeans = lsmeans_&i;
		ods output   Mixed.Tests3=p_&var;
run;

data p_&var;
	length effect $100;
	set p_&var;
	if effect="&gp" then effect="&gp";
		if effect="age" then effect="Age";
			if effect="&gp*age" then effect="Interaction between &gp and Age";
run;

data lsmeans_&var;
	set lsmeans_&i;
	if lower^=. and lower<0 then lower=0;
	age1=age+0.10;
	if 0<age<=15;
run;

proc sort; by &gp age;run;

DATA anno0; 
	set lsmeans_&var(where=(&gp=0));
	xsys='2'; ysys='2';  color='blue';
	X=age1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=age1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=age1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  		X=age1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmeans_&var(where=(&gp=1));
	xsys='2'; ysys='2';  color='red';
	X=age; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    	X=age-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=age+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	  	X=age;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	length color $10;
	set anno0 anno1;
run;

data estimate_&var;
	merge lsmeans_&var(where=(&gp=0 ) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(&gp=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by age;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;
symbol1 i=j ci=red value=dot co=red cv=red h=4 w=1;

axis1 	label=(f=Century h=3 "Age" ) split="*"	value=(f=Century h=3)  order= (0 to 16 by 1) minor=none offset=(0 in, 0 in);

legend1 across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5  "Male" "Female") offset=(-0.2in, -0.2 in) frame;

%if &var=rfpe or &var=rtpe %then %do;
axis2 	label=(f=Century h=3 a=90 "&text") value=(f=Century h=3) order= (0 to 1 by 0.05) offset=(.25 in, .25 in); 
%end;

%if &var=rtce or &var=rce %then %do;
axis2 	label=(f=Century h=3 a=90 "&text") value=(f=Century h=3) order= (0.8 to 3 by 0.2) offset=(.25 in, .25 in); 
%end;

%if &var=rtmle or &var=rfmle %then %do;
axis2 	label=(f=Century h=3 a=90 "&text") value=(f=Century h=3) order= (0.6 to 1.4 by 0.05) offset=(.25 in, .25 in); 
%end;

%if &var=rfce or &var=rtcev %then %do;
axis2 	label=(f=Century h=3 a=90 "&text") value=(f=Century h=3) order= (0 to 7 by 0.5) offset=(.25 in, .25 in); 
%end;

%if &var=rftc %then %do;
axis2 	label=(f=Century h=3 a=90 "&text") value=(f=Century h=3) order= (0.5 to 2.5 by 0.25) offset=(.25 in, .25 in); 
%end;

proc gplot data= estimate_&var gout=xxx.graphs;
	plot estimate1*age estimate0*age1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend1;

	format estimate0 estimate1 4.2; 
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

ods listing;
proc print data=anno_rfpe;run;

proc greplay igout=xxx.graphs  nofs; delete _ALL_; run;
goptions reset=all rotate = landscape;

%let varlist=rfpe rfmle rtpe rtmle rce rtce rftc rfce rtcev;
%mixed(master, gender, &varlist); quit;

goptions hsize=0in vsize=0in;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

goptions reset=all border;
ods listing close;
ods pdf file = "ratio by age.pdf" style=journal;
proc greplay nofs;
igout xxx.graphs;
list igout;
tc template;
tdef t1 5 /llx=5    ulx=5   lrx=50   urx=50  lly=5    uly=35    lry=5      ury=35
        3 /llx=5    ulx=5   lrx=50   urx=50  lly=35   uly=65    lry=35     ury=65
        1 /llx=5    ulx=5   lrx=50   urx=50  lly=65   uly=95    lry=65     ury=95
		6 /llx=50   ulx=50  lrx=95   urx=95  lly=5    uly=35    lry=5      ury=35
        4 /llx=50   ulx=50  lrx=95   urx=95  lly=35   uly=65    lry=35     ury=65
        2 /llx=50   ulx=50  lrx=95   urx=95  lly=65   uly=95    lry=65     ury=95
		;
template t1;
tplay 1:1 2:2 3:3 4:4 5:5 6:6;
tplay 1:7 2:8 3:9 ;
run; quit;
ods pdf close;




