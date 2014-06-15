option nodate nonumber;
data nec;
	set cmv.nec_p1(keep=id necdate) ; by id;
	if first.id;
run;

proc sort data=cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime) nodupkey out=tx_rbc;by id DateTransfusion rbc_TxStartTime; run;

data total_rbc;
	merge tx_rbc(keep=id DateTransfusion in=rbc) nec(keep=id necdate in=tmp) 
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.nec_id(keep=id nidx) cmv.comp_pat(keep=id in=comp); by id;
	if bell then nec=1; else nec=0;
    if rbc and not nec then nidx=0;
    if nidx=. then do; nidx=9; end;
    if comp;
    tx=1;
    if tmp then if DateTransfusion>necdate then tx=0;
run;

proc means data=total_rbc;
    class nidx;
    var tx;
    output out=wbh sum(tx)=num;
run;

data _null_;
    set wbh;
    if nidx=0 then call symput("m0", compress(num));
        if nidx=1 then call symput("m1", compress(num));
            if nidx=2 then call symput("m2", compress(num));
                if nidx=3 then call symput("m3", compress(num));
                    if nidx=9 then call symput("m9", compress(num));    
                        if nidx=. then call symput("m", compress(num));
run;


data rbc;
    set tx_rbc; by id DateTransfusion rbc_TxStartTime;
   	if first.id then do; nrbc=0; end;
   	nrbc+1;
    if last.id;
run;

data nec_rbc;
    merge tx_rbc(in=tx) nec(in=tmp); by id;
    if tmp then if DateTransfusion>necdate then delete;
run;

proc sort; by id DateTransfusion rbc_TxStartTime; run;

data nec_rbc; 
    set nec_rbc; by id DateTransfusion rbc_TxStartTime;
    if first.id then do; mrbc=0; end;
   	mrbc+1;
    if last.id;
 run;
 



data nrbc;
	merge rbc(keep=id nrbc in=rbc) nec_rbc(keep=id mrbc) cmv.nec_id(keep=id nidx in=nec) cmv.comp_pat(keep=id in=comp); by id;
    if rbc and not nec then nidx=0;
    if nidx=3 then mrbc=0;
    if nidx=. then do; nidx=9; nrbc=0; mrbc=0; end;
    if comp;
    if nrbc>=10 then nrbc=10;
    if mrbc>=10 then mrbc=10;
run;

proc print;
where nidx=. or mrbc=.;
run;


proc freq; 
tables mrbc*nidx/nocol norow nopercent;
ods output crosstabfreqs=test; 
run;


data _null_;
    set test(where=(_type_="01" or _type_="00")); 
    if nidx=0 then call symput("n0", compress(frequency));
        if nidx=1 then call symput("n1", compress(frequency));
            if nidx=2 then call symput("n2", compress(frequency));
                if nidx=3 then call symput("n3", compress(frequency));
                    if nidx=9 then call symput("n9", compress(frequency));    
                        if nidx=. then call symput("n", compress(frequency));
run;

data tab_rbc; 
    set test;
    keep mrbc nidx frequency;
    if _type_='11' or _type_='10';
run;

proc transpose data=tab_rbc out=rbc_tab; var frequency; by mrbc; run;

proc format; 
value nm 0="No Tx"
         1="Tx=1" 2="2" 3="3" 4="4" 5="5" 6="6" 7="7" 8="8" 9="9"
         10="10+" 99="Total*"
         ;
run;

data rbc_tab;
    set rbc_tab; output;
    if _n_=1 then do; mrbc=99; col1=&m0; col2=&m1; col3=&m2; col4=&m3; col5=&m9; col6=&m; output; end; 
run;  

proc sort; by mrbc; run;  

ods rtf file="nec_rbc.rtf" style=journal bodytitle; 
proc report data=rbc_tab nowindows split="*" style(column)=[just=center] STYLE (HEADER) = [FONT_WEIGHT = BOLD];
title "pRBC Transfusion by Groups";
col mrbc col2-col4 col1 col5-col6;
define mrbc/"Num of Tx" order order=internal format=nm.  style=[cellwidth=0.75in];
define col1/"pRBC Transfused without NEC*(n=&n0)" style=[cellwidth=1.25in];
define col2/"pRBC Transfused <=48 hrs before NEC*(n=&n1)" style=[cellwidth=1.5in];
define col3/"pRBC Transfused >48 hrs before NEC*(n=&n2)" style=[cellwidth=1.4in];
define col4/"pRBC Transfused after NEC*(n=&n3)" style=[cellwidth=1.25in];
define col5/"No pRBC Tranfused*(n=&n9)" style=[cellwidth=0.75in];
define col6/"Overall*(n=&n)" style=[cellwidth=0.75in];
run;
ODS ESCAPECHAR="^";
ods rtf text = "^S={LEFTMARGIN=1in RIGHTMARGIN=0.5in font_size=11pt}
*Includes only transfusions prior to NEC for NEC cases."; 
ods rtf close;
