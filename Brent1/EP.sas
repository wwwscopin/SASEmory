options nofmterr;
%let path=H:\SAS_Emory\Consulting\Brent\;
libname brent "&path";
filename EP1 "&path.ed_pv_data_2010q3.xls";
filename EP2 "&path.ed_pv_data_2010q4.xls";

PROC IMPORT OUT= edmd1 
            DATAFILE= EP1 
            DBMS=EXCEL REPLACE;
     sheet="EDMD"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= edmd2 
            DATAFILE= EP2 
            DBMS=EXCEL REPLACE;
     sheet="EDMD"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data edmd2;
	set edmd2(rename=(Visit_hospital=vh attending_primary_location=apl  disposition_primary_location=dpl));
	if vh='SR' then Visit_hospital=2; else Visit_hospital=1;
	if apl='SR' then attending_primary_location=2; else attending_primary_location=1;
	if dpl='SR' then  disposition_primary_location=2; else  disposition_primary_location=1;
run;

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
run;

data brent.EDMD;
	set edmd1 edmd2;
	if study_group="age" then group=1;
	if study_group="fever" then group=2;
	if study_group="head injury" then group=3;
	if study_group="respiratory" then group=4;

	Acuity=3;
	exit=substr(IBEX_EXIT_CODE,2,1)+0;
	if 	 attending_num=disposition_attending_num then AD=1; else AD=0;
	rename  md_to_exit_minutes=los revisit_72_hours=return admitted_to_hospital=admission attending_num=pid;
	drop study_group IBEX_EXIT_CODE;
	format group group.  Visit_hospital attending_primary_location  disposition_primary_location site. 
		exit exit. Acuity Acuity. 
		admitted_to_hospital revisit_72_hours rad_ct_abd iv_abx_present iv_fluids_present iv_zofran_present AD yn.;
run;

proc print data=brent.edmd(obs=100);run;
proc sort; by group;run;

proc sort data=brent.edmd(keep=pid disposition_attending_num) out=edmd_id nodupkey;  by pid;run;
data edmd_id;
	set edmd_id;
	if disposition_attending_num=pid then idx=1; else idx=0;
run;
proc sort; by idx pid;
proc print;run;

PROC IMPORT OUT= pnp1 
            DATAFILE= EP1 
            DBMS=EXCEL REPLACE;
     sheet="PNP"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= pnp2 
            DATAFILE= EP2 
            DBMS=EXCEL REPLACE;
     sheet="PNP"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data pnp2;
	set pnp2(rename=(Visit_hospital=vh attending_primary_location=apl  disposition_primary_location=dpl));
	if vh='SR' then Visit_hospital=2; else Visit_hospital=1;
	if apl='SR' then attending_primary_location=2; else attending_primary_location=1;
	if dpl='SR' then  disposition_primary_location=2; else  disposition_primary_location=1;
run;

data brent.PNP;
	set pnp1 pnp2;
	if study_group="age" then group=1;
	if study_group="fever" then group=2;
	if study_group="head injury" then group=3;
	if study_group="respiratory" then group=4;

	Acuity=substr(IBEX_ACUITY, 1, 1)+0;
	exit=substr(IBEX_EXIT_CODE,2,1)+0;
	arole=4;

	if disposition_attending_role="EDMD" then drole=1;
	if disposition_attending_role="MD" then drole=2;
	if disposition_attending_role="NOED" then drole=3;
	if disposition_attending_role="PNP" then drole=4;
	if 	 attending_num=disposition_attending_num then AD=1; else AD=0;

	rename  md_to_exit_minutes=los revisit_72_hours=return admitted_to_hospital=admission attending_num=pid;

	drop study_group IBEX_ACUITY IBEX_EXIT_CODE disposition_attending_role attending_role;
	format group group.  Visit_hospital attending_primary_location  disposition_primary_location site. 
		exit exit. arole drole role. Acuity Acuity. 
		admitted_to_hospital revisit_72_hours rad_ct_abd iv_abx_present iv_fluids_present iv_zofran_present AD yn.;
run;

proc sort; by group;run;
proc sort data=brent.pnp(keep=pid disposition_attending_num) out=pnp_id;  by pid;run;
data pnp_id;
	set pnp_id;
	if disposition_attending_num=pid then idx=1; else idx=0;
run;
proc sort nodupkey; by idx pid disposition_attending_num; run;
proc sort nodupkey; by pid;run;
proc print;run;


*%let pm=%sysfunc(byte(177));  
%macro rank(data, out, varlist)/minoperator;

	data sub;
		set &data;
		*if 	'1Oct2009'd<=Visit_date<'30Sep2010'd;
		if 	'1Jan2010'd<=Visit_date<'31Dec2010'd;
		%if &out=age %then %do; if group=1; %end;
		%else %if &out=fever %then %do; if group=2; %end;
		%else %if &out=injury %then %do; if group=3; %end;
		%else %if &out=respiratory %then %do; if group=4; %end;
		%if &data=brent.EDMD %then %do; if AD=1; %end;
	run;

	data &out;
		if 1=1 then delete;
	run;

	proc freq data=sub;
		tables pid; 
		ods output onewayfreqs =tmp(keep=pid frequency rename=(frequency=n));
	run;

	data tmp;
		set tmp;
		where n>=10;
	run;


	proc sort data=sub; by pid;run;
	data sub;
		merge sub tmp(in=A keep=pid); by pid;
		if A;
	run;

	proc rank data=tmp out=&out	descending ties=low;
		var n;
		ranks rank_n; 
	run;
		

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );
	
	%if &var in (rad_ct_head rad_chest rad_kub rad_kub_chest los) %then %do;
	proc means data=sub noprint;
		class pid;
		var &var;
		output out=tab&i mean(&var)=&var /*std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3 min(&var)=min max(&var)=max*/;
	run;

	data tab&i;
		set tab&i;
		if pid=. then delete;
		if _type_=0 then delete;
		drop _type_ _freq_;
		format &var 5.2;
	run;
	%end;

	%else %if &var=labs %then %do;
	proc means data=sub(where=(admission=0)) noprint;
		class pid;
		var &var;
		output out=tab&i mean(&var)=&var /*std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3 min(&var)=min max(&var)=max*/;
	run;

	data tab&i;
		set tab&i;
		if pid=. then delete;
		if _type_=0 then delete;
		drop _type_ _freq_;
		format &var 5.2;
	run;
	%end;

	%else %do;
	proc freq data=sub;
		tables pid*&var/nocol nopercent;
		ods output crosstabfreqs =tmp;
	run;

	data tab&i;
		set tmp(where=(&var=1));
		if pid=. then delete;
		keep pid  RowPercent;
		rename RowPercent=&var;
		format RowPercent 5.2;
	run;
	%end;

	proc rank out=rank&i ties=low; 
     	var &var;
   		ranks rank_&var;
	run;

	proc sort; by pid;run;

	data &out;
		merge &out rank&i; by pid;
	run; 

	data &data._&out;
		set &out;
	run;

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;

	data &data._&out;
		set &data._&out;
		%if &data=brent.EDMD %then %do;
			%if &out=age %then %do;
				rk=Mean(rank_rad_ct_abd, rank_rad_kub, rank_labs, rank_iv_zofran_present, rank_iv_fluids_present, rank_los, rank_admission, rank_return);
			%end;
			%if &out=fever %then %do;
				rk=Mean(rank_rad_kub_chest, rank_labs, rank_iv_abx_present, rank_los, rank_admission, rank_return);
			%end;
			%if &out=injury %then %do; rk=Mean(rank_rad_ct_head, rank_los, rank_admission, rank_return); %end;
			%if &out=respiratory %then %do;	rk=Mean(rank_rad_chest, rank_los, rank_admission, rank_return); %end;
		%end;
		%if &data=brent.PNP %then %do;
			%if &out=age %then %do;
				rk=Mean( rank_rad_ct_abd, rank_rad_kub, rank_labs, rank_iv_zofran_present, rank_iv_fluids_present, rank_los);
			%end;
			%if &out=fever %then %do; rk=Mean(rank_rad_kub_chest, rank_labs, rank_iv_abx_present, rank_los );	%end;
			%if &out=injury %then %do; rk=Mean(rank_rad_ct_head, rank_los); %end;
			%if &out=respiratory %then %do;	rk=Mean(rank_rad_chest, rank_los); %end;
		%end;
	run;		
	proc rank out=&data._&out ties=low; 
     	var rk;
   		ranks rank;
	run;

%mend rank;	
%let varlist1= rad_ct_abd rad_kub labs iv_zofran_present iv_fluids_present los admission return;
%let varlist2= rad_kub_chest labs iv_abx_present los admission return;
%let varlist3= rad_ct_head los admission return;
%let varlist4= rad_chest los admission return;

%rank(brent.EDMD,age, &varlist1);
%rank(brent.EDMD,fever, &varlist2);
%rank(brent.EDMD,injury, &varlist3);
%rank(brent.EDMD,respiratory, &varlist4);

proc print data=brent.EDMD_Age;run;
proc print data=brent.EDMD_fever;run;
proc print data=brent.EDMD_injury;run;
proc print data=brent.EDMD_respiratory;run;

data overall_edmd;
	merge  
	brent.EDMD_Age(keep=pid n rk rename=(n=na rk=rka))
	brent.EDMD_fever(keep=pid n rk rename=(n=nf rk=rkf))
	brent.EDMD_injury(keep=pid n rk rename=(n=ni rk=rki))
	brent.EDMD_respiratory(keep=pid n rk rename=(n=nr rk=rkr)); by pid;

	if na=. then na=0; if nf=. then nf=0; 	if ni=. then ni=0; if nr=. then nr=0;
	if rka=. then rka=0; if rkf=. then rkf=0; 	if rki=. then rki=0; if rkr=. then rkr=0;

	n=na+nf+ni+nr;
	rk=na/n*rka+nf/n*rkf+ni/n*rki+nr/n*rkr;
	format rk 4.1;
run;
proc rank out=brent.EDMD_Overall ties=low; 
     	var rk;
   		ranks rank;
run;

proc export data=brent.EDMD_Age outfile='H:\SAS_Emory\Consulting\Brent\EDMD.xls' dbms=xls replace; sheet='AGE'; run;
proc export data=brent.EDMD_fever outfile='H:\SAS_Emory\Consulting\Brent\EDMD.xls' dbms=xls replace; sheet='fever'; run;
proc export data=brent.EDMD_injury outfile='H:\SAS_Emory\Consulting\Brent\EDMD.xls' dbms=xls replace; sheet='injury'; run;
proc export data=brent.EDMD_respiratory outfile='H:\SAS_Emory\Consulting\Brent\EDMD.xls' dbms=xls replace; sheet='respiratory'; run;
proc export data=brent.EDMD_overall outfile='H:\SAS_Emory\Consulting\Brent\EDMD.xls' dbms=xls replace; sheet='overall'; run;

%let varlist5= rad_ct_abd rad_kub labs iv_zofran_present iv_fluids_present los;
%let varlist6= rad_kub_chest labs iv_abx_present los ;
%let varlist7= rad_ct_head los ;
%let varlist8= rad_chest los ;

%rank(brent.PNP,age, &varlist5);
%rank(brent.PNP,fever, &varlist6);
%rank(brent.PNP,injury, &varlist7);
%rank(brent.PNP,respiratory, &varlist8);

proc print data=brent.PNP_Age;run;
proc print data=brent.PNP_fever;run;
proc print data=brent.PNP_injury;run;
proc print data=brent.PNP_respiratory;run;

data overall_pnp;
	merge  
	brent.pnp_Age(keep=pid n rank_n rk rename=(n=na rk=rka))
	brent.pnp_fever(keep=pid n rk rename=(n=nf rk=rkf))
	brent.pnp_injury(keep=pid n rk rename=(n=ni rk=rki))
	brent.pnp_respiratory(keep=pid n rk rename=(n=nr rk=rkr)); by pid;

	if na=. then na=0; if nf=. then nf=0; 	if ni=. then ni=0; if nr=. then nr=0;
	if rka=. then rka=0; if rkf=. then rkf=0; 	if rki=. then rki=0; if rkr=. then rkr=0;

	n=na+nf+ni+nr;
	rk=na/n*rka+nf/n*rkf+ni/n*rki+nr/n*rkr;
	format rk 4.1;
run;
proc rank out=brent.pnp_Overall ties=low; 
     	var rk;
   		ranks rank;
run;

proc export data=brent.PNP_Age outfile='H:\SAS_Emory\Consulting\Brent\PNP.xls' dbms=xls replace; sheet='AGE'; run;
proc export data=brent.PNP_fever outfile='H:\SAS_Emory\Consulting\Brent\PNP.xls' dbms=xls replace; sheet='fever'; run;
proc export data=brent.PNP_injury outfile='H:\SAS_Emory\Consulting\Brent\PNP.xls' dbms=xls replace; sheet='injury'; run;
proc export data=brent.PNP_respiratory outfile='H:\SAS_Emory\Consulting\Brent\PNP.xls' dbms=xls replace; sheet='respiratory'; run;
proc export data=brent.PNP_overall outfile='H:\SAS_Emory\Consulting\Brent\PNP.xls' dbms=xls replace; sheet='overall'; run;

	data sub;
		set brent.edmd;
		if 	'1Oct2009'd<=Visit_date<'30Sep2010'd;
		where group=1;
	run;

	proc freq; 
		tables pid;
	run;
