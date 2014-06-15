proc format;
  value grade   
        1 = "I" 2 = "II" 3 = "III" 4="IV" 99="Unilateral" 100="Total";
run;

data ivh0;
	set cmv.ivh_image(keep=id LeftIVHGrade RightIVHGrade ImageDate Imagetime); 	by id;
	format LeftIVHGrade RightIVHGrade grade. ;
run;

/*
proc sort; by id LeftIVHGrade RightIVHGrade ImageDate Imagetime;run;

data ivh0;
	set ivh0; by id LeftIVHGrade RightIVHGrade ImageDate Imagetime;
	if not first.Imagetime then mark=1; else mark=0;
run;

proc print;where mark=1;run;
*/

proc sql; 
	create table ivh as 
	select a.*
	from ivh0 as a , cmv.comp_pat as b
	where a.id=b.id;


proc sort nodupkey; by id ImageDate Imagetime;run;
proc print;run;

data ivh;
	set ivh; by id;
	if first.id;
run;

data _null_;
	set ivh;
	call symput ("n", compress(_n_));
run;

data _null_;
	set cmv.comp_pat;
	call symput ("n_total", compress(_n_));
run;


data ivh2;
	set ivh;
	where LeftIVHGrade in(2,3,4) or rightIVHGrade in (2,3,4);
run;

proc sort data=ivh; by LeftIVHGrade RightIVHGrade;run;

proc print;
	where LeftIVHGrade=99 and RightIVHGrade=99;
run;

data tab;
	do i=1 to 4; 
		do j=1 to 4; 
			LeftIVHGrade=i;  RightIVHGrade=j; output;
		end;
		RightIVHGrade=99; output;		RightIVHGrade=100; output;
	end;
	LeftIVHGrade=99; RightIVHGrade=99;output;
	drop i j;
	LeftIVHGrade=100;output; 
	format LeftIVHGrade RightIVHGrade grade.;
run;
proc sort; by LeftIVHGrade RightIVHGrade;run;

proc freq data=ivh;
tables LeftIVHGrade*RightIVHGrade/nocol norow nopct /*out=count*/;
ods output Freq.Table1.CrossTabFreqs=count1(drop=table  _TYPE_  _TABLE_ Missing);
run;

data count;
	set count1;
	if leftIVHGrade=. and RightIVHGrade^=. then leftIVHGrade=100;
	if leftIVHGrade^=. and RightIVHGrade=. then rightIVHGrade=100;
	if leftIVHGrade=. and RightIVHGrade=. then do; leftIVHGrade=100; rightIVHGrade=100; end;
	format leftIVHGrade grade.;
run;

proc sort; by LeftIVHGrade RightIVHGrade;run;
proc print;run;

data ivh_tab;
	merge tab count(rename=(frequency=nc)); by LeftIVHGrade RightIVHGrade;
run;

proc transpose out=ivh_tab; by LeftIVHGrade; var RightIVHGrade nc;run;
proc print;run;

data ivh_tab;
	set ivh_tab(where=(_NAME_="nc") rename=(col1=nc1 col2=nc2 col3=nc3 col4=nc4 col5=nc99 col6=nc));
	f1=nc1/nc*100; f2=nc2/nc*100; 	f3=nc3/nc*100; 	f4=nc4/nc*100; 	f99=nc99/nc*100; f=nc/&n*100; f_total=&n/&n_total*100;

	call symput("f",compress(put(f_total,4.0)));

	length nout1 nout2 nout3 nout4 nout99 nout $25;
	nout1=nc1||"("||compress(put(f1,4.0))||"%)";
	nout2=nc2||"("||compress(put(f2,4.0))||"%)";
	nout3=nc3||"("||compress(put(f3,4.0))||"%)";
	nout4=nc4||"("||compress(put(f4,4.0))||"%)";
	nout99=nc99||"("||compress(put(f99,4.0))||"%)";
	nout=nc||"/"||compress(&n)||"("||compress(put(f,4.0))||"%)";
	if LeftIVHGrade=100 then do;
		nout1=nc1||"/"||compress(&n)||"("||compress(put(f1,4.0))||"%)";
		nout2=nc2||"/"||compress(&n)||"("||compress(put(f2,4.0))||"%)";
		nout3=nc3||"/"||compress(&n)||"("||compress(put(f3,4.0))||"%)";
		nout4=nc4||"/"||compress(&n)||"("||compress(put(f4,4.0))||"%)";
		nout99=nc99||"/"||compress(&n)||"("||compress(put(f99,4.0))||"%)";
		nout=nc||"/"||compress(&n_total)||"("||compress(put(f_total,4.0))||"%)";
	end;
	drop  _NAME_    _LABEL_;
run;

proc print;run;

ods rtf file="ivh_first.rtf" style=journal;
proc report data=ivh_tab nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];

	title "Imaging: Left IVH Grade by Right IVH Grade(n=&n/&n_total,&f%)";

	where LeftIVHGrade^=4;
	column LeftIVHGrade ("-------------------------------------- Right IVH Grade --------------------------------------" nout1-nout4 nout99) nout;
	define LeftIVHGrade/ order order=data "Left IVH Grade" style(column)=[cellwidth=1.0in just=center];
	define nout1/"I" style(column)=[cellwidth=1.0in just=center] ;
	define nout2/"II" style(column)=[cellwidth=1.0in just=center];
	define nout3/"III" style(column)=[cellwidth=1.0in just=center] ;
	define nout4/"IV" style(column)=[cellwidth=1.0in just=center] ;
	define nout99/"Unilateral" style(column)=[cellwidth=1.0in just=center] ;
	define nout/"Total" style(column)=[cellwidth=1.0in just=center] ;
run;
ods rtf close;
