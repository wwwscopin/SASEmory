
options ls=80 orientation=portrait;

data temp;
	input group tendon comp rupt rom;
	cards;
	0 1598	206	57	149
	1 1412	155	75	80
    2 35	2	2	0
	;
run;

proc format; 
	value gp 0="Passive"
			 1="Active"
			 2="Continuous motion"
			 ;

	value item 1="Total Complications" 2="Ruptures" 3="Decreased ROM";
run;


data tend;
	set temp;
	frupt=rupt/tendon*100;
	from=rom/tendon*100;
	fcomp=comp/tendon*100;
	format frupt from fcomp 4.2;
	nfrupt=rupt||"/"||compress(tendon)||"("||put(frupt,4.2)||"%)";
	nfrom=rom||"/"||compress(tendon)||"("||put(from,4.2)||"%)";
	nfcomp=comp||"/"||compress(tendon)||"("||put(fcomp,4.2)||"%)";
run;

data td;
	set temp;
	gcomp=1; count_comp=comp; grupt=1; count_rupt=rupt;	grom=1; count_rom=rom; output;
	gcomp=0; count_comp=tendon-comp; grupt=0; count_rupt=tendon-rupt;	grom=0; count_rom=tendon-rom; output;
run;
/*
data td;
	set td;
	if grom=1 and group=2 then count_rom=0.5;
run;
*/

proc freq data=td;
	weight count_comp;
	table group*gcomp/fisher;
	ods output  Freq.Table1.FishersExact=ft1;
run;


proc freq data=td;
	weight count_rupt;
	table group*grupt/fisher;
	ods output  Freq.Table1.FishersExact=ft2;
run;

proc freq data=td;
	weight count_rom;
	table group*grom/fisher;
	ods output  Freq.Table1.FishersExact=ft3;
run;
proc print data=ft3;run;

data overallft;
	length pv $10;
	set ft1(firstobs=2 keep=nvalue1 in=A) ft2(firstobs=2 keep=nvalue1 in=B) ft3(firstobs=2 keep=nvalue1 in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;
	pv=put(nvalue1, 4.2);
	if nvalue1<0.01 then pv="<0.01";
	group1=9;  term="Overall";
	keep item pv group1 term;
run;
proc print;run;




%macro orp(data, var, out);

data &out;
	if 1=1 then delete;
run;

%do i=0 %to 1;
	%do j=%eval(&i+1) %to 2;
data tmp;
	set &data;
	where group in(&i, &j);
run;


proc freq data=tmp order=data;
	weight count_&var;
	table group*g&var/fisher relrisk;
	ods output  Freq.Table1.RelativeRisks=rr;
	ods output  Freq.Table1.FishersExact=ft;
run;

data orp_&i&j;
	length pv $8;
	merge ft(firstobs=6 keep=nvalue1 ) rr(firstobs=1 obs=1 keep=value lowerCL upperCL);
	group1=&i; group2=&j;
	or=compress(put(value,4.2)||"["||put(lowerCL,4.2)||"-"||put(upperCL,4.2)||"]");
	pv=put(nvalue1,4.2);
	if nvalue1<0.01 then pv="<0.01";
	term=put(group1, gp.)||"vs "||put(group2, gp.);
	keep term or pv group1 group2;
	/*%if &var=rupt %then %do; if group1=4 or group2=4 then delete; %end;*/
	if group1=4 or group2=4 then delete;
run;

data &out;
	set &out orp_&i&j; 
run;
	%end;
%end;
%mend orp;

%orp(td, comp, comp);run;
%orp(td, rupt, rupt);run;
%orp(td, rom, rom);run;

data orp0;
	set comp(in=A) rupt(in=B) rom(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;
	format item item.;
run;

data orp;
	merge orp0 overallft; by item group1;
run;
proc print;run;


options orientation=portrait nodate;
ods rtf file="rehab_new.rtf" style=journal bodytitle startpage=no;

proc report data=tend nowindows headline spacing=1 split='*' style=[just=center];
	title "Ruptures and Total Complications for Rehab Methods";
	column group nfcomp nfrupt nfrom;
	define group/"Rehab Methods" format=gp. style=[just=right];
	define nfcomp/"Total Complications" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
	define nfrupt/"Ruptures" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
	define nfrom/"Decreased ROM" style(column)=[just=center cellwidth=1.25in] style(header)=[just=center];
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
