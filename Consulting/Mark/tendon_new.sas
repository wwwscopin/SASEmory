
options ls=80 orientation=portrait;
%let path=H:\SAS_Emory\Consulting\Mark;
libname mark "&path";
filename tendon "&path\mark.xls" lrecl=1000;

PROC IMPORT OUT= tendon0 
            DATAFILE= tendon  
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:I45"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc format; 
	value gp 1="Active"
			 2="Passive"
			 3="Passive/Active"
			 4="Immobilization"
			 5="Continuous motion"
			 ;
	value fpl 0="Without FPL" 1="With FPL";

	value item 1="Ruptures" 2="Total Complications";
run;

data tendon1;
	set tendon0;
	dig=digits+0;
	tendon=tendons+0;
	pat= Patients+0;
	rupt= scan(Ruptures____total_,1, , 'dko')+0;
	extensor= Extensor_Deficit___15_deg_+0;
	loss= Significant_loss_of_motion_in_jo+0;
	ca= Contracture_Adhesion+0;
	if  Rehab_method=" " then delete;
	study1=lag(study);
		study2=lag2(study);
	if study=" " then study=study1;
	if study=" " then study=study2;
	if rehab_method="Active" then group=1;
	if find(rehab_method, "Passive") then group=2;
	if rehab_method="Passive/Active" then group=3;
	if rehab_method="Immobilized" or rehab_method="Immobilization" then group=4;
	if rehab_method="Continuous motion machine" then group=5;

	keep  Study study1 Rehab_method dig tendon rupt pat extensor loss ca group;
	format group gp.;
run;
/*proc print;run;*/

proc sort; by study;run;

proc print data=tendon;run;


proc freq;
tables study;
ods output onewayfreqs=tmp;
run;

data study;
	set tmp;
	idx=_n_;
	keep idx study;
run;

data tendon;
	merge tendon1 study; by study;
	if tendon=. then if dig^=. then tendon=dig; else if dig=. then tendon=pat;
	fr=rupt/tendon*100;
	rom=sum(rupt,extensor,loss,ca);
	from=rom/tendon*100;
	format fr from 4.2;
run; 

proc means data=tendon sum;
	class group;
	var tendon rupt rom;
	output out=trr sum=/autoname;
run;

data tend;
	set trr;
	if group=. then delete;
	frupt=rupt_sum/tendon_sum*100;
	from=rom_sum/tendon_sum*100;
	format frupt from 4.2;
	nfrupt=rupt_sum||"/"||compress(tendon_sum)||"("||put(frupt,4.2)||"%)";
	nfrom=rom_sum||"/"||compress(tendon_sum)||"("||put(from,4.2)||"%)";
	if rom_sum=. then nfrom="-";
run;

data td;
	set trr;
	if group=. then delete;
	if rom_sum=. then rom_sum=0;
	drop _type_ _freq_;
	grupt=1; count_rupt=rupt_sum;	grom=1; count_rom=rom_sum; output;
	grupt=0; count_rupt=tendon_sum-rupt_sum; grom=0; count_rom=tendon_sum-rom_sum; output;
run;


proc freq data=td;
	weight count_rupt;
	table group*grupt/fisher;
	ods output  Freq.Table1.FishersExact=ft1;
run;

proc freq data=td;
	weight count_rom;
	table group*grom/fisher;
	ods output  Freq.Table1.FishersExact=ft2;
run;

data overallft;
	length pv $10;
	set ft1(firstobs=2 keep=nvalue1 in=A) ft2(firstobs=2 keep=nvalue1 in=B);
	if A then item=1;
	if B then item=2;
	pv=put(nvalue1, 4.2);
	if nvalue1<0.01 then pv="<0.01";
	group1=9;  term="Overall";
	keep item pv group1 term;
run;


%macro orp(data, var, out);

data &out;
	if 1=1 then delete;
run;

%do i=1 %to 4;
	%do j=%eval(&i+1) %to 5;
data tmp;
	set &data;
	where group in(&i, &j);
run;

data tmp1;
	set tmp;
	count_rom=floor(count_rom);
run;

proc freq data=tmp order=data;
	weight count_&var;
	table group*g&var/fisher relrisk;
	ods output  Freq.Table1.RelativeRisks=rr;
	ods output  Freq.Table1.FishersExact=ft;
run;

%if &j=5 %then %do;
proc freq data=tmp1 order=data;
	weight count_&var;
	table group*g&var/fisher relrisk;
	ods output  Freq.Table1.FishersExact=ft;
run;
%end;

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
