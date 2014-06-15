
options orientation=portrait nodate nonumber /*papersize=("7" "8")*/;
libname gcx "/ttcmv/sas/programs/reporting/baohua";
libname wbh "/ttcmv/sas/programs";
%include "/ttcmv/sas/programs/reporting/baohua/tab_stat.sas";

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
    value vname 1="Age of Blood" 2="Days of pRBC Transfusion after Irridiation";
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
	merge cmv.nec_p1(keep=id necdate isbloodstool isemesis isabndistension in=A) 
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.completedstudylist(in=B); by id;
	if bell;
	if first.id;
run;

*** NEC Imaging **********************************************;

	proc sort data=cmv.nec_image out=nec_image; by id dfseq; run;
	data nec_image; set nec_image; format imagetype imagetype.; run;

* check if given findings have been observed (report a count, or just y/n?) ; 
	data nec_image_totals; set nec_image; by id;

		retain disttotal bltotal sbstotal pitotal pvgtotal pntotal;

		if first.id then do;
			disttotal = intestinaldistension;
			bltotal = bowelloop;
			sbstotal = smallbowelseparation;
			pitotal = pneumointestinalis;
			pvgtotal = portalveingas;
			pntotal = pneumoperitoneum;
		end;

		else do;
			disttotal = disttotal + intestinaldistension;
			bltotal = bltotal + bowelloop;
			sbstotal = sbstotal + smallbowelseparation;
			pitotal = pitotal + pneumointestinalis;
			pvgtotal = pvgtotal + portalveingas;
			pntotal = pntotal + pneumoperitoneum;
		end;

		if last.id;

		if disttotal > 0 then dist = 1; else dist = 0;
		if bltotal > 0 then bl = 1; else bl = 0;
		if sbstotal > 0 then sbs = 1; else sbs = 0;
		if pitotal > 0 then pi = 1; else pi = 0;
		if pvgtotal > 0 then pvg = 1; else pvg = 0;
		if pntotal > 0 then pn = 1; else pn = 0;

		keep id imagetype disttotal bltotal sbstotal pitotal pvgtotal pntotal dist bl sbs pi pvg pn;   

	run;

	data nec; merge nec (in=a) nec_image_totals; by id; if a; run;


*** Use clinical signs and imagining findings to determine Bell stage 2 **********;

data nec; set nec; 
	if (isbloodstool = 1 | isemesis = 1 | isabndistension = 1) & (pi = 1 | pvg = 1 | pn = 1) 
	then bellstage2 = 1; else bellstage2 = 0; 
run;
************************************************************************************;

data tx;
	set cmv.plate_031(keep=id DonorUnitId DateTransfusion rbc_TxStartTime DateIrradiated rbc_TxEndTime rbcvolumetransfused bodyweight)
			/*cmv.plate_033(keep=id DonorUnitId DateTransfusion plt_TxStartTime)
			cmv.plate_035(keep=id DonorUnitId DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DonorUnitId DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

proc sort; by id DonorUnitId DateTransfusion rbc_TxStartTime;run;
proc sort data=tx nodupkey out=tmp dupout=dup_tx; by id DonorUnitId DateTransfusion rbc_TxStartTime;run;
ods rtf file="dup_tx.rtf";
proc print data=dup_tx;
by id;
id id;
var DonorUnitId DateTransfusion rbc_TxStartTime;
run;
ods rtf close;

data txA txB;
    merge tx(in=A) nec(in=tmp); by id; 
    if tmp;
    day_nec_tx=necdate-DateTransfusion;
    if day_nec_tx>=0 then output txA;
    else output txB;
run;


proc sort data=txA; by id day_nec_tx; run;

data necA;
    set txA; by id day_nec_tx;
    if first.id;
    if day_nec_tx>=3 then nidx=2;
    else if day_nec_tx in(0, 1, 2) then nidx=1;
run;

proc sort data=txB; by id descending day_nec_tx; run;

data necB;
    set txB; by id descending day_nec_tx;
    if first.id;
    nidx=3;
run;

data nec_id;
    set necA(in=A) necB(in=B); by id;
run;

proc sort; by id nidx; run;

data nec_id; 
    set nec_id; by id nidx;
    if first.id;
run;

data cmv.nec_id;
    set nec_id;
run;

proc contents;run;

data _null_;
    set nec_id(where=(nidx=1));
    call symput ("n1", compress(_n_));
run;

data _null_;
    set nec_id(where=(nidx=2));
    call symput ("n2", compress(_n_));
run;


proc freq; 
tables bellstage2;
run;

data tx_id;
    merge tx nec_id(keep=id necdate nidx bellstage2 in=tmp) cmv.comp_pat(keep=id dob); by id; 
    day_nec_tx=necdate-DateTransfusion;
    if tmp then age_nec=necdate-dob;
        else age_nec=DateTransfusion-dob;
    if age_nec=. or age_nec<0 then delete;
    
    if nidx=1 then if day_nec_tx in (0, 1, 2) then sub_idx=1; else sub_idx=0;
    if not tmp then nidx=0;
    
    hr=intck('minute', input(rbc_TxStartTime, time8.), input(rbc_TxendTime, time8.))/60;
    if hr<0 then hr=intck('minute', input(rbc_TxStartTime, time8.), input(rbc_TxendTime, time8.))/60+24;
    vol=rbcvolumetransfused/bodyweight*1000;
run;

proc sort data=nec_id; by donorunitid;run;
proc sort data=tx_id; by donorunitid;run;
proc sort data=donor1; by donorunitid;run;


proc format; 
value nidx 0="Transfused without NEC" 1="Transfused <=48 hrs before NEC" 2="Transfused >48 hrs before NEC";
value sub_idx 1="0~2 Days"  0=">2 Days";
value item 1="Age of Blood (Day)" 2="Irradiation Time(Day)";
run;

data donor;
	merge donor1 tx_id(in=tmp rename=(DateIrradiated=DateIrradiated_tx)); by DonorUnitId;
	center = floor(DCCUnitID/10000000);
    format center center.;
    if (center = 3 | center = 4 | center = 5) then dateirradiated = dateirradiated_tx;
     
	age=DateTransfusion-DateDonated;
	age1=DateTransfusion-DateIrradiated;
	
	if DateTransfusion>necdate>0 then do; age=.; age1=.; end;

	if age=. then delete;
	if tmp;
	if age<0 then age=.;
	if age1<0 then age1=.;
	if age>300 then age=.;

	if center in(1,2) then site=1; else site=2;
	
	nidx1= nidx - .1 + .2*uniform(613);
	
	if sub_idx=1 then do; sub_age=age;  sub_age1=age1; sub_vol=vol; sub_hr=hr; end;
	else do; left_age=age;  left_age1=age1; left_vol=vol; left_hr=hr; end;
	
	format site site. nidx nidx. sub_idx sub_idx.;
run;

proc sort; by id DonorUnitId DateTransfusion DateDonated  DateIrradiated;run;

data donor_tab;
    merge donor(in=A) cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob)); by id;
    if A;
    age_tx=DateTransfusion-dob;
    if 0<age_tx<=7 then age_idx=1;
      else if 8<=age_tx<=14 then age_idx=2;
        else if 15<=age_tx<=21 then age_idx=3;
          else if 22<=age_tx<=28 then age_idx=4;
          else if 29<=age_tx<=35 then age_idx=5;
          else if 36<=age_tx<=42 then age_idx=6;
    if nidx in(1,2) then nec=1; else nec=0;
    format nec nec.;
run;

proc sort data=donor_tab nodupkey out=donor_num; by id;run;
proc freq  data=donor_num;
    tables nec;
run;

%table(data_in=donor_tab, where=age_idx=1, data_out=atab,gvar=nec,var=age,type=con, first_var=1, label="Week 1", title="Table A: Summary for Age of Blood (Days)");
%table(data_in=donor_tab, where=age_idx=2, data_out=atab,gvar=nec,var=age,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=atab,gvar=nec,var=age,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=atab,gvar=nec,var=age,type=con, label="Week 4");
%table(data_in=donor_tab, where=age_idx=5, data_out=atab,gvar=nec,var=age,type=con, label="Week 5");
%table(data_in=donor_tab, where=age_idx=6, data_out=atab,gvar=nec,var=age,type=con, label="Week 6");
%table(data_in=donor_tab, data_out=atab,gvar=nec,var=age,type=con, last_var=1, label="Any Weeks");

%table(data_in=donor_tab, where=age_idx=1, data_out=irtab,gvar=nec,var=age1,type=con, first_var=1, label="Week 1", title="Table B: Summary for Irradiation Time (Days)");
%table(data_in=donor_tab, where=age_idx=2, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 4");
%table(data_in=donor_tab, where=age_idx=5, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 5");
%table(data_in=donor_tab, where=age_idx=6, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 6");
%table(data_in=donor_tab, data_out=irtab,gvar=nec,var=age1,type=con, last_var=1, label="Any Weeks");

%table(data_in=donor_tab, where=age_idx=1, data_out=vtab,gvar=nec,var=vol,type=con, first_var=1, label="Week 1", title="Table C: Summary for Volume of pRBC Transfusion (ml/kg)");
%table(data_in=donor_tab, where=age_idx=2, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 4");
%table(data_in=donor_tab, where=age_idx=5, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 5");
%table(data_in=donor_tab, where=age_idx=6, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 6");
%table(data_in=donor_tab, data_out=vtab,gvar=nec,var=vol,type=con, last_var=1, label="Any Weeks");

%table(data_in=donor_tab, where=age_idx=1, data_out=ltab,gvar=nec,var=hr,type=con, first_var=1, label="Week 1", title="Table D: Summary for Length of pRBC Transfusion (hrs)");
%table(data_in=donor_tab, where=age_idx=2, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 4");
%table(data_in=donor_tab, where=age_idx=5, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 5");
%table(data_in=donor_tab, where=age_idx=6, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 6");
%table(data_in=donor_tab, data_out=ltab,gvar=nec,var=hr,type=con, last_var=1, label="Any Weeks");
