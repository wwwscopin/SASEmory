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
			mean0=put(mean,3.0)||" &pm "||compress(put(std,3.0))||"["||compress(put(Q1,3.0))||" - "||compress(put(Q3,3.0))||"]";
			format median 3.0;
		%end;
		%else %do;
			mean0=put(mean,7.4)||" &pm "||compress(put(std,7.4));
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

	proc means data=&data;
		by pid;
		class &gp;
		var &var;
		output out=temp n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median;
	run;

	data tmp;
		merge temp(where=(&gp=0) rename=(n=n0 mean=mean0)) 
			  temp(where=(&gp=1) rename=(n=n1 mean=mean1)); by pid;
		keep pid n0 n1 mean0 mean1; 
	run;
	
	proc means data=tmp n mean std Q1 Q3;
		var mean0 mean1;
		ods output summary=ttmp;
	run;

	data &out&ind;
		set ttmp;
		item=&ind;
		keep item mean0_N mean0_Mean mean0_StdDev mean0_Q1 mean0_Q3 mean1_N mean1_Mean mean1_StdDev mean1_Q1 mean1_Q3;
		rename mean0_N=n0 mean0_Mean=mean0 mean0_StdDev=std0 mean0_Q1=pre_Q1 mean0_Q3=pre_Q3 mean1_N=n1 mean1_Mean=mean1 mean1_StdDev=std1 mean1_Q1=post_Q1 mean1_Q3=post_Q3;
	run;	
%mend id_stat;	

%macro id_tab(data, gp, out, var, ind)/minoperator parmbuff;

		proc freq data=&data;
			by pid;
			table &gp*&var/nocol nopercent;
			ods output crosstabfreqs = temp;
		run;
		*ods trace off;
	proc sort data=temp(where=(&var=1 and _type_="11")); by &var; run;
	
	data tmp;
		merge temp(where=(&gp=0) rename=(frequency=n0 RowPercent=rp0)) 
			  temp(where=(&gp=1) rename=(frequency=n1 RowPercent=rp1)); by pid;
		keep pid n0 n1 rp0 rp1; 
	run;

	proc means data=tmp n mean std Q1 Q3;
		var rp0 rp1;
		ods output summary=ttmp;
	run;

	data &out&ind;
		set ttmp;
		item=&ind;
		keep item rp0_N rp0_Mean rp0_StdDev rp0_Q1 rp0_Q3 rp1_N rp1_Mean rp1_StdDev rp1_Q1 rp1_Q3;
		rename rp0_N=n0 rp0_Mean=mean0 rp0_StdDev=std0 rp0_Q1=pre_Q1 rp0_Q3=pre_Q3 rp1_N=n1 rp1_Mean=mean1 rp1_StdDev=std1 rp1_Q1=post_Q1 rp1_Q3=post_Q3;
	run;
%mend id_tab;
