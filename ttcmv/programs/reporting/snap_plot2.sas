
%include "&include./annual_toc.sas";

*%include "style.sas";

libname cmv_rep "/ttcmv/sas/programs/reporting";

proc format;

value visit
0=' '
1='D 1'
2='D 4'
3 ='D 7'
4='D 14'
5='D 21'
6='D 28'
7='D 40'
8=''
;
run;


data snap2_1; set cmv.snap2;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;



data snap2_1; set snap2_1;
if dfseq=1 then visit=1;
if dfseq=4 then visit=2;
if dfseq=7 then visit =3;
if dfseq=14 then visit =4;
if dfseq=21 then visit=5;
if dfseq = 28 then visit=6;
if dfseq=40 then visit=7;

label visit="" Hb="Hb" Weight="Weight"  HeadCircum="Head Circum" HtLength="Height/Length";
run;


data snap1; set cmv.snap;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;



data snap1; set snap1;
if dfseq=1 then visit=1;
if dfseq=4 then visit=2;
if dfseq=7 then visit =3;
if dfseq=14 then visit =4;
if dfseq=21 then visit=5;
if dfseq = 28 then visit=6;
if dfseq=40 then visit=7;

label visit=" " Weight="Weight"  HeadCircum="Head Circum" HtLength="Height/Length";
run;


proc sql;

create table xx as
select id, id2, dfseq, visit as visit , center from snap1
union
select id, id2, dfseq, visit as visit , center from snap2_1;

quit;

proc sql;

create table snap_sas as
select a.*, b.snaptotalscore 
from xx as a left join  snap1 as b
on a.id=b.id and a.dfseq=b.dfseq;


create table snap_sas as
select a.*, b.SNAP2Score 
from snap_sas as a left join  snap2_1 as b
on a.id=b.id and a.dfseq=b.dfseq;

 
quit;

data snap_sas; set snap_sas; if  center = 0 then delete;run;

 

options nodate orientation=landscape;
ods rtf file = "&output./annual/&snap_plots_whole_file.snap_whole_plots.rtf"  style=journal

toc_data startpage =yes bodytitle ;

goptions reset=all rotate=landscape gunit=pct device=jpeg gsfmode=replace  noborder cback=white colors=(black) ftitle=swissb ftext=swissb htitle=5 htext=3 ;



ods noproctitle proclabel "&snap_plots_whole_title d. SNAP Score Plot ";

goptions border;

                                                                                                                                                                                                                       
                                                                                                                                        
axis1  label=(  " Age ( Days )")  value=("" "D 1" "D 4" "D 7" "D 14" "D 21"  "D 28" "D 40" "D 90"  " "  )  order=(0 to 9 by 1) minor=none;                                                                           
axis2 label=none  order=(0 to 30 by 10) major= (h=2 w=2)  label=(angle=90 "SNAP Score") minor=none;                                                         
axis3 label=none value=none order=(0 to 100 by 10) major= (h=2 w=2)   minor=none color=white;                                                                 
                                                                                                                                        
symbol1 interpol=boxt10                                                                                                                 
  mode=exclude                                                                                                                          
  value=none                                                                                                                            
  co=black                                                                                                                              
  cv=black                                                                                                                              
  height=1                                                                                                                              
  bwidth=5                                                                                                                              
  width=2;                                                                                                                              
                                                                                                                                        
symbol2 value=dot h=1 color=red;                                                                                                        
                                                                                                                                        
symbol3 value=dot h=1.0 i=join repeat=200; 


title1   f=swissb h=3 "DOL 1 SNAP score and Longitudinal SNAP II score ";
/*title2 h=8 " ";

title4 a=90 h=1pct "";
title5 a=-90 h=18pct " ";                                                                                            
                                                                                                                                        
footnote h=17pct " "; */                                                                                                                   
                                                                                                                                        
proc gplot data=snap_sas  ;                                                                                                     
  plot snaptotalscore*visit snaptotalscore*visit / overlay haxis=axis1 vaxis=axis2  ;                                                   
  plot2 SNAP2Score*visit=id / nolegend vaxis=axis3 noframe  ;                                                                                     
  *format visit visit.;                                                                                                                  
run; 

                                                                                                                              
quit;



ods rtf close; 

quit;


