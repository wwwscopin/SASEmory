data screen;
 merge glnd.plate1 glnd.plate2;
 by id;

if today()-dt_screen > 30 then delete;
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

label center='Center'
      enrolled='Enrolled'
	  affil='Center'
      screened='Screened';
 if center >5 then delete;
 

if enrolled=0;
data inelig;
 set screen;
 length  reas1-reas21 reason $ 70;
 if in_sicu=0 then do; reason='In SICU for Other Reason'; output; end;
 if require_pn=0 then do; reason='Will Not Likely Require PN for 7+ Days'; output; end;
array junk(21) age_18_80--study_proc;

array reas(21) $ reas1-reas21 
("Age<18 or >80" " BMI >=40"
        "SICU care <2 or >14 days"
        "Central venous PN < 7 days"
        "no Central access"
        "Physician(s) will not allow"
        "Received PN 4+ days"
        "Patient pregnant"
        "Clinical sepsis prior"
        "Malignancy "
        "Seizure hist/disorder"
        "Unexplained enceph."
        "Cirr or bilirubin >10"
        "Renal dysfunction"
        "Burn trauma injury"
        "Gastric surg Whipple"
        "Organ transplant"
        "Investigational drug"
        "Ent/parent feedings"
        "History of HIV/AIDS"
        "Study procedures");
        
        do i=1 to 21;
        if i<7 and  junk(i) eq 0 then do;
                  reason=reas(i);
                  output;
                  end;
        if i>=7  and junk(i) eq 1 then do;
                  reason=reas(i);
                  output;
                  end;
      end;  
 
 keep affil reason id center;
 proc sort; by center id;
 data inelig1;
  set inelig;
  by center;
  affil1=affil;
  label affil1='Center';
  if ~(first.center and last.center) and ~first.center then affil1='           ';
  keep affil1 id reason ;
  
  data glnd.inelig30;
   set inelig1;
    by id;
    xid=put(id,6.);
    if ~(first.id and last.id) and ~first.id then xid='      ';
  label xid='ID'
        reason='Reason'; 
* ods ps file='30dayinelig.ps';
 
 proc print label noobs;
  var affil1 xid reason;
 title "Reasons Not Eligible in Last 30 Days";
 run;
 *ods ps close;
 
 data glnd.elignr30;
 set screen;
 length reason $ 70;
 if reas_no_consent=1 then do; reason='Patient Death'; output; end;
 if reas_no_consent=2 then do; reason='Patient Did Not Wish to Participate'; output; end;
 if reas_no_consent=3 then do; reason=reas_no_consent_spec; output; end;
 
  label affil='Center'
        reason='Reason'
         id='ID';
      keep affil reason  id;
 *ods ps file='30dayelignr.ps';
 proc print label noobs;
  var affil id reason;
 title "Reasons Eligible But Not Enrolled in Last 30 Days";
 run;
 *ods ps close;
 
