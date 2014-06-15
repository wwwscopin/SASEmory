
PROC IMPORT OUT= WORK.vd10 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\GLND VitD 032812.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'vitD data$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data vd1;
	retain id day ohd rlu lot;
	set vd10(keep=F2-F6 rename=(F3=OHD F5=RLU F6=Lot));
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	if id=. then delete;
	keep id day ohd rlu lot;
run;

PROC IMPORT OUT= WORK.vd20 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\GLND vitD 032912-1.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'GLND vitD 032912-1 $'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


data vd2;
	retain id day ohd rlu lot;
	set vd20(keep=F2-F6 rename=(F3=OHD F5=RLU F6=Lot));
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	if id=. then delete;
	keep id day ohd rlu lot;
run;

PROC IMPORT OUT= WORK.vd30 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\GLND 25OHD data part-3 032912.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$B5:G63"; 
     GETNAMES=No;
     MIXED=No;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


data vd3;
	retain id day ohd rlu lot;
	set vd30(keep=F2-F6 rename=(F3=OHD F5=RLU F6=Lot));
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	if id=. then delete;
	keep id day ohd rlu lot;
run;


data vd;
	set vd1 vd2 vd3;
	if id<10000 then delete;
run;
proc sort; by id day;run;
/*
proc sort nodupkey; by id;run;
proc print;run;
proc sort data=id; by id day;run;
proc means data=vd n;
	class day;
	var id ohd;
run;
*/

PROC IMPORT OUT= WORK.ll0 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\ELISA LL37 VitD VDBP 032812.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'LL-37 Sum$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data ll;
	set ll0(keep=F2 F8);
	if _n_>8;
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	LL=F8+0;
	drop F2 F8;
	if id=. then delete;
run;
proc sort; by id day;run;

PROC IMPORT OUT= vdbp0 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\ELISA LL37 VitD VDBP 032812.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'VDBP Sum$'"; 
     GETNAMES=NO;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data vdbp;
	set vdbp0(keep=F2 F9);
	if _n_>7;
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	vdbp=F9+0;
	drop F2 F9;
	if id=. then delete;
run;
proc sort ; by id day;run;

data vd;
	merge vd ll vdbp; by id day;
run;

proc univariate data=vd plots;
var ll;
run;

option nofmterr nodate nonumber orientation=portrait;
libname wbh "H:\SAS_Emory\Data\Vatamine D";
%let mu=%sysfunc(byte(181));
%put &mu;


/*proc contents data=wbh.info;run;*/
proc format; 
	value yn    0="No" 1="Yes";
	value gender   99 = "Blank"
                 1 = "Male"
 				 2 = "Female" ;
   value treatment   99 = "Blank"
                 1 = "AG-PN"
                 2 = "STD-PN" ; 
	value death 0="Survivor" 1="Non-Survivor";
run;

data infect;
    set wbh.info (keep = id apache_2 ni_any ni_bsi ni_lri);
    any=ifn(ni_any>0,1,0,0);
        bsi=ifn(ni_bsi>0,1,0,0);
            lri=ifn(ni_lri>0,1,0,0);
    *keep id apache_2 any bsi lri;
    format any bsi lri yn.;
run;

data sofa;
	set wbh.followup_all_long;
	where day=1;
	keep id sofa_tot;
run;


data glnd_VD;
	merge vd(in=A) wbh.info(keep=id age gender apache_2 hospital_death treatment days_hosp_post_entry days_sicu_post_entry days_on_vent_adj in=comp) 
		  infect sofa;	by id; 
	format treatment treatment. hospital_death death.;
	if A and comp;
	
	if bsi=. then bsi=0;
	if lri=. then lri=0;
	if any=. then any=0;
	
	label ohd="25(OH)D" ll="LL37" vdbp="VDBP" hospital_death="In-Hospital Mortality"
	bsi="BSI" lri="Pneumonia Infection" any="Any Infection" day="Days on Study" sofa_tot="SOFA (Bseline)"
	days_hosp_post_entry="Days in Hospital" days_sicu_post_entry="Days in SICU" days_on_vent_adj="Days on Ventilator";
run;

proc print;
where hospital_death=.;
run;

/*

proc corr data=glnd_vd plots=matrix(histogram);
	var ohd ll vdbp;
run;

proc sgpanel data=glnd_vd;
	title "Scatter Plot";
	panelby day/columns=3;
	scatter x=ohd y=ll/group=hospital_death;
run;

proc sgpanel data=glnd_vd;
	title "Scatter Plot";
	panelby day/columns=3;
	scatter x=ohd  y=vdbp/group=hospital_death;
run;

proc sgpanel data=glnd_vd;
	title "Scatter Plot";
	panelby day/columns=3;
	scatter x=ll  y=vdbp/group=hospital_death;
run;

proc sgpanel data=glnd_vd;
	title "Scatter Plot";
	panelby day/columns=3;
	scatter x=ll  y=vdbp/group=bsi;
run;

proc sgpanel data=glnd_vd;
	title "Scatter Plot";
	panelby day/columns=3;
	scatter x=ll  y=vdbp/group=lri;
run;

proc sgpanel data=glnd_vd;
	title "Scatter Plot";
	panelby day/columns=3;
	scatter x=ll  y=vdbp/group=Any;
run;


proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_on_vent_adj*ohd/group=bsi;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_hosp_post_entry*ohd/group=bsi;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_sicu_post_entry*ohd/group=bsi;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot sofa_tot*ohd/group=bsi;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_on_vent_adj*ohd/group=lri;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_hosp_post_entry*ohd/group=lri;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_sicu_post_entry*ohd/group=lri;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot sofa_tot*ohd/group=lri;
run;


proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_on_vent_adj*ohd/group=any;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_hosp_post_entry*ohd/group=any;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot days_sicu_post_entry*ohd/group=any;
run;

proc sgscatter data=glnd_vd(where=(day=0));
	title "Scatter Plot";
	plot sofa_tot*ohd/group=any;
run;
*/ 

proc sgplot data=glnd_vd;
vbox ohd/group=bsi /*GROUPORDER=descending*/ category=day groupdisplay=cluster LINEATTRS=(color=black pattern=1)BOXWIDTH=1;
yaxis label="25(OH)D" ;
format day dd.;
run;

proc sgplot data=glnd_vd;
vbox ohd/group=lri /*GROUPORDER=descending*/ category=day groupdisplay=cluster LINEATTRS=(color=black pattern=1)BOXWIDTH=1;
yaxis label="25(OH)D" ;
format day dd.;
run;

proc sgplot data=glnd_vd;
vbox ohd/group=any /*GROUPORDER=descending*/ category=day groupdisplay=cluster LINEATTRS=(color=black pattern=1)BOXWIDTH=1;
yaxis label="25(OH)D" ;
format day dd.;
run;
