/* create missing data */

%include "&include./monthly_toc.sas";
%include "&include./nurses_toc.sas";

data cmv.snap2; set cmv.snap2; 

total_snap2=4;  this_snap2_gt25=0;
this_snap2=0; total_snap2=3;

if MeanBP eq 99 or MeanBP eq 999 then  this_snap2=this_snap2+1;  
if  LowestTemp eq 99 or LowestTemp eq 999 then this_snap2=this_snap2+1;
if  seizures eq 99 or seizures eq 999 then this_snap2=this_snap2+1;
if  UOP eq 99 or UOP eq 999 then this_snap2=this_snap2+1;

if BloodCollect eq 1 and (LowPh eq 99 or LowPh eq 999) then this_snap2=this_snap2+1;
if BloodCollect eq 1 and (PO2Fo2Ratio eq 99 or PO2Fo2Ratio eq 999) then this_snap2=this_snap2+1;


if BloodCollect eq 1 then total_snap2=5;

this_snap2_pct=this_snap2/total_snap2*100;

pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

snap2_nonmiss=compress(this_snap2) || "/" || compress(total_snap2);


if this_snap2_pct >=25 then this_snap2_gt25 =1;


run;



data snap2; 
set cmv.snap2;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

proc sql;

select compress(put(count(*),3.0)) into: sample_all from  snap2;
select compress(put(count(*),3.0)) into: sample_partial from  snap2 where this_snap2_pct >25 ;
quit;

data temp; t=(&sample_partial/&sample_all)*100; run;

proc sql;

select compress(put(t,2.0)) into: ratio from temp; drop table temp;

quit;

proc format ;

value display
99="M"
999="M";
run;

ods escapechar = '~';
options nodate orientation = landscape;
ods rtf file = "&output./nurses/&snap2_missing_file.snap2_missing.rtf"  style=journal

toc_data startpage = yes bodytitle;

ods noproctitle proclabel "&snap2_missing_title : List of LBWI with more than 25% SNAP2 components missing ( M : Missing )";


	title  justify = center "&snap2_missing_title : List of LBWI with more than 25% SNAP2 components missing ( M : Missing ) 
 [&sample_partial/&sample_all (&ratio.%)]";
footnote "";

proc report  data=snap2  nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

 where this_snap2_pct >25; ;

column id dfseq  MeanBP LowestTemp seizures UOP LowPh PO2Fo2Ratio dummy ;

define id / center group        style(column)=[cellwidth=0.75in just=center]  "LBWI Id";

define dfseq /  Left   group   "DOL" ;


define MeanBP/ center    "Mean BP  " style(column)=[cellwidth=1.25in  ] format=display.;
define LowestTemp/ center    "LowestTemp  " style(column)=[cellwidth=1.25in  ] format=display.;
define seizures/ center    "Seizures  " style(column)=[cellwidth=1.25in  ] format=display.;
define UOP/ center    "UOP  " style(column)=[cellwidth=1.25in  ] format=display.;
define LowPh/ center    "LowPh  " style(column)=[cellwidth=1.25in  ] format=display.;
define PO2Fo2Ratio/ center    "P/F ratio  " style(column)=[cellwidth=1.25in  ] format=display.;




define dummy/ noprint;
format center center.;





run;
ods rtf close;
quit;
