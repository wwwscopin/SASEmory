options orientation=landscape nonumber nodate ;
%include "H:\SAS_Emory\RedCap\RawData\con_med.sas";
libname brent "H:\SAS_Emory\RedCap\data";

proc format;
	value idx 0="Control" 1="Case";
run;


data conmed;
	set brent.con_med;
run;
proc sort; by idx id;run;

data _null_;
	set conmed(where=(idx=0));
	call symput("y1", compress(_n_));
run;
data _null_;
	set conmed(where=(idx=1));
	call symput("y2", compress(_n_));
run;


%macro con_med(data);
	data temp; if 1=1 then delete;run;
	%do i=1 %to 23;
		data temp;
			set temp 
				&data(keep=id patient_id idx med&i dt_start&i rename=(med&i=med dt_start&i=dt_start0))
				;
	%end;	
	data con_med; set temp;
		if strip(med)="" then delete; 
		dt_start=mdy(scan(dt_start0,1,'/'), scan(dt_start0,2,'/'), scan(dt_start0,3,'/'));
		drop dt_start0;
		format dt_start mmddyy10. idx idx.;
	run;	
	proc sort; by idx id med dt_start;run;

	data con_med;
		set con_med; by idx id med dt_start;
		if first.med then m=0;
		m+1; 
		if last.med;
	run;
	proc sort; by patient_id;run;
%mend con_med;

%con_med(conmed);

proc sql;
	create table con_med_tab as 
	select *, count(distinct strip(med)) as n
	from con_med 
	group by patient_id
	;
quit;
/*
proc freq data=con_med_tab order=freq;
	tables med*idx;
run;
*/

data con_med_tab;
	set con_med_tab;
	where med="CO-TRIMOXAZOLE" or med="TBD RIF INH" or med="METRONIDAZOLE" or med="FLUCONAZOLE" or med="FLUOXETINE"
	or med="TBD ETHAMBUTOL" or med="TBD ISONIAZID" or med="FPD NORDETTE/ORALCON" or med="TBD RIFAMPICIN" or med="ERYTHROMYCIN";
run;
proc sort; by idx id;run;

data concomitant;
	merge conmed(keep=idx id) 
		  con_med_tab(where=(med="CO-TRIMOXAZOLE") in=A) 
		  con_med_tab(where=(med="FLUCONAZOLE") in=B) 
		  con_med_tab(where=(med="TBD ETHAMBUTOL") in=C) 
		  con_med_tab(where=(med="TBD RIF INH") in=D);
	by idx id;
	if A then med1=1; else med1=0;
	if B then med2=1; else med2=0;
	if C then med3=1; else med3=0;
	if D then med4=1; else med4=0;
run;
proc print;run;

data brent.med;
	set concomitant;
	keep idx id patient_id med1-med4;
run;
proc freq data=brent.med;
	tables med1*idx/fisher;
run;

proc freq data=con_med_tab order=freq;
	tables med*idx;
	ods output crosstabfreqs=wbh;
run;
proc sort; by med; run;

%macro fisher(x1, x2, x3, x4);
data test;
	A=0; B=0; count=&x1; output;
	A=0; B=1; count=&x2; output;
	A=1; B=0; count=&x3; output;
	A=1; B=1; count=&x4; output;
run;

proc freq data=test order=data;
   tables A*B / chisq fisher;
   weight Count;
   output out = pv chisq exact;
run;

		data pv;
			set pv;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
			if pvalue^=. and pvalue<0.001 then pv='<0.001'; else pv=put(pvalue,5.3);
			rf=&x2*(&x3+&x4)/(&x1+&x2)/&x4;
			keep pv rf;
			call symput("pv", compress(pv));
		run;
%mend fisher;

data med_tab;
	merge wbh(where=(med^="" and idx=0) keep=med idx frequency rename=(frequency=x1))
		  wbh(where=(med^="" and idx=1) keep=med idx frequency rename=(frequency=x2)); by med;
	drop idx;
	f1=x1/&y1*100;
	f2=x2/&y2*100;
	cp1=x1||"("||compress(put(f1,4.1))||"%)";
	cp2=x2||"("||compress(put(f2,4.1))||"%)";
	call symput("n", compress(_n_));
run;

%macro med_tab;
	data med; if 1=1 then delete;run;
	%do i=1 %to &n;
		data _null_;
			set med_tab;
			if _n_=&i;
			call symput("x1",put(x1,3.0));
			call symput("x2",put(x2,3.0));
		run;
		%let x3=%eval(&y1-&x1);
		%let x4=%eval(&y2-&x2);
		%fisher(&x1, &x2, &x3, &x4);
		data tmp;
			merge med_tab(firstobs=&i obs=&i) pv;
		run;
		data med;
			set med tmp;
		run;		 
	%end;
%mend med_tab;
%med_tab;

ods rtf file="concomitant_med.rtf" style=journal bodytitle;
proc report data=med nowd split="*" style(report)=[just=center];
	title1 "Comparison betwen Case and Control for Concomitant Meds";
	column med cp1 cp2 pv;
	define med/"Drug Name";
	define cp1/"Control*(n=&y1)" style=[just=c];
	define cp2/"Case*(n=&y2)" style=[just=c];
	define pv/"p value*(Fisher)" style=[just=c];
run;
ods rtf close;
