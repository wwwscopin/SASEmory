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
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3 cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell); by id;
	if bell;
	keep id necdate NECResolveDate;
run;

proc sort; by id necdate;run;
data nec;
    set nec0; by id necdate;
    if first.id;
run;

data rbc_tx;
    merge nec(in=tmp) cmv.plate_031(keep=id DateTransfusion rename=(DateTransfusion=dtx));by id;
    if tmp then if dtx<=necdate;
run;
proc sort nodupkey; by id; run;

data hb_nec;
    merge nec(in=tmp) hb0 
    cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob))
    cmv.completedstudylist(in=comp keep=id); by id; 
    
    day=hbdate-dob+1;
    if comp;

    if tmp then nec=1; else nec=0;
    if tmp then if hbdate>necdate then delete;
    if 0<hb<=8 then anemia=1; else anemia=0;
run;

proc print data=hb_nec(where=(nec=1 and anemia=1));
var id nec hb hbdate anemia;
run;


proc means data=hb_nec noprint;
    by id;
    class nec;
    var anemia;
    output out=wbh sum(anemia)=n;
run;

proc freq data=wbh(where=(nec^=.));
    *tables n*nec/nocol norow nopercent;
    tables n*nec;
run;


data anemia0;
    set hb_nec;
    if anemia;
run;

proc sort; by id day; run;

data anemia;
    set anemia0; by id day; 
    if first.id;
    if day>28 then anemia28=1; else anemia28=0;
    rename HbDate=anemia_date;
    keep id nec anemia anemia28 hbdate;
run;

proc freq; 
    tables nec*anemia28;
run;

data anemia_nec;
    merge rbc_tx(in=tx keep=id) anemia(drop=nec)  cmv.endofstudy(keep=id StudyLeftDate)
    cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob))
    cmv.completedstudylist(in=comp keep=id)
    nec(in=temp) cmv.death(in=dead); by id;
    
    if comp;
    if tx then rbc=1; else rbc=0;
    if anemia=. then anemia=0;
    if temp then nec=1; else nec=0;
    *if dead and nec=0 then nec=.;
    
    day=StudyLeftDate-dob+1;
    if anemia then day=anemia_date-dob+1;
    if rbc;
run;

proc phreg data=anemia_nec;
	class nec;
	model day*anemia(0)=nec nect;
	nect=nec*log(day);
	Test: test nect;
run;
