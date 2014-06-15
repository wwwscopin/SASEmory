data screen;
 merge glnd.plate1 glnd.plate2;
 by id;


******* pat 39001 said reason not enrolled because of did not wish part
this is wrong because on plate2 pat was excluced;
if id=39001 then reas_no_consent=.;

if pt_elig=. and (in_sicu=0 or require_pn=0) then pt_elig=0;
screened=1;
enrolled=0;
if apache_id ne . and  dt_writ_consent ne . then enrolled=1;


if study_proc=1 then  pt_elig=1;
if min(age_18_80  ,bmi_40,
        sicu_or_proc,  cent_ven_pn,  cent_access,  phys_allow)=0 then pt_elig=0;
if sum(pn_4_days,
        pregnant , clin_sepsis,  malig , seizure , unex_enceph , cirr_bilir,
        renal_dysfunc,  burn_trauma_inj , gast_whipple , organ_trans,
        invest_drug,  ent_parent_feed, hiv_aids)>=1 then pt_elig=0;
if pt_elig=0 then reas_no_consent=.;
 
center=int(id/10000);
length affil $ 12;
affil='Emory';
if center=2 then affil='Miriam';;
if center=3 then affil='Vanderbilt';
if center=4 then affil='Colorado';
if center=5 then affil='Wisconsin';

label center='Center'
      enrolled='Enrolled'
	  affil='Center'
      screened='Screened';
 if center >5 then delete;

proc sort; by center;



proc freq;
 tables enrolled; ;

ods select none;
proc freq ; by center;
tables screened;
ods output onewayfreqs=screened;
run;
data screened1;
 set screened;
  nscreened=frequency;
  keep nscreened center;
 run;

proc freq data=screen; by center;
tables pt_elig;
ods output onewayfreqs=elig;
where pt_elig=1;
run;



data elig1; set elig;
 nelig=frequency;
 keep center nelig;
run;



proc freq data=screen; by center;
tables enrolled;
ods output onewayfreqs=enrolled;
where enrolled=1;
run;

data enrolled1; set enrolled;
 nenrolled=frequency;
 keep center nenrolled;
run;

data center;
 do center=1 to 5;
     output;
 end;

data all;
 merge screened1 elig1 enrolled1 center ;
 by center;
ods select all;

proc means noprint;
 var nscreened nelig nenrolled;
 output out=tot sum=nscreened nelig nenrolled;
 run;
 data tot1;
  set tot;
  center=100;
  keep center nscreened nelig nenrolled;


  data glnd.dsmc_recruitment;
   set all tot1;
   if nenrolled=. then nenrolled=0;
   if nelig=. then nelig=0;
   if nscreened=. then nscreened=0;
   

   pelig=round(nelig*100/nscreened);
   penroll=round(nenrolled*100/nelig);

   e1=trim(put(nelig,3.));
   e2=trim(put(pelig,3.));
   e=e1||' ('||e2||'%)';
   if nscreened<=0 then e='     -';
   r1=trim(put(nenrolled,3.));
   r2=trim(put(penroll,3.));
   r=r1||' ('||r2||'%)';

    if nelig<=0 then r='     -';

   keep center nscreened  e r;
   label center='Clinical Center'
         nscreened='No. Screened'
		 e='No. Eligible (%)'
		 r='No. Enrolled (%)';
  format center center.;

   proc print label noobs;
title recruitment;
   run;

data glnd.screened;
 set screen;
 run;


data ran;
 set glnd.plate8;
 keep id dt_random;
**************
now do for each month;

%macro screen (mon, yr, dsn);
***** for which month (mon), year (yr)
      output to dsn;
     
      
data screen;
 merge glnd.plate1 glnd.plate2 ran;
 by id;
x=dt_random;
if x=. then x=dt_screen;
 m=month(x);
 y=year(x);
if m=&mon and y=&yr;

******* pat 39001 said reason not enrolled because of did not wish part
this is wrong because on plate2 pat was excluced;
if id=39001 then reas_no_consent=.;

if pt_elig=. and (in_sicu=0 or require_pn=0) then pt_elig=0;
screened=1;
enrolled=0;
if apache_id ne . and  dt_writ_consent ne . then enrolled=1;

if id=52029 then enrolled=1;

if study_proc=1 then  pt_elig=1;

if min(age_18_80  ,bmi_40,
        sicu_or_proc,  cent_ven_pn,  cent_access,  phys_allow)=0 then pt_elig=0;
if sum(pn_4_days,
        pregnant , clin_sepsis,  malig , seizure , unex_enceph , cirr_bilir,
        renal_dysfunc,  burn_trauma_inj , gast_whipple , organ_trans,
        invest_drug,  ent_parent_feed, hiv_aids)>=1 then pt_elig=0;
if pt_elig=0 then reas_no_consent=.;
 
center=int(id/10000);
length affil $ 12;
affil='Emory';
*if center=1 then affil='Emory';
if center=2 then affil='Miriam';
if center=3 then affil='Vanderbilt';
if center=4 then affil='Colorado';
if center=5 then affil='Wisconsin';

label center='Center'
      enrolled='Enrolled'
	  affil='Center'
      screened='Screened';
 if center >5 then delete;
proc sort; by center;
run;


 /*
proc print;
var center id pt_elig screened ;
title "&mon &yr";
run;



proc datasets;
 delete enrolled;
 delete enrollled1;
 delete elig;
 *****
*/


ods select none;
proc freq ; by center;
tables screened;
ods output onewayfreqs=screened;
run;

data screened1;
 set screened;
  nscreened=frequency;
  keep nscreened center;
 run;

data elig;
   do center=1 to 5;
        frequency=0;
        output;
end;
   

proc freq data=screen; by center;
tables pt_elig;
ods output onewayfreqs=elig;
where pt_elig=1;
run;

data elig1; set elig;
 nelig=frequency;
 keep center nelig;
run;




proc datasets;
 delete enrolled;
 delete enrollled1;
 *****
 create dummy dataset with 0 for enrolled
 just in case noone enrolled in a given month;
 *****;
  data enrolled;
   do center=1 to 5;
        frequency=0;
        output;
   end;
   
   

proc freq data=screen; by center;
tables enrolled;
ods output onewayfreqs=enrolled;
where enrolled=1;
run;

data enrolled1; set enrolled ;
 nenrolled=frequency;
 keep center nenrolled;
run;

data center;
 do center=1 to 5;
     output;
 end;

data all;
 merge screened1 elig1 enrolled1 center ;
 by center;
ods select all;




proc means noprint;
 var nscreened nelig nenrolled;
 output out=tot sum=nscreened nelig nenrolled;
 run;
 data tot1;
  set tot;
  center=100;
  keep center nscreened nelig nenrolled;


  data x;
   set all tot1;
   if nenrolled=. then nenrolled=0;
   if nelig=. then nelig=0;
   if nscreened=. then nscreened=0;
   

   pelig=round(nelig*100/nscreened);
   penroll=round(nenrolled*100/nelig);

   e1=trim(put(nelig,3.));
   e2=trim(put(pelig,3.));
   e=e1||' ('||e2||'%)';
   if nscreened<=0 then e='     -';
   r1=trim(put(nenrolled,3.));
   r2=trim(put(penroll,3.));
   r=r1||' ('||r2||'%)';

    if nelig<=0 then r='     -';
    d8='       ';
    if _n_=1 then d8=put(mdy(&mon, 15, &yr), monyy7.);
    xc=put(center, center.);
      nc=nscreened;
   
   keep xc nc  e r d8;
   label center='Clinical Center'
         d8='Month'
         nscreened='No. Screened'
		 e='No. Eligible (%)'
		 r='No. Enrolled (%)';
  ;

  data x1;
   set x;
    center=xc;
     drop xc;
     nscreened=put(nc,4.);
      label center='Clinical Center'
       nscreened='No. Screened';
      data x2;
      center=' '; d8=' '; nscreened=' '; e=' '; r=' ';
    data &dsn;
     set x1 x2;
     run; 

%mend;
options mprint symbolgen;

***** no generate the screen macro call and store it into sc1.sas
      and then include it 
      it should look like this;
/*

%screen (2,2008,m1);
%screen (1,2008,m2);
%screen (12,2007,m3);
%screen (11,2007,m4);
%screen (10,2007,m5);
%screen (9,2007,m6);




*/;
%macro sc;
   data t;
   file 'sc1.sas';
   %do mo=1 %to 7;
    *x=today();
    x="1Nov2011"d;
	format x mmddyy8.;
	m=month(x)-&mo;
	y=year(x);
	if m<=0 then do;
	   m=12+m;
	   y=y-1;
	end;
	put '%screen (' m ',' y ',' "m&mo" '); ';
	output;
   %end;
	run;
%mend;
%sc;

%inc 'sc1.sas';quit;

data glnd.screen6mo; 
 set m1 m2 m3 m4 m5 m6;
  *set m4 m5 m6;
 /*
 proc print label noobs;
  var  d8 center nscreened e r;
 */
run;

* 3/8/2010:	Fix this program to properly drop Miriam at Nov' 2009 and add Wisconsin;
data glnd.screen6mo;
	set glnd.screen6mo;
	retain cur_date;

	order = _N_; 	* i also want this sorted in the reverse order so that it matches the QC table;

	* track date within each month block;	
	if compress(center) = "Emory" then cur_date = input(d8, monyy7.);

		if ~(( (year(cur_date) = 2009) & (month(cur_date) < 11) & (center = "Wisconsin"))			/* Wisconsin */ 
			| ( (year(cur_date) = 2009) & (month(cur_date) >= 11) & (center = "Miriam") ) | ((year(cur_date) > 2009) & (center = "Miriam")) )		/* Miriam */
		then output;



run;
* i also want this sorted in the reverse order so that it matches the QC table;
	proc sort data = glnd.screen6mo; by cur_date  order; run;

	data glnd.screen6mo;
		set glnd.screen6mo;
		drop cur_date order;
	run;

proc print data = glnd.screen6mo label noobs;
  var d8 center nscreened e r;
run;
		

