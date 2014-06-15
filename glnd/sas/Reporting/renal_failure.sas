/* ae_cases_patients.sas
 *
 * returns two SAS datasets:	one which reports the total number of cases by AE, the other the number and proportion of people 
 * 							with that AE.
 *
 */


/* reference for AE codes 
     	  ae   99 = "Blank"
                 1 = "Respiratory distress"
                 2 = "Tracheostomy"
                 3 = "Significant pulmunart aspiration"
                 4 = "Pneumothorax"
                 5 = "Pulmonary emboli"
                 6 = "Wound dehiscence"
                 7 = "New onset significant hemorrhage"
                 8 = "Mechanical intestinal obstr."
                 9 = "Worsening renal function"
                 10 = "Worsening hepatic function"
                 11 = "Myocardial infarction"
                 12 = "Cerebrovascular accident"
                 13 = "Re-admission to ICU/SICU"
                 14 = "New onset significant skin rash"
                 15 = "Hyperglycemia > 250 mg/dL"
                 16 = "Non-infectious pancreatitis"
                 17 = "Encephalopathy" ;
                 18 = "Hyperglycemia <250(mg/dL)"
                 19 = "Hypoglycemia <50(mg/dL)"
                 20 = "Hypoglycemia <40(mg/dL)";
*/;



/* by patient */

data ae_temp;
	set glnd.plate201;
	
       if ae_type=9;
keep id dt_ae_onset;

data trt;
	set glnd.george;
	keep treatment id dt_random;
	label treatment='Treatment';
	format treatment treatment.;
data l;
   merge ae_temp(in=a) trt;
   by id;
if a;
     days=dt_ae_onset-dt_random;
proc print label;

