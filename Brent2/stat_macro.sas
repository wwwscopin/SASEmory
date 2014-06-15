
%let pm=%sysfunc(byte(177));  
%macro avg(data,varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data /*noprint*/;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		length mean0 $40;
		set tab&i;
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"], "||compress(n);

		format median 5.0;
		item=&i;
		keep mean0 median item;
	run;

	data stat;
		set stat tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;

%mend avg;


%macro stat(data, gp, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data mean std median Q1 Q3 min max/*noprint*/;
		class &gp;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		length mean0 $40;
		set tab&i;

		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"], "||compress(n);
		
		range=put(Q1,5.0)||" - "||compress(put(Q3,5.0));
		if &gp=. then &gp=9;
		format median 5.0;
		item=&i;
		keep &gp mean0 median range item;
	run;

	proc npar1way data = &data wilcoxon;
  		class &gp;
  		var &var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		length pv $6;
		set wp&i;
		if _n_=10;
		item=&i;
		pvalue=cvalue1+0;
		pv=put(pvalue, 5.3);
		if pvalue<0.001 then pv='<0.001';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(&gp=9) rename=(mean0=mean9 range=range9 median=median9))
			  tab&i(where=(&gp=0)) 
			  tab&i(where=(&gp=1)rename=(mean0=mean1 range=range1 median=median1)) wp&i; by item;
	run;

	data stat;
		set stat tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
%mend stat;	
%let my=0;
%let mn=0;

%macro binci(data, gp, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;


proc freq data=&data;
	table &gp;
	ods output OneWayFreqs =freq;
run;

data _null_;
	set freq;
	if &gp=1 then call symput("ny", compress(frequency));
	if &gp=0 then call symput("nn", compress(frequency));
run;

%let nt=%sysevalf(&ny+&nn);


%let i = 1;
%let var = %scan(&varlist, &i);

%do %while ( &var NE );

		proc freq data=&data(where=(&gp=1));
			table &var/ binomial(p=0.5);
  			exact binomial;
			ods output OneWayFreqs =freq;
			ods output BinomialProp = tab&i;
			ods output BinomialPropTest= p&i ;
		run;


data _null_;
	set freq;
	if &var=0 then call symput("mn", compress(frequency));
run;

%let my=%sysevalf(&ny-&mn);


		data p&i;
			length pv $8.;
			set p&i;
			if _n_=8;
			item=&i;
			if nValue1<0.0001 then pv="<0.0001";
			else pv=put(nvalue1,7.4);

			keep item nvalue1 pv ;
		run;


	data tab&i;
		length ci $40;

		merge 
			tab&i(firstobs=1 obs=1 keep=nvalue1) 
			tab&i(firstobs=7 obs=7 keep=nvalue1 rename=(nvalue1=nvalue2)) 
			tab&i(firstobs=8 obs=8 keep=nvalue1 rename=(nvalue1=nvalue3)) 
			; 

		item=&i;
		est=(1-nvalue1)*100;
		upper=(1-nvalue2)*100;
		lower=(1-nvalue3)*100;

		ci=compress(&my)||"/"||compress(&ny)||", "||put(est,4.1)||"%["||put(lower,4.1)||" - "||put(upper,4.1)||"]";
		drop nvalue1-nvalue3;
	run;


	data tab&i;
		merge tab&i p&i; by item ;
	run;

	data &out;
		set &out tab&i; 
		keep item ci nvalue1 pv;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend binci;


%macro tab(data, gp, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;


proc freq data=&data;
	table &gp;
	ods output OneWayFreqs =freq;
run;

data _null_;
	set freq;
	if &gp=1 then call symput("ny", compress(frequency));
	if &gp=0 then call symput("nn", compress(frequency));
run;

%let nt=%sysevalf(&ny+&nn);


%let i = 1;
%let var = %scan(&varlist, &i);

%do %while ( &var NE );

		proc freq data=&data ;
			table &var*&gp/nocol nopercent chisq fisher cmh;
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
			range=put(L_LGOR,4.2)||"--"||compress(put(U_LGOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 5.3;
		run;


		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;


	proc sort data=tab&i; by &var; run;

	data tab&i;
		length nfy nfn $40;
		merge tab&i(where=(&gp=1) keep=&var &gp frequency rowpercent rename=(frequency=ny)) 
		tab&i(where=(&gp=0) keep=&var &gp frequency rename=(frequency=no))
			tab&i(where=(&gp=.) keep=&var &gp frequency rename=(frequency=nt)); 
		by &var;

		item=&i;

		if &var=. then delete;


		fy=ny/&ny*100; 		fn=no/&nn*100;   ft=nt/&nt*100;
		nfy=ny||"/&ny"||"("||put(fy,5.1)||"%)";		nfn=no||"/&nn"||"("||put(fn,5.1)||"%)";   nft=nt||"/&nt"||"("||put(ft,5.1)||"%)";


		tmp=ny+no;
		rpct=ny||"/"||compress(tmp)||"("||put(rowpercent,4.1)||"%)";

		rename &var=code;
		drop &gp;
	run;

	proc sort data=tab&i; by code; run; 

	data tab&i;
		merge tab&i p&i; by item ;
	run;

	data &out;
		set &out tab&i; 
		keep code item ny no nt fy fn ft nfy nfn nft rpct or range pvalue pv;
		format RowPercent 5.1;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%macro log_med(data, gp, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	data log_med;
		set &data;
		log_&var=log(&var);
	run;

	proc means data=log_med mean std median Q1 Q3 min max/*noprint*/;
		class &gp;
		var log_&var;
		output out=tab&i n(log_&var)=n mean(log_&var)=log_mean std(log_&var)=log_std median(log_&var)=log_median q1(log_&var)=log_Q1 q3(log_&var)=log_Q3;
	run;

	data tab&i;
		length mean0 $40;
		set tab&i;

		mean=exp(log_mean); std=exp(log_std); median=exp(log_median); q1=exp(log_Q1); q3=exp(log_Q3);
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"], "||compress(n);
		*mean0=put(median,5.0)||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"], "||compress(n);
		
		range=put(Q1,5.0)||" - "||compress(put(Q3,5.0));
		if &gp=. then &gp=9;
		format median 5.0;
		item=&i;
		keep &gp mean0 median range item;
	run;

	proc npar1way data = log_med wilcoxon;
  		class &gp;
  		var log_&var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		length pv $6;
		set wp&i;
		if _n_=10;
		item=&i;
		pvalue=cvalue1+0;
		pv=put(pvalue, 5.3);
		if pvalue<0.001 then pv='<0.001';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(&gp=9) rename=(mean0=mean9 range=range9 median=median9))
			  tab&i(where=(&gp=0)) 
			  tab&i(where=(&gp=1)rename=(mean0=mean1 range=range1 median=median1)) wp&i; by item;
	run;

	data stat;
		set stat tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
%mend log_med;	
