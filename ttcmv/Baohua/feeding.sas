%include "cmv_bmfeed28.sas";

options nofmterr nodate nonumber orientation=landscape byline;

/*
proc sql; 
    create table feed as 
       select a.id, b.*
       from cmv.completedstudylist as a 
       left join 
       (select * from cmv.plate_106 where dfstatus=1) as b 
       on a.id=b.id
       ;  
quit;
*/

data feeding;
    merge cmv.plate_106(where=(dfstatus=1) in=A keep=id dfstatus parenteral_nut enteral_feed date_enteral_feed enteral_feed120  date_enteral_feed120 weight_below_bw  date_weight_regained)
    cmv.completedstudylist(in=B)  cmv.lbwi_demo(keep=id lbwidob rename=(lbwidob=dob)) 
    cmv.bmfeed28;by id; 
    
    if B;
    if A and not enteral_feed then enteral_feed120=99;
    if A then feed=1; else feed=0;
    df=date_enteral_feed-dob;
    df120=date_enteral_feed120-dob;
    dwg=date_weight_regained-dob;
run;

proc sort nodupkey; by id; run;


data tmp;
    set feeding;
    where df>300 or df120>300 or dwg>300 or (df<0 and df^=.) or (df120<0 and df120^=.) or (dwg<0 and dwg^=.);
run;

proc print;
var id dob date_enteral_feed df date_enteral_feed120 df120 date_weight_regained dwg;
run;

data feeding;
    set feeding;
    if df>300 or df<0 then df=.;
        if df120>300 or df120<0 then df120=.;
            if dwg>300 or dwg<0 then dwg=.;
run;

proc format; 

value yn 1="Yes" 0="No" 99="NA";
value item  1="Total days of parenteral nutrition: Median[min-max], N"
            2="No. infants who received enteral feeds"
            3="From birthday to Date of first enteral feed: Median[min-max], N"
            4="No. infants who reached full feeds"
            5="From birthday to Date first full feeds achieved: Median[min-max], N"
            6="No. infants whose weight fell below birth weight"
            7="From birthday to Date birth weight regained: Median[min-max], N*"
            8="No. of days baby received any breast milk in first 28 days: Median[min-max], N"; 
run;

data feeding1;
    set feeding feeding(in=A);
    if A then center=8;
    if id=. then delete;
run;

proc means data=feeding1 n median min max; 
class center;
var parenteral_nut df df120 dwg bm28;
ods output means.summary=tmp;
run;

data med;
    set tmp;
    h1=compress(parenteral_nut_median)||"["|| compress(parenteral_nut_min)||"-"||compress(parenteral_nut_max)||"], "||compress(parenteral_nut_N);
    h2=compress(df_median)||"["|| compress(df_min)||"-"||compress(df_max)||"], "||compress(df_N);
    h3=compress(df120_median)||"["|| compress(df120_min)||"-"||compress(df120_max)||"], "||compress(df120_N);
    h4=compress(dwg_median)||"["|| compress(dwg_min)||"-"||compress(dwg_max)||"], "||compress(dwg_N);
    h5=compress(bm28_median)||"["|| compress(bm28_min)||"-"||compress(bm28_max)||"], "||compress(bm28_N);
    keep center h1-h5;
run;

proc transpose data=med out=med; var h1-h5;run;

data med; 
    set med;
    rename _name_=var;
    
    if _name_="h1" then item=1;
        if _name_="h2" then item=3;
            if _name_="h3" then item=5;
                if _name_="h4" then item=7;
                    if _name_="h5" then item=8;
run;

proc means data=cmv.comp_pat noprint;
class center;
var id;
output out=wbh n(id)=n;
run;

data _null_;
    set wbh;
    if center=1 then call symput("n1", compress(n));
    if center=2 then call symput("n2", compress(n));
    if center=3 then call symput("n3", compress(n));
    if center=. then call symput("n", compress(n));    
run;


data nid;
    merge cmv.plate_106(in=A) cmv.completedstudylist(in=B); by id;
    center=floor(id/1000000);
    if A and B;
run;

proc means data=nid;
class center;
var id;
output out=temp n(id)=n;
run;

data _null_;
    set temp;
    if center=1 then call symput("m1", compress(n));
    if center=2 then call symput("m2", compress(n));
    if center=3 then call symput("m3", compress(n));
    if center=. then call symput("m", compress(n));    
run;


%macro feed(data, out, varlist);
data &out;
    if 1=1 then delete;
run;

%let i=1; 
%let var=%scan(&varlist, &i);
%do %while(&var NE);

proc freq data=&data; 
tables &var*center/norow nocol nopercent;
ods output crosstabfreqs=tab&i;
run;

data tab&i;   

    %global k1 k2 k3 k;
    set tab&i(keep=center frequency &var rename=(frequency=n));
    rename &var=code;
    if &var=. or &var=99 then delete;
    if center=. then center=8;
    format center center.;
    %if &i=1 %then %do;
    if &var=1 and center=1 then call symput("k1", compress(n));
    if &var=1 and center=2 then call symput("k2", compress(n));
    if &var=1 and center=3 then call symput("k3", compress(n));
    if &var=1 and center=8 then call symput("k",  compress(n)); 
    %end;
run;

%put &k1;
%put &k2;
%put &k3;
%put &k;

proc transpose data=tab&i out=tab&i; by code; var n;run;

data tab&i;
    set tab&i;
    item=&i;
    
    if item^=2 then do;
        f1=col1/&m1*100;      f2=col2/&m2*100;      f3=col3/&m3*100;      f=col4/&m*100;     
        nf1=col1||"/&m1("||put(f1,4.1)||"%)";
        nf2=col2||"/&m2("||put(f2,4.1)||"%)";
        nf3=col3||"/&m3("||put(f3,4.1)||"%)";
        nf=col4||"/&m("||put(f,4.1)||"%)";
    end;
    else do;
        f1=col1/&k1*100;      f2=col2/&k2*100;      f3=col3/&k3*100;      f=col4/&k*100;     
        nf1=col1||"/&k1("||put(f1,4.1)||"%)";
        nf2=col2||"/&k2("||put(f2,4.1)||"%)";
        nf3=col3||"/&k3("||put(f3,4.1)||"%)";
        nf=col4||"/&k("||put(f,4.1)||"%)";    
    end;
run;

data &out;
    set &out tab&i;
    if code=1;
    format item item. code yn.;
run;

proc sort; by item code;run;

%let i=%eval(&i+1);
%let var=%scan(&varlist,&i);
%end;
data &out;
    set &out; 
    item=item*2;
run;
%mend feed;

%let varlist=enteral_feed enteral_feed120 weight_below_bw;
%feed(feeding,feed,&varlist);


data feed;
   set med(rename=(col1=nf1 col2=nf2 col3=nf3 col4=nf)) feed; by item;
run;


%let path=/ttcmv/sas/output/monthly_internal/;
ods rtf file="&path&file_feeding.feed.rtf" style=journal bodytitle startpage=No;
proc report data=feed nowindows split="*";
title1 "&title_feeding (n=&n)";
column item nf1-nf3 nf;
define item/"Questions" format=item. style=[cellwidth=4.75in just=left];
define nf1/ "Midtown*(n=&n1)" style=[just=center cellwidth=1.25in];
define nf2/ "Grady*(n=&n2)" style=[just=center cellwidth=1.25in];
define nf3/ "Northside*(n=&n3)" style=[just=center cellwidth=1.25in];
define nf/ "Overall*(n=&n)" style=[just=center cellwidth=1.25in];
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=11pt}
*The N for this row is the number of patients who regained their birth weight; 
note this is the number of patients who had their birth weight fall minus the number of 
patients who died before regaining their birth weight.";
ods rtf close;
