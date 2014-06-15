option nofmterr nodate nonumber orientation=landscape;
libname wbh "H:\SAS_Emory\Data\complete";
%let mu=%sysfunc(byte(181));
%put &mu;

/*proc contents data=wbh.info;run;*/
proc format; 
	value cit   1="<=10 &mu.mol/L" 2="10-20 &mu.mol/L" 3=">20 &mu.mol/L";
	value citru 1="<=10 &mu.mol/L" 2=">10 &mu.mol/L";
	value yn    0="No" 1="Yes";
	value apache   99 = "Blank"
                 1 = "APACHE <=15"
                 2 = "APACHE >15" ;
	value surg_index 0="Non-GI" 1="GI";
	value trt 1="AG-PN" 2="STD-PN";
run;

PROC IMPORT OUT= citrulline0 
            DATAFILE= "H:\SAS_Emory\Data\complete\Complete Amino Acid profilel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="citrulline$A1:G661"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data citrulline;
	set citrulline0;
	id=first_name+0;
	day=compress(study_day, "day")+0;
	citrulline=round(result);
	if id=32006 then delete;
	keep id day citrulline;
	label citrulline="Citrulline (&mu.mol/L)";
run;
proc sort; by id day; run;
proc means data=citrulline(where=(day=0)) noprint n Q1 median Q3 maxdec=1;
	var citrulline;
	output out=wbh q1(citrulline)=Qc1 median(citrulline)=Qc2  q3(citrulline)=Qc3 /autoname;
run;

data _null_;
	set wbh;
	call symput("qc1", qc1);
	call symput("qc2", qc2);
	call symput("qc3", qc3);
run;

PROC IMPORT OUT= glutamine0 
            DATAFILE= "H:\SAS_Emory\Data\complete\Complete Amino Acid profilel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="glutamine$A1:G658"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data glutamine;
	set glutamine0;
	id=first_name+0;
	day=compress(study_day, "day")+0;
	rename result=glutamine;
	if id=32006 then delete;
	keep id day result;
	label result="Glutamine (&mu.M)";
run;
proc sort; by id day; run;

proc format;
	value qcit 1="Citrulline<~&qc1.&mu.m" 2="Citrulline=&qc1.~&qc2.&mu.m" 3="Citrulline=&qc2.~&qc3.&mu.m" 4="Citrulline>=&qc3&mu.m";
	value sofa 1="<=6" 2=">6";
run;

data glnd;
	merge citrulline glutamine;
	by id day; 

	if day=0 then do;
		if  0<=citrulline<&Qc1 then qcit=1;
		else if &Qc1<=citrulline<&Qc2 then qcit=2;
		else if &Qc2<=citrulline<&Qc3 then qcit=3;
		else if &Qc3<=citrulline then qcit=4;
	end;

	retain base_glu;
	if day=0 then base_glu=glutamine;

	log_glutamine=log10(glutamine);
	
	label qcit="Citrulline";
	format qcit qcit.;
run;

data sofa;
	set wbh.followup_all_long(keep=id day sofa_tot where=(day=1));
	drop day;
run;

data glnd;
	merge glnd sofa	wbh.info(keep=id treatment apache_2); by id;
	if sofa_tot>6 then sofa=2; else sofa=1;
	format apache_2 apache. sofa sofa.;
run;

proc sort; by day; run;

ods graphics on;
proc corr data=glnd(where=(day^=.)) plots=matrix(histogram) spearman;
by day;
var citrulline glutamine;
run;

proc corr data=glnd(where=(day^=.)) plots=matrix(histogram) spearman;
by day;
var citrulline log_glutamine;
run;

proc corr data=glnd(where=(day^=.)) plots=matrix(histogram);
var citrulline glutamine;
run;
ods graphics off;

proc sgpanel data=glnd;
  panelby day / columns=3;
  *reg x=glutamine y=citrulline / cli clm;
  scatter x=glutamine y=citrulline/group=treatment;
  format treatment trt.;
run;
proc sgpanel data=glnd;
  panelby day / columns=3;
  *reg x=glutamine y=citrulline / cli clm;
  scatter x=log_glutamine y=citrulline ;
  label log_glutamine="Log10(Glutamine)";
run;

proc mixed data=glnd;
	class id treatment;
	model citrulline=day treatment day*treatment glutamine;
	random int day /type=cs sub=id;
run;
/*
proc sgplot data=glnd(where=(day^=.));
  scatter x=glutamine y=citrulline / group=day;
run;
*/

/*
proc mixed data=glnd;
	class treatment id;
	model citrulline=base_glu glutamine  treatment/solution;
	repeated /type=cs sub=id;
	*random id;
run;
*/
proc mixed data=glnd;
	class id;
	model citrulline=glutamine/solution;
	*repeated /type=cs sub=id;
	/*repeated; Different Covariance Matrrix from Other!!!*/;
	*random id;
	*random int/sub=id;
	random Int glutamine / sub=id;
run;
