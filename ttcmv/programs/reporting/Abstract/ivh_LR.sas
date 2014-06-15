proc format;
  value grade   
        1 = "I" 2 = "II" 3 = "III" 4="IV" 99="Unilateral";
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

proc print;run;
proc sort nodupkey; by id ImageDate Imagetime;run;

/*
data ivh;
	set ivh; by id;
	if first.id;
run; 
*/
proc sort nodupkey out=ivh_id; by id;run; 
proc print;run;

data _null_;
	set ivh_id;
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
proc sort nodupkey out=ivh2_id; by id;run;
proc print;run;


proc sort data=ivh; by LeftIVHGrade RightIVHGrade;run;
proc sort data=ivh nodupkey out=LR; by LeftIVHGrade RightIVHGrade id;run;

data tab;
	do i=1 to 4; 
		do j=1 to 4; 
			LeftIVHGrade=i;  RightIVHGrade=j; output;
		end;
		RightIVHGrade=99; output;
	end;
	LeftIVHGrade=99; RightIVHGrade=99;output;
	drop i j;
	format LeftIVHGrade RightIVHGrade grade.;
run;

proc freq data=ivh;
tables LeftIVHGrade*RightIVHGrade/nocol norow nopct out=count;
run;

proc print;run;

proc freq data=LR;
tables LeftIVHGrade*RightIVHGrade/nopct out=count_id;
run;

data ivh_tab;
	merge tab count(drop=percent rename=(count=nc)) count_id(drop=percent rename=(count=n)); by LeftIVHGrade RightIVHGrade;
run;

proc transpose out=ivh_tab; by LeftIVHGrade; var RightIVHGrade nc n;run;
proc print;run;

data ivh_tab;
	merge ivh_tab(where=(_NAME_="nc") rename=(col1=nc1 col2=nc2 col3=nc3 col4=nc4 col5=nc99))
			 ivh_tab(where=(_NAME_="n") rename=(col1=n1 col2=n2 col3=n3 col4=n4 col5=n99));

	
	if n1=.  then n1=0;
	if n2=.  then n2=0;
	if n3=.  then n3=0;
	if n4=.  then n4=0;
	if n99=. then n99=0;

	if nc1=.  then nc1=0;
	if nc2=.  then nc2=0;
	if nc3=.  then nc3=0;
	if nc4=.  then nc4=0;
	if nc99=. then nc99=0;

	nf1=n1/&n*100; nf2=n2/&n*100; nf3=n3/&n*100; nf4=n4/&n*100; nf99=n99/&n*100;
	nc=nc1+nc2+nc3+nc4+nc99;
	n=n1+n2+n3+n4+n99;
	nf=n/&n*100;
	nout1=nc1||"/"||compress(n1)||"("||put(nf1,4.1)||"%)";
	nout2=nc2||"/"||compress(n2)||"("||put(nf2,4.1)||"%)";
	nout3=nc3||"/"||compress(n3)||"("||put(nf3,4.1)||"%)";
	nout4=nc4||"/"||compress(n4)||"("||put(nf4,4.1)||"%)";
	nout99=nc99||"/"||compress(n99)||"("||put(nf99,4.1)||"%)";
	nout=nc||"/"||compress(n)||"("||put(nf,4.1)||"%)";


	*if LeftIVHGrade=4 then delete;
run;

ods rtf file="ivh_table.rtf" style=journal;

proc report nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];

	title "Imaging: Left IVH Grade by Right IVH Grade(n=&n/&n_total,%sysevalf(&n/&n_total*100, integer)%)";
	
	column LeftIVHGrade ("-------------------------------------- Right IVH Grade --------------------------------------" nout1-nout4 nout99) nout;
	define LeftIVHGrade/"Left IVH Grade" style(column)=[cellwidth=1.5in just=center];
	define nout1/"I" style(column)=[cellwidth=1in just=center];
	define nout2/"II" style(column)=[cellwidth=1in just=center];
	define nout3/"III" style(column)=[cellwidth=1in just=center];
	define nout4/"IV" style(column)=[cellwidth=1in just=center];
	define nout99/"Unilateral" style(column)=[cellwidth=1in just=center];
	define nout/"Total" style(column)=[cellwidth=1in just=center];
run;
ods rtf close;
