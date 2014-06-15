options nodate nonumber orientation = portrait;
%include "/ttcmv/sas/programs/include/monthly_internal_toc.sas"; 
%let path=/ttcmv/sas/output/monthly_internal/;

proc format;
value item 0="== Overall =="
		1="- Patients ever on mechanical ventilation"
		2=" "
		3="- Ventilator-free days"
		4="== Patients on Mechanical Ventilation Only =="
		5="- Adjusted number of days on ventilator *"
		6="- Ventilator-free days"
;
run;


%let n=0;

data _null_;
	set	cmv.completedstudylist;
	call symput("n", compress(_n_));
run;


%macro mv(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 10;
		center=floor(id/1000000);
		VentType=VentType&i;
		StartDate=StartDate&i;
		EndDate=EndDate&i;
		day=EndDate-StartDate;
		InitialFio2=InitialFio2_&i;
		FinalFio2=FinalFio2_&i;
		Fio2=FinalFio2-InitialFio2;
		comment=comment&i;
		i=&i;
		
		output;
	%end;
	   
	   if venttype=99 then delete;
	   keep id center VentType StartDate EndDate day InitialFio2 FinalFio2 Fio2 comment i; 
	   format venttype vent. StartDate EndDate mmddyy8. center center.;
run;
%mend;

%mv(cmv.mechvent);quit;

data tmp;
    set tmp;
    if venttype=99 then delete;
run;


proc means data=tmp noprint sum;
    class id;
    var day;
    ouput out=temp(where=(id^=.)) sum(day)=sday;
run;

data mvent;
    merge temp(in=A) cmv.plate_005(keep=id LBWIDOB) cmv.endofstudy(keep=id StudyLeftDate) cmv.completedstudylist(keep=id in=comp); by id;
    
    if comp;
    fday=StudyLeftDate-lbwidob;
    if sday>fday then sday=fday;
    if sday=. then sday=0;
    
    vfreeday=fday-sday;
    
	/* For temparily coding here*/
    if id=3033611 then sday=64;
    if id=3041211 then sday=10;  
        
    if sday>0 then mvent=1; else mvent=0;
run;


proc freq data=mvent;
	table mvent/out=tab;
run;

data _null_;
	set tab;
	if mvent=1 then call symput("n_yes", put(count,3.0));
run;

data mv_yes;
	set mvent;
	where mvent=1;
run;

data tab;
	length tmp $ 50;
	set tab(where=(mvent=1));	
	item=0; tmp="n(%)"; output;
	item=1; tmp=compress(count||"/"||compress(&n)||"("||compress(put(percent,4.1))||"%)");output;
run;

proc sort nodupkey; by item tmp;run;

proc univariate data=mvent noprint;
	var vfreeday;
	output out=one median=median Q1=Q1 Q3=Q3;
run;

data one;
	length tmp $ 50;
	set one;
	item=2; tmp="med.[Q1,Q3],n"; output;
	item=3; tmp=compress(put(median,4.1)||"["||compress(put(Q1,3.0))||","||compress(put(Q3,3.0))||"],"||compress(&n));output;
run;

proc univariate data=mv_yes noprint;
	var sday;
	output out=two median=median Q1=Q1 Q3=Q3;
run;

data two;
	length tmp $ 50;
	set two;
	item=4; tmp=" "; ouput;
	item=5; tmp=compress(put(median,4.1)||"["||compress(put(Q1,3.0))||","||compress(put(Q3,3.0))||"],"||compress(&n_yes));output;
run;

proc sort nodupkey; by item tmp;run;

proc univariate data=mv_yes noprint;
	var vfreeday;
	output out=three median=median Q1=Q1 Q3=Q3;
run;

data three;
	length tmp $ 50;
	set three;
	item=6; tmp=compress(put(median,4.1)||"["||compress(put(Q1,3.0))||","||compress(put(Q3,3.0))||"],"||compress(&n_yes));output;
run;


data tab;
	set tab one two three; by item tmp;
	format item item.;
run;


options nodate nonumber orientation = portrait;

ods rtf file="&path.&file_mech_vent.mv.rtf" style=journal bodytitle;
*title "&title_mech_vent.Mechanical Ventilation Summary";
title "&title_mech_vent";
proc print data=tab label noobs style(data)=[just=left];
*where item^=6;
var item;
var tmp/style(data)=[just=center];
label  item=". "
			tmp=". "
		;
run;

ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=1in RIGHTMARGIN=1in}
*A LBWI must be breathing without the aid of a ventilator for at least 48 hours to be considered weaned from the ventilator.';

ods rtf close;
	
