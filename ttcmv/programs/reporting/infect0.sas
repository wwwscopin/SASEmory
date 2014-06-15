options nodate;

data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	center=floor(id/1000000);
	format center center.;
run;

proc sort data=all_pat nodupkey; by id;run;


%let nt=0;
data _null_;
	set all_pat;
	call symput("nt", compress(_n_));
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

data cmv.infect;
    set tmp;
run;

proc freq; 
tables CultureYes*Culturepositive;
run;

*****************************************************************************;
%let nr=0;
data _null_;
	set tmp;
	call symput("nr", compress(_n_));
run;
%put &nr;

proc format; 
value yn	0="No"	1="Yes";

value item  1="Was a culture related to this infection obtained?"
			2="Was a culture related to this infection positive?"
			;
			
value site
			1="Bloodstream"
			2="Central Nervous System Infection"
			3="Cardiovascular System Infection"
    		4="Lower respiratory tract Infection"
			5="Gastrointestinal System Infection"			
			6="Surgical Site Infection"
			7="Urinary Tract Infection"
			8="Other Site Infection"
			9=" "
			99="-- Any Site Infection -- "
		;
run;


data infect;
	set tmp;
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	if CultureOrg=.  then delete;		
run;

proc sort data=infect(where=(SiteBlood or SiteCNS or SiteCardio or SiteLowerResp or SiteGI or SiteSurgical or SiteUT or SiteOther)) out=infect_id nodupkey; by id; run;

%let n=0;
data _null_;
	set infect_id;
	call symput("n", strip(_n_));
	f=_n_/&nt*100;
	call symput("f", put(f,4.2));
run;
%put &nt;
%put &nr;
%put &n;

%macro CYP(data, out, varlist);

data &out;   if 1=1 then delete; run;

%let i=1;
%let var=%scan(&varlist,&i);
%do %while (&var NE);

proc freq data=&data; 
tables  &var/norow nocol nopercent;
ods output OneWayFreqs=tab1;
run;

proc sort data=&data nodupkey out=&data.1; by id &var;run;

proc freq; 
tables  &var/norow nocol nopercent;
ods output onewayfreqs=tab2;
run;

data tabA;
	merge tab1(rename=(frequency=m)) tab2(rename=(frequency=n)); by &var;
	f=n/&n*100;
	nf=m||"/"||compress(n);
run;

proc transpose data=tabA out=tabB; var nf;run;

data tabB;
    set tabB(rename=(col1=No col2=Yes));
   	item=&i;
run;

data &out;
    set &out tabB;
   	format item item.;
	drop _name_;
run;

%let i=%eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend CYP;

%let varlist=CultureYes CulturePositive;
%CYP(tmp,tab,&varlist);

*****************************************************************************;

proc sort data=infect out=infect1 nodupkey; by id CultureSite CultureSiteOther CultureOrg CultureOrgOther; run;
proc sort data=infect out=infect2 nodupkey; by id CultureSite; run;
proc print;
where culturesite=9;
var id culturesite siteother;
run;

proc print;
where siteother=1;
var id culturesite siteother;
run;

proc freq; 
tables CultureSite;
ods output onewayfreqs=site;
run; 

data culturesite;
	set site;
	cultureorg=99;
run;

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

	if culturesite=. and cultureorg^=.  then delete;
	if culturesite=9 and cultureorg^=.  then delete;

	if culturesite^=. and cultureorg=.  then do; 
					cultureorg=99; culture_org="== Any "||strip(put(culturesite,culturesite.))||" =="; 
			end;
	if culturesite=. and cultureorg=.  then do; 
			culturesite=99; cultureorg=99; culture_site="=== Any Infection ===";
			culture_org=" ";
	end;
	
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;
proc sort; by culturesite cultureorg; run;

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
proc sort; by culturesite cultureorg; run;

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

proc sort; by culturesite cultureorg; run;

data Org_&out;
	set tab0 tab1 tab2 tab3; by culturesite cultureorg;
	where count^=0;
run;
proc sort; by culturesite cultureorg; run;

%mend infect;

%infect(data=infect, out=count);quit;
%infect(data=infect1, out=id);quit;

data Org;
	merge Org_count(rename=(count=n_count)) Org_id(rename=(count=n_id))
	culturesite(keep=culturesite cultureorg frequency rename=(frequency=n_id)); by culturesite cultureorg;
	if culturesite=99 and cultureorg=99 then n_id=&n;
	pct=n_id/&nt*100;
	incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	if 	culturesite=99 and cultureorg=99 then 	incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	if 	cultureorg=0 then incident=" ";
run;

data Org;
	set Org; by notsorted Culture_site;
	if not first.Culture_site then Culture_site=" ";
run;

*********************************************************************************;

%macro site_infect(data,out, varlist);

data &out; if 1=1 then delete;run;

%let i=1; 
%let var=%scan(&varlist, &i);
%do %while(&var NE);

proc sort data=&data out=tmp nodupkey; by id descending &var cultureorg; run;

data tmp;
    set tmp; by id descending &var cultureorg;
    if first.id;
run;

proc freq data=&data;
	table &var*CultureOrg/nocol norow nopercent;
	table &var;
	ods output CrossTabFreqs=tabA(drop=table  _TYPE_  _TABLE_ Missing);
	ods output onewayfreqs=tabA0(drop=table  _TYPE_  _TABLE_ Missing);
run;
proc sort data=tabA; by &var cultureorg;run;

proc freq data=tmp; 
    tables &var*CultureOrg/norow nocol nopercent;
   	table &var;
    ods output crosstabfreqs=tabB; 
   	ods output onewayfreqs=tabB0;
run; 
proc sort data=tabB; by &var cultureorg;run;

data tabA&i;
    merge tabA(rename=(frequency=n)) tabB(rename=(frequency=m)); by &var cultureOrg;
    if _type_=11 and &var=1 and m^=0;
    f=m/&nt*100;
    nf=compress(n)||"("||compress(m)||"/"||compress(&nt)||","||put(f,4.1)||"%)";
    cultureorg0=put(cultureorg, cultureorg.);
        site=&i;
    keep cultureorg cultureorg0 n m f nf site;
run;

data tabB&i;
    merge tabA0(rename=(frequency=n)) tabB0(rename=(frequency=m)); by &var;
    if _n_=2;
    f=m/&nt*100;
    nf=compress(n)||"("||compress(m)||"/"||compress(&nt)||","||put(f,4.1)||"%)";
    site=&i;
    cultureorg0="==Any "||strip(put(site, site.))||"==";
    cultureorg=99;
    keep n m f nf site cultureorg cultureorg0;
run;

data tab&i;
    set tabA&i tabB&i;
run;

data tab&i;
    if _n_=1 then do; site=&i; output; end;
    set tab&i; output;
run;

data &out;  
    length site0 $100;
    set &out tab&i;
    keep site cultureorg cultureorg0 site0 nf;
    format site site.;
    site0=put(site, site.);
run;
proc sort; by site cultureorg; run;

data &out;  
    set &out; by site cultureorg;
    if not first.site then site0=" ";
run;

%let i=%eval(&i+1);
%let var=%scan(&varlist, &i);
%end;

*********** For Any SiteOther Infection **************************************;
proc freq data=infect;
	table InfectionSiteOther*CultureOrg/nocol norow nopercent out=otherinf;
run;

data otherinf;
	length site0 $60;
	set otherinf;
	where InfectionSiteOther^=" ";
	site=8;
	site0="--"||strip(InfectionSiteOther)||"("||compress(put(count,2.0))||")";
run;
proc sort; by CultureOrg;run;

data &out;
	length site0 $60;
	set &out otherinf; by site cultureorg;
run;

******  For Any Infection ***********************;
proc sort data=&data(where=(SiteBlood or SiteCNS or SiteCardio or SiteLowerResp or SiteGI or SiteSurgical or SiteUT or SiteOther)) out=end0; by id; run;
data _null_;
    set end0;
    call symput("m0", compress(_n_));
run;

proc sort out=end1 nodupkey; by id; run;
data _null_;
    set end1;
    call symput("m1", compress(_n_));
run;

data end;
    length site0 $100;
    site=99;  
    cultureorg0=" ";
    f=&m1/&nt*100;
    nf="&m0(&m1/&nt,"||put(f,4.1)||"%)";
    site0="== Any Site Infection ==";
run;

data &out;
    set &out end;
run;
%mend site_infect;

%let varlist=SiteBlood SiteCNS SiteCardio SiteLowerResp SiteGI SiteSurgical SiteUT SiteOther;
*%let varlist=SiteBlood SiteCNS SiteLowerResp SiteGI SiteUT SiteOther;
%site_infect(infect, count, &varlist);

ods rtf file="infect.rtf" style=journal bodytitle startpage=no;
title "Infection information for &n0 of &nt LBWIs with CRF completed";
proc print data=tab noobs label split="*"; 
var item;
var no yes/style(data)=[just=center] style(header)=[just=center];
label   item="Question"
		   No="No*#Num/#Patients"
	   	Yes="Yes*#Num/#Patients"
		;
run;

title "Culture Site - Cultured Organisms (n=&nt)";
proc print data=org noobs label split="*"; 
var culture_site culture_org;
var incident/style(data)=[just=center] style(header)=[just=center];
label   Culture_site="Culture Site"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;
ods rtf close;


ods rtf file="site_infect.rtf" style=journal bodytitle startpage=no;
title "Infection Site (n=&nt)";
proc print data=count noobs label split="*" style(data)=[just=left]; 

var site0/style(header)=[just=left]; 
var nf/style(data)=[just=center] style(header)=[just=center];
var cultureorg0;
label   site0="Site of Infection"
		   CultureOrg0="Cultured Organism"
	   	nf="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;
ods rtf close;
