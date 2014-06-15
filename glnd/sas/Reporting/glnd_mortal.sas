
proc contents data=glnd.status;run;
proc sort data = glnd.demo_his; by id; run;

proc format; 
    value item 
            0="Overall"
            1="Treatment"
            2="Center"
            3="Apache Score"
            4="Ventilation"
            ;
     value trt 1="AG-PN" 2="STD-PN";
run;

data mech_vent;
    set glnd.plate17;
	where (dt_mech_vent_start_1 ~= .) | (dt_mech_vent_start_2 ~= .) |(dt_mech_vent_start_3 ~= .) |(dt_mech_vent_start_4 ~= .)|(dt_mech_vent_start_5 ~= .); * include only if they were ever on mechanical ventilation. some people have blank mech vent forms ;
run;
        
proc sort nodupkey;by id;run;    

data mortal;
	merge glnd.status glnd.demo_his	(keep = id race gender dt_birth) mech_vent(in=mech); by id;

	if deceased & (dt_death <= dt_discharge) then mort= 1 ; else mort = 0;
	if deceased then day=dt_death-dt_random; else day=dt_discharge-dt_random;
	age_years = (dt_random - dt_birth) / 365.25;
	
	if mech then vent=1; else vent=0;
	rename apache_2=apache;

	center = floor(id/10000);
	format center center.;
run;

%let t1=7;
%let t2=28;
%let t3=60;

%macro life(data, gvar, out, varlist);

proc freq data=&data;
	tables &gvar/norow nopct;
	ods output onewayfreqs = tab0;
run;

data tab0; 
	set tab0(where=(&gvar=1) rename=(frequency=n1 CumFrequency=n)); 
	item=0;
	f=n1/n*100;
	if &gvar=. then delete;
	n1f=compress(n1)||"("||compress(put(f,2.0))||"%)";
	format f 4.1;
	keep item &gvar n n1 f n1f;
	rename &gvar=code;
run;

proc lifetest data=&data timelist=&t1 &t2 &t3;
	time day*&gvar(0);
	ods output Lifetest.Stratum1.ProductLimitEstimates=s0(keep=Timelist survival StdErr);
run;

data s0;	
	merge s0(where=(timelist=&t1) rename=(survival=survival&t1 StdErr=StdErr&t1)) 
			s0(where=(timelist=&t2) rename=(survival=survival&t2 StdErr=StdErr&t2)) 
			s0(where=(timelist=&t3) rename=(survival=survival&t3 StdErr=StdErr&t3)); 
	code=1; item=0;
	drop timelist;
run;	

data tab0;
	merge tab0 s0; by item code;
run;

data &out;
	if 1=1 then delete;
run;

data &out;
	set tab0;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data;
			tables &var*&gvar/nocol nopct chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;
		
		
		data p&i;
			set p&i;
			item=&i;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
			if pvalue^=. and pvalue<0.001 then pv='<0.001'; else pv=put(pvalue,5.3);

			or=_LGOR_+0;
		
			rg=compress(put(or,4.2))||"["||compress(put(L_LGOR,4.2))||"--"||compress(put(U_LGOR,4.2))||"]";
			if or=. then rg=" ";
			keep item pvalue pv or rg;
		run;


		data p&i;
			merge p&i(firstobs=2 keep=item rg); by item;
		run;

	proc sort data=tab&i; by &var;run;
	data tab&i;
		merge tab&i(where=(&gvar=0) rename=(frequency=n0)) tab&i(where=(&gvar=1) rename=(frequency=n1)); by &var;
		item=&i;
		n=n0+n1;
		f=n1/n*100;
		if &var=. then delete;
		rename &var=code;
		n1f=compress(n1)||"("||compress(put(f,2.0))||"%)";
		keep item &var n n1 f n1f;
		format f 4.1;
	run;
	
	data tab&i;
	   merge tab&i p&i; by item;
	run;

proc lifetest data=&data timelist=&t1 &t2 &t3;
	time day*&gvar(0);
	strata &var;
	survival out=s&var(keep=&var timelist survival sdf_stderr) REDUCEOUT stderr;
	ods output Lifetest.StrataHomogeneity.HomTests=p&var(keep=probchisq);
run;

data s&var;	
	if _n_=1 then set p&var(obs=1);
	merge s&var(where=(timelist=&t1) rename=(survival=survival&t1 sdf_stderr=stderr&t1)) 
    	s&var(where=(timelist=&t2) rename=(survival=survival&t2 sdf_stderr=stderr&t2)) 
		s&var(where=(timelist=&t3) rename=(survival=survival&t3 sdf_stderr=stderr&t3)) ;
	item=&i;
	rename &var=code;
run;

proc sort; by item code;run;

	data tab&i;
		merge tab&i s&var; by item code;
	run;


	data &out;

		length code0 $100;
		set &out tab&i;

		/*if item=0 then  do; code0=put(code, ivh.); end;*/
		if item=1 then  do; code0=put(code, trt.); end;
		if item=2 then  do; code0=put(code, center.); end;
	    if item=3 then  do; code0=put(code, apache.); end;
		if item=4 then  do; code0=put(code, yn.); end;
	
		keep item code code0 n n1f rg survival&t1 StdErr&t1 survival&t2 StdErr&t2 survival&t3 StdErr&t3 ProbChiSq;
	run; 


	data &out;
		set &out;
		Format code;
		INFORMAT code;
 	run;

   %let i= %eval(&i+1);

   %let var = %scan(&varlist,&i);
%end;

%mend life;

%let varlist=treatment center apache vent;
%life(mortal,mort,tab, &varlist);

%let pm=%sysfunc(byte(177));


data tab;
	length pvalue $8;
	set tab; by item code;
	pvalue=put(probchisq,5.3);
	if probchisq^=. and probchisq<0.001 then pvalue="<0.001";
	if not first.item then pvalue=" ";
	format probchisq 4.2;

	surv_err&t1=put((1-survival&t1)*100,4.1)||"&pm"||put(stderr&t1*100,4.1);
	surv_err&t2=put((1-survival&t2)*100,4.1)||"&pm"||put(stderr&t2*100,4.1);
	surv_err&t3=put((1-survival&t3)*100,4.1)||"&pm"||put(stderr&t3*100,4.1);
	rename n=nt;
	format item item.;
run;

data tab1;
	set tab; by item;
	if not first.item then rg =" ";
	output;
	if last.item then do;
	Call missing( of code code0 nt n1f rg survival&t1 StdErr&t1 survival&t2 StdErr&t2 survival&t3 StdErr&t3 ProbChiSq surv_err&t1 surv_err&t2 surv_err&t3) ; 
    output; end;
run;



options orientation=landscape;
ods rtf file="glnd_mort.rtf" style=journal startpage=no bodytitle ;

proc report data=tab1 nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center];
title "Frequency and Cumulative Mortality by Baseline Demographic and Clinical Characteristics";

column item code0 nt ("Died in Hospital" n1f rg) ("*Cumulative Mortality(%) &pm SEE" surv_err&t1 surv_err&t3) pvalue;

define item/order ORDER=INTERNAL width=50 "Characteristic" style(column)=[just=left] style(header)=[just=left];
define code0/" " style(column)=[just=left cellwidth=2in];
define nt/"n" style(column)=[cellwidth=0.6in just=center];
define n1f/"n(%)" style(column)=[cellwidth=0.75in just=center];
define rg/"OR[95%CI]" style(column)=[cellwidth=1.25in just=center];
define surv_err&t1/"&t1 days" style(column)=[cellwidth=1in just=center];
define surv_err&t3/"&t3 days" style(column)=[cellwidth=1in just=center];
define pvalue/"p value" style(column)=[cellwidth=0.8in just=center];

break after item / dol dul skip;
run;
ods rtf close;
