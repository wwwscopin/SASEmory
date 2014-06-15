options ORIENTATION="LANDSCAPE" nodate nonumber;
libname wbh "/ttcmv/sas/programs";	

%let pm=%sysfunc(byte(177));

proc format;
		value anemic 0="Not Anemic" 1="Anemic";
		value tx 
		0="No"
		1="Yes"
		;
		value type
		0="Medical NEC"
		1="Surgical NEC"
		.="No NEC"
		;
run;

data hb0;
	set cmv.plate_015 
		cmv.plate_031(keep=id Hb /*DFSEQ*/ DateHbHct rename=(DateHbHct=hbdate));

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;
		
	if id=3006711 and hbdate='30Dec11'd then hbdate='30Dec10'd;
	keep id HbDate Hb dfseq;
run;

proc sort nodupkey; by id hbdate hb;run;

proc sort data=cmv.plate_031; by id DateTransfusion;run;

data rbc_first;
    set cmv.plate_031(keep=id DateTransfusion rename=(DateTransfusion=date_rbc)); by id date_rbc;
    if first.id;
    keep id date_rbc;
run;


data rbc_nec;
	merge hb0
	cmv.completedstudylist(in=comp keep=id)
	rbc_first(in=tx)
	cmv.plate_006(keep=id gestage birthweight)
	cmv.km(where=(bellstage2=1) keep=id bellstage2 necdate in=bell)
	cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob)); by id;
	
	
	if comp;
	if bell then nec=1; else nec=0;
	if nec then date_rbc=necdate;
	
	day=date_rbc-dob+1;

	
	if hbdate>=date_rbc then hb=.;
	if hb<6 or hb>25 or hbdate<dob then delete;
	
	format gender gender. necdate hbdate date_rbc mmddyy10.;
	rename dfseq=dday;
run;

proc sort data=rbc_nec out=temp; by id hbdate; run;

data rbc_nec0;
    set temp; by id hbdate;
    if first.id;
run;

proc means data=rbc_nec0 mean noprint;
    var gestage birthweight;
    output out=test;
run;

data _null_;
    set test;
    if _n_=4;
    call symput("nage", compress(put(gestage, 4.1)));
    call symput("nbw", compress(put(birthweight, 5.0)));
run;

proc means data=rbc_nec noprint;
	class nec;
	var id;
	output out=nec_obs n(id)=n;
run;

data _null_;
	set nec_obs;
	if nec=0 then call symput("m0",compress(n));
	if nec=1 then call symput("m1",compress(n));
run;

proc means data=rbc_nec0 noprint;
	class nec;
	var id;
	output out=nec_num n(id)=n;
run;

data _null_;
	set nec_num;
	if nec=0 then call symput("n0",compress(n));
	if nec=1 then call symput("n1",compress(n));
run;

proc sort data=rbc_nec out=nec_id nodupkey; by nec dday id; run;

proc means data=nec_id noprint;
	class nec dday;
	var id;
	output out=wbh;
run;

%let a0= 0; %let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b0= 0; %let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;
%let c0= 0; %let c1= 0; %let c4= 0; %let c7= 0; %let c14= 0; %let c21= 0; %let c28=0; %let c40=0;  %let c60=0;

data _null_;
	set wbh;
	if nec=0 and dday=1  then call symput( "a1",   compress(_freq_));
	if nec=0 and dday=4  then call symput( "a4",   compress(_freq_));
	if nec=0 and dday=7  then call symput( "a7",   compress(_freq_));
	if nec=0 and dday=14 then call symput( "a14",  compress(_freq_));
	if nec=0 and dday=21 then call symput( "a21",  compress(_freq_));
	if nec=0 and dday=28 then call symput( "a28",  compress(_freq_));
	if nec=0 and dday=40 then call symput( "a40",  compress(_freq_));
	if nec=0 and dday=60 then call symput( "a60",  compress(_freq_));

	if nec=1 and dday=1  then call symput( "b1",   compress(_freq_));
	if nec=1 and dday=4  then call symput( "b4",   compress(_freq_));
	if nec=1 and dday=7  then call symput( "b7",   compress(_freq_));
	if nec=1 and dday=14 then call symput( "b14",  compress(_freq_));
	if nec=1 and dday=21 then call symput( "b21",  compress(_freq_));
	if nec=1 and dday=28 then call symput( "b28",  compress(_freq_));
	if nec=1 and dday=40 then call symput( "b40",  compress(_freq_));
	if nec=1 and dday=60 then call symput( "b60",  compress(_freq_));
run;

proc format;

value dt   
 0="0" 1="1"  2=" " 3=" " 4 = "4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "60" ;
 
value dta   
  0=" " 1="&a1"  2=" " 3=" " 4 = "&a4" 5=" " 6=" " 7="&a7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&a14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&a21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&a28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&a40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&a60" ;
 

value dtb   
  0=" " 1="&b1"  2=" " 3=" " 4 = "&b4" 5=" " 6=" " 7="&b7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&b14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&b21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&b28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&b40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&b60" ;

value dd   
  0=" " 1=" "  2=" " 3=" " 4 = " " 5=" " 6=" " 7=" " 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = " " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21=" " 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = " "  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40=" " 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = " " ;
  
run;

proc phreg data=rbc_nec;
  class gender(ref=last);
  model day*nec(0) = hb gender gestage birthweight hbt gendert /*gestaget birthweightt*/;
  hbt= hb*log(day);
  gendert = gender*log(day);
  *gestaget = gestage*log(day);
  *birthweightt= birthweight*log(day);
  proportionality_test: test hbt, gendert/*, gestaget, birthweightt*/;
  hazardratio 'HB' hb / units=1 cl=both;
  hazardratio 'Gender' gender / units=1 cl=both;
  hazardratio 'Gestage' gestage / units=1 cl=both;
  hazardratio 'Birthweight' birthweight / units=100 cl=both;
run;
