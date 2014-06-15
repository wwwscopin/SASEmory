
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
		13="Hemoglobin (g/dL)"
		14="Ever pRBC Transfused "
		15="Always Formula Fed"
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
	
	
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate LeftIVHGrade RightIVHGrade 
	MultipleBirth gender LBWIDOB race gestage bw gw bpd sepsis ivh nec feed snap pda rop hb;
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
proc mixed data=hwl /*method=ml*/ ORDER=internal;
        *class id tx t; *this is for repeated statement;
        class id tx; *this is for random statement;
        model weight=tx st1 st2 st1*tx st2*tx/s chisq;
       	random int st1 st2/type=un subject=id s;
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
	
	    estimate "slope"  st2 1 st2*tx 1 0 0/e;
        estimate "slope"  st2 1 st2*tx 0 1 0/e;
        estimate "slope"  st2 1 st2*tx 0 0 1/e;
                 estimate "slope"  st2*tx 1 0 -1/e;

        ods output Mixed.SolutionF=slope;
        ods output Mixed.SolutionR=ind_slope;
		ods output Mixed.Estimates=estimate_wt;
run;

data cmv.wt_slope(where=(effect='st2'));
    set ind_slope;
run;


data _null_;
    length pv $10;
    set estimate_wt;
   	if _n_=28 then call symputx("s0", put(estimate,4.1)||"("||compress(put(stderr,4.1))||")");
	if _n_=29 then call symputx("s1", put(estimate,4.1)||"("||compress(put(stderr,4.1))||")");	   	
	if _n_=30 then call symputx("s2", put(estimate,4.1)||"("||compress(put(stderr,4.1))||")");
	if _n_=31 then do; if probt<0.001 then pv="<0.001"; else pv=put(probt,7.4); call symputx("pv", pv);	end;
run;


data line_wt;
	set estimate_wt(firstobs=1);
	if find(label,"No-Tx", 't') then tx=0; 
		else if find(label,"Before")  then tx=1; else tx=2;
	if find(label,"intercept") then day=0; 
   	else day= compress(scanq(label,2),'Day', ",");
	day1=day+0.05;
	day2=day+0.25;
	
    if day=. then delete;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	*if estimate<0 then delete;
	
	keep tx day day1 day2 estimate upper lower;
run;


DATA anno0; 
	set line_wt;
	where tx=0;
	xsys='2'; ysys='2';  color='green';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno0A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt;
	where tx=0;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;

data anno0;
	length color $6 function $8;
	set anno0 anno0A;
run;

DATA anno1; 
	set line_wt;
	where tx=1;
	xsys='2'; ysys='2';  color='blue';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno1A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt;
	where tx=1;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;

data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;

DATA anno2; 
	set line_wt;
	where tx=2;
	xsys='2'; ysys='2';  color='red';
	X=day2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
   X=day2-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=day2+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=day2;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno2A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt;
	where tx=2;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;

data anno2;
	length color $6 function $8;
	set anno2 anno2A;
run;

data anno;
	set anno0 anno1(in=B) anno2;
	if B and day>28 then delete;
run;

data wt;
	merge line_wt(where=(tx=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
			line_wt(where=(tx=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
			line_wt(where=(tx=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)); 
	by day;
	if  day>28 then do; estimate1=.; lower1=.; upper1=.; end;
run;


proc greplay igout= gcx.graphs  nofs; delete _ALL_; run;
goptions reset=all  /*device=jpeg*/ gunit=pct noborder CBACK=blue CPATTERN=blue ctext=white ctitle=white  colors=(orange green red) 
ftitle="Times/Bold" ftext="Times/Bold" hby = 3;

symbol1 interpol=spline mode=exclude value=circle co=green cv=green height=2 width=1.5;
symbol2 i=spline ci=blue value=dot co=blue cv=blue h=2 w=1.5;
symbol3 i=spline ci=red value=triangle co=red cv=red h=2 w=1.5;


axis1 	label=(h=3 "Age of LBWIs (days)" ) split="*"	value=(h=1.0c=blue)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in) c=white origin=(,15)pct;
axis2 	label=(h=2.5 a=90 f=swissb "Weight(g)") value=(h=2) order= (600 to 2800 by 100) offset=(.25 in, .25 in) minor=(number=1) c=white;
 
title1 	height=3 "All LBWIs Weight vs Age";
title2 	height=2.5  "(With pRBC Transfusion=&t1, Without pRBC Transfusion=&t0)";
title3  height=2.5 "Test equal slope between 'No Tx and After Tx', pvalue=&pv";
*title2 	height=3 "Test of equal slopes, p=&p";

%put &yes;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=None
value = (h=2 c=black "Without pRBC Transfusion, Slope(SE)=&s0 g/day" "Before 1st pRBC Transfusion, Slope(SE)=&s1 g/day" 
"After 1st pRBC Transfusion, Slope(SE)=&s2 g/day") offset=(0.2in, -0.4 in) frame cframe=white;


proc greplay igout=gcx.graphs  nofs; delete _ALL_; run;

proc gplot data= wt gout=gcx.graphs;
	plot estimate0*day estimate1*day1 estimate2*day2/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
	/*note h=1.25 m=(4pct, 11.5 pct) "Day :" ;
	note h=1.25 m=(4pct, 10 pct) "(#No tx)" ;
	note h=1.25 m=(4pct, 8.5 pct) "(#Before tx)" ;
	note h=1.25 m=(4pct, 7.0 pct) "(#After tx)" ;
    */
	format estimate0 estimate1 estimate2 4.0;
run;

options orientation=landscape;
goptions reset=all  /*device=jpeg*/ gunit=pct noborder CBACK=blue CPATTERN=blue ctext=white ctitle=white  colors=(orange green red) 
ftitle="Times/Bold" ftext="Times/Bold" hby = 3;

ods pdf file = "growth_all_ppt.pdf";
proc greplay igout = gcx.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:1;
run;
ods pdf close;
