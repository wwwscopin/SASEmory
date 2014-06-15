
options ls=80 orientation=portrait;

data tendon;
	input group tendon comp ruput rom;
	cards;
	0 1598	206	57	149
	1 1412	155	75	80
    2 35	2	2	0
	;
run;

proc print;run;


proc freq data=tmp order=data;
	weight count_&var;
	table group*g&var/fisher relrisk;
	ods output  Freq.Table1.RelativeRisks=rr;
	ods output  Freq.Table1.FishersExact=ft;
run;



%orp(td, rupt, rupt);run;
%orp(td, rom, rom);run;

data orp0;
	set rupt(in=A) rom(in=B);
	if A then item=1;
	if B then item=2;
	format item item.;
run;

data orp;
	merge orp0 overallft; by item group1;
run;
proc print;run;


options orientation=portrait nodate;
ods rtf file="rehab.rtf" style=journal bodytitle startpage=no;

proc report data=tend nowindows headline spacing=1 split='*' style=[just=center];
	title "Ruptures and Total Complications for Rehab Methods";
	column group nfrupt nfrom;
	define group/"Rehab Methods" style=[just=right];
	define nfrupt/"Ruptures" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
	define nfrom/"Total Complications" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
run;

proc report data=orp split="*" nowindows style=[just=center]; 
	title "Comparsion of Ruptures and Total Complications between Rehab Methods";

	column item term or pv;
	define item/order order=internal "."  format=item.;
	define term/"Effect" style(column)=[just=left cellwidth=2.5in] ;
	define or/"Odds Ratio" style(column)=[just=center cellwidth=1.25in]; 
	define pv/"p value" style(column)=[just=center cellwidth=0.75in] ;
run;
ods rtf close;
