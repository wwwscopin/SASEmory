options nodate;

data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	center=floor(id/1000000);
	format center center.;
run;

proc sort data=all_pat nodupkey; by id;run;


%let n=0;
data _null_;
	set all_pat;
	call symput("n", compress(_n_));
run;

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
		output;
	%end;

		keep id center CultureDate CultureOrg CultureOrgOther CultureSite CultureSiteOther CulturePositive CultureYes i 
		InfecConfirm SiteBlood SiteCNS SiteCardio SiteGI SiteLowerResp SiteSurgical SiteUT SiteOther InfectionSiteOther
		XrayDate Comments  /*DFSEQ DFSTATUS DFVALID MOCInit*/; 
		format CultureDate XrayDate mmddyy. center center. InfecConfirm InfecConfirm. CultureYes CultureYes. CulturePositive CulturePositive. CultureSite CultureSite. CultureOrg CultureOrg. i CulturePos.;
run;
%mend;

%data(cmv.infection_all);quit;

proc sort data=tmp out=infect_id nodupkey; by id; run;
%let n_infect=0;
data _null_;
	set infect_id;
	call symput("n_infect", strip(_n_));
run;


data infect;
	set tmp;
	if CultureOrg=.  then delete;
run;

proc print;

where CultureOrg=9;
run;


proc sort data=infect out=infect1 nodupkey; by id CultureSite CultureSiteOther cultureorg cultureorgother;run;

%macro site_infect(dataset=data,out=count);
ods output Freq.Table1.CrossTabFreqs=tab0(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table2.CrossTabFreqs=tab1(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table3.CrossTabFreqs=tab2(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table4.CrossTabFreqs=tab3(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table5.CrossTabFreqs=tab4(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table6.CrossTabFreqs=tab5(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table7.CrossTabFreqs=tab6(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table8.CrossTabFreqs=tab7(drop=table  _TYPE_  _TABLE_ Missing);


proc freq data=&dataset;
	table (SiteBlood SiteCNS SiteCardio SiteLowerResp SiteGI SiteSurgical SiteUT SiteOther)*CultureOrg/nocol norow nopercent;
run;

%macro site(data,var);
%if &data=tab0 %then %do;  %let  code=1; %end;
%if &data=tab1 %then %do;  %let  code=2; %end;
%if &data=tab2 %then %do;  %let  code=3; %end;
%if &data=tab3 %then %do;  %let  code=4; %end;
%if &data=tab4 %then %do;  %let  code=5; %end;
%if &data=tab5 %then %do;  %let  code=6; %end;
%if &data=tab6 %then %do;  %let  code=7; %end;
%if &data=tab7 %then %do;  %let  code=8; %end;


data &data;
	set &data;
		site=&code;
		if &var=1 and frequency^=0;
		culture_org=put(cultureorg, cultureorg.);
		if cultureorg=. then do; cultureorg=99; culture_org="== Any "|| strip( put(site,site.))||" =="; end;
run;
%mend site;

%site(tab0, SiteBlood);
%site(tab1, SiteCNS);
%site(tab2, SiteCardio);
%site(tab3, SiteLowerResp);
%site(tab4, SiteGI);
%site(tab5, SiteSurgical);
%site(tab6, SiteUT);
%site(tab7, SiteOther);
quit;


data site_&out;
	set tab0 tab1 tab2 tab3 tab4 tab5 tab6 tab7; by site;
	keep site frequency cultureorg culture_org;
run;

%mend site_infect;

%site_infect(dataset=infect, out=count);
proc sort; by site cultureorg; run;
proc print;run;
%site_infect(dataset=infect1, out=id);quit;
proc sort; by site cultureorg; run;
proc print;run;

data site;
	merge site_count(rename=(frequency=n_count)) site_id(rename=(frequency=n_id)); by site cultureorg;
	pct=n_id/&n*100;
	incident=n_count||"("||compress(n_id)||"/"||compress(&n)||"," ||put(pct,5.1)||"%)";
	if not first.site then site=99;
	format site site.;
run;


ods rtf file="site_infect.rtf" style=journal;

title "Infection or Sepsis - Infection Site (n=&n)";
proc print data=site noobs label split="*" style(data)=[just=left]; 

var site; 
var incident/style(data)=[just=center];
var culture_org;
label   site="Site of Infection"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

ods rtf close;

