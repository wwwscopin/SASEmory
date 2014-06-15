options nodate;
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
		1="Volume of parent unit (ml)"
		2="Date unit issued to NICU - Date blood donated"
		3="Date unit irradiated at the Red Cross - Date blood donated"
		4="Date transfer of unit segments to PERL - Date blood donated"
		5="Date received and stored - Date blood donated"
		;

	value tx 
		0="No"
		1="Yes"
		;
run;

data donor0;
	set cmv.plate_001_bu;
	keep DonorUnitId BloodUnitType DateDonated UnitVolume DateFirstIssued ABOGroup RhGroup DateIrradiated Leukoreduced Washed 							
	VolReduced UnitSeroStatus unitstorage plt_type TransferDate UnitReceivedDate DCCUnitId;
	rename BloodUnitType=but ABOGroup=abo RhGroup=rh UnitSeroStatus=sero unitstorage=storage Plt_type=plt;
	format BloodUnitType but. ABOGroup abo. RhGroup rh. UnitSeroStatus sero. unitstorage storage. plt_type plt. 
			  Leukoreduced Washed VolReduced na.;
run;

data donor1;
	set donor0;
	    if DCCUnitId=30000094 then DateDonated='25Feb2011'd;
	day_issue=DateFirstIssued-DateDonated;
	day_irrad=DateIrradiated-DateDonated;
	day_trans=TransferDate-DateDonated;
	day_receive=UnitReceivedDate-DateDonated;
	keep DonorUnitId DateDonated but UnitVolume day_issue day_irrad day_trans day_receive ABO Rh Leukoreduced Washed VolReduced sero storage plt DCCUnitId DateFirstIssued TransferDate	UnitReceivedDate DateIrradiated;
    if day_issue<0 then delete;

    if but not in (1,4) then sero=99;
run;

proc sort; by donorunitid;run;

title "xxx";
proc print;
where day_issue>10000;
run;

/*
proc print;
where day_issue<0;
var dccunitid DonorUnitId DateFirstIssued DateDonated day_issue;
run;

proc print;
var DCCUnitId  day_issue day_irrad day_trans day_receive DateDonated DateFirstIssued DateIrradiated TransferDate	UnitReceivedDate;
where day_irrad<0 and day_irrad^=. or day_issue>100 or day_trans>100 or day_receive>100;
run;
*/

data tx_id0;
	set cmv.plate_031(in=A keep=id DonorUnitId)
			cmv.plate_033(in=B keep=id DonorUnitId)
			cmv.plate_035(in=C keep=id DonorUnitId)
			cmv.plate_037(in=D keep=id DonorUnitId);
			/*cmv.plate_039(in=E keep=id)*/
	if A then tx_RBC=1; else tx_RBC=0; 
	if B then tx_platelet=1; else tx_platelet=0; 
	if C then tx_FFP=1; else tx_FFP=0; 
	if D then tx_Cyro=1; else tx_Cyro=0; 
	/*if E then tx_Granulocyte=1; else tx_Granulocyte=0; */

	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx.;
		;
run;

proc sort nodupkey; by id DonorUnitId;run;

proc sql;
 create table tx_id as 
	select a.*
	from tx_id0 as a, cmv.completedstudylist as b
	where a.id=b.id;

proc sort; by donorunitid id;run;

data pending;
	merge tx_id(in=tx keep=id donorunitid tx_RBC tx_platelet) 
	donor1(in=donor keep=donorunitid); by donorunitID; 
	if tx and not donor;
    if tx_RBC or tx_platelet;
run;

proc sort nodupkey; by donorunitid;run;

%let pending_id=0;
data _null_;
	set pending; 
	call symput("pending_id", compress(_n_));
run;

data donor;
    merge tx_id(in=A) donor1; by donorunitid;
    if tx_RBC=. or tx_platelet=. then delete;
    if (tx_RBC or tx_platelet) and (sero=. or sero=99) then sero=9; 
    if (not tx_RBC) and (not tx_platelet) then sero=99;
    if A;
run;

proc sort data=donor nodupkey; by DonorUnitID /*DateDonated*/; run;

options orientation=landscape;
*********************************************************************************;
/*
proc greplay igout= wbh.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
*/

goptions reset=global rotate=landscape  gunit=pct border /*colors=(orange green red)*/
	ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;

%let mp=(-10 to 35 by 5); %let space=0;

axis1 label=(a=90 h=4 c=black "Percent") minor=none;
axis2 label=(a=0 h=4 c=black "Days") minor=none;

proc univariate data=donor gout=wbh.graphs;
	*histogram day_issue day_irrad day_trans day_receive/cfill=orange ;
	histogram day_irrad/cfill=orange midpoints=&mp ;
	histogram day_issue day_trans day_receive/cfill=orange;
	label day_issue="Date unit issued to NICU - Date blood donated"
			 day_irrad="Date unit irradiated at the Red Cross - Date blood donated" 
			 day_trans="Date transfer of unit segments to PERL - Date blood donated"
			 day_receive="Date received and stored - Date blood donated"
			;	
run;

ods pdf file = "daybar.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template= l2r2 nofs nobyline; * L2R2s;
     treplay 1:1 2:3 3:2 4:4;
     *treplay 1:3 2:4;
run;

ods pdf close;

*********************************************************************************;


options orientation=portrait;

ods rtf file="tx.rtf" style=journal;
proc print data=donor noobs label ;
title "wbh";
where sero=99;

var id donorunitid sero tx_RBC tx_Platelet tx_FFP tx_Cyro /*tx_Granulocyte*/;
label sero="Unit CMV Serostatus";
run;
ods rtf close;


proc sort data=donor out=donor_id nodupkey; by DonorUnitID; run;
data _null_;
	set donor_id;
	call symput("n", compress(_n_));
run;

%macro stat(data=donor);

proc means data=&data n mean std median min max NWAY /*NOPRINT*/;
var unitvolume day_issue day_irrad day_trans day_receive;
output out=stat;
output out=median	median=;
run;

data vday;
	set stat median(in=tmp); by _type_;
	if tmp then _stat_="MEDIAN";
run;

proc transpose data=vday out=vday;
var UnitVolume day_issue day_irrad day_trans day_receive;
run;

data vday_&data;
	set vday;
	item=_n_;
	rename  COL1=N COL2=min Col3=max COL4=mean COL5=std col6=median;
	drop _label_ _name_;
	format	item item.;
run;

/*
ods trace on/lable listing;
ods trace off;
*/
proc freq data=&data;
tables but abo rh leukoreduced washed volreduced sero storage plt;
	ods output Freq.Table1.OneWayFreqs=tab1;
	ods output Freq.Table2.OneWayFreqs=tab2;
	ods output Freq.Table3.OneWayFreqs=tab3;
	ods output Freq.Table4.OneWayFreqs=tab4;
	ods output Freq.Table5.OneWayFreqs=tab5;
	ods output Freq.Table6.OneWayFreqs=tab6;
	ods output Freq.Table7.OneWayFreqs=tab7;
	ods output Freq.Table8.OneWayFreqs=tab8;
	ods output Freq.Table9.OneWayFreqs=tab9;
run;

data tab_&data;
	set tab1(keep=but Frequency percent rename=(but=code) in=tab1)
	 	 tab2(keep=abo Frequency percent rename=(abo=code) in=tab2)
	 	 tab3(keep=rh Frequency percent rename=(rh=code) in=tab3)
	 	 tab4(keep=leukoreduced Frequency percent rename=(leukoreduced=code) in=tab4)
	 	 tab5(keep=washed Frequency percent rename=(washed=code) in=tab5)
	 	 tab6(keep=volreduced Frequency percent rename=(volreduced=code) in=tab6)
	 	 tab7(keep=sero Frequency percent rename=(sero=code) in=tab7)
	 	 tab8(keep=storage Frequency percent rename=(storage=code) in=tab8)
	 	 tab9(keep=plt Frequency percent rename=(plt=code) in=tab9);
	if tab1 then do; group=1; item=put(code, but.); end;
	if tab2 then do; group=2; item=put(code, abo.); end;
	if tab3 then do; group=3; item=put(code, rh.); end;
	if tab4 then do; group=4; item="Leukoreduced--"||strip(put(code, na.)); end;
	if tab5 then do; group=4; item="Washed--"||strip(put(code, na.)); end;
	if tab6 then do; group=4; item="Volume reduced--"||strip(put(code, na.)); end;
	if tab7 then do; group=5; item=put(code, sero.); end;
	if tab8 then do; group=6; item=put(code, storage.); end;
	if tab9 then do; group=7; item=put(code, plt.); end;
	format group group.;
run;

proc sort; by group;run;

/*
data tab_&data;
	set tab; by group notsorted;
	if not first.group then group=99;
run;
*/

%mend stat;

%stat(data=donor);
%stat(data=donor_id);
quit;

data vday;
	merge vday_donor(rename=(n=count)) vday_donor_id(keep=item n); by item;
	tmp=n||"("||compress(count)||")";
run;

data tab;
	merge tab_donor(drop=percent rename=(frequency=count)) tab_donor_id(keep=group frequency); by group;
	pct=frequency/&n*100;
	tmp=frequency||"("||compress(count)||")";
	format pct 4.1;
run;

data tab_donor;
	set tab_donor; by group;
	*if not first.group then group=99;
run;


%let path=/ttcmv/sas/output/monthly_internal/;
ods rtf file="&path.donor.rtf" style=journal bodytitle startpage=no;
*ods rtf file="donor.rtf" style=journal bodytitle startpage=no;

title "Donor Information Summary (n=&n*)";
proc print data=vday_donor noobs label uniform split="*";
var item/style=[just=left];
var n mean std median min max;
format mean std 5.1;
label item="Item"
		n="N *"
		mean="Mean"
		std="Standard Error*"
		median="Median"
		min="Minimum"
		max="Maximum"
	;
run;

proc print data=tab_donor noobs label uniform split="*";
by group;
id group/style(data)=[just=left cellwidth=1.5in];
var item/style(data)=[just=left cellwidth=1.5in];
var frequency percent/style(data)=[just=right cellwidth=1in];
	format percent 4.1;
label group="Section"
		item="Item"
		Frequency="N *"
		Percent="Percent (%)*"
		;
run;
/*
ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
*The total number of donors here does not include &pending_id donors whose blood unit tracking forms are still pending.";
*/
ods rtf close;



