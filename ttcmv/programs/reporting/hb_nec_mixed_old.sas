*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT" nodate;
libname wbh "/ttcmv/sas/programs";	

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
	keep id HbDate Hb;
run;

proc sql;
	create table hb as 
	select a.*, b.gender
	/*from hb0 as a, cmv.comp_pat as b*/
	from hb0 as a, cmv.plate_005 as b
	where a.id=b.id;
quit;

proc sort nodupkey; by id hbdate;run;


data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	rename laparotomydone=type;
	format type type.;
	lable type="NEC Type";
run;

proc print;run;

proc sql;
	create table nec as 
	select a.*, necdate,type, NECResolveDate
	from hb as a, nec0 as b
	where a.id=b.id;
quit;

proc sort; by id hbdate; run;

data nec_date;
	set nec; by id hbdate;  
	retain start;
	if first.id then start=hbdate;
	if last.id then end=hbdate;
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

	X=dt1; 	y=6; FUNCTION='LABEL'; when = 'A'; size=1; color='black'; text=put(dt1, date9.);  OUTPUT; 
	X=dt1; 	y=10; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='black';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;

	X=dt2; 	y=7; FUNCTION='LABEL'; when = 'A'; size=1; color='black'; text=put(dt2, date9.);  OUTPUT; 
	X=dt2; 	y=10; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='black';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;


	* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
	X=necdate; 	y=8; FUNCTION='LABEL'; when = 'A'; size=1; color='red'; text=put(necdate, date9.);  OUTPUT; 
	X=necdate; 	y=10; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='red';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='red';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='red';  OUTPUT; * draw down;


	X=NECResolveDate; 	y=9; FUNCTION='LABEL'; when = 'A'; size=1; color='green'; text=put(NECResolveDate, date9.);  OUTPUT; 
	X=NECResolveDate; 	y=10; FUNCTION='MOVE'; when = 'A'; line=3; size=2; color='green';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=2; size=1; color='green';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=2; size=1; color='green';  OUTPUT; * draw down;
	
	color='black';

	* draw a light gray rectangle ;
	if gender=1 then do;  
		function = 'move'; x = start; y = 12.9; output;
		function = 'BAR'; x = end; y = 16.1; color = 'cyan'; style = 'empty'; line= 0; output;
	end;
	else if gender=2 then do;   			
		function = 'move'; x = start; y = 11.4; output;
		function = 'BAR'; x = end; y = 14.4; color = 'cyan'; style = 'empty'; line= 0; output;
	end;

run;

data one1;
	set one;
	where id=1000211;
	if type=1 and color='red' then color='orange';
run;
proc print;run;

proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions /*rotate = landscape*/;

axis1 	label=(f=zapf h=1.5 'Hemoglobin Blood Collection Date' )  value=(f=zapf h=1.0) split="*";
axis2 	label=(f=zapf h=1.5 a=90 "Hemoglobin(g/dL)") order=(5 to 20 by 1) value=(f=zapf h=1);

symbol1 i=j ci=blue value=circle h=1 w=1;
symbol2 i=none ci=blue value=none h=1 w=1;

data nec1;
	set nec;
	where id=1000211;
	if type=1 then type=0;
run;

proc sort; by hbdate necdate;run;
proc print data=nec1;
where id=1000211;
run;

proc gplot data=nec1 gout=wbh.graphs; 
	where id=1000211;
	by id gender /*type*/;
	plot hb*hbdate hb*NECResolveDate/overlay annotate=one1 vaxis=axis2 haxis=axis1;
	format hbdate dt2 date9. gender gender. /*type type.*/;
	/*label type="Type"*/;
	
	note f='zapf / it' m=(12,-2) h=1.0 "* red->Medical NEC; pink->Surgical NEC";
run;

proc gplot data=nec gout=wbh.graphs; 
	where id^=1000211 and type=0;
	by id gender type;
	plot hb*hbdate hb*NECResolveDate/overlay annotate=one vaxis=axis2 haxis=axis1;
	format hbdate dt2 date9. gender gender. type type.;
	label type="Type";
run;

proc gplot data=nec gout=wbh.graphs; 
	where id^=1000211 and type=1;
	by id gender type;
	plot hb*hbdate hb*NECResolveDate/overlay annotate=one vaxis=axis2 haxis=axis1;
	format hbdate dt2 date9. gender gender. type type.;
	label type="Type";
run;




ods pdf file="hb.pdf";
/*
	proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s nofs;
		list igout;
		treplay 1:1 2:2 ;	
	run;
*/
proc greplay nofs NOBYLINE;
igout wbh.graphs;
list igout;
tc template;
tdef t1 4 /llx=5    ulx=5   lrx=50   urx=50  lly=0    uly=25    lry=0      ury=25
        3 /llx=5    ulx=5   lrx=50   urx=50  lly=25   uly=50    lry=25     ury=50
        2 /llx=5    ulx=5   lrx=50   urx=50  lly=50   uly=75    lry=50     ury=75
        1 /llx=5    ulx=5   lrx=50   urx=50  lly=75   uly=100   lry=75     ury=100
        8 /llx=50   ulx=50  lrx=95   urx=95  lly=0    uly=25    lry=0      ury=25
        7 /llx=50   ulx=50  lrx=95   urx=95  lly=25   uly=50    lry=25     ury=50
        6 /llx=50   ulx=50  lrx=95   urx=95  lly=50   uly=75    lry=50     ury=75
        5 /llx=50   ulx=50  lrx=95   urx=95  lly=75   uly=100   lry=75     ury=100
                                                ;
template t1;
tplay 1:1 2:2 3:3 4:4 5:5 6:6 7:7 8:8;
run;

proc greplay nofs NOBYLINE;
igout wbh.graphs;
list igout;
tc template;
tdef t1 4 /llx=5    ulx=5   lrx=50   urx=50  lly=0    uly=25    lry=0      ury=25
        3 /llx=5    ulx=5   lrx=50   urx=50  lly=25   uly=50    lry=25     ury=50
        2 /llx=5    ulx=5   lrx=50   urx=50  lly=50   uly=75    lry=50     ury=75
        1 /llx=5    ulx=5   lrx=50   urx=50  lly=75   uly=100   lry=75     ury=100
        8 /llx=50   ulx=50  lrx=95   urx=95  lly=0    uly=25    lry=0      ury=25
        7 /llx=50   ulx=50  lrx=95   urx=95  lly=25   uly=50    lry=25     ury=50
        6 /llx=50   ulx=50  lrx=95   urx=95  lly=50   uly=75    lry=50     ury=75
        5 /llx=50   ulx=50  lrx=95   urx=95  lly=75   uly=100   lry=75     ury=100
                                                ;
template t1;
tplay 1:9 2:10 3:11 4:12 5:13 6:14 7:15 8:16;
run;

ods pdf close;

