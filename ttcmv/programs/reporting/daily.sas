proc format;

value PlasmaExchange /* Form: Screening */
0 ='No PEX' 
1 ='PEX' 
2 ='2_Not applicable as Pt not eligible'
3='Overall' 
; 

value Visit /* Form: DailyMeasurements */
-1 ='-1' 
1 ='1' 
2 ='2' 
3 ='3' 
4 ='4' 
5 ='5' 
6 ='6' 
7 ='7' 
8 ='8' 
9 ='9' 
10 ='10' 
11 ='11' 
12 ='12' 
13 ='13' 
14 ='14' 
;

run;

proc sql;
create table daily as
select a.* ,b.plasmaexchange
from daily as a left join
screen as b
on a.patientid = b.patientid;

quit;

data a; set daily;
StudyGroup = plasmaexchange;run;

proc freq data=screen; tables plasmaexchange;run;
**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 
data a; 
set a; 
output; 
studygroup = 3; 
output; 
run; 

proc means data = a fw=5 maxdec=1 nonobs n mean stddev median min max q1 q3; 
class studygroup visitlist; 
var &var; 
ods output summary = &var; 
run;

proc contents data=sbp;run;
/* macro */
%macro cont_vars (data= ,var = , label = , group=); 
proc means data = &data fw=5 maxdec=1 nonobs n mean stddev median min max q1 q3; 
class studygroup visitlist; 
var &var; 
ods output summary = &var; 
run; 
data temp; 
set &var; 
length variable $ 200; 
length disp_visit $ 50; 
length disp $ 60; 
* fix variable names; 
n = &var._n; 
mean = &var._mean; 
std_dev = &var._stddev; 
median = &var._median; 
min = &var._min; 
max = &var._max; 
q1 = &var._q1; 
q3 = &var._q3; 
 
* format for display ; 
disp_n = compress(put(n, 4.0)); 

disp_5point = compress(put(median, 4.1)) || " (" || compress(put(q1, 4.1)) || ", " || compress(put(q3, 4.1)) || ")"; 
if (median ~= .) then disp = trim(disp_5point) || ", " || disp_n; 
else disp = "(no data)";
disp_visit = put(visitlist, visit.); 
* add row headers ; 
variable = &label; drop &var._n &var._mean &var._stddev &var._median &var._min &var._max &var._q1 &var._q3; 
seq=&group;
run;

%if &group=1 %then %do;
data out; set temp; run; 

%end; 
%else %do; 
proc sql; 
create table out as 
select * from out
union
select * from temp;


quit; 
%end;
proc sql; drop table temp; drop table &var;quit;



%mend;
 

%cont_vars(data=a ,var= AgeEnrollmentYear, label = "Age(yr)" , group=1); 

%cont_vars(data=a ,var= sbp, label = "Systolic BP" , group=2); 
%cont_vars(data=a ,var= dbp, label = "Diastolic BP" , group=3);
%cont_vars(data=a ,var= HR, label = "HR" , group=4);
%cont_vars(data=a ,var= Temperature, label = "Temperature" , group=5);

%cont_vars(data=a ,var= hemoglobin, label = "HB" , group=6);
%cont_vars(data=a ,var= HCT, label = "Hematocrit" , group=7);

%cont_vars(data=a ,var=  Creatinine, label = " Creatinine" , group=8);
%cont_vars(data=a ,var=  Calcium, label = " Calcium" , group=9);
%cont_vars(data=a ,var=  Albumin, label = " Albumin" , group=10);
%cont_vars(data=a ,var= Glucose, label = "Glucose" , group=11);
%cont_vars(data=a ,var= Bicarbonate, label = "Bicarb" , group=12);
%cont_vars(data=a ,var= BUN, label = "BUN" , group=13);
%cont_vars(data=a ,var= GCS, label = "GCS" , group=14);

%cont_vars(data=a ,var= OFI_Score, label = "OFI Total" , group=15);

%cont_vars(data=a ,var= PelodTotalScore, label = "Pelod Total" , group=16);
%cont_vars(data=a ,var= PRISMIII_Score, label = "Prism Total" , group=17);

proc sql;
create table out2 as
select * from out
order by studygroup, visitlist, seq;
quit;


proc contents data=a;run;
ods escapechar = '~';
%let Span="\brdrb\brdrs\brdrw1";
options nodate  orientation = landscape; 

ods rtf file = "c:\tamof_daily.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "Table 1: TAMOF Lab measurements by groups";

Title '~S={leftmargin = 2.25in font = ("arial",11pt, bold) just = left}'
'Table 1: TAMOF Lab measurements by groups ~{super *}';
footnote '~S={leftmargin = 2.25in font = ("arial",9pt) just = left}'
'~{super *}';

proc report data=out2  nowindows missing
headline  headskip pspace=1 split='_'
 ;
;

*where eventtype='Incident2002';
column   variable       studygroup visitlist, ( disp  )   dummy ;


define variable / order =data group left  width=15  'Variable' style(column)=[font_size=6pt];

define   studygroup/ group order =data left  width=15  'Group ' style(column)=[font_size=6pt] ;
*define pipe2 /group left  '|' style(column)=[font_size=6pt];

define visitlist / across center  width=15   style(column)=[font_size=7pt ] 'Day on study_Median ( p25,p75),n' ;

define disp/  center   style(column)={font_size=6pt   just=center}   ' ';;
*define pipe /left  '' style(column)=[font_size=6pt];
define dummy/ noprint;

break after variable/skip;
rbreak after / skip  ol;
/*
compute slash ;
slash = '|';
endcomp;
*/
*format variable $variable.;
format studygroup plasmaexchange.;


compute before variable;
line ' ';
endcomp;
/*
compute after;
line ' ';
endcomp;
*/
compute after  ;
line '';/*
style={just=r font_size=10pt};
Page_Count = "Page "||trim(left(put(_Page,
4.)))||" of &Max_Page.";
line Page_Count $;*/
endcomp;

run;
*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close; 
