*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT";
libname wbh "/ttcmv/sas/data";	

proc format;
		value tx 
		0="No"
		1="Yes"
		;
		value type
		0="Medical NEC"
		1="Surgical NEC"
		.="Unknown"
		;
run;

data hb0;
	set cmv.plate_015;
	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;
	rename dfseq=day;
	keep id HbDate Hb dfseq;
run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	rename laparotomydone=type;
	format type type.;
	lable type="NEC Type";
run;

data nec;
	merge hb0 nec0 cmv.comp_pat(in=comp keep=id gender dob); by id;
	if comp;
	if necdate=. then nec=0; else nec=1;
	day0=hbdate-dob;
	retain ndate;
	if first.id then ndate=necdate;
	
	if hbdate>ndate and nec then hb=.;
	format gender gender. ndate mmddyy8.;
run;

proc sort nodupkey; by id hbdate; run;

proc mixed method=ml data=nec covtest;
	class id nec;
	model hb=nec day nec*day/s;
	random int day/type=un subject=id;
	estimate "No NEC, slope" day 1 nec*day 1 0;
	estimate "   NEC, slope" day 1 nec*day 0 1;

	estimate "No NEC, intercept" int 1 nec 1 0/cl;
	estimate "No NEC, Day1"  int 1 nec 1 0 day 1  day*nec 1  0;
	estimate "No NEC, Day7"  int 1 nec 1 0 day 7  day*nec 7  0;
	estimate "No NEC, Day14" int 1 nec 1 0 day 14 day*nec 14 0;
	estimate "No NEC, Day21" int 1 nec 1 0 day 21 day*nec 21 0;
	estimate "No NEC, Day28" int 1 nec 1 0 day 28 day*nec 28 0;
	estimate "No NEC, Day40" int 1 nec 1 0 day 40 day*nec 40 0;
	estimate "No NEC, Day60" int 1 nec 1 0 day 60 day*nec 60 0/e;

	estimate "Yes NEC, intercept" int 1 nec 0 1/cl;
	estimate "    NEC, Day1"  int 1 nec 0 1 day 1  day*nec 0 1  ;
	estimate "    NEC, Day7"  int 1 nec 0 1 day 7  day*nec 0 7  ;
	estimate "    NEC, Day14" int 1 nec 0 1 day 14 day*nec 0 14 ;
	estimate "    NEC, Day21" int 1 nec 0 1 day 21 day*nec 0 21 ;
	estimate "    NEC, Day28" int 1 nec 0 1 day 28 day*nec 0 28 ;
	estimate "    NEC, Day40" int 1 nec 0 1 day 40 day*nec 0 40 ;
	estimate "    NEC, Day60" int 1 nec 0 1 day 60 day*nec 0 60 /e;
run;

proc mixed method=ml data=nec covtest;
	class id nec;
	model hb=nec day*nec/noint s;
	random int day/type=un subject=id;
run;
