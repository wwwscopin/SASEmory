options orientation=portrait nodate nonumber nofmterr;
%let mu=%sysfunc(byte(181));
%let path = S:\bios\TAMOF\Reporting\;

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

data TAMOF.survival; set TAMOF.survival;
      if patientid = 111001 then pelodtotalscore = 21;
      if patientid = 111003 then pelodtotalscore = 30;
      if patientid = 111006 then pelodtotalscore = 22;
      if patientid = 111008 then pelodtotalscore = 22;

      if patientid = 111003 then daysonpex = 3;
      if patientid = 111004 then daysonpex = 3;

      if patientid = 111007 then plasmaexchange = 1;
      if patientid = 111007 then daysonpex = 3; 

      drop pelodpreddeathrate deathrate; *These are not correct anymore and we don't use them anyway ;
run;


data all_pat;
	set TAMOF.survival;
run;

proc sort data=all_pat nodupkey; by patientid;run;


%let nt=0;
data _null_;
	set all_pat;
	call symput("nt", compress(_n_));
run;
%put &nt;

/*
* import from virtual access database ;
proc import table = "dbo_tbl_P13_Infection_Data"
		out=TAMOF.infection
		dbms=access2000 replace;
		database="S:\bios\TAMOF\Reporting\data\TAMOF.mdb";
run;
*/

proc sql;

connect to odbc(dsn=TAMOF );


create table TAMOF.infection as
select * from connection to odbc
(select * from  tbl_P13_Infection_Data); 

disconnect from odbc; 

quit;

proc sort; by patientid;run;


data tamof.infection;
	set tamof.infection; 
	if patientid=. then patientid=102001;
	if patientid in(102001,113004) then IsCulturePositive=1;
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
	merge tmp(in=A) tamof.demographic(keep=patientid  EnrollmentDate rename=(patientid=id))
		 TAMOF.survival(keep=patientid plasmaexchange censor ecmo rename=(patientid=id plasmaexchange=pe) in=B); by id;
	day=CultureDate-datepart(EnrollmentDate);
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	if B;

	if BloodStreamInf then gbsi=1; else gbsi=0;
	if BloodStreamInf and cultureorg=3 then sub_mrsa=1; else sub_mrsa=0;
	if BloodStreamInf and cultureorg=2 then sub_mssa=1; else sub_mssa=0;
	if cultureorg=3 then mrsa=1; else mrsa=0;
	if cultureorg=2 then mssa=1; else mssa=0;
	if CardioInf then gcard=1; else gcard=0;
	if GIInf then ggi=1; else ggi=0;
	if CNSInf then gcns=1; else gcns=0;
	if LowerRespInf then glr=1; else glr=0;
	if SurSiteInf  then gss=1; else gss=0;
	if UTInf then gut=1; else gut=0;
	if OtherInf then gother=1; else gother=0;
	if BloodStreamInf or CardioInf or GIInf or CNSInf or LowerRespInf or SurSiteInf or UTInf or OtherInf then gi=1;else gi=0;
	if BloodStreamInf=0 and gi=1 then gnbsi=1; else gnbsi=0;

	if id=114004 then do; gbsi=1; glr=1; gother=1; gnbsi=0; end;
	if id=101002 then do; sub_mrsa=1; mrsa=1; end;
	if id=101019 or id=113007 then do; sub_mssa=1; mssa=1; end;
	if id=109010 then do; glr=1; gother=1; end;
run;

proc sort data=infect; by id; run;

proc format;
	value site	0="==Infection Site==" 
				1="Bloodstream Infection"
				2="  -- Any MRSA"
				3="  -- Any MSSA"
				4="Cardiovascular System Infection"
				5="Gastrointestinal System Infection"
				6="Central Nervous System Infection"
				7="Lower respiratory tract Infection"
				8="Surgical Site Infection"
				9="Urinary Tract Infection"
			   10="Other"
			   11="===================="
			   12="Any non-BSI infection"
			   13="Any MRSA"
			   14="Any MSSA"
	           15="Any infection";
run;

%macro pt(data,out,gp,varlist);

data &out;	
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

*ods trace on/label listing;
proc sort data=&data nodupkey out=&data._&var; by id descending &var &gp; run;

data &data._&var;
    set &data._&var; by id descending &var &gp;
    if first.id;
run; 


proc freq;
table &gp*&var/nocol nopercent chisq;
ods output  Freq.Table1.CrossTabFreqs=tmp&i;
ods output  Freq.Table1.FishersExact=p&i;
run;
*ods trace off;

data _null_;
	set tmp&i;
	if &gp=0 and &var=1 then call symput("n0", compress(frequency));
	if &gp=0 and &var=. then call symput("m0", compress(frequency));
	if &gp=1 and &var=1 then call symput("n1", compress(frequency));
	if &gp=1 and &var=. then call symput("m1", compress(frequency));
run;

data tab&i;
	f0=&n0/&m0*100;		f1=&n1/&m1*100;
	col0=&n0||"/&m0("||put(f0,4.1)||"%)";
	col1=&n1||"/&m1("||put(f1,4.1)||"%)";
	item=&i	;
	set p&i(firstobs=6 keep=nvalue1);
run;

data &out; 
	set &out tab&i;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;

data tmp;
	item=0;output;
	item=11;output;
run;


data &out;
	set tmp(where=(item=0))
		&out(where=(item<=10))
		tmp(where=(item=11))
	 	&out(where=(item>10) in=A);
		if A then item=item+1;
	rename nvalue1=pv;
	format item site. nvalue1 4.2; 
run;

%mend;
%let varlist=gbsi sub_mrsa sub_mssa gcard ggi gcns glr gss gut gother gnbsi mrsa mssa gi;
%pt(infect,survivor,censor,&varlist);
%pt(infect,ecmo,ecmo,&varlist);
%pt(infect,pex,pe,&varlist);

data subnoecmo subecmo;
	set infect;
	if pe=1 and ecmo=0 then output subnoecmo;
	if pe=1 and ecmo=1 then output subecmo;
run;

proc contents data=infect;run;

proc print data=infect;
var plasmaexchange ecmo;
run;

%pt(subecmo,ecmosur,censor,&varlist);
%pt(subnoecmo,noecmosur,censor,&varlist);

ods rtf file="infect_ecmo.rtf" style=journal bodytitle startpage=no;
proc print data=ecmosur noobs label split="*"; 
title "Infection Rates by Site for 25 TAMOF Children treated with Plasma Exchange and ECMO";
var item/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
var col1 col0 /style(data)=[just=center cellwidth=2in] style(header)=[just=center];
var pv/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label   item="."
		col1="Survivors*#Patients (Incidence%)"
		col0="Non-Survivors*#Patients (Incidence%)"
		pv="p value"
		;
run;

proc print data=noecmosur noobs label split="*"; 
title "Infection Rates by Site for 34 TAMOF Children treated with Plasma Exchange but did not receive ECMO";
var item/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
var col1 col0 /style(data)=[just=center cellwidth=2in] style(header)=[just=center];
var pv/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label   item="."
		col1="Survivors*#Patients (Incidence%)"
		col0="Non-Survivors*#Patients (Incidence%)"
		pv="p value"
		;
run;
ods rtf close;

ods rtf file="infect_simple.rtf" style=journal bodytitle startpage=no;
proc print data=survivor noobs label split="*"; 
title "Infection Rates for 81 TAMOF Children by Vital Status";
var item/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
var col1 col0 /style(data)=[just=center cellwidth=2in] style(header)=[just=center];
var pv/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label   item="."
		col1="Survivors*#Patients (Incidence%)"
		col0="Non-Survivors*#Patients (Incidence%)"
		pv="p value"
		;
run;

proc print data=pex noobs label split="*"; 
title "Infection Rates for 81 TAMOF Children by Treatment";
var item/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
var col0 col1/style(data)=[just=center cellwidth=2in] style(header)=[just=center];
var pv/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label   item="."
		col1="Plasma Exchange*#Patients (Incidence%)"
		col0="Standard Therapy*#Patients (Incidence%)"
		pv="p value"
		;
run;

ods rtf startpage=yes;
proc print data=ecmo noobs label split="*"; 
title "Infection Rates for 81 TAMOF Children by ECMO";
var item/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
var col0 col1/style(data)=[just=center cellwidth=2in] style(header)=[just=center];
var pv/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label   item="."
		col1="ECMO*#Patients (Incidence%)"
		col0="No ECMO*#Patients (Incidence%)"
		pv="p value"
		;
run;
ods rtf close;
