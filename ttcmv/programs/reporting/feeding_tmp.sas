options nofmterr nodate nonumber orientation=landscape;

data feeding;
    merge cmv.plate_106(in=A keep=id parenteral_nut enteral_feed date_enteral_feed enteral_feed120  date_enteral_feed120 weight_below_bw  date_weight_regained)
    /*cmv.comp_pat(in=B)*/
    cmv.valid_ids(in=B)    cmv.lbwi_demo(keep=id lbwidob rename=(lbwidob=dob)) 
    cmv.bmfeed28;by id; 

    center=floor(id/1000000);
    
    if B;
    if A and not enteral_feed then enteral_feed120=99;
    if A then feed=1; else feed=0;
    df=date_enteral_feed-dob;
    df120=date_enteral_feed120-dob;
    dwg=date_weight_regained-dob;
run;

data _null_;
    set feeding(where=(feed=1));
    call symput("ng", compress(_n_));
run;
%put &ng;

proc format; 
value item 1="Did the LBWI receive enteral feeds?"
           2="Did enteral feeds reach 120 ml/kg/day?"
           3="Did weight fall below birth weight during the first 10 days?"
           ;
value yn 1="Yes" 0="No" 99="NA";
value $var "h1"="Total days of parenteral nutrition"
           "h2"="From birthday to Date of first enteral feed"
           "h3"="From birthday to Date first full feeds achieved"
           "h4"="From birthday to Date birth weight regained"
           "h5"="Number of days baby received any breast milk in first 28 days:"; 
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
run;

/*
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
*/

proc means data=feeding;
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
    merge cmv.plate_106(in=A) cmv.valid_ids(in=B); by id;
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
    set tab&i(keep=center frequency &var rename=(frequency=n));
    rename &var=code;
    if &var=. or &var=99 then delete;
    if center=. then center=8;
    format center center.;
run;

proc transpose data=tab&i out=tab&i; by code; var n;run;

data tab&i;
    set tab&i;
    item=&i;
    f1=col1/&m1*100;      f2=col2/&m2*100;      f3=col3/&m3*100;      f=col4/&m*100; 
    nf1=col1||"/&m1("||put(f1,4.1)||"%)";
        nf2=col2||"/&m2("||put(f2,4.1)||"%)";
            nf3=col3||"/&m3("||put(f3,4.1)||"%)";
                nf=col4||"/&m("||put(f,4.1)||"%)";
run;

data &out;
    set &out tab&i;
    format item item. code yn.;
    *nf1="-";
    *nf3="-";
    *nf="-";
run;

proc sort; by item code;run;

%let i=%eval(&i+1);
%let var=%scan(&varlist,&i);
%end;
%mend feed;

%let varlist=enteral_feed enteral_feed120 weight_below_bw;
%feed(feeding,feed,&varlist);

ods rtf file="feed_temp.rtf" style=journal bodytitle startpage=No;

proc print data=med noobs label split="*";
title "End of Study Feeding Summary (n=&n)";
var var /style=[just=left cellwidth=3.75in];
var col1-col4/style=[just=center cellwidth=1.5in];
label var="Days"
      col1="Midtown*Median[min-max], N"
      col2="Grady*Median[min-max], N"
      col3="Northside*Median[min-max], N"
      col4="Overall*Median[min-max], N"
      ;
      format var $var.;
run;

proc print data=feed noobs label split="*";
title "End of Study Feeding Summary (n=&n)";
by item;
id item/style=[cellwidth=2in];
var code nf1-nf3 nf/style=[just=center cellwidth=1.25in];
label item="Question"
      code="Results"
      nf1="Midtown*(&n1)"
      nf2="Grady*(&n2)"
      nf3="Northside*(&n3)"
      nf="Overall*(&n)";
run;
ods rtf close;
