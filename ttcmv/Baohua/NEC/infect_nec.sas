options orientation=portrait nodate nonumber nofmterr;
%let mu=%sysfunc(byte(181));

data _null_;
	set cmv.completedstudylist;
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

data nec;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;

	keep id necdate;
run;
proc sort; by id necdate;run;
data nec;
    set nec; by id necdate;
    if first.id;
run;

data hop;
	merge cmv.endofstudy(in=tmp) cmv.LBWI_Demo nec 
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.completedstudylist(in=comp); by id;
	
	day=StudyLeftDate-lbwidob;
    if day=. then day=today()-lbwidob;
    if bell then nec=1; else nec=0;
    if nec then day=necdate-lbwidob;
    if day=. then delete;
    if tmp and comp;
   	keep id lbwidob studyleftdate day nec;
run;

data nec_num;
    set hop;
    where nec=0;
run;

proc sort nodupkey; by nec; run;

data _null_;
    set nec_num;
    call symput("m0", compress(_n_));
run;

%let m1=%eval(&nt-&m0);

proc sort data=hop nodupkey; by id; run;

	* calculate total patient days in hospital for the study ;
		proc means data = hop n sum median;	
		    class nec;		
	 		var day;
			output out = total_hosp_days  sum(day) = total_hosp_days ;
		run;

		data _null_;
			set total_hosp_days;
			if nec=0 then call symput('total_hosp_days_nec0', compress(total_hosp_days));
			if nec=1 then call symput('total_hosp_days_nec1', compress(total_hosp_days));
		run;

data infect;
	merge tmp nec cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.completedstudylist(in=B); by id;
	CultureOrgOther=lowcase(CultureOrgOther);
	substr(CultureOrgOther,1,1)=upcase(substr(CultureOrgOther,1,1));
	CultureSiteOther=lowcase(CultureSiteOther);
	substr(CultureSiteOther,1,1)=upcase(substr(CultureSiteOther,1,1));
	
    if bell then nec=1; else nec=0;
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
	
    if nec and culturedate>=necdate then do; gbsi=0; sub_mrsa=0; sub_mssa=0; mrsa=0; mssa=0; gcard=0; ggi=0; gcns=0; glr=0; gss=0; gut=0; gother=0; gi=0; gnbsi=0;end;
run;

data sub;
    set infect;
    where nec and 0<culturedate<necdate;
run;

proc sort nodupkey; by id CulturePositive;run;
proc print;
var id culturedate necdate CulturePositive siteblood;
run;

proc freq data=infect; 
tables nec*(gbsi sub_mrsa sub_mssa mrsa mssa gcard ggi gcns glr gss gut gother gi gnbsi);
run;

proc sort data=infect out=infect_id nodupkey; by id; run;

data _null_;
	set infect_id;
	call symput("n", strip(_n_));
run;
proc sort data=infect; by id; run;

proc format;
/*
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
*/
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

data tmp&i;if 1=1 then delete;run;
data p&i;nvalue1=.;run;

proc freq data=&data._&var;
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
	n0=&n0;
	n1=&n1;
	set p&i(firstobs=6 keep=nvalue1);
    length pv $10;
    pv=put(nvalue1,5.3);
	if 0<=nvalue1<0.001 then pv="<0.001";
run;

data &out; 
	set &out tab&i;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;

data &out;
    set &out;
    rate_1000d0 = (n0/ &total_hosp_days_nec0) * 1000;
    rate_1000d1 = (n1/ &total_hosp_days_nec1) * 1000;
	denominator0 = input(&total_hosp_days_nec0, 12.);
		denominator1 = input(&total_hosp_days_nec1, 12.);
	conf_level = .95;
	upper_p = 1 - (1 - conf_level)/2;
	lower_p = 1 - upper_p;  
	
				* upper and lower CI bounds for the Poisson counts of incident infections ;
	upper_mu0 = .5 * cinv(upper_p, 2 * (n0+ 1));
	lower_mu0 = .5 * cinv(lower_p, 2 * (n0));
	upper_mu1 = .5 * cinv(upper_p, 2 * (n1+ 1));
	lower_mu1 = .5 * cinv(lower_p, 2 * (n1));
				* transform these into CI for the RATES;
	upper_rate0 = (upper_mu0/denominator0) * 1000;
	lower_rate0 = (lower_mu0/denominator0) * 1000;
	upper_rate1 = (upper_mu1/denominator1) * 1000;
	lower_rate1 = (lower_mu1/denominator1) * 1000;
	
	rate0=put(rate_1000d0,4.1)||"["||put(lower_rate0,4.1)||"-"||put(upper_rate0,4.1)||"]";
	rate1=put(rate_1000d1,4.1)||"["||put(lower_rate1,4.1)||"-"||put(upper_rate1,4.1)||"]";
	if lower_mu0=. then rate0="-";
	if lower_mu1=. then rate1="-";
run;

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
%pt(infect,necinfect,nec,&varlist);

options orientation=landscape;
ods rtf file="infect_nec.rtf" style=journal bodytitle startpage=no;
proc print data=necinfect noobs label split="|"; 
title1 "Incident infection rates in the &nt LBWIs no longer hospitalized";
title2 "&total_hosp_days_nec0(&m0 LBWIs non-NEC) and &total_hosp_days_nec1(&m1 LBWIs NEC) patient hospital days on study";
var item/style(data)=[just=left cellwidth=2.25in] style(header)=[just=left];
var col0 rate0 col1 rate1/style(data)=[just=center cellwidth=1.5in] style(header)=[just=center];
var pv/style(data)=[just=center cellwidth=0.75in] style(header)=[just=center];
label   item="."
		col0="No NEC|#Patients (Incidence%)"
		rate0="No NEC|infec.1000/hosp. days 95%CI*"
		rate1="NEC|infec.1000/hosp. days 95%CI*"
		col1="NEC|#Patients (Incidence%)"
		pv="p value"
		;
run;
ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=10pt}
^n The infections for NEC group are prior to NEC diagnosis date, and the hospital days are counted until NEC diagnosis date.
^n *95% confidence intervals are calculated using an exact method based on the Possion distribution.";
ods rtf close;
