options nofmterr /*orientation=landscape*/ orientation=portrait;
%let path=H:\SAS_Emory\Consulting\Brent1\;
libname brent "&path";
filename edmd "&path.EDMD.xls";
filename pnp "&path.PNP.xls";

%include "&path.macro.sas";

ods listing;

proc format;
	value group
		1="Age"
		2="Fever"
		3="Head Injury"
		4="Respiratory";
	value site
		1="Egleston"
		2="Scottish Rite";
	value exit
		1="Home"
		2="Home Orders Pending"
		3="Admission"
		4="Intensive Care"
		5="Operating Room"
		6="Transfer";

	value role
		1="EDMD"
		2="MD"
		3="NOED"
		4="PNP";

	value Acuity
		3="3/Pink-2+resources"
		4="4/Gray";
	value yn
		0="No"
		1="Yes";

	value itemA
		1="Count of number of charges for abdominal x-ray"
		2="Count of number of labs done"
		3="Length of ED stay in minutes";
	value PP
		0="Pre" 1="Post";
	value gs
		0="PNP" 1="EDMD";

	value idx -1=" " 0=" Pre-Intervention" 1="Post Intervention" 2=" ";

	
	value item 1="Length of ED stay"
               2="Return rate"
			   3="Admitted to hospital"
			   4="Count of number of Labs"
			   5="Patient receive abd and/or pelvis CT"
			   6="Count of number of charges for head CT"
			   7="Count of number of charges for chest X-ray"
			   8="Count of number of charges for abdominal x-ray"
			   9="Count of number of charges for abdominal x-ray and chest x-ray"
			   10="Charges for IV antibiotics exist"
			   11="Charges for IV fluids exist"
			   12="Charges for IV zofran (ondansetron) exist"
			   ;
run;
proc sort data=brent.edmd; by pid;run;

data tmp_edmd; 
	merge brent.edmd brent.EDMD_Overall(in=A keep=pid); by pid;
	if A;
run;
proc sort data=brent.pnp; by pid;run;
data tmp_pnp; 
	merge brent.pnp brent.pnp_Overall(in=A keep=pid); by pid;
	if A;
run;

data PP;
	set tmp_edmd(in=A) tmp_pnp(in=B);
	if  B then gs=0; else gs=1;
	if  Visit_date>'1Sep2010'd then idx=1; else idx=0;

	mon=intck("month",'1Sep2010'd,visit_date);
	mon0=min(mon,0);
	mon1=max(mon,0);

	if A;

	if Visit_date>'12Jul2011'd and md_to_exit_minutes>500 then md_to_exit_minutes=.;

	*if Visit_hospital=2 then Visit_hospital=0;
	format gs gs. idx  pp.;
	rename 	rad_ct_abd=rca rad_ct_head=rch rad_chest=rc rad_kub=rk rad_kub_chest=rkc iv_abx_present=iap iv_fluids_present=ifp iv_zofran_present=izp;
run;

/*
proc sort data=pp nodupkey out=pp_id; by pid; run;

proc means data=pp_id noprint;
class gs;
output out=wbh n(pid)=n;
run;
*/

%macro test(data,gp,out)/minoperator;

%let x= 1;

%do %while (&x <13);
    %if &x = 1  %then %do; %let var =los;       %end;
    %if &x = 2  %then %do; %let var =return;    %end;
	%if &x = 3  %then %do; %let var =admission; %end;
	%if &x = 4  %then %do; %let var =labs; 		%end;
	%if &x = 5  %then %do; %let var =rca;  		%end;
	%if &x = 6  %then %do; %let var =rch;  		%end;
	%if &x = 7  %then %do; %let var =rc;   		%end;
	%if &x = 8  %then %do; %let var =rk;   		%end;
	%if &x = 9  %then %do; %let var =rkc;  		%end; 	
    %if &x = 10 %then %do; %let var =iap;  		%end;
	%if &x = 11 %then %do; %let var =ifp;  		%end;
	%if &x = 12 %then %do; %let var =izp;  		%end;

data sub;
	set &data;
	%if &var=labs %then %do; where group in (1,2);  %end;
	%if &var=rch  %then %do; where group in (3); 	%end;
	%if &var=rca  %then %do; where group in (1);	%end;
	%if &var=rc   %then %do; where group in (4); 	%end;
	%if &var=rk   %then %do; where group in (1); 	%end;
	%if &var=rkc  %then %do; where group in (2); 	%end;
	%if &var=iap  %then %do; where group in (2); 	%end;
	%if &var=ifp  %then %do; where group in (1); 	%end;
	%if &var=izp  %then %do; where group in (1); 	%end;
run;

%if %eval(&x in 1 4 6 7 8 9) %then %do;
	%stat(sub, &gp, stat, &var, &x);
%end;

%if %eval(&x in 2 3 5 10 11 12) %then %do;
	%tab(sub, &gp, tf, &var, &x);
%end;

data stat;
	set stat1 stat4 stat6 stat7 stat8 stat9;
	keep item mean0 mean1 pv pvalue;
	rename mean0=nfn mean1=nfy;
run;

data tab;
	set tf2 tf3 tf5 tf10 tf11 tf12;
	keep item nfy nfn or rg pv pvalue;
run;

data tab;
	length nfn nfy rg $50;
	set stat tab;
	format item item.;
run;

proc sort; by item; run;
%let x = %eval(&x + 1);
%end;
%mend test;

%test(pp, idx, tab);run;

options orientation=landscape nodate;
ods rtf file="overall.rtf" style=journal bodytitle startpage=no;

proc report data=tab nowindows headline spacing=1 split='*' style=[just=center];
	title "Test Pre/Post Intervention (Overall)";
	column item nfn nfy or rg pv;
	define item/"." format=item. style=[just=Left cellwidth=2in];
	define nfn/"Pre Intervention" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define nfy/"Post Intervention" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define or/"Odds Ratio" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
	define rg/"Range" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
	define pv/"p value" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
run;
ods rtf close;

data site1 site2;
	set pp; 
	rename attending_primary_location=site;
	if attending_primary_location=1 then output site1;
	if attending_primary_location=2 then output site2;
run;
%test(site1, idx, tab);run;

options orientation=landscape nodate;
ods rtf file="eg.rtf" style=journal bodytitle startpage=no;

proc report data=tab nowindows headline spacing=1 split='*' style=[just=center];
	title "Test Pre/Post Intervention (Egleston)";
	column item nfn nfy or rg pv;
	define item/"." format=item. style=[just=Left cellwidth=2in];
	define nfn/"Pre Intervention" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define nfy/"Post Intervention" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define or/"Odds Ratio" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
	define rg/"Range" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
	define pv/"p value" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
run;
ods rtf close;

%test(site2, idx, tab);run;

options orientation=landscape nodate;
ods rtf file="sr.rtf" style=journal bodytitle startpage=no;

proc report data=tab nowindows headline spacing=1 split='*' style=[just=center];
	title "Test Pre/Post Intervention (Scottish Rite)";
	column item nfn nfy or rg pv;
	define item/"." format=item. style=[just=Left cellwidth=2in];
	define nfn/"Pre Intervention" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define nfy/"Post Intervention" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define or/"Odds Ratio" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
	define rg/"Range" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
	define pv/"p value" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
run;
ods rtf close;
