proc format;
  value grade   
        1 = "I" 2 = "II" 3 = "III" 4="IV" 99="N/A";
run;

data ivh0;
	set cmv.ivh_image(keep=id LeftIVHGrade RightIVHGrade); 	by id;
	format LeftIVHGrade RightIVHGrade grade. ;
run;

proc sql; 
	create table ivh as 
	select a.*
	from ivh0 as a , cmv.comp_pat as b
	where a.id=b.id;
proc sort nodupkey out=ivh_id; by id;run; 
proc print;run;

data _null_;
	set ivh_id;
	call symput ("n", compress(_n_));
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

proc freq data=LR;
tables LeftIVHGrade*RightIVHGrade/nopct out=count_id;
run;

data ivh_tab;
	merge tab count(drop=percent rename=(count=nc)) count_id(drop=percent rename=(count=n)); by LeftIVHGrade RightIVHGrade;
run;

proc transpose out=ivh_tab; by LeftIVHGrade; var RightIVHGrade nc n;run;
proc contents;run;
proc print;run;

data ivh_tab;
	merge ivh_tab(where=(_NAME_="nc") rename=(col1=nc1 col2=nc2 col3=nc3 col4=nc4 col5=nc99))
			 ivh_tab(where=(_NAME_="n") rename=(col1=n1 col2=n2 col3=n3 col4=n4 col5=n99));
	nf1=n1/&n*100; nf2=n2/&n*100; nf3=n3/&n*100; nf4=n4/&n*100; nf99=n99/&n*100;
	
	nout1=nc1||"/"||compress(n1)||"("||put(nf1,4.1)||"%)";
	nout2=nc2||"/"||compress(n2)||"("||put(nf2,4.1)||"%)";
	nout3=nc3||"/"||compress(n3)||"("||put(nf3,4.1)||"%)";
	nout4=nc4||"/"||compress(n4)||"("||put(nf4,4.1)||"%)";
	nout99=nc99||"/"||compress(n99)||"("||put(nf99,4.1)||"%)";
	if n1=. then nout1="-";
	if n2=. then nout2="-";
	if n3=. then nout3="-";
	if n4=. then nout4="-";
	if n99=. then nout99="-";
	if LeftIVHGrade=4 then delete;
run;

ods rtf file="ivh_table.rtf" style=journal;

proc report nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];

	title "Left IVH Grade by Right IVH Grade(n=&n)";
	
	column LeftIVHGrade ("-------------------------------------- Right IVH Grade --------------------------------------" nout1-nout4 nout99) ;
	define LeftIVHGrade/"Left IVH Grade" style(column)=[cellwidth=1.5in just=center];
	define nout1/"I" style(column)=[cellwidth=1in just=center];
	define nout2/"II" style(column)=[cellwidth=1in just=center];
	define nout3/"III" style(column)=[cellwidth=1in just=center];
	define nout4/"IV" style(column)=[cellwidth=1in just=center];
	define nout99/"N/A" style(column)=[cellwidth=1in just=center];
run;
ods rtf close;
