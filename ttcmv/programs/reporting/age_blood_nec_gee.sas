

options orientation=portrait nobyline nodate nonumber NOSPOOL=on /*papersize=("7" "8")*/;

libname wbh "/ttcmv/sas/programs";

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
    value idx 1="GEE Model with Age of Blood and Age of Transfusion"
        2="GEE Model with Radiation Time and Age of Transfusion"
        3="GEE Model with Length of Transfusion of Blood and Age of Transfusion"
        4="GEE Model with Volume of Transfusion and Age of Transfusion"
        5="GEE Model with Hemoglobin at Transfusion and Age of Transfusion"
        ;
    value gvar 1="Age of Blood"
        2="Irradiation Days"
        ;
    value s 0=" " 5=" "
        1="Non-NEC" 2="NEC"
        3="Non-NEC" 4="NEC"
        ;
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
	merge cmv.nec_p1(keep=id necdate in=A) cmv.completedstudylist(in=B); by id;
	if A and B;
	if first.id;
run;

data tx_id;
	set cmv.plate_031(keep=id hb DonorUnitId DateTransfusion DateIrradiated rbc_TxStartTime rbc_TxEndTime rbcvolumetransfused bodyweight);
	txt=intck('minute', input(rbc_TxStartTime, time8.), input(rbc_TxendTime, time8.))/60;
    if txt<0 then txt=intck('minute', input(rbc_TxStartTime, time8.), input(rbc_TxendTime, time8.))/60+24;
    volume=rbcvolumetransfused/bodyweight*1000;
run;

proc sort; by id DonorUnitId DateTransfusion rbc_TxStartTime;run;

data tx_id;
    merge tx_id(in=A) nec(in=tmp); by id; 
    if tmp then do; if DateTransfusion<necdate then nec=1; else nec=0; end;
run;

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
	if age<=0 then age=.;
	if age1<0 then age1=.;
	if age>300 then age=.;

	if center in(1,2) then site=1; else site=2;
	format site site.;
run;

proc sort data=donor; by id DonorUnitId; run;

data donor;
    merge donor(in=A) cmv.comp_pat(in=comp keep=id dob) cmv.endofstudy(keep=id StudyLeftDate); by id;   
    if A and comp;
    if nec=. then nec=0;
    bday=DateTransfusion-dob;
    *if center=1;
run;


proc means data=donor median min max;
    class nec;
    var age age1;
    output out=tmp median(age age1)=median_age median_age1 min(age age1)=min_age min_age1 max(age age1)=max_age max_age1;
run;


data _null_;
set tmp;
if nec=0 then do;
    call symput("median_age0", compress(median_age));
    call symput("median_ir0",  compress(median_age1));
    call symput("min_age0", compress(min_age));
    call symput("min_ir0",  compress(min_age1));
    call symput("max_age0", compress(max_age));
    call symput("max_ir0",  compress(max_age1));
end;


if nec=1 then do;
    call symput("median_age1", compress(median_age));
    call symput("median_ir1",  compress(median_age1));
    call symput("min_age1", compress(min_age));
    call symput("min_ir1",  compress(min_age1));
    call symput("max_age1", compress(max_age));
    call symput("max_ir1",  compress(max_age1));
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

%macro gee(data, var, var1, var2,idx);
*ods trace on/label listing;
proc genmod data=&data descend;
    class id &var; 
    /*
    model &var=&var1 &var2/link=log dist=negbin type3; 
    model &var=&var1/link=log dist=negbin type3; 
    */
    model &var1=&var/dist=negbin type3; 
    repeated subject=id/type=exch;
    lsmeans &var/cl;
    
    /*
    estimate "log O.R. &var1" int 1 &var 1 0 / exp;
    estimate "log O.R. &var1" int 1 &var 0 1 / exp;      
    
    estimate "log O.R. &var1" &var1 1 / exp;
    estimate "log O.R. &var2" &var2 1 / exp;
    ods output GEEEmpPEst=est;
    */
    
   	ods output lsmeans =avg;
    ods output Genmod.Type3=pv;
run;

*ods trace off;

data _null_;
    length pv $8;
    set pv;
    if probchisq<0.0001 then pv="<0.0001";
        else pv=put(probchisq,7.4);
    if _n_=1 then call symput("p1", pv);
    /*if _n_=2 then call symput("p2", pv);*/
run;

data est&idx;
    set avg(keep=nec estimate lower upper rename=(estimate=est0 lower=lower0 upper=upper0));
    pv=&p1;
    estimate=exp(est0);
        lower=exp(lower0);
            upper=exp(upper0);
    idx=&idx;
run;

%mend gee;

%gee(donor, nec, age, bday,1);
%gee(donor, nec, age1, bday,2);
/*
%gee(donor, nec, txt, bday,3);
%gee(donor, nec, volume, bday,4);
%gee(donor, nec, hb, bday,5);
*/
quit;

data est;
    set est1 est2 /*est3 est4 est5*/; by idx;
    format idx idx.;
    if idx=1 and nec=0 then do; s=1; low=&min_age0; high=&max_age0; end;
    if idx=1 and nec=1 then do; s=2; low=&min_age1; high=&max_age1; end;
    if idx=2 and nec=0 then do; s=3; low=&min_ir0; high=&max_ir0; end;
    if idx=2 and nec=1 then do; s=4; low=&min_ir1; high=&max_ir1; end;
    if idx=1 then call symput("p1", compress(pv));
    if idx=2 then call symput("p2", compress(pv));
    mci=put(estimate,4.1)||"["||put(lower,4.1)||" -"||put(upper,4.1)||"]";
    rg=compress(low)||"-"||compress(high);
run;

proc sort; by idx nec; run;

data estimate;
    merge est1(where=(nec=0) rename=(estimate=estimate0a lower=lower0a upper=upper0a) in=A)
          est1(where=(nec=1) rename=(estimate=estimate1a lower=lower1a upper=upper1a) in=B)
          est2(where=(nec=0) rename=(estimate=estimate0b lower=lower0b upper=upper0b) in=C)
          est2(where=(nec=1) rename=(estimate=estimate1b lower=lower1b upper=upper1b) in=D)
          ;
          s1=1; s2=2; s3=3; s4=4;
run;

proc print;run;

ODS PDF FILE ="negbin_age_rage.pdf"; 
/*
PROC sgplot DATA=estimate noautolegend;
title "Comparison of Age of Blood/Radiation between NEC and non-NEC";

SCATTER X = s1 Y = estimate0a /yerrorlower=lower0a yerrorupper=upper0a LEGENDLABEL = 'Age of Blood (Non-NEC)' MARKERATTRS=(size=8 SYMBOL=circlefilled color=blue) ERRORBARATTRS=(color=blue);
SCATTER X = s2 Y = estimate1a /yerrorlower=lower1a yerrorupper=upper1a LEGENDLABEL = 'Age of Blood (NEC)' MARKERATTRS=(size=8 SYMBOL=circlefilled color=red) ERRORBARATTRS=(color=red);
SCATTER X = s3 Y = estimate0b /yerrorlower=lower0b yerrorupper=upper0b LEGENDLABEL = 'Irridiation Days (Non-NEC)' MARKERATTRS=(size=8 SYMBOL=circle color=blue) ERRORBARATTRS=(color=blue);
SCATTER X = s4 Y = estimate1b /yerrorlower=lower1b yerrorupper=upper1b LEGENDLABEL = 'Irridiation Days (NEC)' MARKERATTRS=(size=8 SYMBOL=circle color=red) ERRORBARATTRS=(color=red);

xaxis label=" "  grid values=(0 to 5 by 1);
yaxis label="Days " grid values=(0 to 2.5 by 0.5);
keylegend/position=topright across=1 location=inside;
format s1-s4 s.;
RUN;
*/
  
proc sgplot data=est ;
scatter x=s y=estimate/group=idx
yerrorlower=lower yerrorupper=upper
markerattrs=(symbol=circlefilled)
name="scat";
xaxis integer values=(0 to 5 by 1)
label=" ";
yaxis integer values=(0 to 15 by 1)
label="Days";
format s s. idx gvar.;
keylegend "scat" / title=" " noborder;
inset ("p value (Age of Blood)="="&p1" "p value (Irradiation Days)="="&p2")/position=topright noborder;
run;

ods pdf close;

ods rtf file="Negbin_age_rage.rtf" style=journal bodytitle  startpage=never;
proc report data=est nowindows style(column)=[just=center] split="*";
title1 h=3.5 "Estimate by GEE Model";
title2 h=2 "non-NEC:&n0_age Transfusions from &n0_id Donors for &m0 LBWIs, NEC:&n1_age Transfusions from &n1_id Donors for &m1 LBWIs";

column idx nec rg mci pv;
define idx/"Item" group order=internal format=gvar.  style(column)=[width=1.5in just=left] style(header)=[just=left];
define nec/"Status" group format=nec.  style(column)=[width=1in just=center];
define rg/"Min-Max" style(column)=[width=1in just=center];
define mci/"Mean[95%CI]" style(column)=[width=1.5in just=center];
define pv/"p value" group style(column)=[width=0.75in just=center];
run;
ods rtf close;

