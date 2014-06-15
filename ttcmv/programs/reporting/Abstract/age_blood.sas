
options orientation=landscape nobyline nodate nonumber /*papersize=("7" "8")*/;


libname wbh "/ttcmv/sas/programs/reporting";

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
	keep DonorUnitId DateDonated but UnitVolume day_issue day_irrad day_trans day_receive ABO Rh Leukoreduced Washed VolReduced sero storage plt DCCUnitId;
run;


data tx_id;
	set cmv.plate_031(keep=id DonorUnitId DateTransfusion rbc_TxStartTime)
			/*cmv.plate_033(keep=id DonorUnitId DateTransfusion plt_TxStartTime)
			cmv.plate_035(keep=id DonorUnitId DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DonorUnitId DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

proc sort; by id DonorUnitId DateTransfusion rbc_TxStartTime;run;

data tmp;
	set tx_id; by id DonorUnitId DateTransfusion rbc_TxStartTime;
	retain mark;
	if first.rbc_TxStartTime then mark=1; else mark=0;
run;
proc print;
where mark=0;
run;

proc sql;
 create table tx_id as 
	select a.*, b.dob
	from tx_id as a, cmv.comp_pat as b
	where a.id=b.id;


proc sort; by donorunitid;run;
proc sort data=donor1; by donorunitid;run;

data donor;
	merge donor1 tx_id(in=tmp); by DonorUnitId;
	age=DateTransfusion-DateDonated;
	if age=. then delete;
	if tmp;
run;

title "wbh";
proc print;
where age<2;
var donorunitid id DateTransfusion DateDonated age;
run;

data donor_14;
	set donor;
	day=DateTransfusion-dob;
	if day>14;
run;

proc sort; by id day;run;
proc print; 
var id dob DateTransfusion rbc_TxStartTime day;
run;
proc sort nodupkey; by id;run;
proc print; var id dob DateTransfusion rbc_TxStartTime day; run;



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
goptions reset=global rotate=landscape gunit=pct noborder /*colors=(orange green red)*/
	ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;

 	
		%let description = f=zapf "Bar Chart for Age of Blood of RBC Transfusions";
		%let mp=(1 to 30 by 1);
		
		axis1 label=(a=90 h=4 c=black "#RBC Transfusions") order=(0 to 40 by 5) minor=none;
		axis2 label=(a=0 h=4 c=black "Storage Age of RBCs (days)") value=(/*f=zapf*/ h= 2.5) /*order=(-25 to 40 by 1)*/ minor=none;
		


		title1 &description;
		title2 "(&n_age Transfusions from &n_id Donors)";
		/*
		proc univariate data=donor gout=wbh.graphs;
			where age<=20;
   		histogram age/midpoints=&mp type=frequency vaxislabel="Frequency" cfill=orange interbar=1 outhistogram = age;
			label age="Age of Blood (days)";
		run;
		*/

		pattern1 color=orange;
		Proc gchart data=donor gout=wbh.graphs;
			where 3<age<=30;
			vbar age/ midpoints=&mp raxis=axis1 maxis=axis2 space=0.5 coutline=black width=2;
		run;

ods ps file = "age_blood.ps";
ods pdf file = "age_blood.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=whole nofs; * L2R2s;
     treplay 1:1;
     *treplay 1:3 2:4;
run;
ods pdf close;
ods ps close;
