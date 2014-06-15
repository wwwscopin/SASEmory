options orientation=landscape nobyline;
libname wbh "/ttcmv/sas/programs/reporting";

data demo_pat;
	set cmv.pat;
	if id=1002821 then do; gestage=29; BirthWeight=0945; length=35.6; HeadCircum=24.5; end;
run;
proc print;run;

proc means data=demo_pat;
	var gestage BirthWeight length HeadCircum;
	output out=num n(gestage)=n_age n(BirthWeight)=n_wt n(length)=n_len n(HeadCircum)=n_head;
run;

%let n_age=0; 
%let n_wt=0; 
%let n_length=0; 
%let n_head=0;

data _null_;
	set num;
	call symput ("n_age", compress(n_age));
	call symput ("n_wt", compress(n_wt));
	call symput ("n_len", compress(n_len));
	call symput ("n_head", compress(n_head));
run;


proc greplay igout= wbh.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

goptions reset=global gunit=pct border /*colors=(orange green red)*/
	ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;

%macro plot(data);

%let x=1;
%do %while (&x <5); 
  
	%if &x = 1 %then %do; 	
		%let var =gestage; %let description = f=zapf "Bar Chart for Gestational Age (n=&n_age)";
		%let mp=(23 to 38 by 1); 
 		axis1 label=(a=90 h=4 c=black "Percentage (%)") order=(0 to 20 by 2) minor=none;
		axis2 label=(a=0 h=4 c=black "Gestational Age (Weeks)") order=(23 to 38 by 1) minor=none;
	%end;

	%if &x = 2 %then %do; 	
		%let var =BirthWeight; %let description = f=zapf "Bar Chart for  Birth Weight (n=&n_wt)";
		%let mp=(400 to 1500 by 100); 
 		axis1 label=(a=90 h=4 c=black "Percentage (%)") order=(0 to 20 by 2) minor=none;
		axis2 label=(a=0 h=4 c=black "Birth Weight (g)") order=(400 to 1500 by 100) minor=none;
	%end;

	%if &x = 3 %then %do; 	
		%let var =length; %let description = f=zapf "Bar Chart for  Birth Length (n=&n_len)";
		%let mp=(23 to 43 by 1);
 		axis1 label=(a=90 h=4 c=black "Percentage (%)") order=(0 to 20 by 2) minor=none;
		axis2 label=(a=0 h=4 c=black "Birth Length (cm)") order=(23 to 43 by 1) minor=none;
	%end;

	%if &x = 4 %then %do; 	
		%let var =headcircum; %let description = f=zapf "Bar Chart for  Head Circumference (n=&n_head)";
		%let mp=(20 to 30 by 1);
 		axis1 label=(a=90 h=4 c=black "Percentage (%)") order=(0 to 20 by 2) minor=none;
		axis2 label=(a=0 h=4 c=black "Head Circumference (cm)") order=(20 to 30 by 1) minor=none;
	%end;
	
	title &description;
	Proc gchart data=&data gout=wbh.graphs;
		vbar &var/ midpoints=&mp raxis=axis1 maxis=axis2 space=0.5 coutline=black TYPE=pct  ;
	run;


%let x=%eval(&x+1);
   %end;
%mend plot;  

%plot(cmv.pat);quit;

/*
ods pdf file = "birth_histo.pdf";
proc greplay nofs;
	igout wbh.graphs;
	list igout;
	tc template;
	tdef t1  1/llx=0  ulx=0  lrx=50  urx=50  lly=50 uly=100 lry=50 ury=100
				 2/llx=50 ulx=50 lrx=100 urx=100 lly=50 uly=100 lry=50 ury=100
				 3/llx=0  ulx=0  lrx=50  urx=50  lly=0  uly=50  lry=0  ury=50
				 4/llx=50 ulx=50 lrx=100 urx=100 lly=0  uly=50  lry=0  ury=50
			;
	template t1;
	tplay 1:1 2:2 3:3 4:4;
run; quit;
ods pdf close;
*/



ods pdf file = "birth_histo.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= l2r2s nofs; * L2R2s;
     treplay 1:1 2:3 3:2 4:4;
     *treplay 1:3 2:4;
run;
ods pdf close;
