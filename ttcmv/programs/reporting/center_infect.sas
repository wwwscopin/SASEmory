options nodate;

data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	center=floor(id/1000000);
	format center center.;
run;

proc sort data=all_pat nodupkey; by id;run;


proc means data=all_pat;

class center;
var id;
output out=num_id n(id)=n;
run;

%let nc1=0; %let nc2=0; %let nc3=0; %let nc=0;
data _null_;
	set num_id;
	if center=1 then call symput("nc1", compress(n));
	if center=2 then call symput("nc2", compress(n));
	if center=3 then call symput("nc3", compress(n));
	if center=. then call symput("nc", compress(n));
run;


/*
proc contents data=cmv.infection_all; run;
proc print data=cmv.infection_all; run;
*/

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
	*if CultureOrg=.  then delete;
run;



proc sort data=infect out=infect1 nodupkey; by id center;run;

ods output Freq.Table1.OneWayFreqs=tab0(drop=table  F_center   Cumfrequency);
proc freq data=infect;
	table center/nocol norow nopercent;
run;

ods output Freq.Table1.OneWayFreqs=tab1(drop=table  F_center   Cumfrequency);
proc freq data=infect1;
	table center/nocol norow nopercent;
run;

data _null_;
	set tab0;
	if center=1 then call symput("c1", compress(frequency));
	if center=2 then call symput("c2", compress(frequency));
	if center=3 then call symput("c3", compress(frequency));
run;

data _null_;
	set tab1;
	if center=1 then call symput("n1", compress(frequency));
	if center=2 then call symput("n2", compress(frequency));
	if center=3 then call symput("n3", compress(frequency));
run;

%let cc=%eval(&c1+&c2+&c3);
%let nn=%eval(&n1+&n2+&n3);	

data center;
	merge tab0(rename=(frequency=n_count)) tab1(rename=(frequency=n_id)); by center; output;
	center=8; n_count=&cc; n_id=&nn; output;
run;

proc sort nodupkey; by center; run;

data center;
	set center;
	if center=1 then do; pct=n_id/&nc1*100; incident=n_count||"("||compress(n_id)||"/"||compress(&nc1)||"," ||put(pct,5.1)||"%)"; end;
	if center=2 then do; pct=n_id/&nc2*100; incident=n_count||"("||compress(n_id)||"/"||compress(&nc2)||"," ||put(pct,5.1)||"%)"; end;
	if center=3 then do; pct=n_id/&nc3*100; incident=n_count||"("||compress(n_id)||"/"||compress(&nc3)||"," ||put(pct,5.1)||"%)"; end;
	if center=8 then do; pct=n_id/&nc*100; incident=n_count||"("||compress(n_id)||"/"||compress(&nc)||"," ||put(pct,5.1)||"%)"; end;
run;


ods rtf file="center_infect.rtf" style=journal;

title "Infection or Sepsis - Center (n=&nc)";
proc print data=center noobs label split="*" style(data)=[just=left]; 

var center; 
var incident/style(data)=[just=center];
label   center="Study Center"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

ods rtf close;

