

options orientation=landscape nobyline nodate nonumber /*papersize=("7" "8")*/;

libname wbh "/ttcmv/sas/programs";

/*proc contents data=cmv.plate_001_bu;run;*/

proc format;
	value group
		1="Type of unit"
		2="ABO group"
		3="Rh group"
		4="Special processing"
		5="Unit CMV Serostatus"
		6="Storage solution"
		7="Platelet type"
		99=" "
		;
	value item
		1="Voume of parent unit (ml)"
		2="Date unit issued to NICU - Date blood donated"
		3="Date unit irradiated at the Red Cross - Date blood donated"
		4="Date transfer of unit segments to PERL - Date blood donated"
		5="Date received and stored - Date blood donated"
		;
    value nec 0="non-NEC" 1="NEC";
    value site 1="Emory" 2="Northside";
run;


data donor0;
	set cmv.plate_001_bu;
	if bloodunittype = 1;
	keep DonorUnitId BloodUnitType DateDonated UnitVolume DateFirstIssued ABOGroup RhGroup DateIrradiated Leukoreduced Washed 							VolReduced UnitSeroStatus unitstorage plt_type TransferDate UnitReceivedDate DCCUnitId;
	rename BloodUnitType=but ABOGroup=abo RhGroup=rh UnitSeroStatus=sero unitstorage=storage Plt_type=plt;
	format BloodUnitType but. ABOGroup abo. RhGroup rh. UnitSeroStatus sero. unitstorage storage. plt_type plt. 
			  Leukoreduced Washed VolReduced na.;
run;

data donor1;
	set donor0;
	day_issue=DateFirstIssued-DateDonated;
	day_irrad=DateIrradiated-DateDonated;
	day_trans=TransferDate-DateDonated;
	day_receive=UnitReceivedDate-DateDonated;
	keep DonorUnitId DateDonated DateIrradiated but UnitVolume day_issue day_irrad day_trans day_receive ABO Rh Leukoreduced Washed VolReduced sero storage plt DCCUnitId;
run;

proc sort data=cmv.nec_p1; by id necdate;run;
data nec;
	merge cmv.nec_p1(keep=id necdate in=A) 
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.completedstudylist(in=B); by id;
	if bell;
	if first.id;
run;

data tx_id;
	set cmv.plate_031(keep=id DonorUnitId DateTransfusion rbc_TxStartTime DateIrradiated)
			/*cmv.plate_033(keep=id DonorUnitId DateTransfusion plt_TxStartTime)
			cmv.plate_035(keep=id DonorUnitId DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DonorUnitId DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

proc sort; by id DonorUnitId DateTransfusion rbc_TxStartTime;run;

data tx_id;
    merge tx_id(in=A) nec(in=tmp); by id; 
    if tmp then do; if DateTransfusion<=necdate then nec=1; else nec=2; end;
run;

/*
proc print;
var id DateTransfusion necdate nec;
run;
*/

proc sort data=tx_id; by donorunitid;run;
proc sort data=donor1; by donorunitid;run;

data donor;
	merge donor1 tx_id(in=tmp rename=(DateIrradiated=DateIrradiated_tx)); by DonorUnitId;
	center = floor(DCCUnitID/10000000);
    format center center.;
    if (center = 3 | center = 4 | center = 5) then dateirradiated = dateirradiated_tx;
    
	age=DateTransfusion-DateDonated;
	age1=DateTransfusion-DateIrradiated;
	if age=. then delete;
	if tmp;
	if age<0 then age=.;
	if age1<0 then age1=.;
	if age>300 then age=.;

	if center in(1,2) then site=1; else site=2;
	format site site.;
run;


proc sort data=donor; by id DonorUnitId; run;

data donor;
    merge donor(in=A) cmv.comp_pat(in=comp keep=id) cmv.endofstudy(keep=id StudyLeftDate); by id;   
    if A and comp;
    if nec=. then nec=0;
	if nec=1 then day=datetransfusion-necdate; else day=datetransfusion-StudyLeftDate;
	if day=. then delete;
	
	day_to_nec=necdate-DateTransfusion;
	
    wk=floor(day/7);
    if wk=0 then wk=-1;
run;


proc sort data=donor(where=(nec=0)) out=tmp; by id; run;
proc print data=tmp;
where day>0;
var id DonorUnitId nec necdate DateDonated DateTransfusion DateIrradiated age age1 day;
run;


proc means data=donor median;
    class nec;
    var age age1;
    output out=tmp median(age age1)=median_age median_age1;
run;


data _null_;
set tmp;
if nec=0 then do;
    call symput("median_age0", compress(median_age));
    call symput("median_ir0",  compress(median_age1));
end;

if nec=1 then do;
    call symput("median_age1", compress(median_age));
    call symput("median_ir1",  compress(median_age1));
end;
run;

proc sort data=donor out=tmp nodupkey; by nec DonorUnitID; run;

data _null_;
	set donor(where=(nec=0));
	call symput("n0_age", compress(_n_));
run;


data _null_;
	set donor(where=(nec=1));
	call symput("n1_age", compress(_n_));
run;

data _null_;
	set tmp(where=(nec=0));
	call symput("n0_id", compress(_n_));
run;

data _null_;
	set tmp(where=(nec=1));
	call symput("n1_id", compress(_n_));
run;


proc sort data=donor out=temp nodupkey; by nec ID; run;

data _null_;
	set temp(where=(nec=0));
	call symput("m0", compress(_n_));
run;

data _null_;
	set temp(where=(nec=1));
	call symput("m1", compress(_n_));
run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=global gunit=pct noborder colors=(orange green red) ftitle=triplex  ftext=triplex   htitle=3.5 htext=3;

 	
 	 	
		%let descrip1 = "Bar Chart for pRBC Transfusions(non-NEC) by Age of Blood (Days) (median=&median_age0 days)";
		%let descrip2 = "Bar Chart for pRBC Transfusions(NEC) by Age of Blood (Days) (median=&median_age1 days)";
		%let descrip3 = "Bar Chart for pRBC Transfusions(non-NEC) by Irradiation Storage Days (median=&median_ir0 days)";
		%let descrip4 = "Bar Chart for pRBC Transfusions(NEC) by Irradiation Storage Days(median=&median_ir1 days)";
		
		%let mp=(0 to 36 by 1);
		%let mp1=(0 to 18 by 1);


		axis1 label=(a=90 h=3 c=black "#RBC Transfusions") order=(0 to 120 by 10) minor=none;
    	axis2 label=(a=90 h=3 c=black "#RBC Transfusions") order=(0 to 500 by 20) minor=none;
    	axis5 label=(a=90 h=3 c=black "#RBC Transfusions") order=(0 to 20 by 2) minor=none;
    	axis6 label=(a=90 h=3 c=black "#RBC Transfusions") order=(0 to 20 by 2) minor=none;
    	
		axis3 label=(a=0 h=3 c=black "Storage Age of RBCs (days)") value=(h= 2.5) minor=none;
		axis4 label=(a=0 h=3 c=black "Days from Date of Irradiation to Date of Transfusion") value=(h= 2.5) minor=none;		


		title1	;
		title2 &descrip1;
		title3 "(&n0_age Transfusions from &n0_id Donors for &m0 LBWIs)";


		Proc gchart data=donor gout=wbh.graphs;
			where nec=0;
			vbar age/ midpoints=&mp raxis=axis1 maxis=axis3 space=0.5 coutline=black width=2;
		run;
		
		title1	;
		title2 &descrip2;
		title3 "(&n1_age Transfusions from &n1_id Donors for &m1 LBWIs)";
		
		Proc gchart data=donor gout=wbh.graphs;
			where nec=1;
			vbar age/ midpoints=&mp raxis=axis5 maxis=axis3 space=0.5 coutline=black width=2;
		run;

		title1	;	
		title2 &descrip3;
		title3 "(&n0_age Transfusions from &n0_id Donors for &m0 LBWIs)";
		Proc gchart data=donor gout=wbh.graphs;
			where nec=0;
			vbar age1/ midpoints=&mp1 raxis=axis2 maxis=axis4 space=1 coutline=black width=4;
		run;
		
		title1	;	
		title2 &descrip4;
		title3 "(&n1_age Transfusions from &n1_id Donors for &m1 LBWIs)";
		
		Proc gchart data=donor gout=wbh.graphs;
			where nec=1;
			vbar age1/ midpoints=&mp1 raxis=axis6 maxis=axis4 space=1 coutline=black width=4;
		run;
		
 
ods ps file = "age_blood_nec.ps";
ods pdf file = "age_blood_nec.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=l2r2s nofs; * L2R2s;
     treplay 1:1 2:2 3:3 4:4;
run;
ods pdf close;
ods ps close;


*ods trace on/label listing;
proc means data=donor(rename=(age1=rage)) n mean stderr median maxdec=1;
    class nec wk;
    var age rage; 
    ods output Means.Summary=temp0;
run;
*ods trace off;


data age_rage;
set temp0(where=(nec in(0, 1)));
drop nobs;
run;

ods rtf file="age_rage.rtf" style=journal bodytitle;
proc print noobs;
title "Age of Blood and Irridiation Days by NEC and Week";
var nec wk age_n age_mean age_stderr age_median rage_n rage_mean rage_stderr rage_median;
run;
ods rtf close;

data temp;
    set temp0;
    age_lower=age_mean-age_stderr;
    age_upper=age_mean+age_stderr;
    rage_lower=rage_mean-rage_stderr;
    rage_upper=rage_mean+rage_stderr;
    if nec then wk=wk+0.1;
    keep nec wk age_n age_mean age_stderr age_median rage_n rage_mean rage_stderr rage_median age_lower age_upper rage_lower rage_upper;
    format nec nec.;
    if nec^=2;
run;


ODS PDF FILE ="age_rage.pdf";  
title " ";
proc sgplot data=temp(where=(age_stderr^=.));

scatter x=wk y=age_mean / group=nec
yerrorlower=age_lower yerrorupper=age_upper
markerattrs=(symbol=circlefilled)
name="scat";
series x=wk y=age_mean / group=nec
lineattrs=(pattern=solid);
xaxis integer values=(-15 to 0 by 1)
label="Weeks before NEC or End of Study(non-NEC)";
yaxis integer values=(0 to 20 by 1)
label="Age of Blood (days)";
keylegend "scat" / title="" noborder;
run;

proc sgplot data=temp(where=(rage_stderr^=.));
scatter x=wk y=rage_mean / group=nec
yerrorlower=rage_lower yerrorupper=rage_upper
markerattrs=(symbol=circlefilled)
name="scat";
series x=wk y=rage_mean / group=nec
lineattrs=(pattern=solid);
xaxis integer values=(-15 to 0 by 1)
label="Weeks before NEC or End of Study(non-NEC)";
yaxis integer values=(0 to 10 by 1)
label="Irradiation Days";
keylegend "scat" / title="" noborder;
run;
ods pdf close;


options orientation=portrait;

proc sort data=donor;by nec;run;

data donor_plot;
    set donor;
    if site=1 and nec=0 then do; age_e0=age; rage_e0=age1; end;
    if site=1 and nec=1 then do; age_e1=age; rage_e1=age1; end;
    if site=2 and nec=0 then do; age_n0=age; rage_n0=age1; end;
    if site=2 and nec=1 then do; age_n1=age; rage_n1=age1; end;
    day1=day-1;
        day2=day+1;
            day3=day+2;
run;

ODS PDF FILE ="age_rage_scatter.pdf";  
/*
PROC sgpanel DATA=donor(where=(nec^=2));
title "Age of Blood";
*panelby site nec/layout=lattice;
panelby site nec;
scatter x=day y=age/MARKERATTRS=(size=8 SYMBOL=circle color=blue);
rowaxis label="Age of Blood (Days)"  grid values=(0 to 40 by 2) offsetmin=0.05 offsetmax=0.05;
colaxis label="Days before NEC or Days before End of Study(Non-NEC)" grid values=(-98 to 0 by 7) offsetmin=0.05 offsetmax=0.05;
RUN;

PROC sgpanel DATA=donor(where=(nec^=2));
title "Irridiation Days";
*panelby site nec/layout=lattice;
panelby site nec;
scatter x=day y=age1/MARKERATTRS=(size=8 SYMBOL=circle color=blue);
rowaxis label="Irridiation Days"  grid values=(0 to 16 by 1) offsetmin=0.05 offsetmax=0.05;
colaxis label="Days before NEC or Days before End of Study(Non-NEC)" grid values=(-98 to 0 by 7) offsetmin=0.05 offsetmax=0.05;
RUN;
*/

PROC sgplot DATA=donor_plot;
title "Age of Blood";

SCATTER X = day Y = age_e0 / LEGENDLABEL = 'Emory: Non-NEC' MARKERATTRS=(size=8 SYMBOL=circlefilled color=blue);
SCATTER X = day1 Y = age_e1 / LEGENDLABEL = 'Emory: NEC' MARKERATTRS=(size=8 SYMBOL=circlefilled color=red);
SCATTER X = day2 Y = age_n0 / LEGENDLABEL = 'Northside: Non-NEC' MARKERATTRS=(size=8 SYMBOL=circle color=blue);
SCATTER X = day3 Y = age_n1 / LEGENDLABEL = 'Northside: NEC' MARKERATTRS=(size=8 SYMBOL=circle color=red);
yaxis label="Age of Blood (Days)"  grid values=(0 to 40 by 2) offsetmin=0.05 offsetmax=0.05;
xaxis label="Days before NEC or Days before End of Study(Non-NEC)" grid values=(-98 to 0 by 7) offsetmin=0.05 offsetmax=0.05;
keylegend/position=topright across=1 location=inside;
RUN;

PROC sgplot DATA=donor_plot;
title "Irridiation Days";

SCATTER X = day Y = rage_e0 / LEGENDLABEL = 'Emory: Non-NEC' MARKERATTRS=(size=8 SYMBOL=circlefilled color=blue);
SCATTER X = day1 Y = rage_e1 / LEGENDLABEL = 'Emory: NEC' MARKERATTRS=(size=8 SYMBOL=circlefilled color=red);
SCATTER X = day2 Y = rage_n0 / LEGENDLABEL = 'Northside: Non-NEC' MARKERATTRS=(size=8 SYMBOL=circle color=blue);
SCATTER X = day3 Y = rage_n1 / LEGENDLABEL = 'Northside: NEC' MARKERATTRS=(size=8 SYMBOL=circle color=red);
yaxis label="Irridiation Days"  grid values=(0 to 16 by 1) offsetmin=0.05 offsetmax=0.05;
xaxis label="Days before NEC or Days before End of Study(Non-NEC)" grid values=(-98 to 0 by 7) offsetmin=0.05 offsetmax=0.05;
keylegend/position=topright across=1 location=inside;
RUN;

ods pdf close;
