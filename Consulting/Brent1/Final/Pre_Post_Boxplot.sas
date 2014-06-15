options nofmterr /*orientation=landscape*/ orientation=portrait spool nonumber;
%let path=H:\SAS_Emory\Consulting\Brent1\Final\;
libname brent "&path";
filename edmd "&path.EDMD.xls";
filename pnp "&path.PNP.xls";

%include "&path.macro.sas";
%let pm=%sysfunc(byte(177));

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

	value gs
		0="PNP" 1="EDMD";

	value idx -1=" " 0=" Pre Intervention" 1="Post Intervention" 2=" ";

	
	value item 1="Length of ED Stay (Mins)"
               2="72 Hour Return Rate (%)"
			   3="Rates of Admission to Hospital (%)"
			   4="Lab Tests Performed (per 100 Patients)"
			   5="Abdominal/Pelvic CT Scans Performed (%)"
			   6="Head CT Scans Performed (per 100 Patients)"
			   7="Chest X-Ray Performed (per 100 Patients)"
			   8="Abdominal X-Ray Performed (per 100 Patients)"
			   9="Chest and Abdominal X-Ray Performed (per 100 Patients)"
			   10="Intravenous Antibiotics Administered (%)"
			   11="Intravenous Fluid Administered (%)"
			   12="Intravenous Ondansetron Administered (%)"
			   ;
run;
proc sort data=brent.edmd; by pid;run;

data tmp_edmd; 
	merge brent.edmd brent.EDMD_Overall(in=A keep=pid); by pid;
	if A;
run;


data PP;
	set tmp_edmd;
	if  Visit_date>'1Sep2010'd then idx=1; else idx=0;

	mon=intck("month",'1Sep2010'd,visit_date);
	mon0=min(mon,0);
	mon1=max(mon,0);

	if Visit_date>'12Jul2011'd and md_to_exit_minutes>500 then md_to_exit_minutes=.;

	if Visit_date>'31Mar2012'd then delete;
	format idx  pp.;
	rename 	rad_ct_abd=rca rad_ct_head=rch rad_chest=rc rad_kub=rk rad_kub_chest=rkc iv_abx_present=iap iv_fluids_present=ifp iv_zofran_present=izp;
run;

proc sort data=pp out=pp_id nodupkey; by pid; run;


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
	%id_stat(sub, &gp, iqr, &var, &x);
%end;

%if %eval(&x in 2 3 5 10 11 12) %then %do;
	%id_tab(sub, &gp, iqr, &var, &x);
%end;


%let x = %eval(&x + 1);
%end;

data iqr;
	length pre post $20; 
	set  iqr1 iqr4 iqr6 iqr7 iqr8 iqr9 iqr2 iqr3 iqr5 iqr10 iqr11 iqr12; 
	if item=1 then do; 
			pre=put(mean0,3.0)||"["||compress(put(pre_Q1,3.0))||" - "||compress(put(pre_Q3,3.0))||"]";
			post=put(mean1,3.0)||"["||compress(put(post_Q1,3.0))||" - "||compress(put(post_Q3,3.0))||"]";
	end;
	else if item in(4,6,7,8,9) then do;
			pre=put(mean0,4.2)||"["||compress(put(pre_Q1,4.2))||" - "||compress(put(pre_Q3,4.2))||"]";
			post=put(mean1,4.2)||"["||compress(put(post_Q1,4.2))||" - "||compress(put(post_Q3,4.2))||"]";
	end;

	else do;
			pre=put(mean0,4.1)||"["||compress(put(pre_Q1,4.1))||" - "||compress(put(pre_Q3,4.1))||"]";
			post=put(mean1,4.1)||"["||compress(put(post_Q1,4.1))||" - "||compress(put(post_Q3,4.1))||"]";
	end;

run;
proc sort; by item; run;

%mend test;

options orientation=landscape nodate;

proc greplay igout= brent.graphs nofs; delete _ALL_; run;
ods listing close;
%test(pp, idx, tab);run;
ods listing;

       	ods pdf file = "edmd_boxplot.pdf" style=journal startpage=yes;
			proc greplay igout =brent.graphs tc=sashelp.templt template=whole /*whole*/ nofs;
			list igout;
			treplay 1:1; 
			treplay 1:2;
			treplay 1:3;
			treplay 1:4;
			treplay 1:5;
			treplay 1:6;
			treplay 1:7;
			treplay 1:8;
			treplay 1:9;
			treplay 1:10;
			treplay 1:11;
			treplay 1:12;
		run;
		ods pdf close;


ods rtf file="IQR by physician.rtf" style=journal bodytitle startpage=no;

proc report data=iqr nowindows headline spacing=0 split='*' style=[just=center];
	title "Test Pre/Post Intervention with Paired T-test (by Physician)";
	column item n0 pre n1 post pv;
	define item/"." format=item. style=[just=Left cellwidth=4in];
	define n0/"Pre, n=" format=2.0 style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
	define pre/"Pre Mean[Q1-Q3]" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define n1/"Post, n=" format=2.0 style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
	define post/"Post Mean[Q1-Q3]" style(column)=[just=center cellwidth=1.5in] style(header)=[just=center];
	define pv/"p value" style(column)=[just=center cellwidth=0.75in] style(header)=[just=center];
run;
ods rtf close;

