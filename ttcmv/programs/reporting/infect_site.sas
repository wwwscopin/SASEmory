options orientation=portrait nodate nonumber nofmterr;
%let mu=%sysfunc(byte(181));

data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	center=floor(id/1000000);
	format center center.;
run;

proc sort data=all_pat nodupkey; by id;run;
data _null_;
	set all_pat;
	call symput("nt", compress(_n_));
run;
%put &nt;

%macro data(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 6;
		center=floor(id/1000000);
		CultureDate=Culture&i.Date;
		CultureOrg=Culture&i.Org;
		CultureOrgOther=Culture&i.OrgOther;
		CultureSite=Culture&i.Site;
		CultureSiteOther=Culture&i.SiteOther;
		i=&i;
		if cultureorg^=.;
		output;
	%end;

		keep id center CultureDate CultureOrg CultureOrgOther CultureSite CultureSiteOther CulturePositive CultureYes i 
		InfecConfirm SiteBlood SiteCNS SiteCardio SiteGI SiteLowerResp SiteSurgical SiteUT SiteOther InfectionSiteOther
		XrayDate Comments  /*DFSEQ DFSTATUS DFVALID MOCInit*/; 
		format CultureDate XrayDate mmddyy. center center. InfecConfirm InfecConfirm. CultureYes CultureYes. CulturePositive CulturePositive. CultureSite CultureSite. CultureOrg CultureOrg. i CulturePos.;
run;
%mend;

%data(cmv.infection_all);quit;
proc sort; by id; run;

data infect;
	merge tmp all_pat(in=B); by id;
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	
	if SiteBlood then gbsi=1; else gbsi=0;
	if SiteBlood and cultureorg=3 then sub_mrsa=1; else sub_mrsa=0;
	if SiteBlood and cultureorg=2 then sub_mssa=1; else sub_mssa=0;
	if cultureorg=3 then mrsa=1; else mrsa=0;
	if cultureorg=2 then mssa=1; else mssa=0;
	if SiteCardio then gcard=1; else gcard=0;
	if SiteGI then ggi=1; else ggi=0;
	if SiteCNS then gcns=1; else gcns=0;
	if SiteLowerResp then glr=1; else glr=0;
	if SiteSurgical  then gss=1; else gss=0;
	if SiteUT then gut=1; else gut=0;
	if SiteOther then gother=1; else gother=0;
	if SiteBlood or SiteCardio or SiteGI or SiteCNS or SiteLowerResp or SiteSurgical or SiteUT or SiteOther then gi=1;else gi=0;
	if SiteBlood=0 and gi=1 then gnbsi=1; else gnbsi=0;
	if B;	
run;

proc freq data=infect; 
tables gbsi sub_mrsa sub_mssa mrsa mssa gcard ggi gcns glr gss gut gother gi gnbsi;
run;

proc sort data=infect out=infect_id nodupkey; by id; run;

data _null_;
	set infect_id;
	call symput("n", strip(_n_));
run;
proc sort data=infect; by id; run;

proc format;
		value site	
		        0="==Infection Site==" 
				1="Bloodstream Infection"
				2="Gastrointestinal System Infection"
				3="Central Nervous System Infection"
				4="Lower respiratory tract Infection"
				5="Urinary Tract Infection"
			    6="Other"
			    7="===================="
			    8="Any non-BSI infection"
			    9="Any MRSA"
	           10="Any infection";
run;

%macro pt(data,out,varlist);

data &out;	
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );


proc sort data=&data nodupkey out=&data._&var; by id descending &var; run;
data &data._&var.1;
    set &data._&var; by id descending &var;
    if first.id;
run; 

data &data._&var.0;
    set &data._&var; by id descending &var;
run; 

proc freq data=&data._&var.0;
table &var/nocol nopercent;
ods output onewayFreqs=temp&i;
run;

*ods trace on/label listing;
proc freq data=&data._&var.1;
table &var/nocol nopercent;
ods output onewayFreqs=tmp&i;
run;
*ods trace off;

data _null_;
	set temp&i;
	if &var=1 then call symput("m0", compress(frequency));
run;

data _null_;
	set tmp&i;
	if &var=1 then call symput("m1", compress(frequency));
	if &var=1 then call symput("m", compress(cumfrequency));
run;

data tab&i;
    length col $20;
	f=&m1/&m*100;	
	col="&m1/&m("||put(f,4.1)||"%)";
	*col="&m0/&m1/&m("||put(f,4.1)||"%)";
	item=&i	;
run;

data &out; 
	set &out tab&i;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;

data temp;
	item=0;output;
	item=7;output;
run;

data &out;
	set temp(where=(item=0))
		&out(where=(item<=6))
		temp(where=(item=7))
	 	&out(where=(item>6) in=A);
		if A then item=item+1;
    format item site. nvalue1 4.2; 
run;

%mend;
%let varlist=gbsi sub_mrsa sub_mssa gcard ggi gcns glr gss gut gother gnbsi mrsa mssa gi;
%let varlist=gbsi ggi gcns glr gut gother gnbsi mrsa gi;
%pt(infect,necinfect,&varlist);

options orientation=landscape;
ods rtf file="infect_site.rtf" style=journal bodytitle startpage=no;
proc print data=necinfect noobs label split="*"; 
title1 "Incident infection rates in the &nt LBWIs no longer hospitalized";
var item/style(data)=[just=left cellwidth=2.25in] style(header)=[just=left];
var col/style(data)=[just=center cellwidth=3in] style(header)=[just=center];
label   item="."
		col="#Patients (Incidence%)"
		;
run;
ods rtf close;
