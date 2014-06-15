
******* create sas datesets to be used by splus to create reports

********get demographic , screening, and others;

data x;
 set glnd.plate1;
  center=int(id/10000);
  keep id apache_id in_sicu_choice center dt_writ_consent;
   format center center.;
   label center='Clinical Center';
  proc sort; by id;
  
data trt;
 set glnd.george;
keep treatment id dt_random;
label treatment='Treatment';
format treatment trt.;
  data y;
   set glnd.plate9;
    bmi=pre_op_kg/((pre_op_cm/100)**2);
    label bmi='BMI (kg/m*m)';
    
   data apse;
    set glnd.plate6;
    apachese=apache_total;
     label apachese='APACHE II at study entry';
     keep id apachese;
     
      data apic;
    set glnd.plate6b;
    apachesicu=apache_total;
     label apachesicu='APACHE II first day SICU';
     keep id apachesicu;
     

    data glnd.basedemo;
     merge x y(in=a) glnd.plate10 glnd.plate22 trt apse apic;
     by id;
     if a;
     age=(dt_writ_consent-dt_birth)/365.25;
     length affil $ 12;
affil='Emory';
if center=2 then affil='Miriam';;
if center=3 then affil='Vanderbilt';
if center=4 then affil='Colorado';
if center=5 then affil='Wisconsin';

length surg $ 25;
if in_sicu_choice=1 then surg='CABG';
if in_sicu_choice=2 then surg='Cardiac valve';
if in_sicu_choice=3 then surg='Vascular';
if in_sicu_choice=4 then surg='Intestinal resection';
if in_sicu_choice=5 then surg='Peritonitis';
if in_sicu_choice=6 then surg='Upper GI resection';

if id=11014 then surg='Cardiac valve';
              
length rac $ 35;
               if race=  1 then rac= "American Indian / Alaskan Native";
               if race=  2 then rac= "Asian";
               if race=  3 then rac= "Black or African American";;
               if race=  4 then rac= "Native Hawaiian or Pacific Islan";
               if race=  5 then rac= "White";
               if race=  6 then rac= "More than one race";
               if race=  7 then rac= "Other" ;
length diag $ 72;



diag=put(primary_diag, demo_diag.);
if primary_diag=13 then diag=primary_diag_oth;

daysop=dt_random-dt_primary_elig_op;
label daysop='Days from Index Surgery to Enrollment';


     label age='Age at Consent'
          gender='Gender'
               rac='Race'
               hispanic='Hispanic'
               apache_id='Apache II Score at study entry'
               ards='ARDS Present?'
               mech_vent='On Ventilator at Entry'
               surg='Index Surgery'
               affil='Clinical Center'
               diag='Primary Diagnosis leading to Elig. Surgery'
                wbc_count="WBC count (1000/uL)"

        int_aortic_pump="Intra-aortic pump?"
        nosc_infect="Pre-Nosocomial infection?"
        nutr_status="Nutritional status"
        indication_pn_1="PN Indication - Ileus"
        indication_pn_2="PN Indication - Ischemic bowel"
        indication_pn_3="PN Indication - Hemodynamic instab."
        indication_pn_4="PN Indication - Intolerence to ent."
        indication_pn_5="PN Indication - Bowel obstruction"
        indication_pn_6="PN Indication - Other"
        indication_pn_oth="PN Indication - Other (specify)"
        ent_nutr="Enteral nutrition within 30 days prior to entry"
        ent_nutr_days="Days ent nutrition"
        parent_nutr="Parenteral nutrition within 30 days prior to entry"
        parent_nutr_days="Days parent nutrition"
            
               ;
options ls=90 ps=53;     
proc sort; by id;
run;
*endsas;

proc freq;
 tables surg*center;
 ods output crosstabfreqs=one;
 run;
 
 proc sort; by surg;run;
  
 proc transpose data=one out=tmp; by surg; 
 var center frequency ColPercent rowpercent;
 run;
 
 proc print;run;
 data _null_;
    set tmp;
    if _n_=2 then do;
        call symput("n1", compress(col1));
        call symput("n2", compress(col2));
        call symput("n3", compress(col3));
        call symput("n4", compress(col4));
        call symput("n5", compress(col5));    
     end;
 run;
 
 %let n=%eval(&n1+&n2+&n3+&n4+&n5);


 data surg;
    merge tmp(where=(_name_='Frequency')) 
          tmp(where=(_name_='ColPercent') rename=(col1=cp1 col2=cp2 col3=cp3 col4=cp4 col5=cp5)) 
          tmp(where=(_name_='RowPercent') rename=(col1=rp1 col2=rp2 col3=rp3 col4=rp4 col5=rp5)) ; 
          by surg;
          col6=sum(of col1-col5);
          cp6=col6/&n*100;
          drop _NAME_   _LABEL_  ;
          c1=col1||"("||compress(put(cp1,4.1))||"%)";
          c2=col2||"("||compress(put(cp2,4.1))||"%)";
          c3=col3||"("||compress(put(cp3,4.1))||"%)";
          c4=col4||"("||compress(put(cp4,4.1))||"%)";
          c5=col5||"("||compress(put(cp5,4.1))||"%)";
          c6=col6||"("||compress(put(cp6,4.1))||"%)";
          if surg=" " then delete;
 run;

ods rtf file="surg.rtf" style=journal bodytitle;
proc print data=surg noobs label split="*" style(header) = [just=center];
title "Table1: Baseline Demographic and Clinical Characteristics by Treatment";
Var surg /style(data)=[cellwidth=1.5in just=left];
var c1-c6 /style(data) = [cellwidth=0.8in just=center] ;
label  surg="."
       c1="Emory*(n=&n1)"   
       c2="Miriam*(n=&n2)"
       c3="Colorado*(n=&n3)"
       c4="Vanderbilt*(n=&n4)"
       c5="Wisconsin*(n=&n5)"
       c6="Total*(n=&n)"
		;
run;

ods rtf close;
 
/*
proc freq;
 tables dt_random gender race apache_id ards mech_vent surg affil diag ards int_aortic_pump
 nosc_infect nutr_status wbc_count indication_pn_1 indication_pn_2
 indication_pn_3 indication_pn_4 indication_pn_5 indication_pn_6
 indication_pn_oth ent_nutr parent_nutr;
 run;
 */
