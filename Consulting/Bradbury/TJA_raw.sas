options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
libname tja "H:\SAS_Emory\Consulting\Bradbury";

PROC IMPORT OUT= WORK.Temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Bradbury\TJA Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="2009 - All Data$A2:AL242"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
*/

proc format;
value gender 0="F" 1="M";
value tja 0="THA" 1="TKA";
value item 	1="Gender"
			2=" "
			3="Age"
			4="BMI"
			5="A1c"
			6="Blood Presure (Sys)"
			7="Blood Presure (Das)"
			8="LDL"
			9="HDL"
			10="TG"
			;
value idx 	1="BMI"
			2="A1c"
			3="Blood Presure (Sys)"
			4="Blood Presure (Das)"
			5="LDL"
			6="HDL"
			7="TG"
			;
value it 0="Baseline" 1="At 1 Year" 2="At 2 Year";
run;
data tja0;
	set temp;
	if sex="F" then gender=0; else if sex="M" then gender=1;

	rename Age_at_TJA=age;
	if Type_of_TJA="THA" then TJA=0; else if Type_of_TJA="TKA" then TJA=1;
	id=_n_;
	keep id Age_at_TJA TJA gender BMI A1c BP_1 BP_2 BP_3 LDL HDL TG BMI1 A1c1 BP_11 BP_21 BP_31 LDL1 HDL1 TG1 BMI2 A1c2 BP_12 BP_22 BP_32 LDL2 HDL2 TG2;
run;

data tja;
	set tja0(keep=id age tja gender bmi a1c bp_1 bp_2 bp_3 ldl hdl tg in=A)
		tja0(keep=id age tja gender bmi1 a1c1 bp_11 bp_21 bp_31 ldl1 hdl1 tg1 rename=(bmi1=bmi a1c1=a1c bp_11=bp_1 bp_21=bp_2 bp_31=bp_3 ldl1=ldl hdl1=hdl tg1=tg) in=B)
		tja0(keep=id age tja gender bmi2 a1c2 bp_12 bp_22 bp_32 ldl2 hdl2 tg2 rename=(bmi2=bmi a1c2=a1c bp_12=bp_1 bp_22=bp_2 bp_32=bp_3 ldl2=ldl hdl2=hdl tg2=tg) in=C)
		;
		by id;

	if A then t=0; if B then t=1; if c then t=2;
	tmph1=scan(bp_1,1)+0; tmpl1=scan(bp_1,2)+0;
	tmph2=scan(bp_2,1)+0; tmpl2=scan(bp_2,2)+0;
	tmph3=scan(bp_3,1)+0; tmpl3=scan(bp_3,2)+0;

	hbp=mean(of tmph1-tmph3); n=n(of tmph1-tmph3);
	lbp=mean(of tmpl1-tmpl3);

	format gender gender. hbp lbp 3.0 tja tja.;
	/*if n<3 then do; hbp=. ; lbp=.; end;*/
	keep id age tja gender bmi a1c hbp lbp ldl hdl tg t n;
run;

%macro getn(data);
%do j = 0 %to 3;
data _null_;
    set &data;
    where t = &j;
    if tja=0 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if tja=1 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%macro mixed(data, var);
%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

proc means data=&data noprint;
    class tja t;
    var &var;
 	output out = num_&var n(&var) = num_obs;
run;

%let m0= 0; %let m1= 0; %let m2= 0;  %let n0= 0; %let n1= 0; %let n2= 0; 

%getn(num_&var);

proc format;

value dt  -1=" " 0 = "0*(&m0)*(&n0) "  1="1*(&m1)*(&n1)"   2="2*(&m2)*(&n2)" 3=" " ;
		
run;

proc mixed data=&data;
	class id tja t;
	model &var=t tja t*tja;
	repeated t/ subject = id type = cs;
	lsmeans t*tja/pdiff cl;
	ods output lsmeans = lsmeans_&i;
	ods output Mixed.Tests3=p_&var;
run;

data p_&var;
	length effect $100;
	set p_&var;
	if effect="TJA" then do; effect="TJA";  call symput("p1", put(probf, 7.4)); end;
		if effect="t" then do; effect="Followup Year"; call symput("p2", put(probf, 7.4));  end;
			if effect="TJA*t" then do; effect="Interaction between TJA and Year after Surgery"; call symput("p3", put(probf, 7.4)); end;
run;


data lsmeans_&var;
	set lsmeans_&i;
	if lower^=. and lower<0 then lower=0;
	t1=t+0.10;
run;

proc sort; by tja t;run;

DATA anno0; 
	set lsmeans_&var(where=(tja=0));
	xsys='2'; ysys='2';  color='blue';
	X=t; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=t-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=t+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	
  	X=t;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmeans_&var(where=(tja=1));
	xsys='2'; ysys='2';  color='red';
	X=t1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=t1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=t1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=t1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno0 anno1;
run;

data estimate_&var;
	length col0-col1 $20;
	i=&i;
	merge lsmeans_&var(where=(tja=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(tja=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by t;
	col0=compress(put(estimate0,5.1))||"["||compress(put(lower0,5.1))||" - "||compress(put(upper0,5.1))||"]";
	col1=compress(put(estimate1,5.1))||"["||compress(put(lower1,5.1))||" - "||compress(put(upper1,5.1))||"]";
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=blue cv=blue height=4 bwidth=1 width=1;
symbol2 i=j ci=red value=circle co=red cv=red h=4 w=1;

axis1 	label=(f=Century h=3 "Follow up (Years)" ) split="*"	value=(f=Century h=3)  order= (-1 to 3 by 1) minor=none offset=(0 in, 0 in);
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "THA" "TKA") offset=(0.2in, -0.2 in) frame;


%if &var=bmi %then %do;
	axis2 	label=(f=Century h=3 a=90 "BMI") value=(f=Century h=3) order= (25 to 35 by 1) offset=(.25 in, .25 in) minor=(number=1); 
	title1	height=3.5 f=Century "BMI vs Followup ";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;

%if &var=hbp %then %do;
	axis2 	label=(f=Century h=3 a=90 "Blood Pressure (Sys)") value=(f=Century h=3) order= (120 to 150 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "Blood Pressure vs Followup";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;

%if &var=lbp %then %do;
	axis2 	label=(f=Century h=3 a=90 "Blood Pressure (Das)") value=(f=Century h=3) order= (70 to 90 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "Blood Pressure vs Followup";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;

%if &var=a1c %then %do;
	axis2 	label=(f=Century h=3 a=90 "A1C") value=(f=Century h=3) order= (4 to 12 by 1) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "A1C vs Followup";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;

%if &var=ldl %then %do;
	axis2 	label=(f=Century h=3 a=90 "LDL") value=(f=Century h=3) order= (80 to 140 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "LDL vs Followup";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;

%if &var=hdl %then %do;
	axis2 	label=(f=Century h=3 a=90 "HDL") value=(f=Century h=3) order= (30 to 70 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "HDL vs Followup";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;

%if &var=tg %then %do;
	axis2 	label=(f=Century h=3 a=90 "TG") value=(f=Century h=3) order= (60 to 200 by 10) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "TG vs Followup";
	title2	height=2.5 f=Century "p(TJA)=&p1, p(Followup)=&p2, p(Interaction)=&p3";
%end;
 
proc gplot data= estimate_&var gout=tja.graphs;
	plot estimate0*t estimate1*t1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;

	note h=3 m=(5pct, 14.75 pct) "Years:" ;
	note h=3 m=(5pct, 11.25 pct) "(#THA)" ;
	note h=3 m=(5pct, 7.75 pct) "(#TKA)" ;
	format estimate0 estimate1 4.0 t dt.; 
run;


%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend mixed;

proc print data=estimate_hbp;run;

proc greplay igout=tja.graphs  nofs; delete _ALL_; run;
goptions rotate = landscape;

%let varlist=bmi a1c hbp lbp ldl hdl tg;
%mixed(tja,&varlist);

ods pdf file = "tja_all.pdf";
goptions reset=all border;
proc greplay igout = tja.graphs tc=sashelp.templt nofs nobyline;
	template l2r2s;
	treplay 1:1 2:2 3:3 4:4;
	treplay 1:5 2:6 3:7;
run;
ods pdf close;

data estimate;
	length col0 col1 $20;
	set estimate_bmi(keep=i t col0 col1)
		estimate_a1c(keep=i t col0 col1)
		estimate_hbp(keep=i t col0 col1)
		estimate_lbp(keep=i t col0 col1)
		estimate_ldl(keep=i t col0 col1)
		estimate_hdl(keep=i t col0 col1)
		estimate_tg(keep=i t col0 col1);
	 format i idx.;
	 rename t=it;
run;


%let n0=0; 
%let n1=0; 
%let n=0; 

%macro table(index);
data sub_tja;
	set tja;
	where t=&index;
run;

*ods trace on/label listing;
proc freq; 
tables tja;
ods output onewayfreqs=tmp;
run;
*ods trace off;
data _null_;
	set tmp;
	if tja=0 then call symput("n0", compress(Frequency));
	if tja=1 then call symput("n1", compress(Frequency));
run;
%let n=%eval(&n0+&n1);

%let varlist=age bmi a1c hbp lbp ldl hdl tg;
%stat(sub_tja, tja, &varlist);


%let varlist=gender;
%tab(sub_tja, tja, tab, &varlist);

data temp;
	nfn="Mean &pm Std [Q1-Q3], n";
	nfy="Mean &pm Std [Q1-Q3], n";
	nft="Mean &pm Std [Q1-Q3], n";
run;

data table&index;
	length nfn nfy nft code0 $40 pv $6;
	set tab 
		temp(in=B)
		stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=A)
		;
	if B then item=2;
	if A then do; item=item+2; end;
	if item=1 then code0=put(code, gender.);		
run;
%mend tab;

%table(0);
%table(1);
%table(2);

ods rtf file="table_all.rtf" style=journal bodytitle startpage=never ;
proc report data=table0 nowindows style(column)=[just=center] split="*";
title "Compare the result between TKA and THA (Baseline)";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"THA*(n=&n0)";
define nfn/"TKA*(n=&n1)";
define pv/"p value";
run;

proc report data=table1 nowindows style(column)=[just=center] split="*";
title "Compare the result between TKA and THA (At 1 Year )";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"TKA*(n=&n1)";
define nfn/"THA*(n=&n0)";
define pv/"p value";
run;

proc report data=table2 nowindows style(column)=[just=center] split="*";
title "Compare the result between TKA and THA (At 2 Year)";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"TKA*(n=&n1)";
define nfn/"THA*(n=&n0)";
define pv/"p value";
run;

ods rtf startpage=yes;
proc report data=estimate nowindows style(column)=[just=center] split="*";
title "Estimate by TJA and Followup";
column i it col0 col1;
define i/"Variable" group order=internal format=idx. style=[just=left];
define it/"Follow up" format=it. style(column)=[width=1in];
define col0/"THA";
define col1/"TKA";
run;
ods rtf close;
