
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
var ohd ll vdbp;
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
    set wbh.info (keep = id apache_2 ni_any ni_bsi ni_lri dt_any dt_bsi dt_lri);
    any=ifn(ni_any>0,1,0,0);
        bsi=ifn(ni_bsi>0,1,0,0);
            lri=ifn(ni_lri>0,1,0,0);
    keep id apache_2 any bsi lri dt_any dt_bsi dt_lri;
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
	label ohd="25(OH)D" ll="LL37" vdbp="VDBP" hospital_death="In-Hospital Mortality";
run;

proc mixed data=glnd_vd covtest;
	class id day bsi;
	model vdbp=ll day bsi bsi*day;
	random int/subject=id type=cs;
	lsmeans bsi day bsi*day/cl;
run;

proc mixed data=glnd_vd covtest;
	class id day lri;
	model vdbp=ll day lri lri*day;
	random int/subject=id type=cs;
	lsmeans lri day lri*day/cl;
run;

proc mixed data=glnd_vd covtest;
	class id day any;
	model vdbp=ll day any any*day;
	random int/subject=id type=cs;
	lsmeans any day any*day/cl;
run;
