

%macro stat(data, gp, out, varlist,ind);
	data &out;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data;
		class &var;
		var &gp;
		output out=tab&i n(&gp)=n mean(&gp)=mean std(&gp)=std median(&gp)=median q1(&gp)=Q1 q3(&gp)=Q3;
	run;

	data tab&i;
		set tab&i;
		mean0=put(mean,4.1)||" &pm "||compress(put(std,4.1))||"["||compress(Q1)||"-"||compress(Q3)||"]";

		if &var=. then delete;

		item=&ind;
		keep &var mean0 median item;
	run;

	*ods trace on/lable lsting;
	proc npar1way data = &data wilcoxon;
  		class &var;
  		var &gp;
  		ods output KruskalWallisTest=wp&i;
	run;
	*ods trace off;

	data wp&i;
		length pv $10;
		set wp&i;
		if _n_=3;
		item=&ind;
		pvalue=nvalue1;
		pv=put(nvalue1, 7.4);
		if pvalue<0.0001 then pv='<0.0001';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(&var=0)) 
			tab&i(where=(&var=1)rename=(mean0=mean1 median=median1)) wp&i; by item;
		drop &var;
	run;

	data &out;
		set &out tab&i;
	run;

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
	data &out&ind; set &out; run;		
%mend stat;	
