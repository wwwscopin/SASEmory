options nodate nonumber;

proc format;
  value grade   
        1 = "I" 2 = "II" 3 = "III" 4="IV" 0="Unilateral" 100="Total";
run;

data ivh0;
	set cmv.ivh_image(keep=id LeftIVHGrade RightIVHGrade ImageDate Imagetime); 	by id;
	format LeftIVHGrade RightIVHGrade grade. ;
	if LeftIVHGrade=99 then LeftIVHGrade=0;
	if RightIVHGrade=99 then RightIVHGrade=0; 
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
    if LeftIVHGrade in(1,2,3,4) and RightIVHGrade in(1,2,3,4) then bilateral=1; else bilateral=0; 
run;

proc sql; 
	create table ivh as 
	select a.*
	from ivh0 as a , cmv.comp_pat as b
	where a.id=b.id;
	
proc sort; by id ImageDate Imagetime;run;
proc sort data=ivh out=tmp; by id descending bilateral;run;

data tmp;
    set tmp; by id;
    if first.id;
run; 

proc freq data=tmp;
    tables bilateral/out=bi_ivh;
run;

data _null_;
    set bi_ivh;
    if bilateral=0 then call symput("nlr0", compress(count));
    if bilateral=1 then call symput("nlr1", compress(count));
run;
%let n=%eval(&nlr0+&nlr1);

data tab;
	do i=0 to 4; 
		do j=0 to 4; 
			LeftIVHGrade=i;  RightIVHGrade=j; output;
		end;
	end;
	drop i j;
	format LeftIVHGrade RightIVHGrade grade.;
run;
proc sort; by LeftIVHGrade RightIVHGrade;run;

%let nl=0;
%let nr=0;

%macro lr(data, lr);

data ini_&lr;
    set &data(where=(&lr.IVHGrade in(1,2,3,4))); by id ImageDate Imagetime;
   	if first.id;
   	
   	rename &lr.ivhgrade=ini_&lr imagedate=&lr._date;
   	keep id &lr.ivhgrade imagedate;
run;

data _null_;
    set ini_&lr;
    %if &lr=left  %then %do; call symput("nl", compress(_n_)); %end;
    %if &lr=right %then %do; call symput("nr", compress(_n_)); %end;
run;

data ivh_&lr;
    merge ivh ini_&lr(in=temp); by id;
    if temp;
    if imagedate>=&lr._date;
run;

proc means data=ivh_&lr min max;
	class id; 
	var &lr.IVHGrade;
	ods output means.summary=min_max;
run;

data grade_&lr;
	merge ini_&lr min_max(rename=(&lr.IVHGrade_min=min_&lr &lr.IVHGrade_max=max_&lr)); by id;
	if max_&lr>ini_&lr then prog=1; else prog=0;
	if min_&lr<ini_&lr then retro=1; else retro=0;
run;

proc freq; 
tables ini_&lr*max_&lr/out=tab_&lr;
tables ini_&lr*min_&lr/out=table_&lr;
run;


data tab_&lr;
	merge tab_&lr tab(rename=(LeftIVHGrade=ini_&lr rightIVHGrade=max_&lr)); by ini_&lr max_&lr;
	cp=compress(count||"("||put(percent,4.1)||"%)");
	if count=. then cp="-";
	if ini_&lr=. then delete;
run; 
proc sort; by ini_&lr max_&lr;run;
proc transpose data=tab_&lr out=tab&lr; var cp; by ini_&lr;run;
data tab&lr;
    set tab&lr;
    if ini_&lr=0 then delete;
run;

data table_&lr;
	merge table_&lr tab(rename=(LeftIVHGrade=ini_&lr rightIVHGrade=min_&lr)); by ini_&lr min_&lr;
	cp=compress(count||"("||put(percent,4.1)||"%)");
	if count=. then cp="-";
	if ini_&lr=. then delete;
run; 

proc sort; by ini_&lr min_&lr;run;
proc transpose data=table_&lr out=table&lr; var cp; by ini_&lr;run;

data table&lr;
    set table&lr;
    if ini_&lr=0 then delete;
run;

%mend lr;

%lr(ivh, left);
%lr(ivh, right);

data ivh_left;
    set ivh_left; by id imagedate;
    if first.id then do; num_ivh=0; end;
    num_ivh+1;

  	center=floor(id/1000000);
    	if center=1 then num=num_ivh-0.1;
  	  	if center=2 then num=num_ivh;
  	  	if center=3 then num=num_ivh+0.1;
run;

data ivh_right;
    set ivh_right; by id imagedate;
    if first.id then do; num_ivh=0; end;
    num_ivh+1;

  	center=floor(id/1000000);
    	if center=1 then num=num_ivh-0.1;
  	  	if center=2 then num=num_ivh;
  	  	if center=3 then num=num_ivh+0.1;
run;

proc sort data=ivh out=ivh_bi nodupkey; by id; run;
data grade_lr;
    merge ivh_bi(keep=id bilateral) 
    grade_left(rename=(prog=prog_left retro=retro_left) in=A) 
    grade_right(rename=(prog=prog_right retro=retro_right) in=B); by id;
    if prog_left or prog_right or retro_left or retro_right;
    if A or B;
run;

proc print;run;

symbol i=j value=circle repeat=10 /*color=blue*/;
axis1 minor=none order=(0 to 8 by 1);
axis2 minor=none;
proc gplot data=ivh_left;
plot leftivhgrade*num=id/nolegend haxis=axis1 vaxis=axis2;
run;

proc gplot data=ivh_right;
plot rightivhgrade*num=id/nolegend haxis=axis1 vaxis=axis2;
run;


ods rtf file="ivh_progress.rtf"  style=journal bodytitle bodytitle startpage=no;
proc print data=tableft noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Left IVH Grade Progressors (n=&nl)";
var ini_left/style(data)=[cellwidth=2in];
var col2-col5/style(data)=[cellwidth=1in];
label   col2="I"
		col3="II"
		col4="III"
		col5="IV"
		ini_left="Initial Left Grade *by Maximum Left Grade";
run;

proc print data=tabright noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Right IVH Grade Progressors (n=&nr)";
var ini_right/style(data)=[cellwidth=2in];
var col2-col5/style(data)=[cellwidth=1in];
label   col2="I"
		col3="II"
		col4="III"
		col5="IV"
		ini_right="Initial Right Grade *by Maximum Right Grade";
run;

proc print data=tableleft noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Left IVH Grade Non-Progressors (n=&nl)";
var ini_left/style(data)=[cellwidth=2in];
var col1-col5/style(data)=[cellwidth=1in];
label   col1="-"
        col2="I"
		col3="II"
		col4="III"
		col5="IV"
		ini_left="Initial Left Grade *by Minimum Left Grade";
run;

proc print data=tableright noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Right IVH Grade Non-Progressors (n=&nr)";
var ini_right/style(data)=[cellwidth=2in];
var col1-col5/style(data)=[cellwidth=1in];
label   col1="-"
        col2="I"
		col3="II"
		col4="III"
		col5="IV"
		ini_right="Initial Right Grade *by Minimum Right Grade";
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=1.5in RIGHTMARGIN=0.5in font_size=10pt}
* There are &nlr1 bilateral IVH patients and &nlr0 unilateral IVH patients.";
ods rtf close;

