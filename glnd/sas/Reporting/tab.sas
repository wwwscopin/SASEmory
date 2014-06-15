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
	if &gp=1 then call symput("n1", compress(frequency));
	if &gp=2 then call symput("n2", compress(frequency));
run;

%let nt=%sysevalf(&n1+&n2);


%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data ;
			table &var*&gp/nocol nopercent chisq cmh;
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
		length nfy nfn $25;
		merge tab&i(where=(&gp=1) keep=&var &gp frequency rowpercent rename=(frequency=ny)) 
		tab&i(where=(&gp=2) keep=&var &gp frequency rename=(frequency=no))
			tab&i(where=(&gp=.) keep=&var &gp frequency rename=(frequency=nt)); 
		by &var;

		item=&i;

		if &var=. then delete;


		fy=ny/&n1*100; 		fn=no/&n2*100;   ft=nt/&nt*100;
		nfy=ny||"/&n1"||"("||put(fy,5.1)||"%)";		nfn=no||"/&n2"||"("||put(fn,5.1)||"%)";   nft=nt||"/&nt"||"("||put(ft,5.1)||"%)";


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
		if code=1;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;
