
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
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;

		*mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"], "||compress(n);
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||", "||compress(put(median,5.1))||", "||compress(n);
		
		range=put(Q1,5.0)||" - "||compress(put(Q3,5.0));
		if &gp=. then &gp=9;
		format median 5.0;
		item=&i;
		keep &gp mean0 median range item;
	run;

	*ods trace on/label listing;
	proc npar1way data = &data wilcoxon;
  		class &gp;
  		var &var;
  		ods output Wilcoxon.KruskalWallisTest=wp&i;
	run;
	*ods trace off;



	data wp&i;
		length pv $8;
		set wp&i;
		if _n_=3;
		item=&i;
		pvalue=nvalue1+0;
		pv=put(pvalue, 5.3);
		if pvalue<0.001 then pv='<0.001';
		keep item pvalue pv;
	run;


	data tab&i;
		merge tab&i(where=(&gp=9) rename=(mean0=mean9 range=range9 median=median9))
			  tab&i(where=(&gp=1)rename=(mean0=mean1 range=range1 median=median1))
			  tab&i(where=(&gp=2)rename=(mean0=mean2 range=range2 median=median2))
			  tab&i(where=(&gp=3)rename=(mean0=mean3 range=range3 median=median3))
			  tab&i(where=(&gp=4)rename=(mean0=mean4 range=range4 median=median4))
			  wp&i; by item;
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
		proc freq data=&data(where=(&var not in(-77,-88,-99))) ;
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


%macro getn(data);
%do j = 2 %to 28;
data _null_;
    set &data;
    where day = &j;
    if &gvar=1 then call symput( "k&j",  compress(put(num_obs, 3.0)));
	if &gvar=2 then call symput( "l&j",  compress(put(num_obs, 3.0)));
	if &gvar=3 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if &gvar=4 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%macro mixedpain(data, var, gvar);

proc means data=&data noprint;
    class &gvar day;
    var &var;
 	output out = num_&var n(&var) = num_obs;
run;

%let k2= 0; %let k3= 0; %let k4= 0;  %let k7= 0; %let k14= 0; %let k21= 0;  %let k28= 0;   
%let l2= 0; %let l3= 0; %let l4= 0;  %let l7= 0; %let l14= 0; %let l21= 0;  %let l28= 0;
%let m2= 0; %let m3= 0; %let m4= 0;  %let m7= 0; %let m14= 0; %let m21= 0;  %let m28= 0;   
%let n2= 0; %let n3= 0; %let n4= 0;  %let n7= 0; %let n14= 0; %let n21= 0;  %let n28= 0;

%getn(num_&var);

proc format;

value dta  1="Day*(#1)*(#2)*(#3)*(#4)" 2 = "2*(&k2)*(&l2)*(&m2)*(&n2)"  3 = "3*(&k3)*(&l3)*(&m3)*(&n3)"  4 = "4*(&k4)*(&l4)*(&m4)*(&n4)" 7 = "7*(&k7)*(&l7)*(&m7)*(&n7)"
14 = "14*(&k14)*(&l14)*(&m14)*(&n14)" 21 = "21*(&k21)*(&l21)*(&m21)*(&n21)" 28 = "28*(&k28)*(&l28)*(&m28)*(&n28)" 
5=" "  6=" "  8=" "  9=" "  10=" "  11=" "  12=" "  13=" "  15=" "  16=" "  17=" "  18=" "  19=" "  20=" "  22=" "  23=" "  24=" "  25=" " 
26=" "  27=" "   29=" " ;

value dtb  1="Day*(#1)*(#2)*(#3)*(#4)" 2 = "2*(&k2)*(&l2)*(&m2)*(&n2)"  3 = "3*(&k3)*(&l3)*(&m3)*(&n3)"  4 = "4*(&k4)*(&l4)*(&m4)*(&n4)" 7 = "7*(&k7)*(&l7)*(&m7)*(&n7)"
14 = "14*(&k14)*(&l14)*(&m14)*(&n14)" 21 = "21*(&k21)*(&l21)*(&m21)*(&n21)" 28 = "28*(&k28)*(&l28)*(&m28)*(&n28)" 
5=" "  6=" "  8=" "  9=" "  10=" "  11=" "  12=" "  13=" "  15=" "  16=" "  17=" "  18=" "  19=" "  20=" "  22=" "  23=" "  24=" "  25=" " 
26=" "  27=" "   29=" " ;

value dtc  1="Day*(#1)*(#2)*(#3)*(#4)" 2 = "2*(&k2)*(&l2)*(&m2)*(&n2)"  3 = "3*(&k3)*(&l3)*(&m3)*(&n3)"  4 = "4*(&k4)*(&l4)*(&m4)*(&n4)" 7 = "7*(&k7)*(&l7)*(&m7)*(&n7)"
14 = "14*(&k14)*(&l14)*(&m14)*(&n14)" 21 = "21*(&k21)*(&l21)*(&m21)*(&n21)" 28 = "28*(&k28)*(&l28)*(&m28)*(&n28)" 
5=" "  6=" "  8=" "  9=" "  10=" "  11=" "  12=" "  13=" "  15=" "  16=" "  17=" "  18=" "  19=" "  20=" "  22=" "  23=" "  24=" "  25=" " 
26=" "  27=" "   29=" " ;

value dtd  1="Day*(#1)*(#2)*(#3)*(#4)" 2 = "2*(&k2)*(&l2)*(&m2)*(&n2)"  3 = "3*(&k3)*(&l3)*(&m3)*(&n3)"  4 = "4*(&k4)*(&l4)*(&m4)*(&n4)" 7 = "7*(&k7)*(&l7)*(&m7)*(&n7)"
14 = "14*(&k14)*(&l14)*(&m14)*(&n14)" 21 = "21*(&k21)*(&l21)*(&m21)*(&n21)" 28 = "28*(&k28)*(&l28)*(&m28)*(&n28)" 
5=" "  6=" "  8=" "  9=" "  10=" "  11=" "  12=" "  13=" "  15=" "  16=" "  17=" "  18=" "  19=" "  20=" "  22=" "  23=" "  24=" "  25=" " 
26=" "  27=" "   29=" " ;

run;

proc mixed data=&data;
	class id &gvar day;
	model &var=day &gvar day*&gvar;
	repeated day/ subject = id type = cs;
	lsmeans day*&gvar/pdiff cl;
	ods output lsmeans = lsmeans;
	ods output Mixed.Tests3=p_&var;
run;

data p_&var;
	length effect $100 pv $10;
	set p_&var;
	pv=put(probf, 7.4);
	if probf<0.0001 then pv="<0.0001";
	if effect="&gvar" then do; effect="&gvar";  call symput("p1", compress(pv)); end;
		if effect="day" then do; effect="Day"; call symput("p2", compress(pv));  end;
			if effect="&gvar*day" then do; effect="Interaction between &gvar and Day after Surgery"; call symput("p3", compress(pv)); end;
run;

data lsmeans_&var;
	set lsmeans;
	if lower^=. and lower<0 then lower=0;
	day2=day-0.2;
		day3=day+0.2;
			day4=day+0.4;
run;

proc sort; by &gvar day;run;

DATA anno1; 
	set lsmeans_&var(where=(&gvar=1));
	xsys='2'; ysys='2';  color='blue ';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=day-0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno2; 
	set lsmeans_&var(where=(&gvar=2));
	xsys='2'; ysys='2';  color='red';
	X=day2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=day2-0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day2+0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day2;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno3; 
	set lsmeans_&var(where=(&gvar=3));
	xsys='2'; ysys='2';  color='green';
	X=day3; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=day3-0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day3+0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day3;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno4; 
	set lsmeans_&var(where=(&gvar=4));
	xsys='2'; ysys='2';  color='black';
	X=day4; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=day4-0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day4+0.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day4;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno1 anno2 anno3 anno4;
run;

data estimate_&gvar;
	length col0-col1 $20;
	merge lsmeans_&var(where=(&gvar=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	lsmeans_&var(where=(&gvar=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) 
	lsmeans_&var(where=(&gvar=3) rename=(estimate=estimate3 lower=lower3 upper=upper3))
	lsmeans_&var(where=(&gvar=4) rename=(estimate=estimate4 lower=lower4 upper=upper4)); by day;
	col1=compress(put(estimate1,5.1))||"["||compress(put(lower1,5.1))||" - "||compress(put(upper1,5.1))||"]";
	col2=compress(put(estimate2,5.1))||"["||compress(put(lower2,5.1))||" - "||compress(put(upper2,5.1))||"]";
	col3=compress(put(estimate3,5.1))||"["||compress(put(lower3,5.1))||" - "||compress(put(upper3,5.1))||"]";
	col4=compress(put(estimate4,5.1))||"["||compress(put(lower4,5.1))||" - "||compress(put(upper4,5.1))||"]";
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=blue cv=blue height=2 bwidth=1 width=1;
symbol2 i=j ci=red value=circle co=red cv=red h=2 w=1;
symbol3 i=j ci=green value=square co=green cv=green h=2 w=1;
symbol4 i=j ci=black value=triangle co=black cv=black h=2 w=1;

axis1 	label=(f=Century h=3 "Days" ) split="*"	value=(f=Century h=1)  order= (1 to 29 by 1) minor=none offset=(0 in, 0 in);
axis2 	label=(a=90 f=Century h=3 "Pain Score" ) split="*"	value=(f=Century h=3)  order= (0 to 10 by 1) minor=none offset=(0 in, 0 in);
title1 	height=3.5 f=Century "Pain Score vs Days after Surgery";



%if &gvar=acl %then %do;
title2	height=2.5 f=Century "p(ACL)=&p1, p(Days)=&p2, p(Interaction)=&p3";
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Quad" "Ham" "BPTB" "Allo") offset=(-0.2in, -0.2 in) frame;
%end;

%else %if &gvar=gage %then  %do;
title2	height=2.5 f=Century "p(Age)=&p1, p(Days)=&p2, p(Interaction)=&p3";
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Age<=&Q1" "&Q1~&Q2" "&Q2~&Q3" ">&Q3") offset=(-0.2in, -0.2 in) frame;
%end;

%else %if &gvar=gf %then  %do;
title2	height=2.5 f=Century "p(F Tunnel)=&p1, p(Days)=&p2, p(Interaction)=&p3";
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "F-Tunnel<=&Q1f" "&Q1f~&Q2f" "&Q2f~&Q3f" ">&Q3f") offset=(-0.2in, -0.2 in) frame;
%end;

%else %if &gvar=gt %then  %do;
title2	height=2.5 f=Century "p(T Tunnel)=&p1, p(Days)=&p2, p(Interaction)=&p3";
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "T-Tunnel<=&Q1t" "&Q1t~&Q2t" "&Q2t~&Q3t" ">&Q3t") offset=(-0.2in, -0.2 in) frame;
%end;


proc gplot data= estimate_&gvar gout=pain.graphs;
	plot estimate1*day estimate2*day2 estimate3*day3 estimate4*day4/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
	%if &gvar=acl %then %do; format estimate1-estimate4 4.1 day dta.;  %end;
	%else %if &gvar=gage %then %do; format estimate1-estimate4 4.1 day dtb.;  %end;
	%else %if &gvar=gf %then %do; format estimate1-estimate4 4.1 day dtc.;  %end;
	%else %if &gvar=gt %then %do; format estimate1-estimate4 4.1 day dtd.;  %end;
run;

%mend mixedpain;

%macro getm(data);
%do j = 2 %to 28;
data _null_;
    set &data;
    where day = &j;
    if gender=1 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if gender=2 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%macro mixed(data, varlist);
%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

proc means data=&data print;
    class gender day;
    var &var;
 	output out = num_&var n(&var) = num_obs;
run;

%let m2= 0; %let m3= 0; %let m4= 0;  %let m7= 0; %let m14= 0; %let m21= 0;  %let m28= 0;   
%let n2= 0; %let n3= 0; %let n4= 0;  %let n7= 0; %let n14= 0; %let n21= 0;  %let n28= 0;

%getm(num_&var);

proc format;

value dt  1="Day*(#M)*(#F)" 2 = "2*(&m2)*(&n2) "  3="3*(&m3)*(&n3)"   4="4*(&m4)*(&n4)"  7 = "7*(&m7)*(&n7)"
14 = "14*(&m14)*(&n14)" 21 = "21*(&m21)*(&n21)" 28 = "28*(&m28)*(&n28)" 5=" "  6=" "  8=" "  9=" "  10=" "  11=" "  
12=" "  13=" "  15=" "  16=" "  17=" "  18=" "  19=" "  20=" "  22=" "  23=" "  24=" "  25=" " 26=" "  27=" "   29=" " ;
	
run;

proc mixed data=&data;
	class id gender day;
	model &var=day gender day*gender;
	repeated day/ subject = id type = cs;
	lsmeans day*gender/pdiff cl;
	ods output lsmeans = lsmeans_&i;
	ods output Mixed.Tests3=p_&var;
run;

data p_&var;
	length effect $100;
	set p_&var;

	pv=put(probf, 7.4);
	if probf<0.0001 then pv="<0.0001";
	if effect="gender" then do; effect="Gender";  call symput("p1", compress(pv)); end;
		if effect="day" then do; effect="Day"; call symput("p2", compress(pv));  end;
			if effect="gender*day" then do; effect="Interaction between Gender and Day after Surgery"; call symput("p3", compress(pv)); end;
run;


data lsmeans_&var;
	set lsmeans_&i;
	if lower^=. and lower<0 then lower=0;
	day1=day+0.10;
run;

proc sort; by gender day;run;

DATA anno1; 
	set lsmeans_&var(where=(gender=1));
	xsys='2'; ysys='2';  color='blue';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=day-0.05; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+0.05; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno2; 
	set lsmeans_&var(where=(gender=2));
	xsys='2'; ysys='2';  color='red';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=day1-0.05; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+0.05; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno1 anno2;
run;

data estimate_&var;
	length col1-col2 $20;
	merge lsmeans_&var(where=(gender=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	lsmeans_&var(where=(gender=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) ; by day;
	col2=compress(put(estimate2,5.1))||"["||compress(put(lower2,5.1))||" - "||compress(put(upper2,5.1))||"]";
	col1=compress(put(estimate1,5.1))||"["||compress(put(lower1,5.1))||" - "||compress(put(upper1,5.1))||"]";
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=blue cv=blue height=4 bwidth=1 width=1;
symbol2 i=j ci=red value=circle co=red cv=red h=4 w=1;

axis1 	label=(f=Century h=3 "Days" ) split="*"	value=(f=Century h=1.5)  order= (1 to 29 by 1) minor=none offset=(0 in, 0 in);
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Male" "Female") offset=(-0.2in, -0.2 in) frame;



axis2 	label=(f=Century h=3 a=90 "Pain Score") value=(f=Century h=3) order= (0 to 10 by 1) offset=(.25 in, .25 in) minor=(number=1); 
title1	height=3.5 f=Century "Pain Score vs Days after Surgery ";
title2	height=2.5 f=Century "p(Gender)=&p1, p(Day)=&p2, p(Interaction)=&p3";


proc gplot data= estimate_&var gout=pain.graphs;
	plot estimate1*day estimate2*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
	format estimate1 estimate2 4.1 day dt.; 
run;


%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend mixed;
