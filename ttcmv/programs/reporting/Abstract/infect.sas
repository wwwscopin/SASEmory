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
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	if CultureOrg=.  then delete;		
run;

proc print;
where id=1001011;
run;

proc sort data=infect; by id; run;
proc sort data=infect out=infect1 nodupkey; by id CultureSite CultureSiteOther CultureOrg CultureOrgOther; run;


%macro infect(data=data,out=count);

ods output Freq.Table1.CrossTabFreqs=tab0(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table2.CrossTabFreqs=tab1(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table3.CrossTabFreqs=tab2(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table4.CrossTabFreqs=tab3(drop=table  _TYPE_  _TABLE_ Missing);

proc freq data=&data;
	table CultureSite*CultureOrg CultureSite*CultureOrgOther CultureSiteOther*CultureOrg CultureSiteOther*CultureOrgOther/nocol norow nopercent;
run;

data tab0;
	length	culture_site $ 60 culture_org $50;
	set tab0;
	culture_site=put(culturesite,culturesite.);
	culture_org=put(cultureorg,cultureorg.);

	if culturesite=. and cultureorg^=.  then do; 
					culturesite=100; culture_site="== Any "||strip(put(cultureorg,cultureorg.))||" =="; 
			end;
	if culturesite^=. and cultureorg=.  then do; 
					cultureorg=100; culture_org="== Any "||strip(put(culturesite,culturesite.))||" =="; 
			end;
	if culturesite=. and cultureorg=.  then do; 
			culturesite=100; cultureorg=100; culture_site="=***= Any Infection =***=";
			culture_org=" ";
	end;
	
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;


data tab1;
	set tab1;
	culture_site=put(culturesite,culturesite.);
	culture_org="--"||cultureorgother;

   if culturesite=. or cultureorgother=" "  then delete;
	if culturesite=9 then delete;

	cultureorg=27;
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;

data tab2;
	set tab2;
	culture_site="--"||culturesiteother;
	culture_org=put(cultureorg,cultureorg.);

	culturesite=9;
	if cultureorg=27 then delete;
	if culturesiteother=" " or cultureorg=. then delete;
	
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;

proc sort; by culturesite cultureorg; run;

data tab3;
	set tab3;
	if culturesiteother="Cath urine" then delete;
	culture_site="--"||culturesiteother;
	culture_org="--"||cultureorgother;
	
	culturesite=9; cultureorg=27;

	if culturesiteother=" " or cultureorgother=" " then delete;
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
	if frequency=0 then delete;
run;
/*
title "wbh_&out";
proc print data=tab3;run;
*/

proc sort; by culturesite cultureorg; run;

data Org_&out;
	set tab0 tab1 tab2 tab3; by culturesite cultureorg;
	where count^=0;
run;

%mend infect;

%infect(data=infect, out=count);quit;
%infect(data=infect1, out=id);quit;

data Org;
	merge Org_count(rename=(count=n_count)) Org_id(rename=(count=n_id)); by culturesite cultureorg;
	if culturesite=100 and cultureorg=100 then n_id=&n_infect;
	pct=n_id/&n*100;
	incident=n_count||"("||compress(n_id)||"/"||compress(&n)||"," ||put(pct,5.1)||"%)";
run;


data Org;
	set Org; by notsorted Culture_site;

/*
	if Cultureorg not in (2,3) then do;
			Culture_org=propcase(Culture_Org);
		end;

	if Culturesite not in(5,6) then do;
			Culture_site=propcase(Culture_site);
		end;
*/
	if not first.Culture_site then Culture_site=" ";
run;


ods rtf file="infect.rtf" style=journal;

title "Infection or Sepsis - Cultured Organisms (n=&n)";
proc print data=org noobs label split="*"; 
where culturesite<=4;
var culture_site culture_org;
var incident/style(data)=[just=center];
label   Culture_site="Culture Site"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

proc print data=org noobs label split="*"; 
where 100>culturesite>4 ;
var culture_site culture_org;
var incident/style(data)=[just=center];
label   Culture_site="Culture Site"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

proc print data=org noobs label split="*"; 
where culturesite=100 ;
var culture_site;
var incident/style(data)=[just=center];
label   Culture_site="Culture Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

ods rtf close;












