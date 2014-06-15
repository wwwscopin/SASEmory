data screen;
 merge glnd.plate1 glnd.plate2;
 by id;


**** do not use if dt_screen not from last monthly or before;
tod=today();
mon=month(tod);
yr=year(tod);
x=mdy(mon, 1, yr);
if dt_screen >=x then delete;
 drop tod mon yr x;

******* pat 39001 said reason not enrolled because of did not wish part
this is wrong because on plate2 pat was excluced;
if id=39001 then reas_no_consent=.;

if pt_elig=. and (in_sicu=0 or require_pn=0) then pt_elig=0;
screened=1;
enrolled=0;
if apache_id ne . and  dt_writ_consent ne . then enrolled=1;

if id=22027 then enrolled=1;
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

label center='Center'
      enrolled='Enrolled'
	  affil='Center'
      screened='Screened';
 if center >5 then delete;

if id=31351 then enrolled=1;
*************** remove later;
*************;

proc freq;
 tables enrolled;
run;

proc sort; by center;
*proc print;
*var center id pt_elig screened ;
*where center=3;
run;
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
 do center=1 to 4;
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
  
  data glnd.dsmc_recruitment_mon;
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


        if center = 1 then irbdate=mdy(11,1,2006); * Emory ;
        else if center = 2 then irbdate=mdy(1,1,2007); * Miriam ;
        else if center = 3 then irbdate=mdy(1,1,2007); * Vandy ;
        else if center = 4 then irbdate=mdy(2,1,2007); * Colorado; 
        else if center = 5 then irbdate=mdy(11,2,2009); * Wisconsin;
        else if center = 100 then irbdate=.; * total;
   irb=put(irbdate, mmddyy8.);
   keep center nscreened  e r irb;
   label center='Clinical Center'	
         nscreened='No. Screened'
		 e='No. Eligible (%)'
		 r='No. Enrolled (%)'
		 irb="Date IRB Approved";
  format center center.;

   proc print label noobs;
title recruitment;
   run;
