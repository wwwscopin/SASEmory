

options orientation=portrait nobyline nodate nonumber /*papersize=("7" "8")*/;

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
run;

data donor0;
	set cmv.plate_001_bu;
	if bloodunittype = 4;
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


data tx_id;
	set /*cmv.plate_031(keep=id DonorUnitId DateTransfusion rbc_TxStartTime)*/
			cmv.plate_033(keep=id DonorUnitId DateTransfusion plt_TxStartTime)
			/*cmv.plate_035(keep=id DonorUnitId DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DonorUnitId DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.completedstudylist(in=comp);
	by id;
	if comp;
    retain x_date;
	if first.id then x_date=imagedate;
	if ivhdiagdate=. then ivhdiagdate=x_date;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
run;

data tx_id;
    merge tx_id ivh2(in=tmp keep=id imagedate); by id;
    if tmp then if DateTransfusion<imagedate;
    drop imagedate;
run;

proc sort; by id DonorUnitId DateTransfusion plt_TxStartTime;run;

data tmp;
	set tx_id; by id DonorUnitId DateTransfusion plt_TxStartTime;
	retain mark;
	if first.plt_TxStartTime then mark=1; else mark=0;
run;

proc sql;
 create table tx_id as 
	select a.*, b.dob
	from tx_id as a, cmv.comp_pat as b
	where a.id=b.id;
	
proc sort data=tx_id out=nplt nodupkey; by id; run;
/*proc print;run;*/


proc sort data=tx_id; by donorunitid;run;
proc sort data=donor1; by donorunitid;run;

data donor;
	merge donor1 tx_id(in=tmp); by DonorUnitId;
	
	center = floor(DCCUnitID/10000000);
    format center center.;
    if (center = 3 | center = 4 | center = 5) then dateirradiated = dateirradiated_tx;
    
	age=DateTransfusion-DateDonated;
	age1=DateTransfusion-DateIrradiated;
	if age=. then delete;
	if tmp;
	if age<=0 then age=.;
	if age1<0 then age1=.;
run;

proc sort data=donor; by id DonorUnitId; run;

proc print;
wher age<=2 or age1<0;
var id dob DCCunitid DonorUnitId DateTransfusion Datedonated DateIrradiated age age1;
run;

data rbc_day7; 
    set donor; 
    where age>7;
run;

proc sort nodupkey; by id; run;

    
proc print;
var id donorunitid dccunitid datedonated datetransfusion age;
run;


data cmv.age_blood;
    set donor; by id DonorUnitId;
    label age="Age Blood"
           age1="Age Irridiation"
           ;
run;


proc means data=donor median;
    var age age1;
    output out=tmp median(age age1)=median_age median_age1;
run;

data _null_;
set tmp;
call symput("median_age", compress(median_age));
call symput("median_ir", compress(median_age1));
run;

data donor_14;
	set donor;
	day=DateTransfusion-dob;
	if day>14;
run;

proc sort; by id day;run;
proc sort nodupkey; by id;run;
proc sort data=donor out=tmp nodupkey; by DonorUnitID; run;

/*
proc sql;
create table donor as 
	select a.*, DateTransfusion, DateTransfusion-DateDonated as age
	from donor1 as a, tx_id as b
	where a.donorunitID=b.DonorUnitId;

proc sort data=donor nodupkey; by DonorUnitID DateDonated; run;
proc sort data=donor out=tmp nodupkey; by DonorUnitID; run;
*/

data _null_;
	set donor;
	call symput("n_age", compress(_n_));
run;

data _null_;
	set tmp;
	call symput("n_id", compress(_n_));
run;

proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=global gunit=pct noborder colors=(orange green red)
	 ftitle="Times/bold" ftext="Times/bold" htitle=3.5 htext=3;

 	
 	 	
		%let descrip1 = "Bar Chart for Age of Blood of RBC Transfusions (median=&median_age days)";
		%let descrip2 = "Bar Chart for Irradiation Days of Blood of RBC Transfusions (median=&median_ir days)";
		%let mp=(0 to 40 by 1);
		%let mp1=(0 to 25 by 1);

/*		For the purpose of Powerpint slides;
		axis1 label=(a=90 f=swissb c=white "#RBC Transfusions") color=white value=(h= 3) order=(0 to 80 by 10) minor=none;
    	axis2 label=(a=90 f=swissb c=white "#RBC Transfusions") color=white value=(h= 3) order=(0 to 55 by 5) minor=none;
		axis3 label=(a=0  h=4 c=white "Storage Age of RBCs (days)") color=white value=(h= 3) minor=none;
		axis4 label=(a=0  h=4 c=white "Days from Date of Irradiation to Date of Transfusion") color=white value=(h= 3) minor=none;		
*/

		axis1 label=(a=90 h=3 f=zapf c=black "#RBC Transfusions") order=(0 to 120 by 10) minor=none;
    	axis2 label=(a=90 h=3 f=zapf c=black "#RBC Transfusions") order=(0 to 100 by 10) minor=none;
		axis3 label=(a=0 h=3 c=black "Storage Age of RBCs (days)") value=(h= 2.5) minor=none;
		axis4 label=(a=0 h=3 c=black "Days from Date of Irradiation to Date of Transfusion") value=(h= 2.5) minor=none;		


		title1	;
		title2 &descrip1;
		title3 "(&n_age Transfusions from &n_id Donors)";
		/*
		proc univariate data=donor gout=wbh.graphs;
			where age<=20;
   		histogram age/midpoints=&mp type=frequency vaxislabel="Frequency" cfill=orange interbar=1 outhistogram = age;
			label age="Age of Blood (days)";
		run;
		*/

		Proc gchart data=donor gout=wbh.graphs;
			*where 3<age<=30;
			vbar age/ midpoints=&mp raxis=axis1 maxis=axis3 space=0.5 coutline=black width=2;
		run;

		title1	;	
		title2 &descrip2;
		title3 "(&n_age Transfusions from &n_id Donors)";
		Proc gchart data=donor gout=wbh.graphs;
			vbar age1/ midpoints=&mp1 raxis=axis2 maxis=axis4 space=1 coutline=black width=3;
		run;
		
    data donor_age;
        set donor(keep=id age) donor(keep=id age1 rename=(age1=age) in=B);
        if age^=.;
        if B then idx=2; else idx=1;
    run;
    
    proc freq data=donor_age noprint;
        tables age*idx /out=sumpyr /*outpct*/;
    run;
    
    data pyr2;
        set sumpyr;
        if idx=1 then count=-count;
    run;
    
title1 'Bar chart for Age of blood and Irridiation days for RBC Transfusions';
title2 "(&n_age Transfusions from &n_id Donors)";
axis1 label=(a=90 h=3 c=black "Age of Blood (Days)") order=(0 to 36 by 2) value=(h= 2.5) minor=none;

axis2 order=(-90 to 90 by 10) label=("# of RBC Transfusions") minor = none
value = ("90" "80" "70" "60" "50" "40" "30" "20" "10" "0" "10" '20' '30' "40" '50' '60' "70" '80' '90');

Legend1 value=(color=black height=2.5 "Storage Age of Blood (median=&median_age days)" "Days from Date of Irridiation to Date of Transfusion (median=&median_ir days)") label=none;

proc gchart data=pyr2 gout=wbh.graphs;
hbar age / discrete freq nostats sumvar=count space=0.25
   subgroup=idx raxis=axis2 maxis=axis1 legend=legend1;
run;
quit;

 
ods ps file = "age_blood.ps";
ods pdf file = "age_blood.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=v2s nofs; * L2R2s;
     treplay 1:1 2:2;
     *treplay 1:2;
run;
ods pdf close;
ods ps close;

options orientation=landscape;

ods ps file = "age_blood2.ps";
ods pdf file = "age_blood2.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=whole nofs; * L2R2s;
     treplay 1:3;
run;
ods pdf close;
ods ps close;

