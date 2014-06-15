*libname glnd '/glnd/sas/dsmc/20100219';
options ls=82 ps=52 nodate nonumber;

%include "macro.sas";

 data reason1;
  set glnd.screened;
  length reason $ 50;
  if in_sicu=0 then do;
     reason='In SICU due to wrong reason' ;
     output;
  end;
  if require_pn=0 then do;
     reason='Require PN<7 days' ;
     output;
  end;
 if age_18_80=0 then do;
     reason='AGE not 18-80' ;
     output;
  end;
   if bmi_40=0 then do;
     reason='BMI >= 40' ;
     output;
  end;
   if sicu_or_proc=0 then do;
     reason='NOT in Post Op Days Range' ;
     output;
  end;
   if cent_ven_pn=0 then do;
     reason='Central Venous PN < 7 days' ;
     output;
  end;
   if cent_access=0 then do;
     reason='No Central Access' ;
     output;
  end;
   if phys_allow=0 then do;
     reason='Physician(s) Will NOT Allow' ;
     output;
  end;
if pn_4_days=1 then do;
     reason='Received PN 4+ days' ;
     output;
  end;
  if pregnant=1 then do;
     reason='Patient Pregnant' ;
     output;
  end;
  if clin_sepsis=1 then do;
     reason='Clinical Sepsis within 24 hrs study entry' ;
     output;
  end;
if malig=1 then do;
     reason='Malignancy ' ;
     output;
  end;
if seizure=1 then do;
     reason='Seizure Hist/Disorder' ;
     output;
  end;
if unex_enceph=1 then do;
     reason='Unexplained Encephalopathy' ;
     output;
  end;
if cirr_bilir=1 then do;
     reason='Cirrhosis or Bilirubin >=10' ;
     output;
  end;
if renal_dysfunc=1 then do;
     reason='Renal Dysfunction' ;
     output;
  end;
if burn_trauma_inj=1 then do;
     reason='Burn Trauma Injury' ;
     output;
  end;
if gast_whipple=1 then do;
     reason='Gastric Surgery or Whipple' ;
     output;
  end;
if organ_trans=1 then do;
     reason='Organ Transplant' ;
     output;
  end;
if  invest_drug=1 then do;
     reason='Received Investigational Drug' ;
     output;
  end;
if ent_parent_feed=1 then do;
     reason='Ent/Parent Feedings' ;
     output;
  end;
  if hiv_aids=1 then do;
     reason='History of HIV/AIDS' ;
     output;
  end;


 keep id reason;

 proc sort; by id;
 data x;
  set reason1;
   by id;
   length affil $ 12;
   c=int(id/10000);
   label c='Clinical Center';
   if first.id then do;
   
    center=int(id/10000);
    affil='Emory';
    if center=2 then affil='Miriam';;  
    if center=3 then affil='Vanderbilt';
    if center=4 then affil='Colorado';
    if center=5 then affil='Wisconsin';
    glndid=put(id,6.);
   
   end;
  
  format center center.;
   label center='Clinical Center'
    id='GLND ID No.'
    glndid='GLND ID No.'
	reason='Reason Not Eligible'
	affil='Clinical Center';
	drop center;
	if center=. then affil=' ';


  


	data glnd.inelig_screen;
	 set x;
	  drop id;
 proc freq;
 tables reason;
 run;
 

 ods pdf file='inelig_screen.pdf';
 
data single;
 set x;
  by id;
  if first.id and last.id;
  proc sort; by affil;
  proc freq;
   by affil;
   tables reason / nocum nopercent;
   title Summary of all patients with only 1 reason not eligible;
  run;
  title;
data glnd.inelig_screen1;
	 set x;
	  drop id;
	  if c=1;
	  
	  
	  
 proc print label;
 title Emory;
  var glndid reason;
  
 run;
 
 data glnd.inelig_screen2;
	 set x;
	  drop id;
	  if c=2;
	  
 proc print label;
 title Miriam;
  var glndid reason;
 run;
 data glnd.inelig_screen3;
	 set x;
	  drop id;
	  if c=3;
	  
 proc print label;
 title Vanderbilt;
  var glndid reason;
 run;
 data glnd.inelig_screen4;
	 set x;
	  drop id;
	  if c=4;
	  
 proc print label;
 title Colorado;
  var glndid reason;
 run;

data glnd.inelig_screen5;
	 set x;
	  drop id;
	  if c=5;
	  
 proc print label;
 title Wisconsin;
  var glndid reason;
 run;

ods pdf close;
title;



%let n1=0;
%let n2=0;
%let n3=0;
%let n4=0;
%let n5=0;
%let n=0;

%table(glnd.inelig_screen, tab, reason, c); quit;

*options orientation=landscape;

ods rtf file="reason_center.rtf" style=journal bodytitle;
proc print data=tab noobs label split="*" style(header) = [just=center];
title "Reasons Patients Were Ineligible at Screening by Center";
Var reason /style(data)=[cellwidth=2.5in just=left];
var c1-c5 c /style(data) = [cellwidth=0.8in just=center] ;
label  Reason="Reason Not Eligible"
       c1="Emory*(n=&n1)"   
       c2="Miriam*(n=&n2)"
       c3="Vanderbilt*(n=&n3)"
       c4="Colorado*(n=&n4)"
       c5="Wisconsin*(n=&n5)"
       c="Total*(n=&n)";
run;

ods rtf close;


