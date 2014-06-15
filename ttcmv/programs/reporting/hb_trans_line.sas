*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT";
libname wbh "/ttcmv/sas/programs";	

data hb0;
	set cmv.plate_015;
	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	keep id HbDate Hb;
run;

proc sort nodupkey; by id hbdate;run;

data rbc;
	set cmv.plate_031;
	rbc_txt0=HMS(scan(rbc_TxStartTime,1,":"), scan(rbc_TxStartTime,2,":"), 0 ); 
	rbc_txt1=HMS(scan(rbc_TxEndTime,1,":"), scan(rbc_TxEndTime,2,":"), 0 ); 
	rbc_txt=rbc_txt1-rbc_txt0; if rbc_txt<0 then rbc_txt=rbc_txt+24*3600;
	
	keep id BodyWeight rbc_TxStartTime DateHbHct DateTransfusion Hb HbHctTest Hct TimeHbHct rbcVolumeTransfused rbc_TxEndTime rbc_TxStartTime rbc_txt;
	rename DateHbHct=hbdate;
run;

proc sort nodupkey; by id DateTransfusion; run;

data rbc_tx;
	set rbc; by id DateTransfusion;
	if first.id;
run;

data hb;
	set hb0 rbc(keep=id hbdate Hb); by id;
	if hb>25 then hb=.;
	if hb=. or hbdate=. then delete;
	keep id hb hbdate;
run;

proc sort nodupkey; by id hbdate;run;

proc sql;
	create table trans0 as
	select a.*, DateTransfusion, a.Hbdate-DateTransfusion as day 
	from hb as a, rbc_tx as b
	where a.id=b.id;
;

data trans;
    merge trans0 cmv.nec_p1(in=tmp keep=id) cmv.comp_pat(keep=id center in=comp); by id;
    if comp;
    if tmp then nec=1; else nec=0;
    if -14<=day<=14;
run;

proc sort; by center nec id day;run;

proc sgplot data=trans noautolegend;   
   by center nec;                                                                                                   
   series x=day y=hb/ group=id lineattrs=(pattern=solid color=blue) /*markers  markerattrs=(symbol=circlefilled)*/;                                                                                              
   xaxis label="Age Before/After First RBC Tx" values=(-8 to 8 by 1);                                                                                       
   yaxis label="Hemoglobin" values=(0 to 25 by 2);                                                                                        
   title "Hemoglogin by Center";                                                                                                                                                                                                                                 
run;            

options orientation=landscape;
proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all BORDER device=pslepsfc rotate=landscape gsfmode=replace ;

symbol i=j ci=blue repeat=100;
axis1 	label=(h=3 'Age Before/After First RBC Tx' ) value=(h=1.25) split="*" order= (-15 to 15 by 1) minor=none offset=(0 in, 0 in);
axis2 	label=(h=3 a=90 "Hemoglobin(g/dL)") value=(h=2)  order= (5 to 21 by 1);
   
*ods pdf file="test.pdf";
proc gplot data=trans gout=wbh.graphs;   
   by center nec;                                                                                                 
   plot hb*day=id/nolegend haxis = axis1 vaxis = axis2 href=0 CHREF=red lhref=2;                                                                                  
   title "Hemoglogin by Center";
   format nec yn.;                                                                                                                                                                                                                                 
run; 
*ods pdf close;


options orientation=portrait ;
*filename output 'test.eps';
goptions reset=all BORDER device=pslepsfc gsfname=output rotate=portrait gsfmode=replace ;

ods pdf file="Hb_tx_line.pdf" ;
	proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s nofs;
			list igout;
			treplay 1:1 2:2; 
			treplay 1:3 2:4; 
			treplay 1:5 2:6; 
run;
ods  pdf close;
