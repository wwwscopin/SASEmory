
options orientation=portrait nodate nofmterr nonumber;
libname wbh "/ttcmv/sas/data";	
libname gcx "/ttcmv/sas/programs";	

%let pm=%sysfunc(byte(177)); 
%let jing=%sysfunc(byte(35)); 
%let dollar=%sysfunc(byte(36)); 
%let link=%sysfunc(byte(38)); 
%let csign=%sysfunc(byte(162)); 
%let circ=%sysfunc(byte(164)); 
%let ds=%sysfunc(byte(167)); 
%let sign=%sysfunc(byte(182)); 
%let rsign=%sysfunc(byte(174)); 
%let blank=   ;

proc format;
    value group 1="SGA"  2="AGA"  3="LGA";
	value gw 1="<=750" 2="751-1000" 3="1001-1250" 4="1251-1500" 9="";
	value yn 1="Yes" 0="No";
	value tx 0="No Tx" 1="Before Tx" 2="After Tx";
	value feed 1="Bottle Feeding" 0="Breast Feeding";
	value item 
        0="Number"
        1="Gestational age (wk)*"
        2="SNAP score@"
        3="Male"
		4="White"
		5="SGA&circ"
		6="Survival"
		7="BPD"
		8="Sepsis&ds"
		9="Severe IVH&sign"
		10="NEC"
		11="Surgical PDA&link"
		12="ROP&rsign"
		13="Ever pRBC Transfused "
		14="Always Formula Fed"
	;
	
	value ref 
        0="Patient Number(%)"
        1="Gestational age(wk)$"
        2="SNAP score$"
        3="Male"
		4="White"
        5="#pRBC Transfusions"
        6="- 1"
                7="- 2"
                        8="- 3"
                                9="- >3";
 	;
run;

data hwl0;
        merge cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	      cmv.plate_006(keep=id gestage) 
	      cmv.plate_008(keep=id MultipleBirth)
	      cmv.plate_015
	      cmv.plate_012(keep=id SNAPTotalScore rename=(SNAPTotalScore=snap))
	      cmv.bpd(where=(IsOxygenDOL28=1) keep=id IsOxygenDOL28 in=A)
	      cmv.infection_p1(where=(CulturePositive=1) keep=id CulturePositive in=B)
	      cmv.ivh_image(where=(LeftIVHGrade in(3,4) or RightIVHGrade in(3,4)) keep=id LeftIVHGrade RightIVHGrade in=C)
	      cmv.nec_p1(keep=id in=D)
	      cmv.pda(where=(PDASurgery=1) keep=id PDASurgery in=P)
   	      cmv.plate_078(where=(LeftRetinopathyStage>2 or RightRetinopathyStage>2) keep=id LeftRetinopathyStage RightRetinopathyStage in=R)
          wbh.feed(where=(gp=4) keep=id gp in=E)
	; 
	by id;
	
	retain bw; 
	if DFSEQ=1 then bw=Weight;
	if DFSEQ=0 then delete;
	*if 501<bw<=750 then gw=1;
	if bw<=750 then gw=1;
	if 750<bw<=1000 then gw=2;
	if 1000<bw<=1250 then gw=3;
	if 1250<bw<=1500 then gw=4;

	if A then bpd=1; else bpd=0;
	if B then sepsis=1; else sepsis=0;
	if C then ivh=1; else ivh=0;
	if D then nec=1; else nec=0;
	if E then feed=1; else feed=0;
	if P then pda=1; else pda=0;
	if R then ROP=1; else rop=0;

	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	
	if id=2002711 and dfseq=28 then weight=.;
		if id=3023511 and dfseq=21 then weight=.;
			if id=1003511 and dfseq=40 then HtLength=.;
						if id=1009211 and dfseq=21 then HtLength=.;
									if id=2005111 and dfseq=28 then HtLength=.;
												if id=2007911 and dfseq=14 then HtLength=.;
															if id=2008511 and dfseq in(4,7) then HtLength=.;
	if id=1000311 and dfseq=21 then HeadCircum=.;
	if id=1003511 and dfseq=40 then HeadCircum=.;
	if id=1009211 and dfseq=21 then HeadCircum=.;
	if id=2002411 and dfseq=28 then HeadCircum=.;
	if id=2002711 and dfseq=4 then HeadCircum=.;
	if id=2002811 and dfseq=14 then HeadCircum=.;
	if id=2005111 and dfseq in(4,7) then HeadCircum=.;
	if id=2005311 and dfseq=14 then HeadCircum=.;
	if id=2008011 and dfseq=21 then HeadCircum=.;
	if id=3010921 and dfseq=21 then HeadCircum=.;
	if id=3012511 and dfseq=40 then HeadCircum=.;
	if id=3018511 and dfseq=40 then HeadCircum=.;
	
	dayw=weightdate-lbwidob;
	dayh=headdate-lbwidob;	
	dayl=Heightdate-lbwidob;
	
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate LeftIVHGrade RightIVHGrade 
	MultipleBirth gender LBWIDOB race gestage bw gw bpd sepsis ivh nec feed snap pda rop dayw dayh dayl;
	rename DFSEQ=dday LBWIDOB=dob ;
	*if not MultipleBirth and gender=1;
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

data hwl;
	merge hwl(in=A) wbh.death(keep=id in=B); by id;
	if bw<weight_tenth then group=1;
	if weight_tenth<=bw<=weight_ninetieth then group=2;
	if bw>weight_ninetieth then group=3;
	if B then death=1; else death=0;
	if A;
	if group=2 and bpd=0 and sepsis=0 and ivh=0 and nec=0 and pda=0 and rop=0 then ref=1; else ref=0; 
run;

data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	/*if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0;
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */
	
    if dt=. then delete;
	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
run;

proc sort nodupkey; by id dt; run;

data tx_num;
    set tx; by id;
    retain num;
    if first.id then num=0;
    num=num+1;
    idx=num;
    if num>3 then idx=4;
    if last.id;
    keep id tx num idx;
run;

proc sort data=tx nodupkey; by id dt; run;

data tx;
    merge tx tx_num; by id;
    if first.id;
run;

data hwl hwl_base;
	merge hwl(in=hwl) tx(in=trans keep=id dt idx); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	
	daytx=WeightDate-dt;
	
    gtx=tx;

	format gw gw. group group. feed feed. death bpd sepsis ivh nec yn. tx tx.;
        
        if dday=1  then t=1;
        if dday=4  then t=2;
        if dday=7  then t=3;
        if dday=14 then t=4;
        if dday=21 then t=5;
        if dday=28 then t=6;
        if dday=40 then t=7;
        if dday=60 then t=8;
        
        st1=min(dayw,7);
        st2=max(0,dayw-7);
        
 
	if dday=1 then output hwl_base;
	output hwl;
run;

data hwl;
    set hwl(where=(tx=0) in=A) hwl(where=(daytx<0 and daytx^=.) in=B) hwl(where=(daytx>=0) in=C);
    if A then tx=0;
    if B then tx=1; 
    if C then tx=2;
run;

proc freq data=hwl_base; tables ref*idx;run;
proc sort data=hwl_base nodupkey; by id gw group death bpd sepsis ivh nec;run;
proc freq data=hwl_base; tables ref*gw;run;

data _null_;
	set hwl_base;
	call symput("n", compress(_n_));
run;
%put &n;

proc freq data=hwl_base;
table tx;
ods ouput onewayfreqs=tmp;
run;

data _null_;
	set tmp;
    if tx=0 then call symput("t0", compress(frequency));
        if tx=1 then call symput("t1", compress(frequency));
run;

*******************************************************************************;
%macro tab(data, out, varlist);

	data &out;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	%if &var=death %then %let idx=0;
	%else %if &var=race %then %let idx=3;
	%else %let idx=1;

	proc freq data=&data;
		tables &var*gw;
		ods output Freq.Table1.CrossTabFreqs=tmp;
	run;
	
	data tmp;      
	       set tmp;
	       where &var=&idx and gw^=.;
	       nf=compress(frequency||"("||put(colpercent,5.1)||"%)");
	       keep &var gw frequency nf colpercent;
	run;
	
	proc transpose data=tmp out=tab0&i; var nf; run;

	data tab&i;
		set tab0&i;
		item=%eval(&i+2);
		keep item col1-col4;
		rename col1=gw1 col2=gw2 col3=gw3 col4=gw4;
	run; 

	data &out;
		set &out tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;

%mend tab;

*ods trace off;
%let varlist=gender race group death bpd sepsis ivh nec pda rop gtx feed;
%tab(hwl_base, tab, &varlist);


%macro num(data, out, varlist);

	data &out;
		if 1=1 then delete;
	run;

%let i=1;
%let var=%scan(&varlist, &i);

%do %while(&var NE );

proc means data=&data;
	class gw;
	var &var;
	ods output means.summary=tmp(keep=gw NObs &var._mean &var._StdDev);
run;

data tab0;
	set tmp;
	&var=compress(put(&var._mean,4.1)||"&pm"||put(&var._stddev,4.1));
	keep gw nobs &var;
run;

proc transpose data=tab0 out=tab1; var nobs &var; run;

data gnum&i;
	set tab1;
	rename col1=gw1 col2=gw2 col3=gw3 col4=gw4;
	
	%if &var=gestage %then %do;	if lowcase(_name_)='nobs' then item=0; %end;    
    %else %do;	if lowcase(_name_)='nobs' then delete;  %end;      

   	if lowcase(_name_)="&var" then item=&i;              
   	keep item col1-col4;
run;

    data &out;
		set &out gnum&i;
	run; 
	
	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
    %end;
%mend num;

%let varlist=gestage snap;
%num(hwl_base, ga, &varlist);

data _null_;
    set ga(where=(item=0));
    call symput("n1", compress(gw1)); 
    call symput("n2", compress(gw2)); 
    call symput("n3", compress(gw3)); 
    call symput("n4", compress(gw4)); 
run;

%let m=%eval(&n1+&n2+&n3+&n4);

proc format;
	value ggw 1="<=750(&n1)" 2="751-1000(&n2)" 3="1001-1250(&n3)" 4="1251-1500(&n4)" 9="All(&m)";
run;

data tab1;
    length gw1-gw4 $10;
	set ga tab;
	format item item.;
run;

ods rtf file="tab1.rtf" style=journal bodytitle;
proc report nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];
title "Infant Characteristics (n=&n)";

column item ("--------------------------------- Birth Weight Interval (g) --------------------------------" gw1-gw4);

define item/"." style(column)=[just=left] style(header)=[just=left];
define gw1/"<=750"     style(column)=[cellwidth=1.25in];
define gw2/"751-1000"  style(column)=[cellwidth=1.25in];
define gw3/"1001-1250" style(column)=[cellwidth=1.25in];
define gw4/"1251-1500" style(column)=[cellwidth=1.25in];

*break after item/ dol dul skip;
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=10 pt}
Abbreviation: SGA, small-for-gestational age; IVH, intraventricular hemorrhage; NEC, nectrotizing enterocolitis.
^n * Mean &pm SD.
^n @ SNAP score at birth.
^n &circ Birth weight<10^{super th} percentile according to Olsen et al.(Pediatrics 2010,125:e214-e224).
^n &ds Sepsis: Positive blood culture.
^n &sign Grade 3-4 IVH.
^n &link Surgical PDA
^n &rsign Stage 3-5 ROP.
";

ods rtf close;

********************************************************************************;
data hwl_ref;
        set hwl_base;
        where ref=1;
run;

data _null_;
        set hwl_ref;
        call symput("nref",compress(_n_));
run;

data hwl_pop;
        set hwl_base;
        where ref=0;
run;

data _null_;
        set hwl_pop;
        call symput("npop",compress(_n_));
run;

%let varlist=gender race;
%tab(hwl_ref, ref, &varlist);
%tab(hwl_pop, pop, &varlist);

%let varlist=gestage snap;
%num(hwl_ref, ga_ref, &varlist);
%num(hwl_pop, ga_pop, &varlist);

data _null_;
    set ga_ref(where=(item=0));
    call symput("m1", compress(gw1)); 
    call symput("m2", compress(gw2)); 
    call symput("m3", compress(gw3)); 
    call symput("m4", compress(gw4)); 
run;

%macro tx(data, out);
proc freq data=hwl_&data;
tables gw*idx;
ods output freq.table1.crosstabfreqs=tmp;
run;

data tmp1;
    set tmp;
    where gw^=. and idx^=.;
    keep gw idx frequency;
    rename frequency=n;
run;
proc sort; by idx;run;
proc transpose out=tmp2; var n; by idx;run;

data &data._tx;
    set tmp2;
       if _n_=1 then item=5; output;
       %if &data=ref %then %do;
	   nf1=col1/&m1*100; gw1=compress(col1||"("||put(nf1,4.1)||"%)"); 
   	   nf2=col2/&m2*100; gw2=compress(col2||"("||put(nf2,4.1)||"%)"); 
   	   nf3=col3/&m3*100; gw3=compress(col3||"("||put(nf3,4.1)||"%)"); 
  	   nf4=col4/&m4*100; gw4=compress(col4||"("||put(nf4,4.1)||"%)"); 
  	   %end;
  	   
  	   %if &data=pop %then %do;
	   nf1=col1/%eval(&n1-&m1)*100; gw1=compress(col1||"("||put(nf1,4.1)||"%)"); 
   	   nf2=col2/%eval(&n2-&m2)*100; gw2=compress(col2||"("||put(nf2,4.1)||"%)"); 
   	   nf3=col3/%eval(&n3-&m3)*100; gw3=compress(col3||"("||put(nf3,4.1)||"%)"); 
  	   nf4=col4/%eval(&n4-&m4)*100; gw4=compress(col4||"("||put(nf4,4.1)||"%)"); 
  	   %end;
  	   
    item=idx+5;     output;
    keep idx gw1-gw4 item;
run;

data &out;
	set ga_&data &data &data._tx(where=(item^=.));
	if item=0 then do;
       nf1=gw1/&n1*100; gw1=compress(gw1||"("||put(nf1,4.1)||"%)"); 
   	   nf2=gw2/&n2*100; gw2=compress(gw2||"("||put(nf2,4.1)||"%)"); 
   	   nf3=gw3/&n3*100; gw3=compress(gw3||"("||put(nf3,4.1)||"%)"); 
  	   nf4=gw4/&n4*100; gw4=compress(gw4||"("||put(nf4,4.1)||"%)"); 
	end;
	format item ref.;
run;
%mend tx;

%tx(ref, tab4);
%tx(pop, tab41);

ods rtf file="tab4.rtf" style=journal bodytitle startpage=no;

proc report data=tab4 nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];
title "Reference Population* Characteristics (n=&nref)";

column item ("--------------------------------- Birth Weight Interval (g) --------------------------------" gw1-gw4);

define item/"." style(column)=[just=left] style(header)=[just=left];
define gw1/"<=750*(n=&n1)"     style(column)=[cellwidth=1.25in];
define gw2/"751-1000*(n=&n2)"  style(column)=[cellwidth=1.25in];
define gw3/"1001-1250*(n=&n3)" style(column)=[cellwidth=1.25in];
define gw4/"1251-1500*(n=&n4)" style(column)=[cellwidth=1.25in];

run;

proc report data=tab41 nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];
title "Major Morbidity Population Characteristics (n=&npop)";

column item ("--------------------------------- Birth Weight Interval (g) --------------------------------" gw1-gw4);

define item/"." style(column)=[just=left] style(header)=[just=left];
define gw1/"<=750*(n=&n1)"     style(column)=[cellwidth=1.25in];
define gw2/"751-1000*(n=&n2)"  style(column)=[cellwidth=1.25in];
define gw3/"1001-1250*(n=&n3)" style(column)=[cellwidth=1.25in];
define gw4/"1251-1500*(n=&n4)" style(column)=[cellwidth=1.25in];

run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=1.25in RIGHTMARGIN=1.25in}
* The reference population was defined as infants who were appropriate-for-gestational age and survived to discharge without developing BPD, severe intraventricular hemorrhage, necrotizing enterocolitis, surgical PDA, ROP(Stage 3-5), or sepsis.
^n $ Mean &pm SD.";

ods rtf close;


proc sort data=hwl nodupkey; by id dday weight;run;

****************************************************;
** For Local Use;
%macro est(daylist,var,gp);
data &var&gp;
    %let i = 1;
	%let dday = %scan(&daylist, &i);
	%do %while ( &day NE );
         
        %do j=1 %to 4;
            gw=&j; dday=&dday; 
            
            %if &var=weight or &var=ref or &var=group  %then %do;
                int=%sysevalf(&int+&&int&j);
                s1=%sysevalf(&s1+&&sta&j);
                s2=%sysevalf(&s2+&&stb&j);
                %if &dday<=7 %then %do; 
                    est=%sysevalf(&int+&&int&j+(&s1+&&sta&j)*&dday); output;
                %end;
                %else %if &dday>7 %then %do; 
                    est=%sysevalf(&int+&&int&j+(&s1+&&sta&j)*7+(&s2+&&stb&j)*(&dday-7)); output;
                %end;
             %end;
            %else %do;
                int=%sysevalf(&int+&&int&j);
                s2=%sysevalf(&s2+&&stb&j);
                est=%sysevalf(&int+&&int&j+(&s2+&&stb&j)*&dday); output;
            %end;
        %end;
        
	%let i= %eval(&i+1);
	%let day = %scan(&daylist,&i);
	%end;     
	keep dday gw int s1 s2 est;           
run;
%mend est;

proc means data=hwl ;
    	class tx dday;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or dday=. then delete;
run;

%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if tx=0 and dday=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and dday=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and dday=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and dday=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=60 then call symput( "n60",  compress(put(num_obs, 3.0)));

	if tx=1 and dday=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if tx=1 and dday=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if tx=1 and dday=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if tx=1 and dday=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=60 then call symput( "b60",  compress(put(num_obs, 3.0)));

	if tx=2 and dday=1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if tx=2 and dday=4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if tx=2 and dday=7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if tx=2 and dday=14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=60 then call symput( "a60",  compress(put(num_obs, 3.0)));
run;

%put &n1;
%put &b1;
%put &a1;

proc format;

value dt -1=" "  
 0=" " 1="1*(&n1)*(&b1)*(&a1)"  2=" " 3=" " 4 = "4*(&n4)*(&b4)*(&a4)" 5=" " 6=" " 7="7*(&n7)*(&b7)*(&a7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&n14)*(&b14)*(&a14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&n21)*(&b21)*(&a21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&n28)*(&b28)*(&a28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&n40)*-*(&a40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&n60)*-*(&a60)" ;
 
 value dd  0=" " 1="1"  2=" " 3=" " 4 = "4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 60 = "60" ;

run;

proc sort data=hwl; by id tx t;run;
*****************************************************;
proc mixed data=hwl /*method=ml*/ ORDER=internal;
        *class id tx t; *this is for repeated statement;
        class id tx; *this is for random statement;
        model weight=tx st1 st2 st1*tx st2*tx/s chisq;
       	random int st1 st2/type=un subject=id;
        *repeated t/type=un subject=id r;
    
    estimate "No-Tx, intercept" int 1 tx 1 0 0/cl;
	estimate "No-Tx, Day1"   int 1 tx 1 0 0 st1 1   st1*tx 1  0 0;
	estimate "No-Tx, Day4"   int 1 tx 1 0 0 st1 4   st1*tx 4  0 0;
	estimate "No-Tx, Day7"   int 1 tx 1 0 0 st1 7   st1*tx 7  0 0;
	estimate "No-Tx, Day14"  int 1 tx 1 0 0 st2 7   st2*tx 7  0 0;
	estimate "No-Tx, Day21"  int 1 tx 1 0 0 st2 14  st2*tx 14 0 0;
	estimate "No-Tx, Day28"  int 1 tx 1 0 0 st2 21  st2*tx 21 0 0;
	estimate "No-Tx, Day40"  int 1 tx 1 0 0 st2 33  st2*tx 33 0 0;
	estimate "No-Tx, Day60"  int 1 tx 1 0 0 st2 53  st2*tx 53 0 0/e;

	estimate "Before, intercept" int 1 tx 0 1 0/cl;
	estimate "Before, Day1"   int 1 tx 0 1 0 st1 1   st1*tx 0 1  0;
	estimate "Before, Day4"   int 1 tx 0 1 0 st1 4   st1*tx 0 4  0;
	estimate "Before, Day7"   int 1 tx 0 1 0 st1 7   st1*tx 0 7  0;
	estimate "Before, Day14"  int 1 tx 0 1 0 st2 7   st2*tx 0 7 0;
	estimate "Before, Day21"  int 1 tx 0 1 0 st2 14  st2*tx 0 14 0;
	estimate "Before, Day28"  int 1 tx 0 1 0 st2 21  st2*tx 0 21 0;
	estimate "Before, Day40"  int 1 tx 0 1 0 st2 33  st2*tx 0 33 0;
	estimate "Before, Day60"  int 1 tx 0 1 0 st2 53  st2*tx 0 53 0/e;

	estimate "After, intercept" int 1 tx 0 0 1 /cl;
	estimate "After, Day1"   int 1 tx 0 0 1 st1 1   st1*tx 0 0 1  ;
	estimate "After, Day4"   int 1 tx 0 0 1 st1 4   st1*tx 0 0 4  ;
	estimate "After, Day7"   int 1 tx 0 0 1 st1 7   st1*tx 0 0 7  ;
	estimate "After, Day14"  int 1 tx 0 0 1 st2 7   st2*tx 0 0 7 ;
	estimate "After, Day21"  int 1 tx 0 0 1 st2 14  st2*tx 0 0 14 ;
	estimate "After, Day28"  int 1 tx 0 0 1 st2 21  st2*tx 0 0 21 ;
	estimate "After, Day40"  int 1 tx 0 0 1 st2 33  st2*tx 0 0 33 ;
	estimate "After, Day60"  int 1 tx 0 0 1 st2 53  st2*tx 0 0 53 /e;

        ods output Mixed.SolutionF=slope;
		ods output Mixed.Estimates=estimate_wt;
run;

data slope;
    set slope;
    est=estimate;
    stderr=stderr;
    if _n_=6 then call symput("s", put(est,7.4));
run;

data _null_;
    set slope;
   	if _n_=6 then call symputx("s2", put(est,4.1)||"("||compress(put(stderr,3.1))||")");
	if _n_=11 then do; 
        call symputx("s1", put(est+&s,4.1)||"("||compress(put(stderr,3.1))||")");
	end;
	   	
	if _n_=10 then do; 
        call symputx("s0", put(est+&s,4.1)||"("||compress(put(stderr,3.1))||")");
	end;
run;


data line_wt;
	set estimate_wt(firstobs=1);
	if find(label,"No-Tx", 't') then tx=0; 
		else if find(label,"Before")  then tx=1; else tx=2;
	if find(label,"intercept") then day=0; 
   	else dday= compress(scanq(label,2),'Day', ",")+0;
	dday1=dday+0.05;
	dday2=dday+0.25;
	
    *if dday>0;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	*if estimate<0 then delete;
	
	keep tx dday dday1 dday2 estimate upper lower;
run;


DATA anno0; 
	set line_wt;
	where tx=0;
	xsys='2'; ysys='2';  color='green';
	X=dday; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=dday-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=dday+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=dday;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set line_wt;
	where tx=1;
	xsys='2'; ysys='2';  color='blue';
	X=dday1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=dday1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=dday1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=dday1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno2; 
	set line_wt;
	where tx=2;
	xsys='2'; ysys='2';  color='red';
	X=dday2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=dday2-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=dday2+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=dday2;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno;
	set anno0 anno1(in=B) anno2;
	if B and day>28 then delete;
run;

data wt;
	merge line_wt(where=(tx=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
			line_wt(where=(tx=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
			line_wt(where=(tx=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)); 
	by dday;
	if  dday>28 then do; estimate1=.; lower1=.; upper1=.; end;
run;


goptions reset=all  rotate=landscape device=jpeg  gunit=pct noborder cback=white
colors = (black red green blue)  ftext="Times" ftitle="Times"  hby = 3;

symbol1 interpol=spline mode=exclude value=circle co=green cv=green height=2 width=1;
symbol2 i=spline ci=blue value=dot co=blue cv=blue h=2 w=1;
symbol3 i=spline ci=red value=triangle co=red cv=red h=2 w=1;


axis1 	label=(h=2.5 "Age of LBWIs (days)" ) split="*"	value=(h=1.25)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
axis2 	label=(h=2.5 a=90 "Weight(g)") value=(h=2) order= (600 to 2800 by 100) offset=(.25 in, .25 in) minor=(number=1);
 
title1 	height=3 "All LBWIs Weight vs Age";
title2 	height=2.5  "(With pRBC Transfusion=&t1, Without pRBC Transfusion=&t0)";
*title2 	height=3 "Test of equal slopes, p=&p";

%put &yes;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2 "Without pRBC Transfusion, Slope(SE)=&s0 g/day" "Before 1st pRBC Transfusion, Slope(SE)=&s1 g/day" 
"After 1st pRBC Transfusion, Slope(SE)=&s2 g/day") offset=(0.2in, -0.4 in) frame;


proc greplay igout=gcx.graphs  nofs; delete _ALL_; run;

proc gplot data= wt gout=gcx.graphs;
	plot estimate0*dday estimate1*dday1 estimate2*dday2/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
	note h=1 m=(7pct, 10.5 pct) "Day :" ;
	note h=1 m=(7pct, 9.25 pct) "(#No tx)" ;
	note h=1 m=(7pct, 8.25 pct) "(#Before tx)" ;
	note h=1 m=(7pct, 7.25 pct) "(#After tx)" ;

	format estimate0 estimate1 estimate2 4.0 day dt.;
run;

options orientation=landscape;
ods pdf file = "growth_all.pdf";
proc greplay igout = gcx.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:1;
run;
ods pdf close;


proc means data=hwl(where=(dday>7));
var weight;
ods output means.summary=avg_tx0;
run;


data _null_;
set avg_tx0;
call symput("wt", put(weight_mean, 7.2));
run;

proc mixed data=hwl ORDER=internal;
        class id; *this is for random statement;
        model weight=st1 st2/s chisq;
       	random int st1 st2/type=un subject=id;
        ods output Mixed.SolutionF=cef_weight;
run;   

data _null_;
set cef_weight;
if _n_=3 then call symput("wt9", put(Estimate, 7.2));
run;
       
proc mixed data=hwl ORDER=internal;
        class id; *this is for random statement;
        model HeadCircum=dayh/s chisq;
       	random int dayh/type=un subject=id;
        ods output Mixed.SolutionF=cef_hc;
run;   

data _null_;
set cef_hc;
if _n_=2 then call symput("hc9", put(Estimate, 7.4));
run;   
    	
proc mixed data=hwl ORDER=internal;
        class id; *this is for random statement;
        model HtLength=dayl/s chisq;
       	random int dayl/type=un subject=id;
        ods output Mixed.SolutionF=cef_length;
run;

data _null_;
set cef_length;
if _n_=2 then call symput("hl9", put(Estimate, 7.4));
run; 
 
*#####################################################################################;
%macro slope(var=weight,tx=0);

%if &tx=1 %then %do; data tmp;  set hwl(where=(tx=&tx and dday<=28)); run; %end;
%else %if &tx=9 %then %do; data tmp;  set hwl; run; %end;
%else %do; data tmp; set hwl(where=(tx=&tx)); run; %end;

proc means data=hwl(where=(dday>7));
class tx;
var weight;
ods output means.summary=avg_tx;
run;

data _null_;
    set avg_tx;
    if tx=0 then call symput("wt0", put(weight_mean,7.2));
     if tx=1 then call symput("wt1", put(weight_mean,7.2));
      if tx=2 then call symput("wt2", put(weight_mean,7.2));
run;

proc mixed data=hwl ORDER=internal;
        class id tx; *this is for random statement;
        %if &var=weight %then %do;
            model &var=tx st1 st2 st1*tx st2*tx/s chisq;
           	random int st1 st2/type=un subject=id;
        %end;
        
        %else %if &var=HeadCircum %then %do;
            model &var=tx dayh dayh*tx/s chisq;
           	random int dayh/type=un subject=id;
        %end;
        
        %else %if &var=HtLength %then %do;
            model &var=tx dayl dayl*tx/s chisq;
           	random int dayl/type=un subject=id;
        %end;
        ods output Mixed.SolutionF=cef_&var.0;
run;

data cef_&var.1;
    set cef_&var.0;
    %if &var=weight %then %do; if _n_ in(6,10,11,12) then output; %end;
        %else %do; if _n_ in(5,6,7,8) then output; %end;
run;

proc transpose out=cef_&var; var estimate;run;

data cef_&var;
    set cef_&var;
    %if &var=weight %then %do;
    wt0=col1+col2; gwt0=wt0/&wt0*1000;
    wt1=col1+col3; gwt1=wt1/&wt1*1000;
    wt2=col1;      gwt2=wt2/&wt2*1000;
    wt9=&wt9;    gwt9=&wt9/&wt*1000;
    %end;
    
    %if &var=HeadCircum %then %do;
    hc0=(col1+col2)*7; hc1=(col1+col3)*7; hc2=col1*7; hc9=&hc9*7; 
    %end;
    
    %if &var=HtLength %then %do;
    length0=(col1+col2)*7; length1=(col1+col3)*7; length2=col1*7; length9=&hl9*7;
    %end;
    
    drop _name_ col1-col4;
run;

proc sort data=tmp nodupkey out=gwn; by tx id; run;

proc freq; 
tables gw;
ods output onewayfreqs=txn;
run;

data _null_;
    set txn;
   if gw=1 then call symput("ng1", compress(frequency));
      if gw=2 then call symput("ng2", compress(frequency));
         if gw=3 then call symput("ng3", compress(frequency));
            if gw=4 then call symput("ng4", compress(frequency));
run;


%if &var=weight %then %do;
%if &tx^=2 %then %do;
proc mixed data=tmp;
%end;
%else %do;
proc mixed data=tmp method=mvque0;
%end;
        class id gw t;
        model &var=gw st1 st2 st1*gw st2*gw/s chisq;
        repeated t/type=un subject=id r;
        ods output Mixed.SolutionF=cef&tx;
run;

data _null_;
        set cef&tx;
        if effect="Intercept" then  call symput("int", put(estimate,7.2));
        if effect="st1" then  call symput("s1", put(estimate,7.2));
        if effect="st2" then  call symput("s2", put(estimate,7.2));
        if effect="gw" and gw=1 then  call symput("int1", put(estimate,7.2));
        if effect="gw" and gw=2 then  call symput("int2", put(estimate,7.2));
        if effect="gw" and gw=3 then  call symput("int3", put(estimate,7.2));
        if effect="gw" and gw=4 then  call symput("int4", put(estimate,7.2));
        if effect="st1*gw" and gw=1 then  call symput("sta1", put(estimate,7.2));
        if effect="st1*gw" and gw=2 then  call symput("sta2", put(estimate,7.2));
        if effect="st1*gw" and gw=3 then  call symput("sta3", put(estimate,7.2));
        if effect="st1*gw" and gw=4 then  call symput("sta4", put(estimate,7.2));
        if effect="st2*gw" and gw=1 then  call symput("stb1", put(estimate,7.2));
        if effect="st2*gw" and gw=2 then  call symput("stb2", put(estimate,7.2));
        if effect="st2*gw" and gw=3 then  call symput("stb3", put(estimate,7.2));
        if effect="st2*gw" and gw=4 then  call symput("stb4", put(estimate,7.2));
run;
%end;

%if &var=HeadCircum %then %do;
    %if &tx^=2 %then %do; proc mixed data=tmp; %end;
    %else %do; proc mixed data=tmp method=mvque0; %end;
        class id gw t;
        model &var=gw dayh dayh*gw/s chisq;
        repeated t/type=un subject=id r;
        ods output Mixed.SolutionF=cef&tx;
    run;
%end;
%if &var=HtLength %then %do; 
    %if &tx^=2 %then %do; proc mixed data=tmp; %end;
    %else %do; proc mixed data=tmp method=mvque0; %end;
        class id gw t;
        model &var=gw dayl dayl*gw/s chisq;
        repeated t/type=un subject=id r;
        ods output Mixed.SolutionF=cef&tx;
    run;
%end;

data _null_;
        set cef&tx;
        if effect="Intercept" then  call symput("int", put(estimate,7.2));
        if effect="dayh" or effect="dayl" then  call symput("s2", put(estimate,7.2));
        if effect="gw" and gw=1 then  call symput("int1", put(estimate,7.2));
        if effect="gw" and gw=2 then  call symput("int2", put(estimate,7.2));
        if effect="gw" and gw=3 then  call symput("int3", put(estimate,7.2));
        if effect="gw" and gw=4 then  call symput("int4", put(estimate,7.2));
        if (effect="dayh*gw" or effect="dayl*gw") and gw=1 then  call symput("stb1", put(estimate,7.2));
        if (effect="dayh*gw" or effect="dayl*gw") and gw=2 then  call symput("stb2", put(estimate,7.2));
        if (effect="dayh*gw" or effect="dayl*gw") and gw=3 then  call symput("stb3", put(estimate,7.2));
        if (effect="dayh*gw" or effect="dayl*gw") and gw=4 then  call symput("stb4", put(estimate,7.2));
run;

%let daylist=1 4 7 14 21 28 40 60;
%est(&daylist,&var,&tx);

proc sort; by gw day;run;

options orientation=portrait;
goptions reset=all  device=jpeg gunit=pct noborder cback=white
colors = (black red green blue)  ftext="Times"  hby = 3;

symbol1 interpol=spline mode=exclude value=circle height=2 bwidth=1 width=1 repeat=100;
axis1 label=(h=2.5 "Age of LBWIs (days)" ) split="*" value=(h=2.0)  order=( 0 to 61 by 1) minor=none offset=(0 in, 0 in);

%if &tx=0 %then %do; %let txt=No Tx; %let m=&t0; %end;
%if &tx=1 %then %do; %let txt=Before Tx; %let m=&t1; %end;
%if &tx=2 %then %do; %let txt=After Tx; %let m=&t1; %end;
%if &tx=9 %then %do; %let txt=All; %let m=&n; %end;

%if &var=weight %then %do;
axis2 label=(h=2.5 a=90 "Weight(g)") value=(h=2) order= (0 to 3200 by 200) offset=(.25 in, .25 in) minor=(number=1);
title h=10"Average daily body weight vs. postnatal age in days for &m LBWIs (&txt) stratified by 250 g birth weight intervals";
%end;

%if &var=HeadCircum %then %do;
axis2 label=(h=2.5 a=90 "Head Circumference(cm)") value=(h=2) order= (20 to 36 by 1) offset=(.25 in, .25 in) minor=(number=1);
title h=10 "Average daily head circumference vs. postnatal age in days for &m LBWIs (&txt) stratified by 250 g birth weight intervals";
%end;

%if &var=HtLength %then %do;
axis2 label=(h=2.5 a=90 "Length(cm)") value=( h=2) order= (20 to 50 by 2) offset=(.25 in, .25 in) minor=(number=1);
title h=10 "Average daily length vs. postnatal age in days for &m LBWIs (&txt) stratified by 250 g birth weight intervals";
%end;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2 shape = symbol(3,2) label=NONE 
value = (h=2 "<=750 g n=&ng1" "751-1000 g n=&ng2" "1001-1250 g n=&ng3" "1251-1500 g n=&ng4") offset=(0.2in, -0.4 in) frame;
   
proc gplot data=&var&tx gout=gcx.graphs;
plot est*dday=gw/haxis = axis1 vaxis = axis2 legend=legend;
format dday dd.;
run;
%mend slope;

proc greplay igout=gcx.graphs  nofs; delete _ALL_; run; 

%slope(var=weight,tx=0);
%slope(var=weight,tx=1);
%slope(var=weight,tx=2);
%slope(var=weight,tx=9);


%slope(var=HeadCircum,tx=0);
%slope(var=HeadCircum,tx=1);
%slope(var=HeadCircum,tx=2);
%slope(var=HeadCircum,tx=9);

%slope(var=HtLength,tx=0);
%slope(var=HtLength,tx=1);
%slope(var=HtLength,tx=2);
%slope(var=HtLength,tx=9);

proc means data=hwl(where=(dday>7));
class tx gw;
var weight;
ods output means.summary=avg;
run;

proc means data=hwl(where=(dday>7));
class gw;
var weight;
ods output means.summary=avg9;
run;

data cef9;
    merge cef_weight cef_HeadCircum cef_HtLength;
    gw=9;
run;

data growth;
    merge weight0(where=(dday=1) rename=(s2=wt0))
          weight1(where=(dday=1) rename=(s2=wt1))
          weight2(where=(dday=1) rename=(s2=wt2))
          weight9(where=(dday=1) rename=(s2=wt9))
          avg(where=(tx=0) keep=tx gw weight_mean rename=(weight_mean=avg0))
          avg(where=(tx=1) keep=tx gw weight_mean rename=(weight_mean=avg1))
          avg(where=(tx=2) keep=tx gw weight_mean rename=(weight_mean=avg2))
          avg9(keep=gw weight_mean rename=(weight_mean=avg9))
          HeadCircum0(where=(dday=1) rename=(s2=hc0))
          HeadCircum1(where=(dday=1) rename=(s2=hc1))
          HeadCircum2(where=(dday=1) rename=(s2=hc2))
          HeadCircum9(where=(dday=1) rename=(s2=hc9))
          HtLength0(where=(dday=1) rename=(s2=length0))
          HtLength1(where=(dday=1) rename=(s2=length1))
          HtLength2(where=(dday=1) rename=(s2=length2))         
          HtLength9(where=(dday=1) rename=(s2=length9));   
          by gw;
          hc0=hc0*7; length0=length0*7;
          hc1=hc1*7; length1=length1*7;
          hc2=hc2*7; length2=length2*7;
          hc9=hc9*7; length9=length9*7;
          gwt0=wt0/avg0*1000;
          gwt1=wt1/avg1*1000;
          gwt2=wt2/avg2*1000;
          gwt9=wt9/avg9*1000;
  
    keep  gw wt0 gwt0 hc0 length0 wt1 gwt1 hc1 length1 wt2 gwt2 hc2 length2 wt9 gwt9 hc9 length9;
    format wt0 gwt0 hc0 length0 wt1 gwt1 hc1 length1 wt2 gwt2 hc2 length2 wt9 gwt9 hc9 length9 5.2 
    gw ggw.;
run;

data growth;
    set growth cef9; by gw;
    format gw ggw.;
run;
    
goptions reset=all;
ods pdf file = "growth.pdf";
proc greplay igout =gcx.graphs tc=sashelp.templt template=v3 nofs;
    list igout;
	treplay 1:1 2:2 3:3; 
		treplay 1:5 2:6 3:7; 
			treplay 1:9 2:10 3:11; 
run;
ods pdf close;

options orientation=landscape;
ods rtf file="tab3.rtf" style=journal bodytitle;
proc report data=growth nowindows headline spacing=1 split='#' style(column)=[just=center] style(header)=[just=center];
title "Growth Velocity by Birth Weight Interval* (n=&n)";

column gw ("------------ Weight Gain -------------" ("--------------- (g/d)*1----------------" wt0-wt2 wt9)
("---------------- (g/kg/d)*2 ---------------" gwt0-gwt2 gwt9)) 
("----------- Length (cm/wk) ----------" length0-length2 length9)
("--- Head Circumference (cm/wk) --" hc0-hc2 hc9);

define gw/order order=data "Birth Weight Interval, g(n)" style(column)=[cellwidth=1.25in];
define wt0/"No Tx"          style(column)=[cellwidth=0.5in];
define wt1/"Before Tx"      style(column)=[cellwidth=0.5in];
define wt2/"After Tx"       style(column)=[cellwidth=0.5in];
define wt9/"All"            style(column)=[cellwidth=0.5in];
define gwt0/"No Tx"         style(column)=[cellwidth=0.5in];
define gwt1/"Before Tx"     style(column)=[cellwidth=0.5in];
define gwt2/"After Tx"      style(column)=[cellwidth=0.5in];
define gwt9/"All"           style(column)=[cellwidth=0.5in];
define length0/"No Tx"      style(column)=[cellwidth=0.5in];
define length1/"Before Tx"  style(column)=[cellwidth=0.5in];
define length2/"After Tx"   style(column)=[cellwidth=0.5in];
define length9/"All"        style(column)=[cellwidth=0.5in];
define hc0/"No Tx"          style(column)=[cellwidth=0.5in];
define hc1/"Before Tx"      style(column)=[cellwidth=0.5in];
define hc2/"After Tx"       style(column)=[cellwidth=0.5in];
define hc9/"All"            style(column)=[cellwidth=0.5in];
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
* The average daily increments for body weight (g/d and g/kg/d) and the average weekly 
increment for length and head circumference were computed after the first week and 
before discharge, transfer, or death.
^n *1 Absolute growth rate after 7 days: Mean slope estimates.
^n *2 Relative velocity after 7 days, computed by absolute growth rate over mean body weight after the first week.";
ods rtf close;

proc sort data=hwl nodupkey out=tmp; by gw tx id;run;
proc freq; tables gw*tx;run;

%let ref01=0; %let ref02=0; %let ref03=0; %let ref04=0; 
%let ref11=0; %let ref12=0; %let ref13=0; %let ref14=0; 
%let group11=0; %let group12=0; %let group13=0; %let group14=0; 
%let group21=0; %let group22=0; %let group23=0; %let group24=0; 

%macro slopeg(var,gp);

proc sort data=hwl(where=(&var=&gp)) nodupkey out=gwn; by id; run;
proc freq; 
tables gw;
ods output onewayfreqs=txn;
run;

data _null_;
    set txn;
   if gw=1 then call symput("&var&gp.1", compress(frequency));
      if gw=2 then call symput("&var&gp.2", compress(frequency));
         if gw=3 then call symput("&var&gp.3", compress(frequency));
            if gw=4 then call symput("&var&gp.4", compress(frequency));
run;

proc mixed data=hwl(where=(&var=&gp));
        class id gw t;
        model weight=gw st1 st2 st1*gw st2*gw/s chisq;
        repeated t/type=un subject=id r;
        ods output Mixed.SolutionF=cef_ref;
run;

data _null_;
        set cef_ref;
        if effect="Intercept" then  call symput("int", put(estimate,7.2));
        if effect="st1" then  call symput("s1", put(estimate,7.2));
        if effect="st2" then  call symput("s2", put(estimate,7.2));
        
        if effect="gw" and gw=1 then  call symput("int1", put(estimate,7.2));
        if effect="gw" and gw=2 then  call symput("int2", put(estimate,7.2));
        if effect="gw" and gw=3 then  call symput("int3", put(estimate,7.2));
        if effect="gw" and gw=4 then  call symput("int4", put(estimate,7.2));
        if effect="st1*gw" and gw=1 then  call symput("sta1", put(estimate,7.2));
        if effect="st1*gw" and gw=2 then  call symput("sta2", put(estimate,7.2));
        if effect="st1*gw" and gw=3 then  call symput("sta3", put(estimate,7.2));
        if effect="st1*gw" and gw=4 then  call symput("sta4", put(estimate,7.2));
        if effect="st2*gw" and gw=1 then  call symput("stb1", put(estimate,7.2));
        if effect="st2*gw" and gw=2 then  call symput("stb2", put(estimate,7.2));
        if effect="st2*gw" and gw=3 then  call symput("stb3", put(estimate,7.2));
        if effect="st2*gw" and gw=4 then  call symput("stb4", put(estimate,7.2));
run;

%let daylist=1 4 7 14 21 28 40 60;
%est(&daylist,&var,&gp);
proc sort;by gw day;
%mend slopeg;

%slopeg(ref,0);
%slopeg(ref,1);
%slopeg(group,1);
%slopeg(group,2);
data wt_ref;
    set ref0 ref1(in=B); by gw day;
    keep gw day est;
    if B then gw=gw+4;
run;
proc sort; by gw day;run;

data wt_ga;
    set group1 group2(in=B); by gw day;
    keep gw day est;
    if B then gw=gw+4;
run;
proc sort; by gw day;run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red green blue)  ftext="Times"  hby = 3;

symbol1 interpol=spline mode=exclude value=circle height=2 bwidth=3 width=1 l=4 ;
symbol2 interpol=spline mode=exclude value=triangle height=2 bwidth=3 width=1 l=1;

axis1 label=(h=2.5 "Age of LBWIs (days)" ) split="*" value=(h=1.5)  order=( 0 to 61 by 1) minor=none offset=(0 in, 0 in);
axis2 label=(h=2.5 a=90 "Weight(g)") value=(h=2.0) order= (0 to 3200 by 200) offset=(.25 in, .25 in) minor=(number=1);
title h=10 "Average daily body weight vs. postnatal age in days for LBWIs stratified by 250 g birth weight intervals";

legend1 across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = ( h=2 "<=750 g (Major Morbidity) n=&ref01" "751-1000 g (Major Morbidity) n=&ref02" "1001-1250 g (Major Morbidity) n=&ref03" "1251-1500 g (Major Morbidity) n=&ref04" 
"<=750 g (No Major Morbidity) n=&ref11" "751-1000 g (No Major Morbidity) n=&ref12" "1001-1250 g (No Major Morbidity) n=&ref13" "1251-1500 g (No Major Morbidity) n=&ref14") 
offset=(0.2in, -0.4 in) frame;

legend2 across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2 "<=750 g (SGA) n=&group11" "751-1000 g (SGA) n=&group12" "1001-1250 g (SGA) n=&group13" "1251-1500 g (SGA) n=&group14" 
"<=750 g (AGA) n=&group21" "751-1000 g (AGA) n=&group22" "1001-1250 g (AGA) n=&group23" "1251-1500 g (AGA) n=&group24") 
offset=(0.2in, -0.4 in) frame;

proc greplay igout=gcx.graphs  nofs; delete _ALL_; run; 

proc gplot data=wt_ref gout=gcx.graphs;
plot est*day=gw/ haxis = axis1 vaxis = axis2 legend=legend1;
format day dd.;
run;

proc gplot data=wt_ga gout=gcx.graphs;
plot est*day=gw/ haxis = axis1 vaxis = axis2 legend=legend2;
format day dd.;
run;

options orientation=portrait;
goptions reset=all;
ods pdf file = "growth2.pdf";
proc greplay igout =gcx.graphs tc=sashelp.templt template=v2s nofs;
    list igout;
	treplay 1:1 2:2; 
run;
ods pdf close;
