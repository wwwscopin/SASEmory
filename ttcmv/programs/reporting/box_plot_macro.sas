
%include "&include./annual_toc.sas";


libname cmv_rep "/ttcmv/sas/programs/reporting";

proc sql;

create table enrolled as
select a.* ,moc_dob
from 
cmv.valid_ids  as a
left join
cmv.plate_007 as b
on a.id=b.id
 ;

create table enrolled as
select a.*,b.*
from enrolled as a left join 
( select * from anthro_olsen where dfseq =1) as b
on a.id=b.id;

quit;

data enrolled; 
length twin_status $ 15;
set enrolled;
id2 = left(trim(id));
mocId=input(substr(id2, 1, 5),5.);
twin=input(substr(id2, 6, 1),5.);
center = input(substr(id2, 1, 1),1.);

moc_age_enrol =  (EnrollmentDate - moc_dob)/365 ; 


run;

proc sql;

create table twin_status as
select max(twin)as ismultiple, mocid from enrolled group by mocid;

create table enrolled as
select a.*, b.ismultiple
from enrolled as a left join
twin_status as b
on a.mocid=b.mocid
order by center,  EnrollmentDate asc,id;


quit;
data enrolled; set enrolled;

if ismultiple eq 1 then twin_status="singleton";
else if ismultiple eq 2 then twin_status="twin";
else if ismultiple eq 3 then twin_status="triplet";

if gender=1 then treatmentgroup=0;
if gender=2 then treatmentgroup=1;
run;


data chemistry_plot2; /*set chemistry_plot; */ set enrolled;

if id > 1000000 and id < 2000000 then treatmentgroup2= treatmentgroup +.05;
if id > 2000000 and id < 3000000 then treatmentgroup2= treatmentgroup -.05;
if id > 3000000 and id < 4000000 then treatmentgroup2= treatmentgroup +.08;
run;
data chemistry_plot2; set chemistry_plot2;

if dfseq > 1 then delete; 
run;

proc sql;
create table chemistry_plot3 as 
select a.* ,b.twin_status,b.ismultiple,b.id as id2
from chemistry_plot2 as a right join
enrolled as b
on a.id = b.id;

quit;
data chemistry_plot3; set chemistry_plot3;

if ismultiple > 1 then delete; 
run;


proc format;
value gender
-1=''
0='Males'
1='Females'
2='';

run;


%macro box_plot (data= ,var = , title=,label = , studygroup=, orderlow=, orderhigh=,orderby=,n=); 

goptions reset = all; 

goptions gunit=pct  device=jpeg htitle=3 htext=3   ftitle=zapf ftext= zapf;


 axis1   label=(  j=center  "Gender"  ) minor=none offset=(0,0)  major=none split="_" order=(-1 to 2 by 1) ;
axis2 label=(  j=center a=90   "&label" )  minor=none offset=(0,0)  major=(height=.7) minor=(number=2 h=.2) order=(&orderlow to &orderhigh by &orderby);

symbol1 interpol=boxt10  value=none co=black cv=black height=.6 bwidth=10 width=2; 


symbol2 value=dot h=1 ;

title1 /*ls=1.5*/  "&title at Birth for Singleton LBWI";


proc gplot data=&data   gout= cmv_rep.graphs; 
format treatmentgroup gender.; 
plot  &var*treatmentgroup &var*treatmentgroup2/ overlay name ="&n" nolegend  haxis=axis1 vaxis=axis2  ;
 

run;
quit; 

%mend box_plot;


%box_plot(data=chemistry_plot3 ,var=olsen_weight_z, title=Figure 7: Weight (Z-score) , label= Weight (Z-score), studygroup=1, orderlow=-5, orderhigh=5,orderby=0.5, n=wei_o); 
%box_plot(data=chemistry_plot3 ,var=olsen_length_z, title=Figure 8: Length (Z-score) , label=Length (Z-score) ,studygroup=1, orderlow=-5, orderhigh=5,orderby=0.5, n=len_o); 
%box_plot(data=chemistry_plot3 ,var=olsen_hc_z, title=Figure 9: Head Circumference (Z-score) , label=Head Circumference (Z-score) , studygroup=1, orderlow=-5, orderhigh=5,orderby=0.5, n=cir_o); 



options nodate orientation=portrait;
goptions device=ps gsfname=grafout gsfmode=replace  hsize=7in vsize=7in; 
 


ods rtf file = "&output./annual/&m_f_plot_file.M_f_mixed_plot.rtf"  style=journal
toc_data startpage =yes bodytitle ;


ods noproctitle proclabel "&m_f_plot_title. LBWI growth plots by gender";


proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=whole
nofs;


treplay 1:wei_o; 
 treplay 1:len_o; 
treplay 1:cir_o;
treplay 1:wei ; 
treplay 1:len  ; 

treplay 1:cir  ;

run;


ods rtf close; 
ods listing; 

quit;


options nodate orientation=portrait;
goptions device=jpeg gsfname=grafout gsfmode=replace  hsize=7in vsize=7in; 
 


ods pdf file = "&output./annual/&m_f_plot_file.M_f_mixed_plot2.pdf"  style=journal
 ;


ods noproctitle proclabel "&m_f_plot_title. LBWI growth plots by gender";


proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=whole
nofs;


treplay 1:wei_o; 
 treplay 1:len_o; 
treplay 1:cir_o;
treplay 1:wei ; 
treplay 1:len  ; 

treplay 1:cir  ;

run;


ods pdf close; 
ods listing; 

quit;





