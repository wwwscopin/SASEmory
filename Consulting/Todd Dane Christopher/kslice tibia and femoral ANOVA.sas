
options orientation=portrait;
%let dane=H:\SAS_Emory\Consulting\Todd Dane Christopher\output;
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Todd Dane Christopher\Kslice tibia and femoral volume cleaned data.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="'master all$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc print data=temp;run;
proc freq;
	tables knee gender;
run;
*/
proc format;
	value knee 1="Left" 2="Right";
	value gender 0="Female" 1="Male";
run;

data tf0;
	set temp(rename=(knee=knee0 gender=gender0));
	if knee0='L' then knee=1; else if knee0='R' then knee=2;
	if gender0='f' then gender=0; else if gender0='m' then gender=1;
	format knee knee. gender gender.;
	drop gender0 knee0;
	if gender=. then delete;
run;
proc sort; by gender;run;

proc means data=tf0 n mean std Q1 median Q3 noprint;
	var age;
	output out=age Q1(age)=Q1_age median(age)=median_age Q3(age)=Q3_age;
run;
data _null_;
	set age;
	call symput ("Q1_age", put(Q1_age, 4.1));
	call symput ("median_age", put(median_age, 4.1));
	call symput ("Q3_age", put(Q3_age, 4.1));
run;

proc format;
	value age_group 1="Age<=&Q1_age(Q1)"  2="Age=&Q1_age(Q1)~&median_age(Median)"  3="Age=&median_age(median)~&Q3_age(Q3)"  4="Age>&Q3_age(Q3)";
	value age .="Overall";
run;

data tf;
	set tf0;
	if age<=&Q1_age then age_group=1;
	else if &q1_age<age<=&median_age then age_group=2;
	else if &median_age<age<=&Q3_age then age_group=3;
	else age_group=4;
	format age_group age_group.;
run;

/*
proc mixed data =tf covtest;
	class gender; 	
	model F_CEWd_R=age gender age*gender age*age/residual; 
run;

proc mixed data =tf covtest;
	class gender; 	
	model F_CEWd_R=age gender age*gender/residual; 
run;

proc sgplot data=temp;
	scatter x=pred y= Resraw;      
	scatter x=pred y= Reschi;
	scatter x=pred y= Resdev;       
run;

*ods trace on/label listing;
proc genmod data =tf;
	class gender age; 	
	model L_F_Ep_V=age gender age*gender /r p; 
	ods output ObStats=temp;
run;
*ods trace off;

proc univariate data=temp  plots normal;
	var resraw Reschi Resdev;
	qqplot/normal(mu=est sigma=est);
run;

proc sgplot data=temp;
	scatter x=pred y= Resraw;      
	scatter x=pred y= Reschi;
	scatter x=pred y= Resdev;       
run;

proc contents data=tf short varnum;run;

proc univariate data=tf plots normal;
	var F_PE_Rat F_ML_Rat T_PE_Rat T_ML_Rat F_CEWd_R T_CEWd_R; 
	qqplot;
run;

proc univariate data=tf plots normal;
	var Fem_Ph_V Fem_Ep_V; 
	qqplot/normal(mu=est sigma=est);
run;

proc freq;
tables gender*age/norow nopercent;
run;
*/
%macro anova(data_in=,var=,label=);
*ods trace on/label listing;
proc mixed data =&data_in covtest;
	class gender age; 	
	model &var=age gender age*gender age*age/ solution ; 
	lsmeans gender age*gender/pdiff cl;
	ods output lsmeans = lsmean0;
	ods output Mixed.Diffs= diff0;
	ods output Mixed.Tests3=pv;
run;
*ods trace off;

data _null_;
	set pv;
	if _n_=1 then do; if probf<0.0001 then call symput ("p1", "<0.0001"); else call symput ("p1", put(probf,7.4)); end;
	if _n_=2 then do; if probf<0.0001 then call symput ("p2", "<0.0001"); else call symput ("p2", put(probf,7.4)); end;
	if _n_=3 then do; if probf<0.0001 then call symput ("p3", "<0.0001"); else call symput ("p3", put(probf,7.4)); end;
	if _n_=3 then do; if probf<0.0001 then call symput ("p4", "<0.0001"); else call symput ("p4", put(probf,7.4)); end;
run;

data lsmean;
	set lsmean0(rename=(age=age0));
	age=age0+0;
run;


data lsmean_plot;
	set lsmean0(rename=(age=age0));
	age=age0+0;
	if gender=1 then age=age+0.2;
run;

data diff;
	set diff0(where=(age=_age));
	age=age+0;
run;

proc means data=&data_in n;
	class gender age;
	var &var;
	output out=wbh n(&var)=n;
run;

data &var._tab;
	retain age est0 est1 diff probt;
	length est0 est1 diff $25;
	merge lsmean(where=(gender=0) keep=gender age Estimate lower upper rename=(Estimate=Estimate0 lower=lower0 upper=upper0)) 
		  lsmean(where=(gender=1) keep=gender age Estimate lower upper rename=(Estimate=Estimate1 lower=lower1 upper=upper1))
		  wbh(where=(gender=0) keep=gender age n rename=(n=n0))
		  wbh(where=(gender=1) keep=gender age n rename=(n=n1))
		  diff(keep=age estimate lower upper Probt); by age;
		  est0=compress(put(estimate0, 5.2)||"["||put(lower0, 5.2)||"-"||put(upper0, 5.2))||"], "||compress(n0);
		  est1=compress(put(estimate1, 5.2)||"["||put(lower1, 5.2)||"-"||put(upper1, 5.2))||"], "||compress(n1);
		  diff=compress(put(estimate, 5.2)||"["||put(lower, 5.2)||"-"||put(upper, 5.2))||"]";
			
		  if probt<0.0001 then pv="<0.0001*";
		  else if probt<0.05 then pv=compress(put(probt, 7.4))||"*";
		  else if probt<0.10 then pv=put(probt, 7.3);
		  else pv=put(probt,5.2);

		  keep age est0 est1 diff probt pv;
		  format age age.;
		  Label est0="Estimate[95%CI],N *Female" est1="Estimate[95%CI],N *Male" diff="Difference" pv="p value" age="Age";
run;
ods rtf file="&dane.\&var..rtf" style=journal bodytitle ;
proc print data=&var._tab noobs label split="*" ;
	title1 &label;
	title2 "p(Gender)=&p2; p(Age)=&p1; p(Age*Gender)=&p3;";
	var age est0 est1 diff pv/style=[just=c];
run;
ods rtf close;

ods listing close;
ods graphics on/ reset width=600px height=400px imagename="&var" imagefmt=gif;
ods html file="vw.html" path="&dane"; 

proc sgplot data=lsmean_plot;
   scatter x=age y=estimate / group=gender yerrorlower=lower yerrorupper=upper   markerattrs=(symbol=circlefilled) name="scat";
   series x=age y=estimate / group=gender lineattrs=(pattern=solid);
   xaxis integer values=(0 to 16 by 1) label="Age";
   yaxis label=&label;
   keylegend "scat" / title="" border  location=inside across=1 position=topleft ;
run;
quit;
ods html close;
ods listing;
%mend anova;
%anova(data_in=tf, var=Fem_Ph_V, label="Femoral Physis Volume");
%anova(data_in=tf, var=Fem_Ep_V, label="Femoral Epiphysis Volume");
%anova(data_in=tf, var=L_F_Ep_V, label="Lateral Femoral Epiphysis Volume");
%anova(data_in=tf, var=M_F_EP_V, label="Medial Femoral Epiphysis Volume");
%anova(data_in=tf, var=F_PE_Rat, label="Femur Physis to Epiphysis Ratio");
%anova(data_in=tf, var=F_ML_Rat, label="Femur Medial to Lateral Epiphysis Ratio");
%anova(data_in=tf, var=Tib_Ph_V, label="Tibia physis volume");
%anova(data_in=tf, var=Tib_Ep_V, label="Tibia Epiphysis Volume");
%anova(data_in=tf, var=L_T_Ep_V, label="Lateral tibia epiphyseal volume");
%anova(data_in=tf, var=M_T_Ep_V, label="Medial tibial epiphyseal volume");
%anova(data_in=tf, var=T_PE_Rat, label="Tibial physis to epiphysis ratio");
%anova(data_in=tf, var=T_ML_Rat, label="Tibial Medial to Lateral Epiphysis Ratio");
%anova(data_in=tf, var=F_Cart_V, label="Femur Cartilage Cap Volume");
%anova(data_in=tf, var=T_Cart_V, label="Tibial Cartilage Cap Volume");
%anova(data_in=tf, var=F_Epi_Wd, label="Width of Femur Epiphysis");
%anova(data_in=tf, var=T_Epi_Wd, label="Width of Tibial Epiphysis");
%anova(data_in=tf, var=F_Cart_W, label="Femur Cartilage Cap Width");
%anova(data_in=tf, var=T_Cart_W, label="Tibia Cartilage Cap Width");
%anova(data_in=tf, var=F_CEWd_R, label="Femur Cartilage Cap width to Epiphysis width Ratio");
%anova(data_in=tf, var=T_CEWd_R, label="Tibia Cartilage Cap width to Epiphysis width Ratio");
quit;
