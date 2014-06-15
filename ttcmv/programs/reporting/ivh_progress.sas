options nodate nonumber;

proc format;
  value grade   
        1 = "I" 2 = "II" 3 = "III" 4="IV" 0="Unilateral" 100="Total";
run;

data ivh0;
	set cmv.ivh_image(keep=id LeftIVHGrade RightIVHGrade ImageDate Imagetime); 	by id;
	format LeftIVHGrade RightIVHGrade grade. ;
	if LeftIVHGrade=99 then LeftIVHGrade=0;
	if RightIVHGrade=99 then RightIVHGrade=0; 
run;

proc sql; 
	create table ivh as 
	select a.*
	from ivh0 as a , cmv.comp_pat as b
	where a.id=b.id;
	
proc sort; by id ImageDate Imagetime;run;

proc means data=ivh min max;
	class id; 
	var LeftIVHGrade RightIVHGrade;
	ods output means.summary=min_max;
run;

data max_left;
	set min_max(where=(LeftIVHGrade_max>0));
	keep id LeftIVHGrade_max;
run;

data max_right;
	set min_max(where=(RightIVHGrade_max>0));
	keep id RightIVHGrade_max;
run;

data max_ivh;
    merge max_left max_right; by id;
run;

data min_ivh;
    set min_max; 
    keep id LeftIVHGrade_min RightIVHGrade_min;
run;

proc print;run;

data ini_right;
	set ivh(where=(RightIVHGrade>0)); by id ImageDate Imagetime;
	if first.id;
	keep id RightIVHGrade;
run;

data ini_left;
	set ivh(where=(LeftIVHGrade>0)); by id ImageDate Imagetime;
	if first.id;
	keep id LeftIVHGrade;
run;

data ini_ivh;
    merge ini_left ini_right; by id;
    if LeftIVHGrade^=. and RightIVHGrade^=. then lr=1; else lr=0;
run;

proc means; 
class lr;
var id;
output out=wbh;
run;

proc print;run;

data _null_;
	set ini_left;
	call symput("nl",compress(_n_));
run;

data _null_;
	set ini_right;
	call symput("nr",compress(_n_));
run;

data _null_;
	set wbh;
    if lr=0	then call symput("nlr0",compress(_freq_));
    if lr=1	then call symput("nlr1",compress(_freq_));    
run;

%put &nlr0;

data grade;
	merge ini_ivh(rename=(LeftIVHGrade=ini_L RightIVHGrade=ini_R)) 
          min_ivh(rename=(LeftIVHGrade_min=min_L RightIVHGrade_min=min_R))
	      max_ivh(rename=(LeftIVHGrade_max=max_L RightIVHGrade_max=max_R)); by id;

	if ini_l=1 or ini_r=1 then ini=1;else ini=0;
	if max_l in(3,4) or max_r in(3,4) then max=1; else max=0;

  	keep id ini_L ini_R max_L max_R ini max min_L min_R;
	format ini_L ini_R max_L max_R min_L min_R grade.;
run;

data tx_id;
	merge   cmv.plate_031(keep=id DateTransfusion rbc_TxStartTime in=A)
			cmv.plate_033(keep=id DateTransfusion plt_TxStartTime  Plateletnum in=B)
			cmv.plate_035(keep=id DateTransfusion ffp_TxStartTime PT PTT Fibrinogen  in=C)
			cmv.plate_037(keep=id DateTransfusion cryo_TxStartTime in=D)
			/*cmv.plate_039(keep=id )*/
		; by id;
    if A then rbc=1; else rbc=0;
    if B then plt=1; else plt=0;
    if C then ffp=1; else ffp=0;
    if D then cryo=1; else cryo=0;
run;

proc sort nodupkey; by id DateTransfusion; run;
data tx_id;
    set tx_id; by id;
    if first.id;
run;

data lbwi_ivh;
	merge 

	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	cmv.plate_006(keep=id GestAge  BirthWeight  Length  HeadCircum Apgar1Min Apgar5Min CordPh)
	tx_id
	cmv.completedstudylist(in=B)
	grade(where=(ini=1) in=A);
	by id;
	
	if A and B;

	keep id Gender race GestAge BirthWeight Length  HeadCircum Apgar1Min Apgar5Min CordPh ini max plt Plateletnum ffp pt ptt Fibrinogen;		 
run;

proc means data=lbwi_ivh;
class max;
var gestage birthweight Apgar5Min CordPh pt ptt Fibrinogen Plateletnum;
run; 

data ttab;
	do i=0 to 4; 
		do j=0 to 4; 
			LeftIVHGrade=i;  RightIVHGrade=j; output;
		end;
	end;
	drop i j;
	format LeftIVHGrade RightIVHGrade grade.;
run;
proc sort; by LeftIVHGrade RightIVHGrade;run;

data tab;
    set ttab;
    if LeftIVHGrade=0 then delete;
    if RightIVHGrade=0 then delete;
run;

proc freq data=grade; 
tables ini_l*max_l/out=tab_l;
tables ini_R*max_R/out=tab_r;
tables ini_l*min_l/out=table_l;
tables ini_R*min_R/out=table_r;
run;

data tab_l;
	merge tab_l tab(rename=(LeftIVHGrade=ini_l rightIVHGrade=max_l)); by ini_l max_l;
	cp=compress(count||"("||put(percent,4.1)||"%)");
	if count=. then cp="-";
	if ini_l=. then delete;
run; 
proc sort; by ini_l max_l;run;
proc transpose data=tab_l out=tabL; var cp; by ini_L;run;

data tab_r;
	merge tab_r tab(rename=(LeftIVHGrade=ini_r rightIVHGrade=max_r)); by ini_r max_r;
	cp=compress(count||"("||put(percent,4.1)||"%)");
	if count=. then cp="-";
	if ini_r=. then delete;
run; 
proc sort; by ini_r max_r;run;
proc transpose data=tab_r out=tabr; var cp; by ini_r;run;


data table_l;
	merge table_l ttab(rename=(LeftIVHGrade=ini_l rightIVHGrade=min_l)); by ini_l min_l;
	cp=compress(count||"("||put(percent,4.1)||"%)");
	if count=. then cp="-";
	if ini_l=. then delete;
run; 
proc sort; by ini_l min_l;run;
proc transpose data=table_l out=tableL; var cp; by ini_L;run;

data tableL;
    set tableL;
    if ini_l=0 then delete;
run;


data table_r;
	merge table_r ttab(rename=(LeftIVHGrade=ini_r rightIVHGrade=min_r)); by ini_r min_r;
	cp=compress(count||"("||put(percent,4.1)||"%)");
	if count=. then cp="-";
	if ini_r=. then delete;
run; 
proc sort; by ini_r min_r;run;
proc transpose data=table_r out=tabler; var cp; by ini_r;run;

data tableR;
    set tableR;
    if ini_R=0 then delete;
run;

ods rtf file="ivh_progress.rtf"  style=journal bodytitle bodytitle startpage=no;
proc print data=tabl noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Left IVH Grade Progress (n=&nl)";
var ini_l/style(data)=[cellwidth=2in];
var col1-col4/style(data)=[cellwidth=1in];
label   col1="I"
		col2="II"
		col3="III"
		col4="IV"
		ini_l="Initial Left Grade *by Maximum Left Grade";
run;

proc print data=tabR noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Right IVH Grade Progress (n=&nr)";
var ini_r/style(data)=[cellwidth=2in];
var col1-col4/style(data)=[cellwidth=1in];
label   col1="I"
		col2="II"
		col3="III"
		col4="IV"
		ini_r="Initial Right Grade *by Maximum Right Grade";
run;

proc print data=tablel noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Left IVH Grade Retrogress (n=&nl)";
var ini_l/style(data)=[cellwidth=2in];
var col1-col5/style(data)=[cellwidth=1in];
label   col1="-"
        col2="I"
		col3="II"
		col4="III"
		col5="IV"
		ini_l="Initial Left Grade *by Minmum Left Grade";
run;

proc print data=tableR noobs label split="*" style(data)=[just=center] style(header)=[just=center];
title "Right IVH Grade Retrogress (n=&nr)";
var ini_r/style(data)=[cellwidth=2in];
var col1-col5/style(data)=[cellwidth=1in];
label   col1="-"
        col2="I"
		col3="II"
		col4="III"
		col5="IV"
		ini_r="Initial Right Grade *by Minmum Right Grade";
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=1.5in RIGHTMARGIN=0.5in font_size=10pt}
* There are &nlr1 bilateral IVH patients and &nlr0 unilateral IVH patients.";
ods rtf close;
