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

proc sort nodupkey out=tmp_id; by id; run;

%let n0=0;
data _null_;
	set tmp_id;
	call symput("n0", compress(_n_));
	f=_n_/&nt*100;
	call symput("f", put(f,4.2));
run;
%put &f;


proc freq data=tmp; 
tables  CultureYes CulturePositive/norow nocol nopercent;
ods output  Freq.Table1.OneWayFreqs=tab1;
ods output  Freq.Table2.OneWayFreqs=tab2;
run;


proc sort data=tmp nodupkey out=CY; by id CultureYes;run;
proc sort data=tmp nodupkey out=CP; by id CulturePositive;run;

	
proc freq data=CY; 
tables  CultureYes/norow nocol nopercent;
ods output onewayfreqs=tab3;
run;

proc freq data=CP; 
tables  CulturePositive/norow nocol nopercent;
ods output onewayfreqs=tab4;
run;

data tabA;
	merge tab1(rename=(frequency=m)) tab3(rename=(frequency=n)); by CultureYes;
	f=n/&n0*100;
	nf=m||"/"||compress(n);
run;

proc transpose data=tabA out=tabA; var nf;run;

data tabB;
	merge tab2(rename=(frequency=m)) tab4(rename=(frequency=n)); by CulturePositive;
	f=n/&n0*100;
	nf=m||"/"||compress(n);
run;

proc transpose data=tabB out=tabB; var nf;run;

proc format; 
value yn	0="No"	1="Yes";

value item  1="Was a culture related to this infection obtained?"
			2="Was a culture related to this infection positive?"
			;
run;

data tab;
	set tabA(in=A rename=(col1=No col2=Yes)) tabB(in=B rename=(col1=No col2=Yes));
	if A then item=1;
	if B then item=2;
	format item item.;
	drop _name_;
run;
*****************************************************************************;


data infect;
	set tmp;
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	if CultureOrg=.  then delete;		
run;

proc sort data=tmp out=infect_id nodupkey; by id; run;

%let n=0;
data _null_;
	set infect_id;
	call symput("n", strip(_n_));
run;
%put &nt;
%put &nr;
%put &n0;
%put &n;

proc print;
where id=1001011;
run;

proc sort data=infect; by id; run;
proc sort data=infect out=infect1 nodupkey; by id CultureSite CultureSiteOther CultureOrg CultureOrgOther; run;

proc sort data=infect out=infect2 nodupkey; by id CultureSite; run;
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

/*
	if culturesite=. and cultureorg^=.  then do; 
					culturesite=99; culture_site="== Any "||strip(put(cultureorg,cultureorg.))||" =="; 
			end;
*/
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
	length culture_org $60;
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

********************* For BloodStreamInfection with Other CultureOrgOther *************;
proc freq data=infect;
	table SiteBlood*CultureOrgOther/nocol norow nopercent;
	ods output Freq.Table1.CrossTabFreqs=btab0(drop=table  _TYPE_  _TABLE_ Missing);
run;

data btab0;
	length culture_org $60;
	set btab0;
		site=8;
		if SiteBlood=1 and frequency^=0;
		culture_org=cultureorgother;
run;

proc sort; by cultureorgother;run;

proc sort data=infect out=b_infect nodupkey; by id SiteBlood cultureorgother; run;

proc freq data=b_infect;
	table SiteBlood*CultureOrgOther/nocol norow nopercent;
	ods output Freq.Table1.CrossTabFreqs=btab1(drop=table  _TYPE_  _TABLE_ Missing);
run;

data btab1;
	length culture_org $60;
	set btab1;
		site=8;
		if SiteBlood=1 and frequency^=0;
		culture_org=cultureorgother;
run;
proc sort; by cultureorgother;run;

data btab;
	merge btab0(rename=(frequency=n0)) btab1(rename=(frequency=n1)); by cultureorgother;
	pct=n1/&nt*100;
	incident=n0||"("||compress(n1)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	site=1;
	site0=put(site, site.);
	format site site.;
	if cultureorgother=" " then delete;
run;
******************************************************;

proc sort data=infect out=sc1 nodupkey; by id SiteBlood cultureorg; run;
proc freq; tables SiteBlood*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c1; run; 
proc sort data=infect out=sc2 nodupkey; by id SiteCNS cultureorg; run;
proc freq; tables SiteCNS*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c2; run; 
proc sort data=infect out=sc3 nodupkey; by id SiteCardio cultureorg ; run;
proc freq; tables SiteCardio*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c3; run; 
proc sort data=infect out=sc4 nodupkey; by id SiteLowerResp cultureorg; run;
proc freq; tables SiteLowerResp*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c4; run; 
proc sort data=infect out=sc5 nodupkey; by id SiteGI cultureorg ; run;
proc freq; tables SiteGI*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c5; run; 
proc sort data=infect out=sc6 nodupkey; by id SiteSurgical cultureorg ; run;
proc freq; tables SiteSurgical*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c6; run; 
proc sort data=infect out=sc7 nodupkey; by id SiteUT cultureorg ; run;
proc freq; tables SiteUT*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c7; run; 
proc sort data=infect out=sc8 nodupkey; by id SiteOther cultureorg ; run;
proc freq; tables SiteOther*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c8; run; 

data site_id;
	set c1(in=A where=(SiteBlood and cultureorg^=.)) c2(in=B where=(SiteCNS and cultureorg^=.))
		c3(in=C where=(SiteCardio and cultureorg^=.)) c4(in=D where=(SiteLowerResp and cultureorg^=.)) 
		c5(in=E where=(SiteGI and cultureorg^=.)) c6(in=F where=(SiteSurgical))
		c7(in=G where=(SiteUT and cultureorg^=.)) c8(in=H where=(SiteOther and cultureorg^=.));
	if A then site=1;
		if B then site=2;
			if C then site=3;
				if D then site=4;
					if E then site=5;
						if F then site=6;
							if G then site=7;
								if H then site=8;
	rename frequency=n_id;
	keep site cultureorg frequency;
	if frequency=0 then delete;
run;


proc sort data=infect out=site1 nodupkey; by id SiteBlood; run;
proc freq; tables SiteBlood;ods output onewayfreqs=s1; run; 
proc sort data=infect out=site2 nodupkey; by id SiteCNS; run;
proc freq; tables SiteCNS;ods output onewayfreqs=s2; run; 
proc sort data=infect out=site3 nodupkey; by id SiteCardio; run;
proc freq; tables SiteCardio;ods output onewayfreqs=s3; run; 
proc sort data=infect out=site4 nodupkey; by id SiteLowerResp; run;
proc freq; tables SiteLowerResp;ods output onewayfreqs=s4; run; 
proc sort data=infect out=site5 nodupkey; by id SiteGI; run;
proc freq; tables SiteGI;ods output onewayfreqs=s5; run; 
proc sort data=infect out=site6 nodupkey; by id SiteSurgical; run;
proc freq; tables SiteSurgical;ods output onewayfreqs=s6; run; 
proc sort data=infect out=site7 nodupkey; by id SiteUT; run;
proc freq; tables SiteUT;ods output onewayfreqs=s7; run; 
proc sort data=infect out=site8 nodupkey; by id SiteOther; run;
proc freq; tables SiteOther;ods output onewayfreqs=s8; run; 

data s_tab;
	set s1(in=A where=(SiteBlood)) s2(in=B where=(SiteCNS)) s3(in=C where=(SiteCardio)) 
			s4(in=D where=(SiteLowerResp)) s5(in=E where=(SiteGI)) s6(in=F where=(SiteSurgical)) 
			s7(in=G where=(SiteUT)) s8(in=H where=(SiteOther));
	if A then site=1;
		if B then site=2;
			if C then site=3;
				if D then site=4;
					if E then site=5;
						if F then site=6;
							if G then site=7;
								if H then site=8;
	rename frequency=n_id;
	cultureorg=99;
	keep site cultureorg frequency;
run;

proc freq data=infect;
	table InfectionSiteOther*CultureOrg/nocol norow nopercent out=otherinf;
run;

data otherinf;
	length site0 $60;
	if _n_=1 then do;site=8; site0="Other"; cultureorg=0; output; end;
	set otherinf;
	where InfectionSiteOther^=" ";
	site=8;
	site0="--"||strip(InfectionSiteOther)||"("||compress(put(count,2.0))||")";
	output;
run;
proc sort; by CultureOrg;run;

data site0;
	length site0 $60;
	merge site_count(rename=(frequency=n_count)) site_id s_tab; by site cultureorg;
	pct=n_id/&nt*100;
	incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	if site=6 then incident="--";
	site0=put(site, site.);
	if not first.site then site0=" ";
	if site=8 then site0=" ";
	format site site.;
run;

data site;
	length site0 $60;
	set site0 otherinf; by site cultureorg;
run;

data site_info0;
	length site0 $50;
	merge site_count(rename=(frequency=n_count)) site_id s_tab; by site cultureorg;
	pct=n_id/&nt*100;
	incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	if site=6 then delete;
	where cultureorg=99;
	format site site.;
	keep site site0 n_count n_id pct incident;
	site0=put(site, site.);
run;

data infect_site;	
	set infect;
	if 	BloodStreamInf then BSI=1; else BSI=0;
run;

proc sort nodupkey out=infect_site_id; by id; run;

proc freq data=infect_site;
tables BSI/out=BSIA;
run;

proc freq data=infect_site_id;
tables BSI/out=BSIB;
run;

data BSI;
	merge BSIA(rename=(count=n_count)) BSIB(rename=(count=n_id)); by BSI;
	pct=n_id/&nt*100;
	incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	site0="Any non-BSI infection";
	keep site0 BSI incident;
run;

data site_info;
	length incident $30 site0 $50;
	if _n_=1 then do; site0="==Infection Site=="; incident=" "; output; end;
	if _n_=7 then do; site0="======================"; incident=" "; output; end;
	set site_info0 BSI(where=(BSI=0)) org(where=(culturesite=99 and cultureorg=99) in=C) ;
	if C then site0="Any infection";  output;
run;


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

proc print data=site_info noobs label split="*"; 
title "Infection Rates for &nt LBWIs by Site";
var site0/style(data)=[just=left cellwidth=3in] style(header)=[just=left];
var incident/style(data)=[just=center cellwidth=3in] style(header)=[just=center];
label   site0="."
		incident="#infect(#Patients,Incidence%)"
		;
run;

ods rtf startpage=yes;

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
proc print data=site noobs label split="*" style(data)=[just=left]; 

var site0/style(header)=[just=left]; 
var incident/style(data)=[just=center] style(header)=[just=center];
var culture_org;
label   site0="Site of Infection"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

proc print data=btab noobs label split="*" style(data)=[just=left]; 
title "Bloodstream Infection - Other Culture (n=14)";
by site0; id site0;

*var site0/style(header)=[just=left]; 
var incident/style(data)=[just=center] style(header)=[just=center];
var culture_org;
label   site0="Site of Infection"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Infection (#Patients, %incidence)"
		;
run;

ods rtf close;
