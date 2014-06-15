
%let pm=%sysfunc(byte(177));  
%macro stat(data, gp, varlist, index);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data /*noprint*/;
		class &gp;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;

		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.1))||" - "||compress(put(Q3,5.1))||"], "||compress(n);
		
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
		merge tab&i(where=(&gp=0)) 
			  tab&i(where=(&gp=1)rename=(mean0=mean1 range=range1 median=median1)) wp&i; by item;
	run;

	data stat;
		set stat tab&i;
		format item item.;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;

data stat; 
	set stat; output;
	if _n_=1 then do;
	%if &gp=comp %then %do; item=0; mean0="Work Comp=No";  mean1="Work Comp=Yes"; pv=" "; output; %end;
		%if &gp=tobacco %then %do; item=0; mean0="Tobacoc=No";  mean1="Tobacco=Yes"; pv=" "; output; %end;
			%if &gp=age_grp %then %do; item=0; mean0="Age <=65";  mean1="Age >65"; pv=" "; output; %end;
				%if &gp=pre_rom_grp %then %do; item=0; mean0="ROM FE Active <90";  mean1="ROM FE Active >=90"; pv=" "; output; %end;
					%if &gp=pre_pain_grp %then %do; item=0; mean0="Pain Score <7";  mean1="Pain Score >=7"; pv=" "; output; %end;
						%if &gp=surg_grp %then %do; item=0; mean0="Surgery =1";  mean1="Surgery >1"; pv=" "; output; %end;
							%if &gp=capsular %then %do; item=0; mean0="Capsular=No";  mean1="Capsular=Yes"; pv=" "; output; %end;
								%if &gp=tissue_grp %then %do; item=0; mean0="fair/poor/inadequate";  mean1="good/adequate"; pv=" "; output; %end;
									%if &gp=repair_comp %then %do; item=0; mean0="Partial";  mean1="Complete"; pv=" "; output; %end;
										%if &gp=size_grp %then %do; item=0; mean0="small/medium";  mean1="large/massive"; pv=" "; output; %end;
	end;
run;
proc sort; by item; run;
data stat&index; 	set stat; 	idx=&index; run;
%mend stat;	
