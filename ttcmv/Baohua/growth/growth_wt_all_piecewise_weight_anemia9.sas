options orientation=portrait nodate nonumber;
libname wbh "/ttcmv/sas/programs";	
libname dead "/ttcmv/sas/data";
%let pm=%sysfunc(byte(177)); 
%let ds=%sysfunc(byte(167)); 
%let one=%sysfunc(byte(185)); 
%let two=%sysfunc(byte(178)); 

proc means data=cmv.plate_012 median;
var SNAPTotalScore;
output out=tmp median(SNAPTotalScore)=median;
run;

data _null_;
    set tmp;
    call symput("median",compress(median));
run;


proc format; value tx 0="No"	1="Yes";
       
value item 0="--"
           1="Gender"
           2="Race(only for Black and White)"
           3="Center"
           4="Anemia(Hemoglobin<=9 g/dL) before 1st pRBC transfusion"
           5="Anemia(Hemoglobin<=8 g/dL) before 1st pRBC transfusion"
           6="Gestational Age Group"
           7="Gestational Age by Median"
           8="SNAP at Birth"
           9="Any breast milk fed before 1st pRBC transfusion"
           10="Caffeine used before 1st pRBC transfusion"
           ;
value Anemic 0="Not Anemic" 1="Anemic";
value snapg  0="SNAP Score <=Median(&median)" 1="SNAP Score >Median";

    value group 1="SGA"  2="AGA"  3="LGA";
value ttx 0="Pre-1st pRBC Tx" 1="Post-1st pRBC Tx";

run;

data rbc;
	set cmv.plate_031;
    keep id DateTransfusion Hb DateHbHct;
	rename DateHbHct=hbdate;
run;

proc sort nodupkey; by id DateTransfusion; run;

data hb;
	set cmv.plate_015(rename=(dfseq=day)) rbc(keep=id hbdate Hb); by id;
		if hbdate=. then hbdate=BloodCollectDate;
run;

proc sort; by id hbdate;run;

data hwl0;
	merge cmv.plate_008(keep=id MultipleBirth) 
    cmv.plate_006(keep=id gestage) 
	cmv.plate_012(keep=id SNAPTotalScore)
	hb dead.death(keep=id deathdate in=dead)          
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	center=floor(id/1000000);
	if SNAPTotalScore>&median then snapg=1;else snapg=0;
	
		if id=2002711 and dfseq=28 then weight=.;
		if id=3023511 and dfseq=21 then weight=.;
		
	if gestage>=28 then gesta=0; else gesta=1;
	if dead then death=1; else death=0;
	
	retain bw; 
	if day=1 then bw=Weight;
	
	keep id day Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth SNAPTotalScore
			LBWIDOB Gender  IsHispanic  Race RaceOther Hb HbDate Center snapg bw gestage gesta deathdate death;
	rename SNAPTotalScore=snap LBWIDOB=dob;
run;

data tmp;
    merge cmv.plate_006 cmv.comp_pat(in=A); by id;
	if gestage>=28 then gesta=0; else gesta=1;
    if A;
run;

proc freq; 
tables gesta;
run;

proc means data=tmp n mean median;
    var gestage;
    output out=gest median(gestage)=med;
run;

data _null_;
    set gest;
    call symput("gestage", compress(med));
run;

proc freq data=tmp; 
table gestage;
run;

proc sql;
	create table hwl1 as 
	select a.*
	from hwl0 as a, cmv.completedstudylist as b
	where a.id=b.id
	;
	
proc sql;
create table hwl as 
select a.* , b.* 
from hwl1 as a 
inner join cmv.olsen as b
on a.gender=b.gender and a.gestage=b.gestage;

proc sort nodupkey; by id day;run;

data tx;
	set cmv.plate_031(in=A keep=id hb DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0;
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	/*if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */

    if A;

	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
run;

proc sort nodupkey; by id dt; run;
data tx;
    set tx; by id dt;
    if first.id;
    rename hb=hb0;
run;


data feed;
    merge cmv.bm_collection(keep=id DFSEQ BreastMilkObtained) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob))
    tx; by id;
    retain age;
    if first.id then age=dt-dob;
    if dfseq<age or (dfseq=7 and age^=.) then feed=BreastMilkObtained;
    if feed=1;
run;
proc sort nodupkey; by id;run;


%macro conmed(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 9;
		center=floor(id/1000000);
		Dose=Dose&i;
		DoseNumber=DoseNumber&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		day=EndDate-StartDate;
		Indication=Indication&i;
		MedCode=MedCode&i;
		MedName=MedName&i;
		Unit=Unit&i;
		prn=prn&i;

		i=&i;

		output;
	%end;

		keep id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
run;
%mend;

%conmed(cmv.con_meds);quit;

data anemia;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=9) or 0<hb0<=9;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data anemia8;
    merge cmv.plate_015 tx ; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=8) or 0<hb0<=8;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data cafe;
    merge tmp(where=(medcode=5) keep=id medcode enddate) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob))
    tx; by id;
    if /*enddate-dob<=7 and*/ enddate<dt;
run;
proc sort nodupkey; by id;run;


data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt) feed(keep=id in=breast) cafe(keep=id in=cafe) anemia(keep=id in=A) anemia8(keep=id in=B); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	if breast then feed=1; else feed=0;
	if cafe then caffine=1;else caffine=0;
	if A then anemic=1; else anemic=0;
		if B then anemic8=1; else anemic8=0;
		
	if bw<weight_tenth then group=1;
	if weight_tenth<=bw<=weight_ninetieth then group=2;
	*if bw>weight_ninetieth then group=3;
	
	daytx0=weightDate-dt;
	
	age=dt-dob;

	if 50<=daytx0 then daytx=60;
	else if 35<=daytx0<50 then daytx=40;
	else if 32<=daytx0<35 then daytx=28;
	else if 6<=daytx0<32 then daytx=round(daytx0/7)*7;
	else if daytx0>1 then daytx=4;
	else if -1<=daytx0<=1 then daytx=daytx0;
	else if -6<daytx0<-1 then daytx=-4;
	else if -9<daytx0<=-6 then daytx=-7;
	else if -18<daytx0<=-9 then daytx=-14;
	else if -25<daytx0<=-18 then daytx=-21;
	else if -35<daytx0<=-25 then daytx=-28;
	else if  -50<daytx0<=-35 then daytx=-40;
	else if  daytx0<=-50 then daytx=-60;

	daytx1= daytx - .3 + .6*uniform(613);	
	
	wk=day/7;
	if tx then output hwl_tx;
	if not tx then output hwl_no_tx;
	output hwl;
run;

proc freq data=hwl_tx(where=(day=1));
    tables anemic8*death;
        tables anemic*death;
run;

data  hwl_tx;
	set hwl_tx(drop=day);
	if daytx0<=0 then tx=0; else tx=1;
	rename daytx0=day;
	d1=min(daytx0,0);
	d2=max(daytx0,0);
	if daytx0=. then delete;
run;

proc sort data=hwl_tx; by anemic id hbdate; run;


proc sort data=hwl_tx nodupkey out=at; by anemic tx id;run;
proc freq data=at; 
table anemic*tx;
ods output crosstabfreqs=wbh;
run;

proc freq data=at; 
by anemic;
table tx*death;
ods output crosstabfreqs=tmp;
run;

data _null_;
    set wbh;
    if anemic=1 and tx=0 then call symput("a0", compress(frequency));
        if anemic=1 and tx=1 then call symput("a1", compress(frequency));
            if anemic=0 and tx=0 then call symput("na0", compress(frequency));
                if anemic=0 and tx=1 then call symput("na1", compress(frequency));
run;

data hb_anemia;
    set hwl_tx;
    if 0<hb<=9;
    keep anemic tx id dt tx death  hbdate hb;
run;

proc sort nodupkey; by id hbdate hb; run;

%macro make_plots(data=lab); 

%let y1= 0; %let y4= 0; %let y7= 0; %let y14= 0; %let y21= 0; %let y28= 0; %let y40= 0; %let y60= 0; %let y0=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28= 0; %let n40= 0; %let n60= 0; %let n0=0;

data tmp;
    set &data;
    *where day<=0;
run;

%let x=1;
%do %while (&x <2);
	
	%if &x = 1  %then %do; 	%let variable =weight;    	        %let description =  'Weight(g)'; 
																				%let order=(400 to 3000 by 200);	  %end;   																				

* get 'n' at each day;
		proc means data=tmp noprint;
				by anemic;
    			class daytx;
    			var &variable;
     			output out = sizes_&data n(&variable) = n;
  		run;
  		
		data sizes_&data;
			set sizes_&data;	
			if daytx=. then delete;
		run;

	* populate 'n' annotation variables ;
    		data _null_;
    			set sizes_&data;
     			if anemic=0 and daytx=-40 then call symput( "n40",  compress(_freq_));
     			if anemic=1 and daytx=-40 then call symput( "y40",  compress(_freq_));
     			if anemic=0 and daytx=-28 then call symput( "n28",  compress(_freq_));
     			if anemic=1 and daytx=-28 then call symput( "y28",  compress(_freq_));
     			if anemic=0 and daytx=-21 then call symput( "n21",  compress(_freq_));
     			if anemic=1 and daytx=-21 then call symput( "y21",  compress(_freq_));
     			if anemic=0 and daytx=-14 then call symput( "n14",  compress(_freq_));
     			if anemic=1 and daytx=-14 then call symput( "y14",  compress(_freq_));
     			if anemic=0 and daytx=-7  then call symput( "n7",   compress(_freq_));
     			if anemic=1 and daytx=-7  then call symput( "y7",   compress(_freq_));
     			if anemic=0 and daytx=-4  then call symput( "n4",   compress(_freq_));
     			if anemic=1 and daytx=-4  then call symput( "y4",   compress(_freq_));
     			if anemic=0 and daytx=0   then call symput( "n0",   compress(_freq_));
     			if anemic=1 and daytx=0   then call symput( "y0",   compress(_freq_));
     	   run; 
     		
	proc format; 
	 	value y_axis   
			-41=" " -40="-40(&y40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28(&y28)" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21(&y21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14(&y14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7(&y7)" -6=" " - 5=" "  -4="-4(&y4)"  -3=" "   
			 -2=" "  -1=" " 0= "0(&y0)" 1=" ";
			   

	 	value n_axis   
			-41=" " -40="-40(&n40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28(&n28)" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21(&n21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14(&n14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7(&n7)" -6=" " - 5=" "  -4="-4(&n4)"  -3=" "   
			-2=" "  -1=" " 0= "0(&n0)" 1=" ";     
    run;
    
     /* Set up Symbol for Data Points */
symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=100; 
         
    axis1 	label=(h=3 'Days before 1st pRBC Transfusion (days)' ) value=(h=3) split="*" order= (-40 to 0 by 5) minor=none offset=(0 in, 0 in);
    axis3 	label=(h=3 'Days After 1st pRBC Transfusion (days)' ) value=(h=3) split="*" order= (0 to 65 by 5) minor=none offset=(0 in, 0 in);
    axis2 	label=(h=3 a=90 &description) value=(h=2) order=&order ;

                  
	proc gplot data=tmp gout=wbh.graphs;
		title h=3.5 justify=center &description, "Anemic (Hb<=9 g/dL) (n=&a0)";  
		note h=2 m=(2pct, 8.5 pct) "Days:" ;
		where anemic=1 and day<=0; 
		plot &variable*day=id/ overlay haxis = axis1 vaxis = axis2  nolegend vref=9 lvref=20 /*href=0 lhref=20*/; 
		format &variable 5.0;
	run;
	
	proc gplot data=tmp gout=wbh.graphs;
		title h=3.5 justify=center &description, "Anemic (Hb<=9 g/dL) (n=&a1)";  
		note h=2 m=(2pct, 8.5 pct) "Days:" ;
		where anemic=1 and day>0; 
		plot &variable*day=id/ overlay haxis = axis3 vaxis = axis2  nolegend vref=9 lvref=20 /*href=0 lhref=20*/; 
		format &variable 5.0;
	run;

	proc gplot data=tmp gout=wbh.graphs;
		title h=3.5 justify=center &description, "Not Anemic (Hb>9 g/dL) (n=&na0)";  
		note h=2 m=(2pct, 8.5 pct) "Days:" ;
		where anemic=0 and day<=0; 
		plot &variable*day=id/ overlay haxis = axis1 vaxis = axis2  nolegend vref=9 lvref=20 /*href=0 lhref=20*/; 
		format &variable 5.0;
	run;
	
	proc gplot data=tmp gout=wbh.graphs;
		title h=3.5 justify=center &description, "Not Anemic  (Hb>9 g/dL)(n=&na1)";  
		note h=2 m=(2pct, 8.5 pct) "Days:" ;
		where anemic=0 and day>=0; 
		plot &variable*day=id/ overlay haxis = axis3 vaxis = axis2  nolegend vref=9 lvref=20 /*href=0 lhref=20*/; 
		format &variable 5.0;
	run;
	
	%let x = &x + 1;	
	%end;
%mend make_plots;

      
goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
				colors = (black red) ftitle="Times" ftext="Times"  fby ="Times" hby = 3;

proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;        	        	
%make_plots(data=hwl_tx); run;


options orientation=landscape;
goptions reset=all; 			           			        
* clear graph catalog ;

  	ods pdf file = "anemia9_weight.pdf" startpage=no;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=l2r2s /*whole*/ nofs;
						list igout;
						treplay 1:1 2:3 3:2 4:4; 
					run;
ods pdf close;
