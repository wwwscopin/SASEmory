/*
proc contents data=cmv.nec_image;run;
proc print data=cmv.nec_image;run;
*/

proc format;
	value it 1="MRI" 2="CT Scan" 3="Ultrasound" 4="X-ray" 9="Any Type";
	value ny 0="No" 1="Yes" 99="NA";
	value item 1="Significant intestinal distension with ileus" 
					2="'Rigid' bowel loops"			
					3="Small bowel separation"
					4="Pneumatosis intestinalis"
					5="Portal vein gas"
					6="Pneumoperitoneum('free air')"
					7="Other";
run;

data nec_img;
	set cmv.nec_image;
	keep id ImageDate Imagetime ImageType IntestinalDistension BowelLoop SmallBowelSeparation PneumoIntestinalis Pneumoperitoneum  PortalVeinGas other OtherFinding;
	format imagetype it. IntestinalDistension BowelLoop SmallBowelSeparation PneumoIntestinalis Pneumoperitoneum  PortalVeinGas other ny.;
run;

proc sql;
	create table nec_img as 
	select a.*
	from nec_img as a, cmv.comp_pat as b
	where a.id=b.id;

proc sort nodupkey; by id imagedate imagetime;run;

proc sort nodupkey out=num; by id;run;

data _null_;
	set cmv.comp_pat;
	call symput("n", compress(_n_));
run;

%put &n;

%macro img(data,out,varlist);

data &out;
	if 1=1 then delete;
run;

data tab;
	%do i=1 %to 4;
		imagetype=&i; code=0; output ;
		imagetype=&i; code=1; output ;
		imagetype=&i; code=99; output ;
	%end;
	imagetype=9; code=0; output;
	imagetype=9; code=1; output;
	imagetype=9; code=99; output;
run;

proc sort; by imagetype code;run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

proc sort data=&data nodupkey out=nid; by &var id; run;
proc freq data=nid;
	table &var;
	ods output onewayfreqs= tb&i(keep=&var frequency rename=(&var=code frequency=n));
run;

data tb&i;
	set tb&i;
	imagetype=9;
run;

proc sort data=&data nodupkey out=ni; by imagetype &var id; run;
proc freq data=ni;
	table ImageType*&var;
	ods output crosstabfreqs = tab&i(keep=imagetype &var frequency rename=(&var=code frequency=n));
run;

data tab&i;
	set tab&i;
	if imagetype=. or code=. then delete;
run;

data tab&i;
	set tab&i tb&i;
run;

proc sort; by imagetype code;run;

proc freq data=&data;
	table ImageType*&var;
	ods output crosstabfreqs = ta&i(keep=imagetype &var frequency rename=(&var=code frequency=m));
run;

data ta&i;
	set ta&i;
	if imagetype=. then imagetype=9;
	if code=. then delete;
run;

proc sort; by imagetype code;run;

data tab&i;
	merge tab tab&i ta&i; by imagetype;
	item=&i;
	format item item. code ny.;
run;

data &out;
	set &out tab&i;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;

proc sort ; by item code; run;

proc transpose data=&out out=&out.1;
	by item code;
	var n; 
run;
proc sort; by item code; run;

proc print;run;

proc transpose data=&out out=&out.2;
	by item code;
	var m; 
run;
proc sort; by item code; run;
proc print;run;

data &out;
	merge &out.1(drop=_name_ _label_ rename=(col1=n1 col2=n2 col3=n3 col4=n4 col5=n))
			 &out.2(drop=_name_ _label_ rename=(col1=m1 col2=m2 col3=m3 col4=m4 col5=m))
	; by item code;

	
	f1=n1/&n*100; f2=n2/&n*100; f3=n3/&n*100; f4=n4/&n*100;  f=n/&n*100;

	nf1=m1||"("||compress(n1)||")"||compress(put(f1,4.1))||"%";
	nf2=m2||"("||compress(n2)||")"||compress(put(f2,4.1))||"%";
	nf3=m3||"("||compress(n3)||")"||compress(put(f3,4.1))||"%";
	nf4=m4||"("||compress(n4)||")"||compress(put(f4,4.1))||"%";
	nf=m||"("||compress(n)||")"||compress(put(f,4.1))||"%";

	nf1="-";
	nf2="-";
run;

%mend;

%let varlist=IntestinalDistension BowelLoop SmallBowelSeparation PneumoIntestinalis PortalVeinGas Pneumoperitoneum other;
%img(nec_img, type_ny, &varlist);

ods rtf file="nec_image_id.rtf" style=journal;
proc print data=type_ny noobs label style(data)=[just=center] style(header)=[just=center];
title "Has any of the following been observed on the NEC image(n=&n)?";
where code^=99;
by item;
id item/style(data)=[just=left] style(header)=[just=left];
var code nf1/style(data)=[just=center cellwidth=0.6in];
var nf2/style(data)=[just=center cellwidth=0.9in];
var nf3 nf4 nf/style(data)=[just=right cellwidth=1in] ;


label item="Image Finding"
		code="Result"
		nf1="MRI"
		nf2="CT Scan"
		nf3="Ultrasound"
		nf4="X-ray"
		nf="Any type"
		;
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
#Imagings(# Pat)%Pat';
ods rtf close;
