proc format;
	value  slope 1="+"
					 -1="-"
					 0="0"	
   ;
run;
			
data insulin;
	set glnd.followup_all_long(keep=id day gluc_mrn gluc_aft gluc_eve tot_insulin);
	center=floor(id/10000);
	format center center.;
	gluc_mean=mean(gluc_mrn,gluc_aft,gluc_eve);
	where gluc_mrn^=. or gluc_aft^=. or gluc_eve^=. or tot_insulin^=.;
	log_gluc_mean=log(gluc_mean);
	log_tot_insulin=log(tot_insulin);
	if id=12207 then delete;
	format gluc_mean 5.1;
run;


** Check the distribution of the gluc_mean ************************;
*******************************************************************;

ods pdf file="dist_gluc_mean.pdf";
title "Distribution for mean of blood glucose";

proc univariate data=insulin plot;
	var gluc_mean;
run;

ods pdf close;

goptions rotate = landscape reset=global gsfmode=replace gunit=pct border
ctext=black ftitle=swissb ftext=swiss htitle=3 htext=3;

axis1 label=(a=90 h=4 c=Black "Blood glucose (mg/dL) / Insulin (units)") order=(0 to 500 by 100) minor=none;
axis2 label=( h=4 c=Black "Day") order=(0 to 28 by 4) offset=(0cm, 0cm) minor=none;

axis3 label=(a=90 h=4 c=Black "Blood glucose (mg/dL)") order=(0 to 300 by 50) minor=none;
axis4 label=( h=4 c=Black "Total insulin adminstrated (units)") order=(0 to 500 by 50) minor=none;
axis5 label=( h=4 c=Black "Total insulin adminstrated (units)") /*order=(0 to 200 by 20)*/ minor=none;

legend1 across=1 down=4 label=none 
		mode=protect position=(top right inside)
        value=('Morning' 'Afternoon' 'Evening' 'Mean') offset=(0cm, -0.5cm);

legend2 across=1 down=2 label=none 
		mode=protect position=(top right inside)
        value=('Blood glucose' 'Insulin') offset=(0cm, -0.5cm);


symbol1 value=circle   i=none h=2 w=2 c=blue;  *repeat=130;



********** Make scatter plot for all id  **************************;
*******************************************************************;

data insulin_exclude;
	set insulin(keep=id tot_insulin);
	where tot_insulin^=0;
	drop tot_insulin;
run;


Proc sql;
	create table insulin_plot as
	select insulin.*
	from insulin, insulin_exclude
	where insulin.id=insulin_exclude.id and insulin.center^=2;
quit;


proc gplot data=insulin_plot gout=cat1;
	title "Blood glucose (mg/dL) vs Total insulin adminstrated (units)";
	by center;
	*plot gluc_mrn*tot_insulin gluc_aft*tot_insulin gluc_eve*tot_insulin gluc_mean*tot_insulin/overlay vaxis=axis3 haxis=axis4;
	plot gluc_mean*tot_insulin/vaxis=axis3 haxis=axis4 legend=legend1; *noframe;
run;


********** Make scatter plot for random slected 5 id  *************;
*******************************************************************;


data insulin_id;
	set insulin(keep=id center);
run;

proc sort data=insulin_id nodup; by id;run;

proc surveyselect data =insulin_id(where=(center=1))  method = SRS rep = 1 
                         sampsize = 5 seed = 12345 out = sub_emory;
  id _all_;
run;

proc surveyselect data =insulin_id(where=(center=3))  method = SRS rep = 1 
                         sampsize = 5 seed = 12345 out = sub_van;
  id _all_;
run;

proc surveyselect data =insulin_id(where=(center=4))  method = SRS rep = 1 
                         sampsize = 5 seed = 12345 out = sub_col;
  id _all_;
run;


data sub_id;
	set sub_emory sub_van sub_col insulin_id(where=(center=5));
run;


Proc sql;
	create table sub_insulin as
	select insulin.*
	from insulin, sub_id
	where insulin.id=sub_id.id;
quit;


symbol1 value=circle   i=j h=4 w=2 c=blue;  *repeat=130;
symbol2 value=square   i=j h=4 w=2 c=red;   *repeat=130;
symbol3 value=triangle i=j h=4 w=2 c=green; *repeat=130;
symbol4 value=Diamond  i=j h=4 w=2 c=cyan;  *repeat=130;
symbol5 value=star     i=j h=4 w=2 c=black; *repeat=130;


proc gplot data=sub_insulin gout=cat1;
	title "Blood glucose (mg/dL) vs Total insulin adminstrated (units)";
	by center;
	*plot gluc_mrn*tot_insulin gluc_aft*tot_insulin gluc_eve*tot_insulin gluc_mean*tot_insulin/overlay vaxis=axis3 haxis=axis4;
	plot gluc_mean*tot_insulin=id/overlay vaxis=axis3 haxis=axis4;* legend=legend1; *noframe;
run;


axis6 label=(a=90 h=4 c=Black "Ln[Blood glucose (mg/dL)]") order=(4 to 5.5 by 0.5) minor=none;
axis7 label=( h=4 c=Black "Ln[Total insulin adminstrated (units)]") order=(0 to 7 by 1) minor=none;

proc gplot data=sub_insulin gout=cat1;
	title " Ln[Blood glucose (mg/dL)] vs Ln[Total insulin adminstrated (units)]";
	by center;
	*plot gluc_mrn*tot_insulin gluc_aft*tot_insulin gluc_eve*tot_insulin gluc_mean*tot_insulin/overlay vaxis=axis3 haxis=axis4;
	plot log_gluc_mean*log_tot_insulin=id/overlay vaxis=axis6 haxis=axis7;* legend=legend1; *noframe;
run;


********** Check the slope for all patients  **********************;
*******************************************************************;

proc reg data=insulin_plot noprint outest=insulin_slope;

by id;
 model gluc_mean=tot_insulin;
run;

data insulin_slope;
	set insulin_slope(keep=id Intercept tot_insulin);
	if tot_insulin>0 then slope=1;
	if tot_insulin=0 then slope=0;
	if tot_insulin<0 then slope=-1;
	format slope slope.;
run;

proc sort data=insulin_slope; by tot_insulin;run;

ods pdf file="slope.pdf";

title "Slope for fitting gluc_mean vs tot_insulin";

proc means data=insulin_slope;
 class slope;
 var tot_insulin;
run;

/*
proc univariate data=insulin_slope plot;
	var tot_insulin;
run;
*/

proc print data=insulin_slope;run;

ods pdf close;


********** Make final plot for output        **********************;
*******************************************************************;

data some_id;
	set insulin;
	where tot_insulin>500;
	keep id;
run;

Proc sql;
	create table some_insulin as 
	select insulin.*
	from insulin, some_id
	where insulin.id=some_id.id;
quit;


data sub_insulin;
	set sub_insulin some_insulin;
run;

ods pdf file="data_glucose_insulin.pdf";

title "Data for Blood glucose vs Total insulin adminstrated";

proc print data=sub_insulin noobs label;
	id id; 
	var center gluc_mrn gluc_aft gluc_eve gluc_mean tot_insulin day;
	label center="Center";
	label gluc_mrn="Morning (mg/dL)";
	label gluc_aft="Afternoon (mg/dL)";
	label gluc_eve="Evening (mg/dL)";
	label gluc_mean="Mean (mg/dL)";
	label tot_insulin="Insulin (units)";
	label day="Day";
run;

ods pdf close;


title "wbh";
data full_id;
	set insulin(keep=id day);
	where day=28;
	drop day;
run;

proc sort data=full_id nodup;by id;run;
proc print;run;


ods pdf file="full_data_glucose_insulin.pdf";

title "Data for Blood glucose vs Total insulin adminstrated";

proc print data=insulin noobs label;
	where id in (11369,21020,32064,41156);
	id id; 
	var center gluc_mrn gluc_aft gluc_eve gluc_mean tot_insulin day;
	label center="Center";
	label gluc_mrn="Morning (mg/dL)";
	label gluc_aft="Afternoon (mg/dL)";
	label gluc_eve="Evening (mg/dL)";
	label gluc_mean="Mean (mg/dL)";
	label tot_insulin="Insulin (units)";
	label day="Day";
run;

ods pdf close;


	
proc gplot data=some_insulin gout=cat1;
	title1 "Blood glucose (mg/dL) vs Total insulin adminstrated (units)";
	title2 "For patients with extreamly large value of blood glucose or insulin";
	by id;
	*plot gluc_mrn*tot_insulin gluc_aft*tot_insulin gluc_eve*tot_insulin gluc_mean*tot_insulin/overlay vaxis=axis3 haxis=axis5;
	plot gluc_mean*tot_insulin/vaxis=axis3 haxis=axis5 legend=legend1; *noframe;
run;


ods pdf file="glucose_insulin.pdf";

proc greplay nofs gout=cat1;
igout cat1;
list igout;
tc template;
tdef t1 1 /llx=0   ulx=0   lrx=50  urx=50  lly=50 uly=100 lry=50 ury=100
        2 /llx=50  ulx=50  lrx=100 urx=100 lly=50 uly=100 lry=50 ury=100
        3 /llx=0   ulx=0   lrx=50  urx=50  lly=0  uly=50  lry=0  ury=50
        4 /llx=50  ulx=50  lrx=100 urx=100 lly=0  uly=50  lry=0  ury=50
			;
template t1;
tplay 1:1  2:2  3:3  4:4;
tplay 1:5  2:6  3:7  4:8;
tplay 1:9  2:10 3:11 4:12;
tplay 1:13 2:14 3:15 4:16;
tplay 1:17 2:18;
run; quit;
ods pdf close;


