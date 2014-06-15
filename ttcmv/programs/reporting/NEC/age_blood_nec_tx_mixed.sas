
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
    value vname 1="Age of Blood" 2="Days of pRBC Transfusion after Irradiation";
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

data tx;
	set cmv.plate_031(keep=id DonorUnitId DateTransfusion rbc_TxStartTime DateIrradiated rbc_TxEndTime rbcvolumetransfused bodyweight)
			/*cmv.plate_033(keep=id DonorUnitId DateTransfusion plt_TxStartTime)
			cmv.plate_035(keep=id DonorUnitId DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DonorUnitId DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

proc sort; by id DonorUnitId DateTransfusion rbc_TxStartTime;run;

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

data _null_;
    set nec_id(where=(nidx=1));
    call symput ("n1", compress(_n_));
run;

data _null_;
    set nec_id(where=(nidx=2));
    call symput ("n2", compress(_n_));
run;

data _null_;
    set nec_id(where=(nidx=3));
    call symput ("n3", compress(_n_));
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
value nidx 0="Transfused without NEC" 1="Transfused <=48 hrs before NEC" 2="Transfused >48 hrs before NEC" 3="Transfused after NEC";
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
	
	if nidx in (1,2) and DateTransfusion>necdate>0 then do; age=.; age1=.; end;

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
      else if 8<age_tx<=14 then age_idx=2;
        else if 15<age_tx<=21 then age_idx=3;
          else if 22<age_tx<=28 then age_idx=4;
    if nidx in(1,2) then nec=1; else nec=0;
    format nec nec.;
run;

/*
data tmp;
    set donor_tab;
    if nec=1;
run;
proc sort nodupkey; by id; run;

proc print;run;
*/

%table(data_in=donor_tab, where=age_idx=1, data_out=atab,gvar=nec,var=age,type=con, first_var=1, label="Week 1", title="Table A: Summary for Age of Blood (Days)");
%table(data_in=donor_tab, where=age_idx=2, data_out=atab,gvar=nec,var=age,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=atab,gvar=nec,var=age,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=atab,gvar=nec,var=age,type=con, label="Week 4");
%table(data_in=donor_tab, data_out=atab,gvar=nec,var=age,type=con, last_var=1, label="Any Week");

%table(data_in=donor_tab, where=age_idx=1, data_out=irtab,gvar=nec,var=age1,type=con, first_var=1, label="Week 1", title="Table B: Summary for Irradiation Time(Days)");
%table(data_in=donor_tab, where=age_idx=2, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=irtab,gvar=nec,var=age1,type=con, label="Week 4");
%table(data_in=donor_tab, data_out=irtab,gvar=nec,var=age1,type=con, last_var=1, label="Any Week");

%table(data_in=donor_tab, where=age_idx=1, data_out=vtab,gvar=nec,var=vol,type=con, first_var=1, label="Week 1", title="Table C: Summary for Volume of Transfusion (ml/kg)");
%table(data_in=donor_tab, where=age_idx=2, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=vtab,gvar=nec,var=vol,type=con, label="Week 4");
%table(data_in=donor_tab, data_out=vtab,gvar=nec,var=vol,type=con, last_var=1, label="Any Week");

%table(data_in=donor_tab, where=age_idx=1, data_out=ltab,gvar=nec,var=hr,type=con, first_var=1, label="Week 1", title="Table D: Summary for Length of Transfusion (hrs)");
%table(data_in=donor_tab, where=age_idx=2, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 2" );
%table(data_in=donor_tab, where=age_idx=3, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 3" );
%table(data_in=donor_tab, where=age_idx=4, data_out=ltab,gvar=nec,var=hr,type=con, label="Week 4");
%table(data_in=donor_tab, data_out=ltab,gvar=nec,var=hr,type=con, last_var=1, label="Any Week");

data cmv.nec_tx;
    set donor;
    where nidx in(1,2);
run;

proc sort data=donor out=lbwi nodupkey; by id; run;
proc means data=lbwi n; 
    class nidx; 
    var id;
    output out=wbh n(id)=n;
run;

data _null_;
    set wbh;
    if nidx=0 then call symput("n0", compress(n));
       if nidx=1 then call symput("n1", compress(n));
           if nidx=2 then call symput("n2", compress(n));
              if nidx=3 then call symput("n3", compress(n));
run;

proc means data=donor(where=(nidx=1)) maxdec=1 mean stderr median Q1 Q3 min max;
class sub_idx;
var age age1 vol hr;
run;

proc mixed data=donor(where=(nidx=1));
    class sub_idx;
    model age=sub_idx;
    lsmeans sub_idx/cl;
run;

proc mixed data=donor(where=(nidx=1));
    class sub_idx;
    model age1=sub_idx;
    lsmeans sub_idx/cl;
run;

proc mixed data=donor(where=(nidx=1));
    class sub_idx;
    model vol=sub_idx;
    lsmeans sub_idx/cl;
run;
   
proc mixed data=donor(where=(nidx=1));
    class sub_idx;
    model hr=sub_idx;
    lsmeans sub_idx/cl;
run;
     
%macro make_plots(data, var); 
goptions device=pslepsfc reset=global gunit=pct noborder cback=white colors = (black red) ;

%if  &var=age %then %let description=Age of Blood (Day);
%if  &var=age1 %then %let description=Days of pRBC Transfused after Irradiation;
%if  &var=vol %then %let description=Volume per Transfusion (ml/kg);
%if  &var=hr %then %let description=Length of pRBC Transfusion (hr);
     
 
     data one;
        function="label"; x=50; y=16; color='red'; size=1; text="red color--> pRBC(0-2 Days) before NEC"; 
     run;
         
          		* get 'n' at each day;
         		proc means data=&data noprint;

         			class nidx;
         			var &var;
         			output out = sizes_&data n(&var) = num_obs;
         		run;

         	   %let m1= 0; %let m2= 0; %let m0= 0;  %let m3=0;
         
         		* populate 'n' annotation variables ;
         		%do i = 0 %to 3;
         			data _null_;
         				set sizes_&data;
         				where nidx = &i;
         				call symput( "m&i",  compress(put(num_obs, 3.0)));
         			run;
         		%end;
         
proc format; 
    value group -1="Group*(m|n)" 0="Tx without NEC*(&m0|&n0) " 1 = "Tx <=48 hrs before NEC*(&m1|&n1)" 
    2 = "Tx >48 hrs before NEC*(&m2|&n2)"    3="Tx after NEC*(&m3|&n3)" 4=" ";              
run;

proc sort data=&data;by nidx;run;         

proc means data=&data mean stderr median Q1 Q3 min max maxdec=1;
    class nidx ;
    var &var;
    ods output Means.Summary=test;
run; 	

proc mixed data=&data;
    class nidx;
    model &var=nidx;
    lsmeans nidx/cl;
   	ods output lsmeans = avg;
run;

proc sort; by nidx; run;

data avg;
    set avg;
    if lower<0 then lower=0;
run;

data avg_&var;
    merge test avg(keep=nidx estimate stderr lower upper rename=(stderr=sem)); by nidx;
    if nidx=0 then do; m=&m0; num=&n0; end;
    if nidx=1 then do; m=&m1; num=&n1; end;
    if nidx=2 then do; m=&m2; num=&n2; end;
    if nidx=3 then do; m=&m3; num=&n3; end;   
run;

data tmp;
    merge &data avg(keep=nidx estimate lower upper); by nidx;
    if nidx=0 then nidx=0.3;
run;

DATA anno; 
	set avg;
	xsys='2'; ysys='2';  color='black';
	if nidx^=0 then do;
	    X=nidx; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	end;
	else do;
        X=0.3; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	end;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	if nidx^=0 then do;
    	X=nidx-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
		X=nidx+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	  	X=nidx;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
	end;
	else do;
    	X=0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
		X=0.4; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	  	X=0.3;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
	end;
  	return;
run;

axis1 label=(" ") value=(h=1.2) split="*" order= (-1 to 4 by 1 ) minor=none offset=(0 in, 0 in);

%if &var=age %then %do;
axis2 label=(h=3 a=90 "&description") order=(0 to 40 by 2) value=( h=2) ;
title h=3 "Mean Age of Blood and 95% CI by NEC and pRBC Group";
%end;
         
%if &var=age1 %then %do;
axis2 label=(h=3 a=90 "&description") order=(0 to 16 by 1) value=(h=2) ;
title h=3 "Mean Irradition Storage Days and 95% CI by NEC ang pRBC Group";
%end;

%if &var=vol %then %do;
axis2 label=(h=3 a=90 "&description") order=(0 to 40 by 2) value=( h=2) ;
title h=3 "Mean Volume per Transfusion and 95% CI by NEC ang pRBC Group";
%end;

%if &var=hr %then %do;
axis2 label=(h=3 a=90 "&description") order=(0 to 8 by 1) value=( h=2) ;
title h=3 "Mean Length of pRBC Transfusion and 95% CI by NEC ang pRBC Group";
%end;

symbol1 i=none mode=exclude value=dot co=black cv=black h=2 w=1; 	 
symbol2 ci=blue value=circle h=0.4;         
symbol3 ci=red value=dot h=0.6;    


        		proc gplot data=tmp gout=gcx.graphs;

         			plot   estimate*nidx left_&var*nidx1 sub_&var*nidx1/overlay annotate= anno haxis = axis1 vaxis = axis2  nolegend;
          			format nidx group. estimate left_&var  sub_&var 5.0;
          			note h=1.5 m=(40pct, 2 pct) "*Dots in Red color-> pRBC(0-2 days) before NEC" ;
          		run;	

%if &var=age %then %do; title h=10 "Boxplots of the Median and IQR and Individual Data Values for Age of Blood (Days) by NEC and pRBC Group"; %end;
%if &var=age1 %then %do; title h=10 "Boxplots of the Median and IQR and Individual Data Values for Irradiation Storage Days by NEC and pRBC Group"; %end;
%if &var=vol %then %do; title h=10 "Boxplots of the Median and IQR and Individual Data Values for Volume per Transfusion by NEC and pRBC Group"; %end;
%if &var=hr %then %do; title h=10 "Boxplots of the Median and IQR and Individual Data Values for Length of pRBC Transfusion by NEC and pRBC Group"; %end;
                  
symbol1 interpol=boxt mode=exclude value=none co=black cv=black height=1 bwidth=5 width=2; 	 
symbol2 ci=blue value=circle h=0.4;         
symbol3 ci=red value=dot h=0.6;  
                                                      
        		proc gplot data=tmp gout=gcx.graphs;
         			plot   &var*nidx left_&var*nidx1 sub_&var*nidx1/overlay haxis = axis1 vaxis = axis2  nolegend;
          			format nidx group. &var 5.0;
          			note h=1.5 m=(40pct, 2 pct) "*Dot in red color-> Transfused <=48 hrs before NEC" ;
          		run;	   		
          		
         
%mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout=gcx.graphs  nofs; delete _ALL_; run;
  

		%make_plots(donor, age); run;
		%make_plots(donor, age1); run;
		%make_plots(donor, vol); run;
		%make_plots(donor, hr); run;
        *ods listing close;        

filename output 'age_irrad.eps';
goptions reset=all rotate = portrait device=pslepsfc gsfname=output gsfmode=replace noborder;


       	ods pdf file = "age_irrad.pdf" style=journal startpage=yes;
			proc greplay igout =gcx.graphs tc=sashelp.templt template=v2s /*whole*/ nofs;
			list igout;
			treplay 1:1 2:4; 
			treplay 1:2 2:5; 
			treplay 1:7 2:10; 
			treplay 1:8 2:11; 
		run;
		ods pdf close;
		
data avg_model;
    set avg_age 
        avg_age1(rename=(age1_Mean=age_mean age1_StdErr=age_StdErr age1_Median=age_Median  age1_Q1=age_Q1  age1_Q3=age_Q3 
        age1_Min=age_min age1_Max=age_max) in=B)
        avg_vol(rename=(vol_Mean=age_mean vol_StdErr=age_StdErr vol_Median=age_Median  vol_Q1=age_Q1  vol_Q3=age_Q3 
        vol_Min=age_min vol_Max=age_max) in=C)
        avg_hr(rename=( hr_Mean=age_mean hr_StdErr=age_StdErr hr_Median=age_Median  hr_Q1=age_Q1  hr_Q3=age_Q3 
        hr_Min=age_min hr_Max=age_max) in=D);
        if B then vname=2; else if C then vname=3; else if D then vname=4; else vname=1;
run;
		
proc sort; by nidx vname; run;

ods rtf file="age_blood_mixed.rtf" style=journal bodytitle;
proc report data=avg_model(where=(vname=1)) split="*" style=[just=center];
title "Age of Blood (Days)";
column  nidx  num m estimate sem lower upper age_Mean age_StdErr  age_Median age_Q1 age_Q3  age_Min age_max;
define nidx/"Group" group order format=nidx.;
*define vname/"Variable" group order format=vname.;
define num/"Num of LBWI";
define m/"Num of Tx";

define estimate/"Mean*(Mixed Model)" format=4.1;
define sem/"StdErr*(Mixed Model)" format=4.1;
define lower/"Lower*(Mixed Model)" format=4.1;
define upper/"Upper*(Mixed Model)" format=4.1;

define Age_mean/"Mean" ;
define Age_Stderr/"StdErr" ;
define Age_Median/"Median" ;
define Age_Q1/"Q1" ;
define Age_Q3/"Q3" ;
define Age_Min/"Min" ;
define Age_max/"Max" ;
run;

ods rtf startpage=no;

proc report data=avg_model(where=(vname=2)) split="*" style=[just=center];
title "Irradiation Storage Days";
column  nidx  num m estimate sem lower upper age_Mean age_StdErr  age_Median age_Q1 age_Q3  age_Min age_max;
define nidx/"Group" group order format=nidx.;
*define vname/"Variable" group order format=vname.;
define num/"Num of LBWI";
define m/"Num of Tx";

define estimate/"Mean*(Mixed Model)" format=4.1;
define sem/"StdErr*(Mixed Model)" format=4.1;
define lower/"Lower*(Mixed Model)" format=4.1;
define upper/"Upper*(Mixed Model)" format=4.1;

define Age_mean/"Mean" ;
define Age_Stderr/"StdErr" ;
define Age_Median/"Median" ;
define Age_Q1/"Q1" ;
define Age_Q3/"Q3" ;
define Age_Min/"Min" ;
define Age_max/"Max" ;
run;

proc report data=avg_model(where=(vname=3)) split="*" style=[just=center];
title "Volume per Transfusion (ml/kg)";
column  nidx  num m estimate sem lower upper age_Mean age_StdErr  age_Median age_Q1 age_Q3  age_Min age_max;
define nidx/"Group" group order format=nidx.;
*define vname/"Variable" group order format=vname.;
define num/"Num of LBWI";
define m/"Num of Tx";

define estimate/"Mean*(Mixed Model)" format=4.1;
define sem/"StdErr*(Mixed Model)" format=4.1;
define lower/"Lower*(Mixed Model)" format=4.1;
define upper/"Upper*(Mixed Model)" format=4.1;

define Age_mean/"Mean" ;
define Age_Stderr/"StdErr" ;
define Age_Median/"Median" ;
define Age_Q1/"Q1" ;
define Age_Q3/"Q3" ;
define Age_Min/"Min" ;
define Age_max/"Max" ;
run;

proc report data=avg_model(where=(vname=4)) split="*" style=[just=center];
title "Length of pRBC Transfusion (hr)";
column  nidx  num m estimate sem lower upper age_Mean age_StdErr  age_Median age_Q1 age_Q3  age_Min age_max;
define nidx/"Group" group order format=nidx.;
*define vname/"Variable" group order format=vname.;
define num/"Num of LBWI";
define m/"Num of Tx";

define estimate/"Mean*(Mixed Model)" format=4.1;
define sem/"StdErr*(Mixed Model)" format=4.1;
define lower/"Lower*(Mixed Model)" format=4.1;
define upper/"Upper*(Mixed Model)" format=4.1;

define Age_mean/"Mean" ;
define Age_Stderr/"StdErr" ;
define Age_Median/"Median" ;
define Age_Q1/"Q1" ;
define Age_Q3/"Q3" ;
define Age_Min/"Min" ;
define Age_max/"Max" ;
run;
ods rtf close;
