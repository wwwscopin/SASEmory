options orientation=portrait nodate nofmterr;
libname wbh "/ttcmv/sas/data";	
libname gcx "/ttcmv/sas/programs";	

%let pm=%sysfunc(byte(177)); 

proc format;
    value group 1="SGA"  2="AGA"  3="LGA";
	value gw 1="<=750" 2="751-1000" 3="1001-1250" 4="1251-1500";
	value yn 1="Yes" 0="No";
	value tx 0="No Tx" 1="Before Tx" 2="After Tx";
	value feed 1="Bottle Feeding" 0="Breast Feeding";
	value item 
        0="Number"
        1="Gestational age (wk)*"
        2="SNAP score@"
        3="Male"
		4="White"
		5="SGA†"
		6="Survival‡"
		7="BPD§"
		8="Sepsis$"
		9="Severe IVH¶"
		10="NEC#"
		11="Ever Transfused (Any Transfusion)"
		12="Always Bottle Feeding"
	;
	
	value ref 
        0="Number"
        1="Gestational age (wk)"
        2="SNAP score"
        3="Male"
		4="White"
        5="#Transfusion"
        6=".  --1"
                7=".  --2"
                        8=".  --3"
                                9=".  -->3";
 	;
run;

data hwl0;
        merge cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	      cmv.plate_006(keep=id gestage) 
	      cmv.plate_008(keep=id MultipleBirth)
	      cmv.plate_015
	      cmv.plate_012(keep=id SNAPTotalScore rename=(SNAPTotalScore=snap))
	      cmv.bpd(where=(oxygen_at_36=1) keep=id oxygen_at_36 in=A)
	      cmv.infection_p1(where=(CulturePositive=1) keep=id CulturePositive in=B)
	      cmv.ivh_image(where=(LeftIVHGrade in(3,4) or RightIVHGrade in(3,4)) keep=id LeftIVHGrade RightIVHGrade in=C)
	      cmv.nec_p1(keep=id in=D)
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


	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate LeftIVHGrade RightIVHGrade 
	MultipleBirth gender LBWIDOB race gestage bw gw bpd sepsis ivh nec feed snap;
	rename DFSEQ=day LBWIDOB=dob ;
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
	if group=2 and bpd=0 and sepsis=0 and ivh=0 and nec=0 then ref=1; else ref=0; 
run;


data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0;
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	/*if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */

	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
run;

proc sort; by id dt; run;
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
	
	if daytx^=. and daytx<0 then tx=1;
	if daytx>=0 then tx=2;

	format gw gw. group group. feed feed. death bpd sepsis ivh nec yn. tx tx.;
        
        if day=1  then t=1;
        if day=4  then t=2;
        if day=7  then t=3;
        if day=14 then t=4;
        if day=21 then t=5;
        if day=28 then t=6;
        if day=40 then t=7;
        if day=60 then t=8;
        
        st1=min(day,7);
        st2=max(0,day-7);
        
    wk=day/7;    
	if day=1 then output hwl_base;
	output hwl;
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
            if tx=2 then call symput("t2", compress(frequency));
run;
%let t12=%eval(&t1+&t2);
%put &n;

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
%let varlist=gender race group death bpd sepsis ivh nec tx feed;
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

proc format;
	value ggw 1="<=750(&n1)" 2="751-1000(&n2)" 3="1001-1250(&n3)" 4="1251-1500(&n4)";
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
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
\f3\f24
Abbreviation: SGA, small-for-gestional age; IVH, intravetricular hemorrhage; NEC, nectrotizing enterocolitis.
^n * Best obstetrical estimate (mean &pm SD).
^n @ SNAP score at birth.
^n † Birth weight<10 percentile according to Arbuckel et al.
^n ‡ Survival of infants meeting inclusion criteria.
^n § Oxygen dependence at 36 weeks postmenstrual age.
^n $ Sepsis occuring after 72 hours of age with proven culture.
^n ¶ Grade 3-4 IVH.
^n # NEC, Bell's Stage II or worse.
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
title "Reference Population Characteristics (n=&nref)";

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
ods rtf close;


proc sort data=hwl nodupkey; by id day weight;run;

****************************************************;
** For Local Use;
%macro est(daylist,var,gp);
data &var&gp;
    %let i = 1;
	%let day = %scan(&daylist, &i);
	%do %while ( &day NE );
         
        %do j=1 %to 4;
            gw=&j; day=&day; 
            
            %if &var=weight or &var=ref or &var=group  %then %do;
                int=%sysevalf(&int+&&int&j);
                s1=%sysevalf(&s1+&&sta&j);
                s2=%sysevalf(&s2+&&stb&j);
                %if &day<=7 %then %do; 
                    est=%sysevalf(&int+&&int&j+(&s1+&&sta&j)*&day); output;
                %end;
                %else %if &day>7 %then %do; 
                    est=%sysevalf(&int+&&int&j+(&s1+&&sta&j)*7+(&s2+&&stb&j)*(&day-7)); output;
                %end;
             %end;
            %else %do;
                int=%sysevalf(&int+&&int&j);
                s2=%sysevalf(&s2+&&stb&j);
                est=%sysevalf(&int+&&int&j+(&s2+&&stb&j)*&day); output;
            %end;
        %end;
        
	%let i= %eval(&i+1);
	%let day = %scan(&daylist,&i);
	%end;     
	keep day gw int s1 s2 est;           
run;
%mend est;

proc means data=hwl ;
    	class tx day;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or day=. then delete;
run;

%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if tx=0 and day=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and day=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and day=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and day=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and day=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and day=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and day=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and day=60 then call symput( "n60",  compress(put(num_obs, 3.0)));

	if tx=1 and day=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if tx=1 and day=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if tx=1 and day=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if tx=1 and day=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if tx=1 and day=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if tx=1 and day=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if tx=1 and day=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if tx=1 and day=60 then call symput( "b60",  compress(put(num_obs, 3.0)));

	if tx=2 and day=1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if tx=2 and day=4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if tx=2 and day=7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if tx=2 and day=14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if tx=2 and day=21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if tx=2 and day=28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if tx=2 and day=40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if tx=2 and day=60 then call symput( "a60",  compress(put(num_obs, 3.0)));
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
proc mixed data=hwl method=ml ORDER=internal;
        class id tx t;
        model weight=tx st1 st2 st1*tx st2*tx/s chisq;
        repeated t/type=un subject=id r;
    
    estimate "No-Tx, intercept" int 1 tx 1 0 0/cl;
    estimate "No-Tx, wk1"   int 1 tx 1 0 0 st1 7   -1  st1*tx 7   -1;
	estimate "No-Tx, wk2"   int 1 tx 1 0 0 st2 7    0  st2*tx 7    0;
	estimate "No-Tx, wk3"   int 1 tx 1 0 0 st2 14  -7  st2*tx 14  -7;
	estimate "No-Tx, wk4"   int 1 tx 1 0 0 st2 21 -14  st2*tx 21 -14;
	estimate "No-Tx, wk5"   int 1 tx 1 0 0 st2 28 -21  st2*tx 28 -21;

        ods output Mixed.SolutionF=slope;
		ods output Mixed.Estimates=estimate_wt;
run;
