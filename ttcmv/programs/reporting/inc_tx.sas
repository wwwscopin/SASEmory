/* macro */


%include "&include./annual_toc.sas";

*%include "style.sas";


%macro cont_vars (data= ,var = , label = , group=, tx=); 


data tx_2; set &data;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


data tx_2; set tx_2;

output; 
center = 0; 
output; 
run; 


proc means data = tx_2 fw=5 maxdec=1 nonobs n mean stddev median min max q1 q3; 
class center; 
var &var; 
ods output summary = &var; 
run; 
data temp; 
set &var; 
length variable $ 200; 
length disp_visit $ 50; 
length disp $ 60; 
length txtype  $ 10;


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
disp_visit = dfseq; 
* add row headers ; 
variable = &label; drop &var._n &var._mean &var._stddev &var._median &var._min &var._max &var._q1 &var._q3; 
seq=&group;
txtype="&tx";
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

drop table tx_2;


quit; 
%end;
proc sql; drop table temp; drop table &var;quit;



%mend;
 

%cont_vars(data=cmv.rbctx ,var= Hb, label = "Hb (g/dl)" , group=1, tx=RBC); 


%cont_vars(data=cmv.rbctx ,var=Hct, label = "Hct (%) " , group=2, tx=RBC); 
%cont_vars(data=cmv.rbctx ,var=BodyWeight, label = "Body Weight (grams)" , group=3, tx=RBC);


%cont_vars(data=cmv.ffptx ,var=PT, label = "PT (sec)" , group=4, tx=FFP);

%cont_vars(data=cmv.ffptx ,var=PTT, label = "PTT (sec)" , group=5, tx=FFP);

%cont_vars(data=cmv.platelettx ,var=Plateletnum, label = "Platelet (10^9/L)" , group=6, tx=PLT);



proc sql;
create table out2 as
select * from out
order by center, seq;
quit;



ods escapechar = '~';
%let Span="\brdrb\brdrs\brdrw1";
options nodate  orientation = landscape; 

ods rtf  style=ttcmvtables file = "&output/annual/&all_tx_summary_file.t1_rbc_tx_summary5.rtf"  style=journal

toc_data startpage = yes bodytitle ;


ods noproctitle proclabel "&all_tx_summary_title d. LBWI Characteristics prior to Tx ";

title  justify = center "&all_tx_summary_title d. LBWI Characteristics prior to Tx  ";

proc report data=out2  nowindows missing
headline  headskip pspace=1 split='_'
 ;
;


column    variable       center, ( disp  )   dummy ;

*define   tx/ group order =data left  width=15  'Tx' style(column)=[font_size=8pt] ;
define variable / order =data group left  width=15  'Variable' ;


*define pipe2 /group left  '|' style(column)=[font_size=8pt];

define center / across order=internal  style(column) = [just=center cellwidth=3in]   "Center_Median ( p25,p75),n"  ;

define disp/  center   style(column)=[   just=center cellwidth=3in]   ' ';;
*define pipe /left  '' ;
define dummy/ noprint;

break after variable/skip;
rbreak after / skip  ol;


format center center.;


compute before variable;
line ' ';
endcomp;



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
