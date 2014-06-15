options nodate nonumber orientation=landscape;

proc format; 
    value center 0="Overall" 1="Midtown" 2="Grady" 3="Northside";
    value type 1="Conventional" 2="Oscillator" 3="CPAP" 9="-- Any Vent Type --";
run;


data all_pat;
	set cmv.comp_pat(keep=id);
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;

proc means data=all_pat noprint;
	class center;
	output out=n_pat n(center)=num;
run;

data n_pat;
	set n_pat(drop=_TYPE_ _FREQ_);
 	if center=1  then call symput("n1", compress(put(num,3.0)));
 	if center=2  then call symput("n2", compress(put(num,3.0)));
 	if center=3  then call symput("n3", compress(put(num,3.0)));

 	if center=.  then do; 
		center=0;
		call symput("n_total", compress(put(num,3.0)));
	end;
run;



%macro mv(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 10;
		center=floor(id/1000000);
		VentType=VentType&i;
		StartDate=StartDate&i;
		EndDate=EndDate&i;
		day=EndDate-StartDate;
		InitialFio2=InitialFio2_&i;
		FinalFio2=FinalFio2_&i;
		Fio2=FinalFio2-InitialFio2;
		comment=comment&i;
		i=&i;
		
		output;
	%end;
	   
	   if venttype=99 then delete;
	   keep id center VentType StartDate EndDate day InitialFio2 FinalFio2 Fio2 comment i; 
	   format venttype type. StartDate EndDate mmddyy8. center center.;
run;
%mend;

%mv(cmv.mechvent);quit;

data tmp;
    set tmp;
    if venttype=99 then delete;
run;


proc sort; by id venttype;run;


proc sql; 

	create table tmp as
	select tmp.*
	from tmp, all_pat
	where tmp.id=all_pat.id
;


proc means data=tmp sum noprint;
    class id venttype;
    var day;
    output out=vent(where=(id^=. and venttype^=. and sday>0) keep=id venttype sday) sum(day)=sday;
run;

data vent;
    merge vent cmv.plate_005(keep=id LBWIDOB) cmv.endofstudy(keep=id StudyLeftDate); by id;
	center=floor(id/1000000);
	
	if sday>StudyLeftDate-lbwidob then sday=StudyLeftDate-lbwidob;
	
	/* For temparily coding here*/
    if id=3033611 then sday=64;
    if id=3041211 then sday=10;
    
run;

proc means data=vent median;
    class center venttype;
    var sday;
    output out=temp(where=(venttype^=.) keep=center venttype median n) median(sday)=median n(sday)=n;
run;

data mech_vent;
    set temp;
    if center=. then center=0;
    if center=0 then do; f=n/&n_total*100; nf=compress(n)||"/"||compress(&n_total)||"("||compress(put(f,4.2))||"%)"; end;
    if center=1 then do; f=n/&n1*100; nf=compress(n)||"/"||compress(&n1)||"("||compress(put(f,4.2))||"%)"; end;
    if center=2 then do; f=n/&n2*100; nf=compress(n)||"/"||compress(&n2)||"("||compress(put(f,4.2))||"%)"; end;
    if center=3 then do; f=n/&n3*100; nf=compress(n)||"/"||compress(&n3)||"("||compress(put(f,4.2))||"%)"; end;
run;

proc means data=tmp sum noprint;
    class id;
    var day;
    output out=vent0(where=(id^=. and sday>0) keep=id sday) sum(day)=sday;
run;

data vent0;
    merge vent0(in=A) cmv.plate_005(keep=id LBWIDOB) cmv.endofstudy(keep=id StudyLeftDate); by id;
    if A;	
    if sday>StudyLeftDate-lbwidob then sday=StudyLeftDate-lbwidob;

	/* For temparily coding here*/
    if id=3033611 then sday=64;
    if id=3041211 then sday=10;
run;


proc means data=vent0;
var sday;
run;


proc means data=vent0 median noprint;
    var sday;
    output out=temp0 median(sday)=median n(sday)=n;
run;

data any_vent;
    set temp0;
    center=0; 
    venttype=9;
    f=n/&n_total*100;
    nf=compress(n)||"/"||compress(&n_total)||"("||compress(put(f,4.2))||"%)";
    keep center venttype median n nf f;   
run;


data mech_vent;
    set mech_vent any_vent;
run;
proc sort;by center venttype; run;
   

**********************************************************************************;

proc means data=tmp;
    class center venttype;
	var InitialFio2 FinalFio2;
	output out=mv median(InitialFio2)=median_Initial median(FinalFio2)=median_Final;
run;

data mv;
    set mv;
    if center^=. and venttype=. then delete;
    if center=. then center=0;
    if venttype=. then venttype=9;
    keep center venttype median_initial median_final;
run;

proc sort; by center venttype;run;

data mech_vent;
    merge mech_vent mv; by center venttype;
    format center center. venttype type.;   
run;


title "Mechanical Ventilation (n=&n_total)";
ods printer printer="PostScript EPS Color" file = "mechvent.eps" style=journal;
ods rtf file="mechvent.rtf" style=journal bodytitle;
ods ps file="mechvent.ps" style=journal;
proc print data=mech_vent noobs label split='*' style=[just=center];

	by center;
	id center;
	var venttype/style=[CELLWIDTH=1.5in just=left];
	var nf median median_initial median_final /style= [CELLWIDTH=1.25in just=center];

 label 	nf='Ever Used(%)'
			center='Center'
			median_initial='Median* Initial FiO2'
			Median_final='Median* Final FiO2'
			median="Median Days on Ventilation"
			venttype="Vent Type"
	;
run;
ods ps close;
ods rtf close;
ods printer close;
