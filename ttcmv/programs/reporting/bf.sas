options nodate nonumber papersize=("7" "8");

libname wbh "/ttcmv/sas/data";

data all_pat;
	set wbh.comp_pat;
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;


data _null_;
	set  all_pat;
	call symput("n",compress(_n_));
run;

%macro bf(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 15;
		center=floor(id/1000000);
		Comments=Comments&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		donor_milk=donor_milk&i;
		fresh_milk=fresh_milk&i;
		frozen_milk=frozen_milk&i;
		moc_milk=moc_milk&i;
		i=&i;
		if StartDate=. and EndDate=. then delete;
		output;
	%end;

		keep id center donor_milk moc_milk fresh_milk frozen_milk EndDate Startdate i /*Comments  DFSEQ DFSTATUS DFVALID MOCInit*/; 
		format  StartDate EndDate mmddyy8. center center.;
run;
%mend;

%bf(cmv.breastfeedlog);quit;

proc sql;
	create table milk as
	select a.*, dob 
	from 	tmp as a,	all_pat as b
	where a.id=b.id
	;

proc sort; by id i; run;

data milk; 
	set milk; 
	day1=startdate-dob;
	day2=enddate-dob;
	wk1=round(day1/7);
	wk2=round(day2/7);
	if wk1=. then wk1=0; 
	if wk2=. then wk2=0; 
	do i=wk1 to wk2 by 1; 
		wk=i; output;
	end;
run;

data milk;
	set milk; 
	if wk=0 then wk=1; 
run;

proc sort nodupkey; by id wk;run;

proc sort data=milk out=milk0 nodupkey; by id; run;

*******************************************************************************************************;
proc sql;
	create table bfstatus as
	select a.id, FeedStatus, floor(a.id/1000000) format=center. as center 
	from 	wbh.comp_pat as a,	cmv.plate_020 as b
	where a.id=b.id and feedstatus=1;
	;

proc sort nodupkey; by id center; run;


proc sql;
	create table pending_id as 
	select id
	from bfstatus
	except 
	select id
	from milk;

*******************************************************************************************************;




%let n_bf=0;
data _null_;
	set milk0;
	call symput("n_bf", strip(_n_));
run;

%let n_moc_fresh=0; %let n_moc_fresh=0; %let n_donor_fresh=0; %let n_donor_fresh=0;

data milk1 milk2 milk3 milk4;
	set milk;
	if moc_milk and fresh_milk then output milk1;
	if moc_milk and frozen_milk then output milk2;
	if donor_milk and fresh_milk then output milk3;
	if donor_milk and frozen_milk then output milk4;
run;

proc sort data=milk1 nodupkey; by id; run;
data _null_;
	set milk1;
 	call symput("n_moc_fresh",_n_);
run;

proc sort data=milk2 nodupkey; by id; run;
data _null_;
	set milk2 ;
 	call symput("n_moc_frozen",_n_);
run;

proc sort data=milk3 nodupkey; by id; run;
data _null_;
	set milk3;
 	call symput("n_donor_fresh",_n_);
run;

proc sort data=milk4 nodupkey; by id; run;
data _null_;
	set milk4;
 	call symput("n_donor_frozen",_n_);
run;

%macro feed(data,source);

proc freq data=&data;

	%if &source=moc %then %do; where moc_milk=1; %end;
	%if &source=donor %then %do; where donor_milk=1; %end;
	table wk*(fresh_milk frozen_milk)/norow nocol nopercent;
	ods output Freq.Table1.CrossTabFreqs=tab1(drop=table  _TYPE_  _TABLE_ Missing);
	ods output Freq.Table2.CrossTabFreqs=tab2(drop=table  _TYPE_  _TABLE_ Missing);
run;

proc sort data=tab1; by wk; run;
proc sort data=tab2; by wk; run;

data tab_&source;
	merge tab1(where=(fresh_milk=1) rename=(frequency=fresh)) tab2(where=(frozen_milk=1) rename=(frequency=frozen)); by wk;
	if wk=. then delete; output;
	%if &source=moc %then %do;
		wk=100;	fresh=&n_moc_fresh; frozen=&n_moc_frozen;
	%end;
	%if &source=donor %then %do;
		wk=100; fresh=&n_donor_fresh; frozen=&n_donor_frozen;
	%end; output;
run;

proc sort nodupkey; by wk; run;

%mend feed;

%feed(milk, moc);
%feed(milk, donor);quit;

data feed_moc;
	set tab_moc; by wk; 
	pct_fresh=fresh/&n*100;
	pct_frozen=frozen/&n*100;
	tmp_fresh=fresh||"("||put(pct_fresh, 4.1)||"%)";	
	tmp_frozen=frozen||"("||put(pct_frozen, 4.1)||"%)";
	format wk wk.;
	rename tmp_fresh=fresh_moc tmp_frozen=frozen_moc;
run;


data feed_donor;
	set tab_donor; by wk; 
	if fresh=. then fresh=0;
	if frozen=. then frozen=0;


	pct_fresh=fresh/&n*100;
	pct_frozen=frozen/&n*100;
	tmp_fresh=fresh||"("||put(pct_fresh, 4.1)||"%)";	
	tmp_frozen=frozen||"("||put(pct_frozen, 4.1)||"%)";
	rename tmp_fresh=fresh_donor tmp_frozen=frozen_donor;

	format wk wk.;
run;

proc print data=feed_donor;run;

data wbh.bmfeed;
	merge feed_moc(keep=wk fresh_moc frozen_moc) feed_donor(keep=wk fresh_donor frozen_donor); by wk;
run;

goptions reset=global gunit=pct border
hsize=7 in vsize=5 in;

ods printer printer="PostScript EPS Color" file = "breastfeed.eps" style=journal;
ods ps file = "breastfeed.ps" style=journal;
ods pdf file = "breastfeed.pdf" style=journal;
ods rtf file = "breastfeed.rtf" style=journal startpage=no bodytitle;
ods tagsets.simplelatex file="&dir.bf1.tex"  stylesheet="sas.sty"(url="sas_wbh");
ods tagsets.tablesonlylatex file="&dir.bf.tex" (notop nobot) newfile=table style=journal;

title  "Summary of Breast Milk Collection (n=&n)";
proc print data=wbh.bmfeed noobs label split="*" style(data)=[just=center];
var wk/style(data)=[just=left];
var fresh_moc frozen_moc fresh_donor frozen_donor;
	label wk="Week"
		fresh_moc="Fresh Milk:* #MOC(%)"
		frozen_moc="Frozen Milk:* #MOC(%)"
		fresh_donor="Fresh Milk:* #Donor(%)"
		frozen_donor="Frozen Milk:* #Donor(%)"
	;
run;
/*
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
*For 0-2 week, the data include donor milk,which is 20(7/42,16.7%).
#For 6-8 week, the data include donor milk,which is 1(1/42,2.4%).';
*/

ods tagsets.tablesonlylatex close;
ods tagsets.simplelatex close;
ods rtf close;
ods pdf close;
ods ps close;
ods printer close;


ods rtf file="breastfeed_id.rtf";

proc print data=milk0;

var id;
run;

ods rtf close;
