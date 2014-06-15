
%let pm=%sysfunc(byte(177));  
%macro stat(data, gp, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data /*noprint*/;
		class &gp;
		var &var;
		output out=tab&i n(&var)=m mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;
	
	data tab&i;
		set tab&i;

		*mean0=put(median,5.0)||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"],"||compress(m);
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"("||compress(m)||")";
		
        %if &var=Apgar5Min %then %do;
    		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"("||compress(m)||")";
    	%end;
    	
				
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

%macro tab(data, gp, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data;
			table &var*&gp/nocol nopercent chisq fisher cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

	proc sort data=tab&i; by &var; run;
	
	
	data _null_;
	   set tab&i(where=(_type_="01"));
        if &gp=1 then call symput("ny", compress(frequency));
	    if &gp=0 then call symput("nn", compress(frequency));
	run;
	
	%let nt=%sysevalf(&ny+&nn);
	
	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(&gp=1) keep=&var &gp frequency rowpercent rename=(frequency=ny)) 
		tab&i(where=(&gp=0) keep=&var &gp frequency rename=(frequency=no));
		by &var;

		item=&i;

		if &var=. then delete;

		nt=ny+no;
		fy=ny/&ny*100; 		fn=no/&nn*100;  ft=nt/&nt*100;  
		nfy=ny||"/&ny"||"("||put(fy,5.1)||"%)";		nfn=no||"/&nn"||"("||put(fn,5.1)||"%)";   


		nft=nt||"/&nt"||"("||put(ft,5.1)||"%)";

		rename &var=code;
		drop &gp;
	run;
	
	proc sort data=tab&i; by code; run; 

		
	   data p&i;
    		length pv $6;
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


	data tab&i;
		merge tab&i p&i; by item ;
	run;

	data &out;
		set &out tab&i; 
		keep code item ny no nt fy fn ft nfy nfn nft or range pvalue pv;
		format RowPercent 5.1;
		format code;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%macro table(data, out, var1, var2);

proc freq data=&data;
 tables &var1*&var2;
 ods output crosstabfreqs=one;
 run;
 
 proc sort; by &var1;run;
 proc sort data=&data nodupkey out=temp(keep=&var2); by &var2;run;

 
 data _null_;
    set temp(where=(&var2^=.));
    call symput("m", compress(_n_));
 run;
 
  
 proc transpose data=one out=tmp; by &var1; 
 var &var2 frequency ColPercent rowpercent;
 run;
 

 data _null_;
    set tmp;
    if _n_=2 then do;
        %do j=1 %to &m;
            call symput("n&j", compress(col&j));
        %end;
     end;
 run;
 
 %do j=1 %to &m;
     %let n=%eval(&n+&&n&j);
 %end;
 
 data tmp1;
    set tmp(where=(_name_='ColPercent'));
    %do j=1 %to &m;
        rename col&j=cp&j;
    %end;
 run;
 
  data tmp2;
    set tmp(where=(_name_='RowPercent'));
    %do j=1 %to &m;
        rename col&j=rp&j;
    %end;
 run;
 
 
 data &out;
    merge tmp(where=(_name_='Frequency')) 
          tmp1 
          tmp2; 
          by &var1;
          col=sum(of col1-col&m);
          cp=col/&n*100;
          drop _NAME_   _LABEL_  ;
          %do j=1 %to &m;
              c&j=col&j||"("||compress(put(cp&j,4.1))||"%)";
          %end;
              c=col||"("||compress(put(cp,4.1))||"%)";
          if &var1=" " then delete;
run;
 
%mend table;
