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
		cmv.plate_031(keep=id Hb DFSEQ DateHbHct rename=(DateHbHct=hbdate));

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;

    if id=2014411 and dfseq=101 then hbdate=mdy(12,01,11);				
    if id=3043411 and dfseq=14 then hbdate=mdy(03,03,12);
	if id=3006711 and hbdate='30Dec11'd then hbdate='30Dec10'd;
	keep id HbDate Hb;
run;

proc sort nodupkey; by id hbdate hb;run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate NECResolveDate;
run;

proc sort; by id necdate;run;
data nec;
    set nec0; by id necdate;
    if first.id;
run;

proc sort data=cmv.plate_031 out=rbc_tx; by id DateTransfusion;run;

data rbc_tx;
    set rbc_tx; by id DateTransfusion;
    if first.id;
    rename DateTransfusion=dtx;
    keep id DateTransfusion;
run;

data hb_nec;
    merge nec(in=tmp) hb0 rbc_tx(in=temp) cmv.tx_nec cmv.endofstudy(keep=id StudyLeftDate)
    cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob))
    cmv.completedstudylist(in=comp keep=id); by id; 
    
    day=hbdate-dob+1;
    if tmp then nday=necdate-dob+1;
    else nday=StudyLeftDate-dob+1;
    
    if comp and temp;

    if tmp then nec=1; else nec=0;
    if tmp then if hbdate>necdate then delete;
    *if necdate>dtx then delete;
    if nidx=3 then delete;
run;


proc mixed data=hb_nec;
    class id nec; 
    model hb=day nec nec*day/s outp=predicted;
    random int day/subject=id s;
    ods listing exclude SolutionF;
    ods listing exclude SolutionR;
    ods output SolutionF=fixed1;
    ods output SolutionR=rand1;
run;

data _null_;
    set fixed1;
    if _n_=1 then call symput("int", compress(put(Estimate, 7.4)));
        if effect="nec" and nec=0 then call symput("int0", compress(put(Estimate, 7.4)));
        if effect="nec" and nec=1 then call symput("int1", compress(put(Estimate, 7.4)));
run;

data int;
    merge nec(in=nec) rand1(where=(Effect="Intercept")); by id; 
    if nec then int=&int+&int1+estimate;
    if not nec then int=&int+&int0+estimate; 
run;

proc means data=int Q1 median Q3;
var int;
output out=wbh Q1(int)=Q1_int median(int)=median q3(int)=q3_int;
run;

data _null_;
    set wbh;
    call symput("Q1", compress(put(Q1_int, 5.2)));
        call symput("Q2", compress(put(median, 5.2)));
            call symput("Q3", compress(put(Q3_int, 5.2)));
run;

data hb_nec; 
    merge hb_nec int(keep=id int);
    if int<=&q1 then qint=1; 
        else if &q1<int<=&q2 then qint=2;
            else if &q2<int<=&q3 then qint=3;
                else if int>&q1 then qint=4;
run;

proc phreg data=hb_nec;
	model nday*nec(0)=int;
	hazardratio ' ' int / units=1 cl=both;
run;

proc phreg data=hb_nec;
    class qint(ref=last);
	model nday*nec(0)=qint/rl;
run;
