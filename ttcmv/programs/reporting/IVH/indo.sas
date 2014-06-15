options nodate nonumber;
%include "macro.sas";


data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.completedstudylist(in=comp);
	by id;
	if comp;
    retain x_date;
	if first.id then x_date=imagedate;
	if ivhdiagdate=. then ivhdiagdate=x_date;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
    keep id;
run;

/*
data cmv.ivh2; 
    set ivh2;
run;

proc print;run;
*/

data civh;
    merge ivh2(in=tmp)
          cmv.bpd(where=(IsOxygenDOL28=1) keep=id IsOxygenDOL28 in=A)
          cmv.nec_p1(keep=id in=B)
          cmv.plate_100(keep=id in=C)
          cmv.completedstudylist(in=comp)
          cmv.plate_101(where=(deathdate^=.) keep=id deathdate in=D); 
          by id;
          if A then bpd=1; else bpd=0;
          if B then nec=1; else nec=0;
          if C or D then death=1; else death=0;
          if tmp then ivh=1; else ivh=0;
          if comp;
run;

proc sort nodupkey; by id; run;

proc freq data=civh(where=(ivh=1)); 
tables death nec bpd;
run;

proc freq data=civh(where=(ivh=0)); 
tables death nec bpd;
run;

proc freq data=civh;
    tables death*ivh/chisq fisher;
run;


/*
data indo;
    merge cmv.med(in=A) cmv.comp_pat(in=B); by id;
    if A and B and medcode=14;
        *if A and B and indication=3;
    keep id medcode indication;
run;

proc sort nodupkey; by id;run;
*/

data indo;
    merge cmv.med cmv.plate_005(keep=id LBWIDOB); by id;
    if medcode=14 and StartDate-LBWIDOB<=1; 
    keep id;
run;


data indo;
	merge indo(in=A) cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant in=B)
	      cmv.comp_pat(in=comp keep=id center);
	by id;
	if (A or Indomethacin) then indo=1; else indo=0;
	if comp;
	if A and B then idx=2;
	if A and not B then idx=0; 
	if (not A) and B then idx=1;
run;

proc sort nodupkey; by id; run;

proc freq data=indo(where=(indo=1)); 
tables idx;
run;

data ivh_indo;
    merge indo ivh2(in=A); by id;
    if A;
run;

%let n1=0;
%let n2=0;
%let n3=0;
%let n=0;

%table(indo, tab, indo, center); quit;

proc format;
	value ivh 0="IVH=No" 1="IVH=Yes";
	value ny 0="No" 1="Yes";
run;


ods rtf file="Indomethacin_center.rtf" style=journal bodytitle;
proc print data=tab noobs label split="*" style(header) = [just=center];
title "Table1: Indomethacin by Cetner";
Var indo /style(data)=[cellwidth=1.5in just=left];
var c1-c3 c /style(data) = [cellwidth=0.8in just=center] ;
format indo ny.;
label  indo="Indomethacin"
       c1="Midtown*(n=&n1)"   
       c2="Grady*(n=&n2)"
       c3="Northside*(n=&n3)"
       c="Total*(n=&n)";
run;

ods rtf close;

%let n1=0;
%let n2=0;
%let n3=0;
%let n=0;

%table(ivh_indo, tab1, indo, center); quit;

ods rtf file="Indomethacin_ivh2_center.rtf" style=journal bodytitle;
proc print data=tab1 noobs label split="*" style(header) = [just=center];
title "Table2: Indomethacin by Center for IVH (grade II, III, IV)";
Var indo /style(data)=[cellwidth=1.5in just=left];
var c1-c3 c /style(data) = [cellwidth=0.8in just=center] ;
format indo ny.;
label  indo="Indomethacin"
       c1="Midtown*(n=&n1)"   
       c2="Grady*(n=&n2)"
       c3="Northside*(n=&n3)"
       c="Total*(n=&n)";
run;

ods rtf close;

proc sql;

create table enrolled as
select a.* ,moc_dob
from 
cmv.Eligibility as a
left join
cmv.plate_007 as b
on a.id=b.id
where (Enrollmentdate is not null ) ;



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

/*
create table enrolled as
select * from enrolled
order by center,  EnrollmentDate asc,id;

*/
quit;

proc sort; by id; run;

data enrolled; 

merge enrolled cmv.completedstudylist(in=comp); by id;
if comp;

if ismultiple eq 1 then twin_status="singleton";
else if ismultiple eq 2 then twin_status="twin";
else if ismultiple eq 3 then twin_status="triplet";
run;

data cmv.enrolled;
    set enrolled;
    keep id ismultiple;
run;

proc print;run;

proc freq; 
tables ismultiple;
run;
