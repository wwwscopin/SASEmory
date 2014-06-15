options ORIENTATION="LANDSCAPE";
*options ORIENTATION="PORTRAIT";
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

data hct0;
	set cmv.plate_015;
	if hct=. then delete;
	if hctdate=. then hctdate=BloodCollectDate;
	keep id hctDate hct;
run;

proc sql;
	create table hct as 
	select a.*, b.gender
	from hct0 as a, cmv.pat as b
	where a.id=b.id;
quit;

proc sort nodupkey; by id hctdate;run;


data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	rename laparotomydone=type;
	format type type.;
	lable type="NEC Type";
run;

proc sql;
	create table nec as 
	select a.*, necdate,type, NECResolveDate
	from hct as a, nec0 as b
	where a.id=b.id;
quit;

proc sort; by id hctdate; run;

data nec_date;
	set nec; by id hctdate;  
	retain start;
	if first.id then start=hctdate;
	if last.id then end=hctdate;
	if end=. then delete;
	format start end mmddyy8.;
run;

proc sort nodupkey; by id; run;
proc sort data=nec out=nec_date1; by id necdate; run;


data nec_date1;
	set nec_date1; by id necdate;
	if first.id then necd0=necdate;
	if first.id;
	keep id necd0;
	format necd0 mmddyy9.;
run;

data nec; 
	merge nec nec_date(keep=id start end) nec_date1; by id;
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
		;
run;

proc sort nodupkey; by id dt; run;

data nec; 
	merge nec(in=nec) tx(keep=id dt); by id;
	retain dt1;
	if first.id then dt1=dt;
	if nec;
	format dt1 mmddyy9.;
run;

proc sort; by id;run;

data nec_tx0;
	set nec;
	td=necd0-dt;
	if td>0;
run;

proc sort; by id td; run;

data  nec_tx1;
	set nec_tx0; by id td;
	retain dt2;
	if first.id then dt2=dt;
	if first.id;
	format dt2 mmddyy9.;
	keep id dt2;
run;

data nec;
	merge nec nec_tx1; by id;
run;

proc sort; by id gender type;run;

data one;
	set nec;
	xsys='2'; ysys='2';

	X=dt1; 	y=5; FUNCTION='LABEL'; when = 'A'; size=1; color='black'; text=put(dt1, date9.);  OUTPUT; 
	X=dt1; 	y=30; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='black';  OUTPUT; * start at mean ;
	y=10; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
	y=50; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;

	X=dt2; 	y=10; FUNCTION='LABEL'; when = 'A'; size=1; color='black'; text=put(dt2, date9.);  OUTPUT; 
	X=dt2; 	y=30; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='black';  OUTPUT; * start at mean ;
	y=10; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
	y=50; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;


	* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
	X=necdate; 	y=15; FUNCTION='LABEL'; when = 'A'; size=1; color='red'; text=put(necdate, date9.);  OUTPUT; * start at mean ;
	X=necdate; 	y=30; FUNCTION='MOVE'; when = 'A';line=1; size=2; color='red';  OUTPUT; * start at mean ;
	y=10; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='red';  OUTPUT; * draw down;
	y=50; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='red';  OUTPUT; * draw down;

	X=NECResolveDate; 	y=20; FUNCTION='LABEL'; when = 'A'; size=1; color='yellow'; text=put(NECResolveDate, date9.);  OUTPUT; * start at mean ;
	X=NECResolveDate; 	y=30; FUNCTION='MOVE'; when = 'A';line=2; size=2;   OUTPUT; * start at mean ;
	y=10; 	FUNCTION='DRAW'; when = 'A'; line=2; size=1; color='yellow';  OUTPUT; * draw down;
	y=50; 	FUNCTION='DRAW'; when = 'A'; line=2; size=1; color='yellow';  OUTPUT; * draw down;


	color='black';

	* draw a light gray rectangle ;
	if gender=1 then do;  
		function = 'move'; x = start; y = 37.7; output;
		function = 'BAR'; x = end; y = 46.5; color = 'ltgray'; style = 'empty'; line= 0; output;
	end;
	else if gender=2 then do;   			
		function = 'move'; x = start; y = 33.3; output;
		function = 'BAR'; x = end; y = 41.4; color = 'ltgray'; style = 'empty'; line= 0; output;
	end;


run;

proc print;run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions rotate = landscape;

axis1 	label=(f=zapf h=1.5 'Hematocrit Blood Collection Date' ) value=(f=zapf h=1.0) split="*";
axis2 	label=(f=zapf h=1.5 a=90 "Hematocrit(%)") order=(0 to 60 by 5) value=(f=zapf h=1);

symbol1 i=j ci=blue value=circle h=1 w=1;
symbol2 i=none ci=blue value=none h=1 w=1;


proc gplot data=nec gout=wbh.graphs; 
	by id gender type;
	plot hct*hctdate hct*NECResolveDate/overlay annotate=one vaxis=axis2 haxis=axis1; 
	format hctdate NECResolveDate date9. gender gender. type type.;
	label type="Type";
run;

       
ods pdf file="hct.pdf";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=l2r2s nofs;
		list igout;
		treplay 1:1 2:2 3:3 4:4; 			
		treplay 1:5 2:6 3:7 4:8; 	
		treplay 1:9 2:10 3:11 4:12; 			
	run;
ods pdf close;



