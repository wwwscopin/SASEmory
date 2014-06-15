
%let pm=%sysfunc(byte(177));

proc format;

value item 0="Characteristic"
		1="Total days in the hospital"
		2="  Mean &pm sd "
		3="  Median &pm mad "
		4='  Range '
;
run;



%let n=0;

data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	keep id;
run;

data all_pat;
	set	all_pat;
	call symput("n", compress(_n_));
run;

data dob0;
   set cmv.LBWI_Demo;
   keep id LBWIDOB;
	rename LBWIDOB=dob;
run;

proc sql;
	create table dob as 
	select a.*
	from dob0 as a, all_pat as b
	where a.id=b.id
;

data eos;
   set cmv.endofstudy;
   keep id StudyLeftDate Reason;
run;

proc sql;
	create table hop as 
	select a.*, b.StudyLeftDate, b.Reason
	from dob as a
	left join
	eos as b
	on a.id=b.id
;

data hop;
	set hop;
	if dob=. then delete;
	day=StudyLeftDate-dob;
	if day=. then day=today()-dob;
run;

title "xxx";
proc print;run;

proc means data=hop median;
	var day;
	output out=hop_med n(day)=n median(day)=med; 
run;

data _null_;
	set hop_med;
	call symput("med",compress(med));
	call symput("n_hop",compress(n));
run;

data hop;
	set hop;
   med=compress(&med);
 	dev=abs(med-day);
run;

proc means data=hop;
	var day dev;
	output out=duration n(day)=n mean(day)=mean std(day)=std median(day)=med std(dev)=mad min(day)=min max(day)=max; 
run;

data duration;
	length tmp $50;
	set duration;
	/*item=0; tmp="Total(n=compress(&n))";output;*/
	/*item=1; tmp="n=&n_hop";output;*/
	item=1; tmp=" ";output;
	item=2; tmp=compress(put(mean,4.1))||" &pm "||compress(put(std,4.1));output;
	item=3; tmp=compress(put(med,4.1))||" &pm "||compress(put(mad,4.1));output;
	item=4; tmp=compress(put(min,4.1))||" &pm "||compress(put(max,4.1));output;
	format item item.;
run;

ods escapechar='^';
options nodate nonumber orientation = portrait;
*ods rtf file = "&output./monthly/&qc_report_file.qc_table.rtf"  style = journal toc_data startpage = yes bodytitle;
ods rtf file = "hop.rtf"  style = journal toc_data startpage = yes bodytitle;
*ods noproctitle proclabel "&qc_report_title Center QC Reports ";
ods noproctitle proclabel "Duration of Hospitalization";

*title1  justify = center "&qc_report_title. Data Query Report:";
title1  justify = center "Duration of Hospitalization (Days)";

proc print data=duration label noobs split="*" style(data)=[just=left];
var item;
var tmp/style(data)=[just=center];
label  item="Characteristic"
			tmp="Total*n=&n"
		;
run;

ods rtf close;
	
