options ORIENTATION=LANDSCAPE nodate nonumber;
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

data hb;
    merge hb0 cmv.completedstudylist(in=comp); by id;
    if 0<hb<=9 then anemia9=1; else anemia9=0;
    if 0<hb<=8 then anemia8=1; else anemia8=0;
    if 0<hb<=7 then anemia7=1; else anemia7=0;
    if comp;
run;
proc sort; by id; run;
ods pdf file="hb_anemia.pdf";
ods graphics on / reset=index width=12in height=9in;
proc sgplot data=hb(where=(hb<=9));
    histogram hb;
    label hb="Hemoglobin(g/dL)";
run;
ods graphics off;
ods pdf close;

proc sql; 
    create table anemia as
    select *, sum(anemia9) as m_anemia9,
    sum(anemia8) as m_anemia8,
    sum(anemia7) as m_anemia7
    from hb
    group by id;
    
  
proc sort data=anemia out=anemia nodupkey; by id; run;
proc freq; table (m_anemia9 m_anemia8 m_anemia7);run;


