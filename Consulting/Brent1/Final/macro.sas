%let pm=%sysfunc(byte(177));  
%macro stat(data, gp, out, varlist,ind);
	data &out;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data;
		class &gp;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;
		%if &var=los %then %do;
			mean0=put(mean,3.0)||" &pm "||compress(put(std,3.0))||"["||compress(put(Q1,3.0))||" - "||compress(put(Q3,3.0))||"], "||compress(n);
			format median 3.0;
		%end;
		%else %do;
			mean=mean*100; std=std*100;
			mean0=put(mean,4.1)||" &pm "||compress(put(std,4.1))||", "||compress(n);
		%end;
		if &gp=. then delete;

		item=&ind;
		keep &gp mean0 median item;
	run;

	proc npar1way data = &data wilcoxon;
  		class &gp;
  		var &var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		length pv $10;
		set wp&i;
		if _n_=10;
		item=&ind;
		pvalue=nvalue1;
		pv=put(nvalue1, 7.4);
		if pvalue<0.0001 then pv='<0.0001';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(&gp=0)) 
			tab&i(where=(&gp=1)rename=(mean0=mean1 median=median1)) wp&i; by item;
		drop &gp;
	run;

	data &out;
		set &out tab&i;
	run;

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
	data &out&ind; set &out; run;		
%mend stat;	

%macro tab(data, gp, out, varlist, ind)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data ;
			table &gp*&var/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			XP2_FISH=.;
			set p&i;
			item=&ind;
			pvalue=XP2_FISH+0;
			if pvalue=. then pvalue= P_PCHI+0;
			if pvalue^=. and pvalue<0.01 then pv='<0.0001'; else pv=put(pvalue,7.4);

			or=_MHOR_+0;
			range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 7.4;
		run;

		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;

	proc sort data=tab&i; by &var; run;


	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(&gp=1 and &var=1) keep=&var &gp frequency rowpercent rename=(frequency=ny rowpercent=rpcty)) 
			  tab&i(where=(&gp=0 and &var=1) keep=&var &gp frequency rowpercent rename=(frequency=no rowpercent=rpctn)) 
			  tab&i(where=(&gp=1 and &var=.) keep=&var &gp frequency rename=(frequency=n1)) 
			  tab&i(where=(&gp=0 and &var=.) keep=&var &gp frequency rename=(frequency=n0));

		item=&ind;
		nfy=ny||"/"||compress(n1)||"("||put(rpcty,4.1)||"%)";		nfn=no||"/"||compress(n0)||"("||put(rpctn,4.1)||"%)";
		nfy=compress(nfy);
		drop &gp &var;
	run;


	data tab&i;
		merge tab&i p&i; by item ;
	run;

	data &out;
		set &out tab&i; 
		keep item ny no rpcty rpctn n0 n1 nfy nfn or range pvalue pv;
	run; 
   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
   %end;
   	data &out&ind; set &out; rename range=rg; run;		
%mend tab;

%macro id_stat(data, gp, out, var,ind);

goptions reset=all rotate = landscape gsfmode=replace noborder ftitle=swiss ftext=swiss;

data temp;	if 1=1 then delete; run;

	proc means data=&data;
		by pid;
		class &gp;
		var &var;
		output out=temp n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median;
	run;


	data temp;
		set temp;
		item=&ind;
		%if &var^=los %then %do; 
			mean=mean*100;
			std=std*100;
		%end;
		gp1= &gp - .1 + .2*uniform(613);
	run;

	data paired;
		merge temp(where=(&gp=0) keep=pid &gp mean rename=(mean=mean0))
			temp(where=(&gp=1) keep=pid &gp mean rename=(mean=mean1)); by pid;
		diff=mean1-mean0;
	run;

	proc ttest data =paired;
  		paired mean0*mean1;
		ods output Ttests=pv;
	run;

	data _null_;
		set pv;
		
		if probt<0.0001 then pv='<0.0001';
		else if probt<0.001 then pv=put(probt, 7.4);
		else if probt<0.1 then pv=put(probt, 7.3);
		else pv=put(probt, 7.2);
		
		call symput("pv", compress(pv));
	run;

	/*
	proc npar1way data=temp wilcoxon;
		class &gp;
		var mean;
		ods output WilcoxonTest=pv;
	run;

	data _null_;
		length pv $10;
		set pv;
		if _n_=10;
		pv=put(nvalue1, 5.2);
		if nvalue1<0.01 then pv='<0.01';
		call symput("pv", compress(pv));
	run;
	*/

axis1 	label=(h=2 ' ' ) value=( h=2.0) split="*" order= (-1 to 2 by 1 ) minor=none offset=(0 in, 0 in);

%if &var=los %then %do;
axis2 	label=(h=1.5 a=90 "Length of ED Stay (Mins)") order=(60 to 180 by 10) value=( h=1.25) ;
%end;


%if &var=labs %then %do;
axis2 	label=(h=1.5 a=90 "Lab Tests Performed (per 100 Patients)") order=(0 to 100 by 10) value=( h=1.25) ;
%end;

%if &var=rch %then %do;
axis2 	label=(h=1.5 a=90 "Head CT Scans Performed (per 100 Patients)") order=(0 to 80 by 10) value=(h=1.25) ;
%end;

%if &var=rc %then %do;
axis2 	label=(h=1.5 a=90 "Chest X-Ray Performed (per 100 Patients)") order=(0 to 60 by 5) value=( h=1.25) ;
%end;

%if &var=rk %then %do;
axis2 	label=( h=1.5 a=90 "Abdominal X-Ray Performed (per 100 Patients)") order=(0 to 40 by 5) value=( h=1.25) ;
%end;

%if &var=rkc %then %do;
axis2 	label=( h=1.5 a=90 "Chest and Abdominal X-Ray Performed (per 100 Patients)") order=(0 to 60 by 5) value=( h=1.25) ;
%end;


symbol1 interpol=boxt mode=exclude value=none color=black height=2 bwidth=10 width=2; 
symbol2 i=none mode=exclude value=dot color=blue h=0.4; 	

                  
proc gplot data=temp gout=brent.graphs;
	title " ";
    plot   mean*&gp mean*gp1/overlay haxis = axis1 vaxis = axis2  nolegend;
    format &gp idx. mean 5.0;
	note m=(15,-5) h=1.5 "p value=&pv";
run;
*ods trace off;

	data tmp;
		merge temp(where=(&gp=0) rename=(n=n0 mean=mean0)) 
			  temp(where=(&gp=1) rename=(n=n1 mean=mean1)); by pid;
		keep pid n0 n1 mean0 mean1; 
	run;

	data id_&ind;
		set tmp;
		item=&ind;
	run;

	
	proc means data=tmp n mean std Q1 Q3;
		var mean0 mean1;
		ods output summary=ttmp;
	run;

	data &out&ind;
		length pv $10;
		set ttmp;
		item=&ind;
		pv="&pv";
		keep item mean0_N mean0_Mean mean0_StdDev mean0_Q1 mean0_Q3 mean1_N mean1_Mean mean1_StdDev mean1_Q1 mean1_Q3 pv;
		rename mean0_N=n0 mean0_Mean=mean0 mean0_StdDev=std0 mean0_Q1=pre_Q1 mean0_Q3=pre_Q3 mean1_N=n1 mean1_Mean=mean1 mean1_StdDev=std1 mean1_Q1=post_Q1 mean1_Q3=post_Q3;
	run;	
%mend id_stat;	

%macro id_tab(data, gp, out, var, ind)/minoperator parmbuff;

goptions reset=all rotate =landscape gsfmode=replace noborder ftitle=swiss ftext=swiss;

data temp;	if 1=1 then delete; run;

		proc freq data=&data;
			by pid;
			table &gp*&var/nocol nopercent;
			ods output crosstabfreqs = temp;
		run;
		*ods trace off;
	proc sort data=temp(where=(&var=1 and _type_="11")); by &var; run;

	data temp;
		set temp;
		gp1= &gp - .1 + .2*uniform(613);
	run;

	/*
	proc npar1way data=temp wilcoxon;
		class &gp;
		var rowpercent;
		ods output WilcoxonTest=pv;
	run;

	data _null_;
		length pv $10;
		set pv;
		if _n_=10;
		pv=put(nvalue1, 5.2);
		if nvalue1<0.01 then pv='<0.01';
		call symput("pv", compress(pv));
	run;
	*/

	data tmp;
		merge temp(where=(&gp=0) rename=(frequency=n0 RowPercent=rp0)) 
			  temp(where=(&gp=1) rename=(frequency=n1 RowPercent=rp1)); by pid;
		diff=rp1-rp0;
		keep pid n0 n1 rp0 rp1 diff; 
	run;

	proc ttest data =tmp;
  		paired rp0*rp1;
		ods output Ttests=pv;
	run;

	data _null_;
		set pv;
		if probt<0.0001 then pv='<0.0001';
		else if probt<0.001 then pv=put(probt, 7.4);
		else if probt<0.1 then pv=put(probt, 7.3);
		else pv=put(probt, 7.2);
		call symput("pv", compress(pv));
	run;


axis1 	label=(h=2 ' ' ) value=( h=2.0) split="*" order= (-1 to 2 by 1 ) minor=none offset=(0in, 0in);


%if &var=return %then %do;
axis2 	label=( h=1.5 a=90 "72 Hour Return Rate (%)") order=(0 to 5 by 1) value=( h=1.25) ;
%end;

%if &var=admission %then %do;
axis2 	label=( h=1.5 a=90 "Rates of Admission to Hospital (%)") order=(0 to 10 by 1) value=( h=1.25) ;
%end;

%if &var=rca %then %do;
axis2 	label=( h=1.5 a=90 "Abdominal/Pelvic CT Scans Performed (%)") order=(0 to 8 by 1) value=( h=1.25) ;
%end;

%if &var=iap %then %do;
axis2 	label=( h=1.5 a=90 "Intravenous Antibiotics Administered (%)") order=(0 to 40 by 5) value=( h=1.25) ;
%end;

%if &var=ifp %then %do;
axis2 	label=( h=1.5 a=90 "Intravenous Fluid Administered (%)") order=(0 to 80 by 10) value=( h=1.25) ;
%end;

%if &var=izp %then %do;
axis2 	label=( h=1.5 a=90 "Intravenous Ondansetron Administered (%)") order=(0 to 30 by 5) value=( h=1.25) ;
%end;


symbol1 interpol=boxt mode=exclude value=none color=black height=2 bwidth=10 width=2; 	 
symbol2 i=none mode=exclude value=dot color=blue h=0.4; 	

                  
proc gplot data=temp gout=brent.graphs;
	title " ";
    plot   RowPercent*&gp RowPercent*gp1/overlay haxis = axis1 vaxis = axis2  nolegend;
    format &gp idx. RowPercent 5.0;
	note m=(15,-5) h=1.5 "p value=&pv";
run;
*ods trace off;


	proc means data=tmp n mean std Q1 Q3;
		var rp0 rp1;
		ods output summary=ttmp;
	run;

	data &out&ind;
		length pv $10;
		set ttmp;
		item=&ind;
		pv="&pv";
		keep item rp0_N rp0_Mean rp0_StdDev rp0_Q1 rp0_Q3 rp1_N rp1_Mean rp1_StdDev rp1_Q1 rp1_Q3 pv;
		rename rp0_N=n0 rp0_Mean=mean0 rp0_StdDev=std0 rp0_Q1=pre_Q1 rp0_Q3=pre_Q3 rp1_N=n1 rp1_Mean=mean1 rp1_StdDev=std1 rp1_Q1=post_Q1 rp1_Q3=post_Q3;
	run;
%mend id_tab;
