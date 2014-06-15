options nodate nonumber;

proc format; 
   value grade 0="NA" 1="I" 2="II" 3="III" 4="IV" ;
run;

data ivh0;
	merge cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.comp_pat(in=comp);
	by id;
	if comp;
	td=ImageDate-IVHDiagDate;
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
run;

proc sort; by id td;run;

data ivh1;
    set ivh0; by id td;
    if LeftIVHGrade in(1,2,3,4) and RightIVHGrade in(1,2,3,4) then bilateral=1; else bilateral=0; 
    if first.id then do; num_ivh=0; end;
    num_ivh+1;

  	center=floor(id/1000000);
    	if center=1 then num=num_ivh-0.1;
  	  	if center=2 then num=num_ivh;
  	  	if center=3 then num=num_ivh+0.1;
  	  	
    if	LeftIVHGrade=99 then LeftIVHGrade=0;
    if	RightIVHGrade=99 then RightIVHGrade=0;
run;




ods rtf file="ivh_day.rtf" style=journal;
proc print label;
var id IVHDiagDate ImageDate td LeftIVHGrade RightIVHGrade bilateral num_ivh/style=[cellwidth=0.75in];
label td="ImageDate-IVHDiagDate";
run;
ods rtf close;


proc sort data=ivh1 out=tmp; by id descending bilateral;run;

data tmp;
    set tmp; by id;
    if first.id;
run; 

proc freq data=tmp;
    tables bilateral/out=bi_ivh;
run;

data _null_;
    set bi_ivh;
    if bilateral=0 then call symput("n0", compress(count));
    if bilateral=1 then call symput("n1", compress(count));
run;

%let n_ivh=%eval(&n0+&n1);

proc freq data=ivh1;
    *by id;
    tables LeftIVHGrade*num_ivh /out=tmp1;
    tables RightIVHGrade*num_ivh /out=tmp2;
    *tables id*(LeftIVHGrade RightIVHGrade)*num_ivh;
    *ods output crosstabfreqs=wbh;
run;


data tab;
	do i=0 to 4; 
		do j=1 to 8; 
			Grade=i;  num_ivh=j; output;
		end;
	end;
run;

data tmp;
    merge tab tmp1(rename=(leftivhgrade=grade count=left)) tmp2(rename=(rightivhgrade=grade count=right)); by grade num_ivh;
run;

proc transpose data=tmp output=tmp; by grade; 
var left right;
run;

ods rtf file="ivh_num.rtf" style=journal bodytitle;
proc report data=tmp(rename=(_name_=name)) nowindows headline spacing=1 split='*' style(column)=[just=center width=0.6in] style(header)=[just=center];
*where grade^=0;
title "IVH Stage by Image";
column grade name col1-col8;
define grade/order=internal group "Stage" format=grade.;
define name/" " ;
define col1/"1st ";
define col2/"2nd ";
define col3/"3rd ";
define col4/"4th ";
define col5/"5th ";
define col6/"6th ";
define col7/"7th ";
define col8/"8th ";
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=1in RIGHTMARGIN=1in font_size=11pt}
There are &n_ivh babies with IVH, &n0 are unilateral and &n1 are bilateral.";
ods rtf close;
*******************************************************************************************************************************;
