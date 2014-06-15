options nodate nonumber;
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
    value sp 1="Leukoreduced"  2="Washed" 3="VolReduced";
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
    if day_trans<0 then delete;   

    if but not in (1,4) then sero=99;  
run;

proc sort; by donorunitid;run;

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
run;

proc sort nodupkey; by id DonorUnitId;run;

proc sql;
 create table tx_id as 
	select a.*
	from tx_id0 as a, cmv.completedstudylist as b
	where a.id=b.id;

proc sort; by donorunitid id;run;

data pending_rbc;
	merge tx_id(in=tx keep=id donorunitid tx_RBC tx_platelet) 
	donor1(in=donor keep=donorunitid); by donorunitID; 
	if tx and not donor;
    if tx_RBC;
run;

proc sort nodupkey; by donorunitid;run;

%let pending_rbc=0;
data _null_;
	set pending_rbc; 
	call symput("pending_rbc", compress(_n_));
run;

data pending_plt;
	merge tx_id(in=tx keep=id donorunitid tx_RBC tx_platelet) 
	donor1(in=donor keep=donorunitid); by donorunitID; 
	if tx and not donor;
    if tx_platelet;
run;

proc sort nodupkey; by donorunitid;run;

%let pending_plt=0;
data _null_;
	set pending_plt; 
	call symput("pending_plt", compress(_n_));
run;

data pending_id;
	merge tx_id(in=tx keep=id donorunitid tx_RBC tx_platelet) 
	donor1(in=donor keep=donorunitid); by donorunitID; 
	if tx and not donor;
run;

proc sort nodupkey; by donorunitid;run;

%let pending_id=0;
data _null_;
	set pending_id; 
	call symput("pending_id", compress(_n_));
run;


data donor;
    merge tx_id(in=A) donor1; by donorunitid;
    *if tx_RBC=. or tx_platelet=. then delete;
    if (tx_RBC or tx_platelet) and (sero=. or sero=99) then sero=9; 
    if (not tx_RBC) and (not tx_platelet) then sero=99;
    if A;
    
    if leukoreduced then sp=1;
    if washed then sp=2;
    if volreduced then sp=3;
run;

proc sort data=donor nodupkey; by DonorUnitID /*DateDonated*/; run;

data query_list;
    set donor;
    if tx_rbc or tx_platelet;
    if (day_irrad<0 and day_irrad^=.) or day_issue>100 or day_trans>100 or day_receive>100 or (day_receive<0 and day_receive^=.);
run;

filename myhtml "query_list.html";
ods html body=myhtml;

proc print data=query_list;
var ID DCCUnitId tx_RBC tx_platelet day_issue day_irrad day_trans day_receive DateDonated DateFirstIssued DateIrradiated TransferDate UnitReceivedDate;
run;

ods html close;

/*
data missing_volume; set donor; where UnitVolume=.;run;
title "xxx";
proc print;
var id DonorUnitId unitvolume;
run;
*/

data donor;
    set donor;
    if day_irrad<0 and day_irrad^=. or day_issue>300 or day_trans>300 or day_receive>300 or (day_receive<0 and day_receive^=.) then delete; 
run;

filename myhtml "day.html";
ods html body=myhtml;

proc univariate data=donor(where=(tx_rbc=1 or tx_platelet=1)) plot;
    var day_issue day_trans day_receive;
run;
ods html close;

data sp;
    set donor;
    where washed^=.;
run;

data _null_;
    set sp;
    call symput("nsp", compress(_n_));
run;

options orientation=landscape;
*********************************************************************************;
proc greplay igout= wbh.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
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

ods listing close;
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

ods listing;
proc sort data=donor out=donor_id nodupkey; by DonorUnitID; run;
data _null_;
	set donor_id;
	call symput("n", compress(_n_));
run;

data donorrbc;
    set donor;
    if tx_RBC;
run;

proc sort data=donorrbc out=donorrbc_id nodupkey; by DonorUnitID; run;
data _null_;
	set donorrbc_id;
	call symput("nrbc", compress(_n_));
run;


data donorplt;
    set donor;
    if tx_platelet;
run;

proc sort data=donorplt out=donorplt_id nodupkey; by DonorUnitID; run;
data _null_;
	set donorplt_id;
	call symput("nplt", compress(_n_));
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
%mend stat;

%macro tab(data,out,varlist);
data &out;
    if 1=1 then delete;
run;

%let i=1;
%let var=%scan(&varlist, &i);
%do %while (&var NE);

proc freq data=&data(where=(&var^=99));
tables &var;
ods output onewayfreqs=tab&i;
run;

data _null_;
    set tab&i end=last;
    if last then call symput("n&i", compress(cumfrequency));
run;

data tab&i;
    set tab&i;
    group=&i;
    rename &var=code;
    pct=frequency/&&n&i*100;
    col=put(pct,3.1)||"%("||compress(frequency)||"/"||compress(&&n&i)||")";
    if group=4 then do;
        pct=frequency/&nsp*100;
        col=put(pct,3.1)||"%("||compress(frequency)||"/"||compress(&nsp)||")";    
    end;
    keep &var percent frequency pct col group;
run;



data &out;
    set &out tab&i;
 	if group=1 then item=put(code, but.);
	if group=2 then item=put(code, abo.);
	if group=3 then item=put(code, rh.); 
	if group=4 then item=put(code, sp.);
	if group=5 then item=put(code, sero.); 
	if group=6 then item=put(code, storage.); 
	if group=7 then item=put(code, plt.);
	format group group.;
run;

%let i=%eval(&i+1);
%let var=%scan(&varlist, &i);
%end;
%mend tab;

%stat(data=donor);
%stat(data=donorrbc);
%stat(data=donorplt);
%stat(data=donor_id);
quit;

%let varlist=but abo rh sp sero storage plt;
%tab(donor_id, tab_donor, &varlist);

data vday;
	merge vday_donor(rename=(n=count)) vday_donor_id(keep=item n); by item;
	tmp=n||"("||compress(count)||")";
run;


%let path=/ttcmv/sas/output/monthly_internal/;
ods rtf file="&path.&file_donor.donor.rtf" style=journal bodytitle startpage=no;
*ods rtf file="donor.rtf" style=journal bodytitle startpage=no;

title "&title_donor for any transfusion (n=&n*)";
proc print data=vday_donor(where=(item=1)) noobs label uniform split="*";
var item/style=[just=left];
var n mean std median min max;
format mean std 5.1;
label item="Item"
		n="N"
		mean="Mean"
		std="Standard Error*"
		median="Median"
		min="Minimum"
		max="Maximum"
	;
run;


title "&title_donor for RBC transfusion only (continued, n=&nrbc*)";
proc print data=vday_donorrbc noobs label uniform split="*";
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
ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=12pt}
*The total number of donors here does not include &pending_rbc RBC donors whose blood unit tracking forms are still pending.";
ods rtf startpage=no;

title "&title_donor for Platelet tranfusion only (continued, n=&nplt*)";
proc print data=vday_donorplt noobs label uniform split="*";
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

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=12pt}
*The total number of donors here does not include &pending_plt Platelet donors whose blood unit tracking forms are still pending.";

ods rtf startpage=yes;

proc report data=tab_donor nowindows split="|";
title "&title_donor (continued, n=&n*)";
column group item frequency col;
define group/"Section" group style=[just=left cellwidth=1.5in];
define item/"Item" style(column)=[just=center cellwidth=1.5in];
define frequency/"N" style=[just=center cellwidth=0.5in];
define col/"Percent#" style=[just=center cellwidth=1.75in];
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=12pt}
*The total number of donors here does not include &pending_id donors whose blood unit tracking forms are still pending.
^n # Missing/Not Applicable are not counted in the denominator.";
ods rtf close;
