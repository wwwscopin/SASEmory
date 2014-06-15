%let path=H:\SAS_Emory\Consulting\George\;
filename george "&path.Fresh Data.xls";

PROC IMPORT OUT= knee0 
            DATAFILE= george 
            DBMS=EXCEL REPLACE;
     sheet="Sheet2"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc format; 
	value group
		0="STD"
		1="Flex"
		;

	value t
		0="PREOP"
		1="6 WEEK"
		2="6 MONTH"
		3="1 YEAR"
		4="2 YEAR"
		;
run;


data knee;
	set knee0;
	if 1<_n_<118;
	if F1='PREOP' then t1=0; if F1='6 WEEK' then t1=1; if F1='6 MONTH' then t1=2; if F1='1 YEAR' then t1=3; if F1='2 YEAR' then t1=4;
	if F8='PREOP' then t2=0; if F8='6 WEEK' then t2=1; if F8='6 MONTH' then t2=2; if F8='1 YEAR' then t2=3; if F8='2 YEAR' then t2=4;
	hss=F4+0; kss=f5+0; Flexion=f6+0;  Extension=F7+0; Physical=F11+0; Mental=F12+0;
	id1=F3+0; id2=F10+0;
	name1=compress(f2);	name2=compress(f9);

	if name1 in('AAA', 'RMD', 'GWB', 'HJD', 'HLM', 'HSR', 'JWH', 'RGG', 'SEC', 'WMP', 'WMP', 'WRB') then group1=1;
	if name1 in('AOH', 'DSS', 'GP', 'HDG', 'HGJ', 'JAH', 'JAL', 'JLM', 'JMW', 'LLG', 'WG', 'GWD') then group1=0;

	if name2 in('AAA', 'RMD', 'GWB', 'HJD', 'HLM', 'HSR', 'JWH', 'RGG', 'SEC', 'WMP', 'WMP', 'WRB') then group2=1;
	if name2 in('AOH', 'DSS', 'GP', 'HDG', 'HGJ', 'JAH', 'JAL', 'JLM', 'JMW', 'LLG', 'WG', 'GWD') then group2=0;

	if id1=2920 then name1="WMP_R";		if id1=2912 then name1="WMP_L";
	if id2=2920 then name2="WMP_R";		if id2=2912 then name2="WMP_L";

	drop F1-F12;
	format group1 group2 group. t1 t2 t.;
run;

data knee1;
	set knee;
	drop id2 t2 name2 group2 Physical Mental;
	rename id1=id name1=name t1=t group1=group;
run;

proc sort; by name id t; run;

data knee2;
	set knee;
	keep id2 t2 name2 group2 Physical Mental;
	rename id2=id name2=name t2=t group2=group;
run;
proc sort; by name id t; run;

data new_knee;
	merge knee1 knee2; by name id t; 
run;

proc print;run;

proc means data=new_knee maxdec=2;
	class group t;
	var hss kss flexion extension physical mental;
run;

proc ttest data = new_knee(where=(t=0));
	class group;
	var hss kss flexion extension physical mental;
run;

proc ttest data = new_knee(where=(t=1));
	class group;
	var hss kss flexion extension physical mental;
run;

proc ttest data = new_knee(where=(t=2));
	class group;
	var hss kss flexion extension physical mental;
run;

proc ttest data = new_knee(where=(t=3));
	class group;
	var hss kss flexion extension physical mental;
run;

proc ttest data = new_knee(where=(t=4));
	class group;
	var hss kss flexion extension physical mental;
run;


proc npar1way data = new_knee(where=(t=0)) wilcoxon;
 	class group;
	var hss kss flexion extension physical mental;
	exact;
run;

proc npar1way data = new_knee(where=(t=1)) wilcoxon;
 	class group;
	var hss kss flexion extension physical mental;
	exact;
run;

proc npar1way data = new_knee(where=(t=2)) wilcoxon;
 	class group;
	var hss kss flexion extension physical mental;
	exact;
run;

proc npar1way data = new_knee(where=(t=3)) wilcoxon;
 	class group;
	var hss kss flexion extension physical mental;
	exact;
run;

proc npar1way data = new_knee(where=(t=4)) wilcoxon;
 	class group;
	var hss kss flexion extension physical mental;
	exact;
run;


