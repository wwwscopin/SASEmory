options orientation=portrait nodate nonumber nofmterr;
%let mu=%sysfunc(byte(181));
%let path = S:\bios\TAMOF\Reporting;

libname TAMOF "S:\bios\TAMOF\Reporting\data";

proc format; 
value yn	0="No"	1="Yes";

value item  1="Was a culture related to this infection obtained?*"
			2="Was a culture related to this infection positive?#"
			;

value site
			1="Bloodstream Infection"
			2="Cardiovascular System Infection"
			3="Gastrointestinal System Infection"			
			4="Central Nervous System Infection"
			5="Lower respiratory tract Infection"
			6="Surgical Site Infection"
			7="Urinary Tract Infection"
			8="Other"
			9=" "
			99="-- Any Site Infection -- "
		;

value CultureOrg 
			0=" "
			1="Staphylococcus epidermidis"
			2="Methicillin-susceptible Staphylococcus aureus (MSSA)"
			3="Methicillin-resistant Staphylococcus aureus (MRSA)"
			4="Vancomycin-susceptible Enterococcus faecalis"
			5="Vancomycin-resistant Enterococcus faecalis"
			6="Vancomycin-susceptible Enterococcus faecium"
			7="Vancomycin-resistant Enterococcus faecium"
			8="Klebsiella pneumoniae"
			9="Pseudomonas aeruginosa"
			10="Streptococcus pneumoniae"
			11="Streptococcus viridans"
			12="Streptococcus agalactiae"
			13="Escherichia coli"
			14="Acinetobacter baumannii"
			15="Enterobacter cloace"
			16="Enterobacter aerogenes"			
			17="Clostridium difficile"
			18="Candida albicans"
			19="Candida glabrata"
			20="Candida tropicalis"
			21="Influenza"
			22="Cytomegalovirus"
			23="Henoch-Schonlein Purpura"
			24="Respiratory Syncytial Virus"
			25="Epstain-barr Virus"
			26="Enterovirus"
			27="Adenovirus"
			28="Other Culture"
			-9=" "
			99="-- Any Culture Organism --"
			;

	value CultureSite 
			1="Blood"
			2="Urine"
			3="Wound"
			4="Sputum/Tracheal Aspirate"
			5="BAL"
			6="CSF"
			7="Stool"
			8="Catheter Tip"
			9="Other"
			-9=" "
			99="-- Any Culture Site --"
			;

run;



data all_pat;
	set tamof.endofstudy;
run;

proc sort data=all_pat nodupkey; by patientid;run;


%let nt=0;
data _null_;
	set all_pat;
	call symput("nt", compress(_n_));
run;
%put &nt;


* import from virtual access database ;
proc import table = "dbo_tbl_P13_Infection_Data"
		out=TAMOF.infection
		dbms=access2000 replace;
		database="&path\data\TAMOF.mdb";
run;

data tamof.infection;
	set tamof.infection;
	if patientid=. then patientid=102001;
	if patientid in(102001,113004) then IsCulturePositive=1;
run;

proc print;
where CNSInf=1;
var patientid CNSInf;
run;

%let nr=0;
data _null_;
	set tamof.infection;
	call symput("nr", compress(_n_));
run;
%put &nr;

proc sort nodupkey out=infect_id; by patientid; run;

%let n0=0;
data _null_;
	set infect_id;
	call symput("n0", compress(_n_));
	f=_n_/&nt*100;
	call symput("f", put(f,4.2));
run;
%put &n0;

proc print data=tamof.infection;
where CultureObtained=. or IsCulturePositive=.;
run;

ods trace on/label listing;
proc freq data=tamof.infection; 
tables  CultureObtained IsCulturePositive/norow nocol nopercent;
ods output  Freq.Table1.OneWayFreqs=tab1;
ods output  Freq.Table2.OneWayFreqs=tab2;
run;
ods trace off;
proc print data=tab1;run;

proc sort data=tamof.infection nodupkey out=CO; by patientid CultureObtained;run;
proc sort data=tamof.infection nodupkey out=CP; by patientid IsCulturePositive;run;
proc print;var patientid IsCulturePositive; run;
	
proc freq data=CO; 
tables  CultureObtained/norow nocol nopercent;
ods output onewayfreqs=tab3;
run;

proc freq data=CP; 
tables  IsCulturePositive/norow nocol nopercent;
ods output onewayfreqs=tab4;
run;

data tabA;
	merge tab1(rename=(frequency=m)) tab3(rename=(frequency=n)); by CultureObtained;
	f=n/&n0*100;
	*nf=m||"("||compress(n)||"/&n0)"||put(f,4.1)||"%";
	nf=m||"("||compress(n)||")";
run;

proc transpose data=tabA out=tabA; var nf;run;

data tabB;
	merge tab2(rename=(frequency=m)) tab4(rename=(frequency=n)); by IsCulturePositive;
	f=n/&n0*100;
	nf=m||"("||compress(n)||")";
run;

proc transpose data=tabB out=tabB; var nf;run;

data tab;
	set tabA(in=A rename=(col1=No col2=Yes)) tabB(in=B rename=(col1=No col2=Yes));
	if A then item=1;
	if B then item=2;
	format item item.;
	drop _name_;
run;

%macro data(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 6;
		CultureDate=datepart(CultureDate&i);
		CultureOther=CultureOther&i;
		OrgCode=OrgCode&i;
		CultureSite=CultureSite&i;
		CultureOtherSite=CultureOtherSite&i;
		i=&i;
		if culturesite=-9 or orgcode=-9 then delete;
		output;
	%end;

	keep  BloodStreamInf CardioInf GIInf CNSInf LowerRespInf SurSiteInf UTInf OtherInf OtherInfText
		  CultureObtained  IsCulturePositive
    	  CultureDate CultureSite CultureOtherSite OrgCode CultureOther i
		  PatientId StudySite ProjectID SubjectId SAESeqId UniqueId VisitList;
	rename patientid=id OrgCode=CultureOrg CultureOtherSite=CultureSiteOther CultureOther=CultureOrgOther;

	format CultureDate mmddyy. CultureObtained  IsCulturePositive yn. 
		   CultureSite CultureSite. OrgCode CultureOrg.;
run;
%mend;

%data(tamof.infection);quit;
proc sort; by id; run;
proc sort data=tmp out=infect_id nodupkey; by id; run;

%let n=0;
data _null_;
	set infect_id;
	call symput("n", strip(_n_));
run;
%put &n;

data infect;
	merge tmp(in=A) tamof.demographic(keep=patientid  EnrollmentDate rename=(patientid=id)); by id;
	day=CultureDate-datepart(EnrollmentDate);
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	if A;
run;

proc sort nodupkey out=wbh; by id;run;

%let nf=0;
data _null_;
	set wbh;
	call symput("nf", strip(_n_));
run;
%put &nf;


options orientation=landscape;
title "Infection Data Listing (n=&nf TAMOF Children)";
proc sort nodupkey; by id CultureDate; run;
ods rtf file="list.rtf" style=journal bodytitle;
proc print data=infect noobs label;
by id; id id/style(data)=[cellwidth=0.6in]; 
var CultureDate;
var day/style(data)=[cellwidth=0.6in];
var culturesite CultureSiteOther CultureOrg CultureOrgOther;
label id="Patient ID"
	 day="Day on Study";
run;
ods rtf close;

options orientation=portrait;run;

proc contents;run;

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
	length	culture_site $ 60 culture_org $60;
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
	length	culture_site $ 60 culture_org $60;
	set tab1;
	culture_site=put(culturesite,culturesite.);
	culture_org="--"||cultureorgother;

    if culturesite=. or cultureorgother=" "  then delete;
	if culturesite=9 then delete;

	cultureorg=28;
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;

proc sort; by culturesite cultureorg; run;

data tab2;
	length	culture_site culture_org $60;
	set tab2;

	culture_site="--"||culturesiteother;
	culture_org=put(cultureorg,cultureorg.);

	culturesite=9;
	if cultureorg=28 then delete;
	if culturesiteother=" " or cultureorg=. then delete;
	
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;


proc sort; by culturesite cultureorg; run;

data tab3;
	length	culture_site culture_org $60;
	set tab3;
	culture_site="--"||culturesiteother;
	culture_org="--"||cultureorgother;
	
	culturesite=9; cultureorg=28;

	if culturesiteother=" " or cultureorgother=" " then delete;
	keep culturesite culture_site  cultureorg culture_org frequency;
	rename frequency =count;
run;

proc sort; by culturesite cultureorg; run;

data Org_&out;
	if _n_=1 then do; culturesite=9; culture_site=put(culturesite,culturesite.); cultureorg=0; count=1; output; end;
	set tab0 tab1 tab2 tab3; by culturesite cultureorg;
	where count^=0 ; output;
run;
proc sort; by culturesite cultureorg; run;

%mend infect;

%infect(data=infect, out=count);
%infect(data=infect1, out=id);quit;

data Org;
	merge Org_count(rename=(count=n_count)) Org_id(rename=(count=n_id))
	culturesite(keep=culturesite cultureorg frequency rename=(frequency=n_id)); by culturesite cultureorg;
	if culturesite=99 and cultureorg=99 then n_id=&n;
	pct=n_id/&nt*100;
	*incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	incident=compress(n_id)||"/"||compress(&nt)||"(" ||put(pct,5.1)||"%)";
	if 	culturesite=99 and cultureorg=99 then 	incident=compress(n_id)||"/"||compress(&nt)||"(" ||put(pct,5.1)||"%)";
	if 	cultureorg=0 then incident=" ";
run;


data Org;
	set Org; by notsorted Culture_site;
	if not first.Culture_site then Culture_site=" ";
run;

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
	table (BloodStreamInf CardioInf GIInf CNSInf LowerRespInf SurSiteInf UTInf OtherInf)*CultureOrg/nocol norow nopercent;
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
%if &data=tab8 %then %do;  %let  code=8; %end;

data &data;
	length culture_org $60;
	set &data;
		site=&code;
		if &var=1 and frequency^=0;
		culture_org=put(cultureorg, cultureorg.);
		if cultureorg=. then do; cultureorg=99; culture_org="== Any "|| strip( put(site,site.))||" =="; end;
run;
%mend site;

%site(tab0, BloodStreamInf);
%site(tab1, CardioInf);
%site(tab2, GIInf);
%site(tab3, CNSInf);
%site(tab4, LowerRespInf);
%site(tab5, SurSiteInf);
%site(tab6, UTInf);
%site(tab7, OtherInf);
quit;

data site_&out;
	set tab0 tab1 tab2 tab3 tab4 /*tab5*/ tab6 tab7; by site;
	keep site frequency cultureorg culture_org;
run;

%mend site_infect;

%site_infect(dataset=infect, out=count);
proc sort; by site cultureorg; run;

********************* For BloodStreamInfection with Other CultureOrgOther *************;
proc freq data=infect;
	table BloodStreamInf*CultureOrgOther/nocol norow nopercent;
	ods output Freq.Table1.CrossTabFreqs=btab0(drop=table  _TYPE_  _TABLE_ Missing);
run;

data btab0;
	length culture_org $60;
	set btab0;
		site=8;
		if BloodStreamInf=1 and frequency^=0;
		culture_org=cultureorgother;
run;

proc sort; by cultureorgother;run;

proc sort data=infect out=b_infect nodupkey; by id BloodStreamInf cultureorgother; run;

proc freq data=b_infect;
	table BloodStreamInf*CultureOrgOther/nocol norow nopercent;
	ods output Freq.Table1.CrossTabFreqs=btab1(drop=table  _TYPE_  _TABLE_ Missing);
run;

data btab1;
	length culture_org $60;
	set btab1;
		site=8;
		if BloodStreamInf=1 and frequency^=0;
		culture_org=cultureorgother;
run;
proc sort; by cultureorgother;run;

data btab;
	merge btab0(rename=(frequency=n0)) btab1(rename=(frequency=n1)); by cultureorgother;
	pct=n1/&nt*100;
	*incident=n0||"("||compress(n1)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
		incident=compress(n1)||"/"||compress(&nt)||"(" ||put(pct,5.1)||"%)";
	site=1;
	site0=put(site, site.);
	format site site.;
	if cultureorgother=" " then delete;
run;
******************************************************;

proc sort data=infect out=sc1 nodupkey; by id BloodStreamInf cultureorg; run;
proc freq; tables BloodStreamInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c1; run; 
proc sort data=infect out=sc2 nodupkey; by id CardioInf cultureorg; run;
proc freq; tables CardioInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c2; run; 
proc sort data=infect out=sc3 nodupkey; by id GIInf cultureorg ; run;
proc freq; tables GIInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c3; run; 
proc sort data=infect out=sc4 nodupkey; by id CNSInf cultureorg; run;
proc freq; tables CNSInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c4; run; 
proc sort data=infect out=sc5 nodupkey; by id LowerRespInf cultureorg ; run;
proc freq; tables LowerRespInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c5; run; 
proc sort data=infect out=sc6 nodupkey; by id SurSiteInf cultureorg ; run;
proc freq; tables SurSiteInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c6; run; 
proc sort data=infect out=sc7 nodupkey; by id UTInf cultureorg ; run;
proc freq; tables UTInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c7; run; 
proc sort data=infect out=sc8 nodupkey; by id OtherInf cultureorg ; run;
proc freq; tables OtherInf*CultureOrg/norow nocol nopercent;ods output crosstabfreqs=c8; run; 

data site_id;
	set c1(in=A where=(BloodStreamInf and cultureorg^=.)) c2(in=B where=(CardioInf and cultureorg^=.))
		c3(in=C where=(GIInf and cultureorg^=.)) c4(in=D where=(CNSInf and cultureorg^=.)) 
		c5(in=E where=(LowerRespInf and cultureorg^=.)) /*c6(in=F where=(SurSiteInf))*/
		c7(in=G where=(UTInf and cultureorg^=.)) c8(in=H where=(OtherInf and cultureorg^=.));
	if A then site=1;
		if B then site=2;
			if C then site=3;
				if D then site=4;
					if E then site=5;
						*if F then site=6;
							if G then site=7;
								if H then site=8;
	rename frequency=n_id;
	keep site cultureorg frequency;
	if frequency=0 then delete;
run;


proc sort data=infect out=site1 nodupkey; by id BloodStreamInf; run;
proc freq; tables BloodStreamInf;ods output onewayfreqs=s1; run; 
proc sort data=infect out=site2 nodupkey; by id CardioInf; run;
proc freq; tables CardioInf;ods output onewayfreqs=s2; run; 
proc sort data=infect out=site3 nodupkey; by id GIInf; run;
proc freq; tables GIInf;ods output onewayfreqs=s3; run; 
proc sort data=infect out=site4 nodupkey; by id CNSInf; run;
proc freq; tables CNSInf;ods output onewayfreqs=s4; run; 
proc sort data=infect out=site5 nodupkey; by id LowerRespInf; run;
proc freq; tables LowerRespInf;ods output onewayfreqs=s5; run; 
proc sort data=infect out=site6 nodupkey; by id SurSiteInf; run;
proc freq; tables SurSiteInf;ods output onewayfreqs=s6; run; 
proc sort data=infect out=site7 nodupkey; by id UTInf; run;
proc freq; tables UTInf;ods output onewayfreqs=s7; run; 
proc sort data=infect out=site8 nodupkey; by id OtherInf; run;
proc freq; tables OtherInf;ods output onewayfreqs=s8; run; 

data s_tab;
	set s1(in=A) s2(in=B) s3(in=C) s4(in=D) s5(in=E) s6(in=F) s7(in=G) s8(in=H);
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
	table OtherInfText*CultureOrg/nocol norow nopercent out=otherinf;
run;

data otherinf;
	length site0 $50;
	if _n_=1 then do;site=8; site0="Other"; cultureorg=0; output; end;
	set otherinf;
	where otherinftext^=" ";
	site=8;
	*site0="--"||strip(otherinftext)||"("||compress(put(count,2.0))||")";
	site0="--"||strip(otherinftext);
	output;
run;
proc sort; by CultureOrg;run;

data site0;
	length site0 $50;
	merge site_count(rename=(frequency=n_count)) site_id s_tab; by site cultureorg;
	pct=n_id/&nt*100;
	*incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	incident=compress(n_id)||"/"||compress(&nt)||"(" ||put(pct,5.1)||"%)";
	if site=6 then /*incident="--"*/ delete;
	site0=put(site, site.);
	if not first.site then site0=" ";
	if site=8 then site0=" ";
	format site site.;
run;

data site;
	set site0 otherinf; by site cultureorg;
run;

data site_info0;
	length site0 $50;
	merge site_count(rename=(frequency=n_count)) site_id s_tab; by site cultureorg;
	pct=n_id/&nt*100;
	*incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	incident=compress(n_id)||"/"||compress(&nt)||"("||put(pct,5.1)||"%)";
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
	*incident=n_count||"("||compress(n_id)||"/"||compress(&nt)||"," ||put(pct,5.1)||"%)";
	incident=compress(n_id)||"/"||compress(&nt)||"("||put(pct,5.1)||"%)";
	site0="Any non-BSI infection";
	keep site0 BSI incident;
run;


****************** To include MRSA ****************;

proc print data=infect;
where id in(101002,101019,113007);
var id cultureorg;
run;

data mrsa;
	set infect;
	where BloodStreamInf=1 and cultureorg=3;
	*where cultureorg=3;
run;

proc sort nodupkey out=mrsa0; by id;run;

data _null_;
	set mrsa;
	call symput("n_mrsa",compress(_n_));
run;

data _null_;
	set mrsa0;
	call symput("m_mrsa",compress(_n_));
run;

data mssa;
	set infect;
	where BloodStreamInf=1 and cultureorg=2;
	*where cultureorg=2;
run;

proc print;
var id cultureorg;
run;

proc sort nodupkey out=mssa0; by id;run;

data _null_;
	set mssa;
	call symput("n_mssa",compress(_n_));
run;

data _null_;
	set mssa0;
	call symput("m_mssa",compress(_n_));
run;

data mrsa_site;
	site0="  -- Any MRSA";
	pct=&m_mrsa/&nt*100;
	incident=compress(&m_mrsa)||"/"||compress(&nt)||"(" ||put(pct,5.1)||"%)";  output;

	site0="  -- Any MSSA";
	pct=&m_mssa/&nt*100;
	incident=compress(&m_mssa)||"/"||compress(&nt)||"("||put(pct,5.1)||"%)";  output;
run;

data site_info1;
	set site_info0(where=(site=1)) mrsa_site site_info0(where=(site^=1)); 
run;
proc print;run;
***************************************************;

data site_info;
	length incident $30 site0 $50;
	if _n_=1 then do; site0="==Infection Site=="; incident=" "; output; end;
	if _n_=10 then do; site0="===================="; incident=" "; output; end;
	set site_info1 BSI(where=(BSI=0)) org(where=(culturesite=99 and cultureorg=99) in=C) ;
	if C then site0="Any infection";  output;
run;

ods rtf file="infect_all.rtf" style=journal bodytitle startpage=no;
title "Infection Information for &n0 of &nt TAMOF Children with &nr CRFs Completed";
proc print data=tab noobs label split="*"; 
var item/style(header)=[just=left];
var no yes/style(data)=[just=center cellwidth=2in] style(header)=[just=center];
label   item="Question"
		No="No*#Num(#Patients)"
	   	Yes="Yes*#Num(#Patients)"
		;
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=1.25in RIGHTMARGIN=1.25in}
*Not answered for 7 CRFs.';
ODS rtf TEXT='^S={LEFTMARGIN=1.25in RIGHTMARGIN=1.25in}
#Not answered for 7 CRFs.';


proc print data=site_info noobs label split="*"; 
title "Infection Rates for &nt TAMOF Children by Site";
var site0/style(data)=[just=left cellwidth=3in] style(header)=[just=left];
var incident/style(data)=[just=center cellwidth=3in] style(header)=[just=center];
label   site0="."
		incident="#Patients (Incidence%)"
		;
run;

ods rtf startpage=yes;
title "Culture Site - Cultured Organisms (n=&nt TAMOF Children)";
proc print data=org noobs label split="*"; 
var culture_site culture_org;
var incident/style(data)=[just=center] style(header)=[just=center];
label   Culture_site="Culture Site"
		   Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Patients (incidence%)"
		;
run;
ods rtf close;

ods rtf file="site_infect_all.rtf" style=journal bodytitle startpage=no;

title "Infection Site - Cultured Organisms (n=&nt TAMOF Children)";
proc print data=site noobs label split="*" style(data)=[just=left]; 
where cultureorg^=-9;

var site0/style(data)=[just=left cellwidth=2in] style(header)=[just=left]; 
var incident/style(data)=[just=center] style(header)=[just=center];
var culture_org;
label   site0="Site of Infection"
		Culture_Org="Cultured Organism"
	   	incident="Incident Infection*#Patients (incidence%)"
		;
run;

proc print data=btab noobs label split="*" style(data)=[just=left]; 
title "Bloodstream Infection - Other Culture (n=10 TAMOF Children)";
by site0; id site0;

var incident/style(data)=[just=center] style(header)=[just=center];
var culture_org;
label   site0="Site of Infection"
		Culture_Org="Cultured Organism"
		incident="Incident Infection*#Patients (incidence%)"
		;
run;
ods rtf close;



data bs;
	length 	cultureorg0	CultureSite0 $80;
	set infect(where=(BloodStreamInf=1)) ;
	
	cultureorg0=put(cultureorg, cultureorg.);
	CultureSite0=put(CultureSite, culturesite.);

	if CultureOrg=28 then cultureorg0=strip(put(cultureorg, cultureorg.))||"-"||CultureOrgOther;
	if CultureSite=9 then CultureSite0=strip(put(CultureSite, culturesite.))||"-"||CultureSiteOther;
run;


ods rtf file="bs.rtf" style=journal bodytitle startpage=no;
title "Bloodstream Infection Listing (n=36 TAMOF Children)";
proc print data=bs label split="*" style(data)=[just=left]; 
by id; id id;
var CultureDate CultureObtained IsCulturePositive day CultureOrg0 CultureSite0;
label  CultureOrg0="Culture Organism" CultureSite0="Culture Site";
run;
ods rtf close;
