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
	*rename dfseq=day;
	keep id HbDate Hb dfseq;
run;

proc sort nodupkey; by id hbdate hb;run;

proc sort data=hb0 out=hb_last; by id decending hbdate;run;

data hb_last;
    set hb_last; by id descending hbdate;
    if first.id;
    rename hbdate=ndate;
    keep id hbdate;
    if id<1000000 then delete;
run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	rename laparotomydone=type;
	format laparotomydone type.;
	lable laparotomydone="NEC Type";
run;

data nec;
	merge hb0 nec0 cmv.completedstudylist(in=comp) hb_last
	cmv.plate_031(keep=id DateTransfusion rbc_TxStartTime in=in_tx )
	cmv.plate_006(keep=id gestage)
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob))
	cmv.endofstudy(keep=id StudyLeftDate); by id;
	
	
	if comp;
	if bell then nec=1; else nec=0;
	day=hbdate-dob+1;
	retain ndate;
	if nec and first.id then ndate=necdate;

	
	if hbdate>ndate and nec then hb=.;
	if hb<6 or hb>25 or hbdate<dob then delete;

	if nec=0 then if in_tx=0 then nec=0; else if in_tx=1 then nec=2;
	format gender gender. ndate mmddyy8.;
	
	followup0=StudyLeftDate-dob;
	if nec=1 then followup0=ndate-dob;
	rename dfseq=dday;
	followup=min(followup0,30);
run;

proc sort data=nec out=nec_followup nodupkey; by id followup;run;

proc means data=nec_followup sum;
    class nec;
    var followup;
    output out=nday sum(followup)=day_followup;
run;

data _null_;
    set nday;
	if nec=0 then call symput("day0_fp",compress(day_followup));
	if nec=1 then call symput("day1_fp",compress(day_followup));
	if nec=2 then call symput("day2_fp",compress(day_followup));
run;


proc sort data=nec out=nec_tx nodupkey; by id DateTransfusion rbc_TxStartTime;run;
data nec_tx;
    set nec_tx;
    if nec=1 then if ndate>DateTransfusion;
    if (DateTransfusion-dob)<=30;
run;
proc means data=nec_tx n;
    class nec;
    var id;
    output out=ntx n(id)=n;
run;

data _null_;
    set ntx;
	if nec=0 then call symput("n0_tx","-");
	if nec=1 then call symput("n1_tx",compress(n));
	if nec=2 then call symput("n2_tx",compress(n));
run;

proc means data=nec(where=((hbdate-dob)<=30)) /*noprint*/;
	class nec;
	var id;
	output out=nec_obs n(id)=n;
run;


data _null_;
	set nec_obs;
	if nec=0 then call symput("m0",compress(n));
	if nec=1 then call symput("m1",compress(n));
	if nec=2 then call symput("m2",compress(n));
run;

proc sort data=nec nodupkey out=nec_id; by id;run;

proc means data=nec_id noprint;
	class nec;
	var id;
	output out=nec_num n(id)=n;
run;

data _null_;
	set nec_num;
	if nec=0 then call symput("n0",compress(n));
	if nec=1 then call symput("n1",compress(n));
	if nec=2 then call symput("n2",compress(n));
run;

proc format; 
    value nec 0="Non-NEC without TX" 1="NEC" 2="Non-NEC with TX";
run;

data fit_tab;
    length n m ntx followup $12;
    nec=0; n="&n0"; m="&m0"; ntx="&n0_tx"; followup="&day0_fp"; ntx_day=ntx/followup*30; output;
    nec=1; n="&n1"; m="&m1"; ntx="&n1_tx"; followup="&day1_fp"; ntx_day=ntx/followup*30; output;
    nec=2; n="&n2"; m="&m2"; ntx="&n2_tx"; followup="&day2_fp"; ntx_day=ntx/followup*30; output;
    format nec nec. ntx_day 5.1;
run;

    ods rtf file="nec_tab1.rtf" style=journal bodytitle;			

	title "Transfusion Rates for Controls and NEC LBWIs in 1st Month";
			
			proc print data=fit_tab noobs label split="|";
			var nec/style=[just=center width=1.5in];
			var n m ntx followup ntx_day /style=[just=center width=1.25in];
			label nec="Group"
			      n="#LBWIs"
			      m="#Hb(obs)"
			      ntx="Number of Tx"
			      followup="Follow-up Days"
			      ntx_day="pRBC Tx Rate*";			    
			run;
		    ods escapechar='^';
			ods rtf text="^S={LEFTMARGIN=1.25in RIGHTMARGIN=1.25in font_size=11pt} * Transfusion rate per 30 days of follow-up.";
	ods rtf close;
