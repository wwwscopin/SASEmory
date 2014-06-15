*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT" nodate nobyline nonumber nofmterr;
libname wbh "/ttcmv/sas/programs";	
libname die "/ttcmv/sas/data";

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

data rbc;
	set cmv.plate_031;
    keep id DateTransfusion Hb DateHbHct;
	rename DateHbHct=hbdate;
run;
proc sort nodupkey; by id DateTransfusion; run;

data hb0;
	set cmv.plate_015 rbc(keep=id hbdate Hb); by id;
	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	keep id HbDate Hb;
run;

proc sql;
	create table hb as 
	select a.*, b.gender
	from hb0 as a, cmv.plate_005 as b
	where a.id=b.id;
quit;

proc sort nodupkey; by id hbdate;run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	
	rename laparotomydone=type;
	format type type.;
	label type="NEC Type";
run;

proc sql;
	create table nec as 
	select a.*, necdate,type, NECResolveDate
	from hb as a, nec0 as b
	where a.id=b.id;
quit;

proc sort; by id hbdate; run;

data nec_date;
	set nec; by id hbdate;  
	retain start0;
	if first.id then start0=hbdate;
	if last.id then end0=hbdate;
	if end0=. then delete;
	format start0 end0 mmddyy8.;
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
	merge nec nec_date(keep=id start0 end0) nec_date1; by id;
run;

data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
			/*cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/;

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	/*if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0; 
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */

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
	if td>=0;
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

proc contents data=cmv.km;run;

data nec;
	merge nec(in=tmp) nec_tx1 cmv.plate_006(keep=id gestage) 
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.comp_pat(in=comp) die.death(in=died); by id;
    *if dt1=. then delete;
    if bell;
    if 18<=gestage<=21 then do; hb_lower=11.69-1.96*1.27;  hb_upper=11.69+1.96*1.27;  end;
        if 22<=gestage<=25 then do; hb_lower=12.20-1.96*1.60;  hb_upper=12.20+1.96*1.60;  end;
            if 26<=gestage<=29 then do; hb_lower=12.91-1.96*1.38;  hb_upper=12.91+1.96*1.38;  end;
               if 30<=gestage then do; hb_lower=13.64-1.96*2.21;  hb_upper=13.64+1.96*2.21;  end;
    if tmp and comp;               
    if died then death=1; else death=0;
    start=min(of start0 end0 dt1 dt2 necdate NECResolveDate);
    end=max(of start0 end0 dt1 dt2 necdate NECResolveDate);
    if end=NECResolveDate then end=end+1;
    if id=1000211 then end=mdy(06,23,10)+1;
    if id=2013511 then end=mdy(12,30,11)+1;
	format start end mmddyy8.;
run;

proc sort; by id gender type;run;

proc print;
var id hb dt1 dt2 necdate NECResolveDate death start end;
run;

data one;
    length text $30;
	set nec;
	xsys='2'; ysys='2';

 
	X=dt1; 	y=6.5; FUNCTION='LABEL'; when = 'A'; size=0.9; color='black'; text=put(dt1, date9.);  
	
  	X=dt1; 	y=10; FUNCTION='MOVE';   when = 'A'; line=1; size=2; color='black';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;

	X=dt2; 	y=7.5; FUNCTION='LABEL'; when = 'A'; size=0.9; color='black'; text=put(dt2, date9.); 
    if dt2=dt1 then text="";  
  	X=dt2; 	y=10; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='black';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;


	* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
	X=necdate; 	y=8.5; FUNCTION='LABEL'; when = 'A'; size=0.9; color='red'; text=put(necdate, date9.);  
	if necdate=dt1 or necdate=dt2 then text=put(necdate, date9.)||"(Transfused)"; 
	OUTPUT; 
	X=necdate; 	y=10; FUNCTION='MOVE'; when = 'A'; line=1; size=2; color='red';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='red';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='red';  OUTPUT; * draw down;


	X=NECResolveDate; 	y=9.5; FUNCTION='LABEL'; when = 'A'; size=0.9; color='green'; text=put(NECResolveDate, date9.);
	if NECResolveDate=dt1 or NECResolveDate=dt2 then text=put(NECResolveDate, date9.)||"(Transfused)"; 
 
	if id=1003111 then text=put(NECResolveDate, date9.)||"(Died)";  
	if id=1003411 then text=put(NECResolveDate, date9.)||"(Died)";  
	if id=1011311 then text=put(NECResolveDate, date9.)||"(Died)";
	if id=1020211 then text=put(NECResolveDate, date9.)||"(Died)";
	if id=1007011 then text=put(NECResolveDate, date9.)||"(Died)";  
	
	if id=3040411 then text=put(NECResolveDate, date9.)||"(Died)";  
	if id=3056111 then text=put(NECResolveDate, date9.)||"(Died)";  
    *if id=3040411 then text=put(NECResolveDate, date9.)||"(Died)";  
	*if id=3040411 then text=put(NECResolveDate, date9.)||"(Died)";  
	*if id=3040411 then text=put(NECResolveDate, date9.)||"(Died)";  
	OUTPUT; 
	X=NECResolveDate; 	y=10; FUNCTION='MOVE'; when = 'A'; line=3; size=2; color='green';  OUTPUT; * start at mean ;
	y=8; 	FUNCTION='DRAW'; when = 'A'; line=2; size=1; color='green';  OUTPUT; * draw down;
	y=15; 	FUNCTION='DRAW'; when = 'A'; line=2; size=1; color='green';  OUTPUT; * draw down;
	
	color='black';

	* draw a light gray rectangle ;
	

	function = 'move'; x = start; y = hb_lower; output;
	function = 'BAR'; x = end; y = hb_upper; color = 'cyan'; style = 'empty'; line= 0; output;

run;

data one1;
	set one;
	where id in(1000211, 2013511);
	if type=1 and color='red' then color='brown';
run;

proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions /*rotate = landscape*/ device=jpeg ftext=cent FTITLE=cent FBY=cent;

axis1 	label=(h=1.5 'Hemoglobin Blood Collection Date' )  value=( h=1) split="*" minor=none offset=(.25 in, 0 in);
axis2 	label=(h=1.5 a=90 "Hemoglobin(g/dL)") order=(6 to 20 by 2) value=(h=1) minor=none;

symbol1 i=j ci=blue value=circle h=1 w=1;
symbol2 i=none ci=blue value=none h=1 w=1;

data nec1;
	set nec;
	where id in(1000211, 2013511);
	if type=1 then type=0;
run;

proc sort; by hbdate necdate;run;

proc gplot data=nec1 gout=wbh.graphs; 
	where id in(1000211, 2013511);
	title h=1.25 "ID=#byval(id) Gender=#byval(gender) Type=Medical + Surgical NEC";
	by id gender /*type*/;
	plot hb*hbdate hb*NECResolveDate/overlay annotate=one1 vaxis=axis2 haxis=axis1 vref=9 lvref=20;
	format hbdate dt2 mmddyy. gender gender. /*type type.*/;
	/*label type="Type"*/;
	
	 note m=(15,-2) h=1 "* red->Medical NEC; brown->Surgical NEC";
	 if id=1000211 then do;
        note m=(18,-3) h=1 "Black->1st or the closest Hb measured date(Before NEC)";
        note m=(18,-3.75) h=1 "Red(Brown)->NEC diagnosis date";
        note m=(18,-4.5) h=1 "Green->NEC resolved date";
        note m=(18,-5.25) h=1 "Cyan->Hb normal range";
	 end;
run;


proc gplot data=nec gout=wbh.graphs; 
	title h=1.25 "ID=#byval(id) Gender=#byval(gender) Type=#byval(type)";
	where id  not in(1000211, 2013511) and type=0;
	by id gender type;
	plot hb*hbdate hb*NECResolveDate/overlay annotate=one vaxis=axis2 haxis=axis1 vref=9 lvref=20;
	format hbdate dt2 mmddyy. gender gender. type type.;
	label type="Type";
run;


proc gplot data=nec gout=wbh.graphs; 
	title h=1.25 "ID=#byval(id) Gender=#byval(gender) Type=#byval(type)";
	where id not in(1000211, 2013511) and type=1;
	by id gender type;
	plot hb*hbdate hb*NECResolveDate/overlay annotate=one vaxis=axis2 haxis=axis1 vref=9 lvref=20;
	format hbdate dt2 mmddyy. gender gender. type type.;
	label type="Type";
run;


filename output 'hb.eps';
goptions reset=all rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

ods pdf file="hb.pdf";
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
tplay 1:9 2:10 3:11 4:12 5:13 6:14 7:15 8:16;
tplay 1:17 2:18 3:19 4:20 5:21 6:22 7:23 8:24;
tplay 1:25 2:26 3:27 4:28 5:29 6:30 7:31 8:32;
run;
ods pdf close;
