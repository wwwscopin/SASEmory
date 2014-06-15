/* ae_cases_patients_by_center.sas
 *
 * returns two SAS datasets:	one which reports the total number of cases by AE, the other the number and proportion of people 
 * 							with that AE.
 *
 */


/********************************************************************
THIS FILE NEEDS TO BE UPDATED FOR THE ADDITION OF HYPO/HYPERGLYCEMIA
REFER TO AE_CASES_PATIENTS.SAS
*********************************************************************/

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
*/;



/* by patient */

data ae_temp;
	set glnd.plate201;
	
	array ae(17);

	* mark AEs that do occur, for the patient group with AEs. will be "." for the AEs that they do not have.;
	do i=1 to 17;
 		if ae_type=i then ae(i)=1;
	end; 
	
	* handle hyper/hypoglycemia ;
                if (ae_type = 15) & (ae_glycemia = 1) then hyper = 1;
                if (ae_type = 15) & (ae_glycemia = 2) then hypo = 1;

  
	keep id ae1-ae17 hyper hypo;
run;

proc sort; by id; run;

* for each patient, go through each AE and determine whether they've had it and also sum up the number of AEs for later reporting of cases;
proc means noprint;
	by id;
	var ae1-ae17 hyper hypo;
	output out=aes_by_patient max=ae1-ae17 
	sum = sum_ae1-sum_ae17 max(hyper hypo) = hyper hypo sum(hyper hypo) = sum_hyper sum_hypo;
proc print;

proc print;

* get full list of IDs;
data r;
	set glnd.plate8;
	keep id;

* get treatments;
data trt;
	set glnd.george;
	keep treatment id;
	label treatment='Treatment';
	format treatment trt.;

* assemble people with each AE, all IDs, treatments;      
data glnd.ae_patients;
       merge r aes_by_patient trt;
        by id;

		* change all non-occurences of AEs to 0;
        array ae(17);
        do i=1 to 17;
           if ae(i)=. then ae(i)=0;
        end;
		
	center = int(id/10000) ; * returns first digit of center ;
	if hyper = . then hyper = 0;
			if hypo = . then hypo = 0;


	
      keep id ae1-ae17 treatment center hypo hyper;
      format ae1-ae17 yn.;
      format center center.;
      label ae1 = "Respiratory distress"
                 ae2 = "Tracheostomy"
                 ae3 = "Significant pulmonary aspiration"
                 ae4 = "Pneumothorax"
                 ae5 = "Pulmonary emboli"
                 ae6 = "Wound dehiscence"
                 ae7 = "New onset significant hemorrhage"
                 ae8 = "Mechanical intestinal obstr."
                 ae9 = "Worsening renal function"
                 ae10 = "Worsening hepatic function"
                 ae11 = "Myocardial infarction"
                 ae12 = "Cerebrovascular accident"
                 ae13 = "Re-admission to ICU/SICU"
                 ae14 = "New onset significant skin rash"
                 ae15 = "Hyperglycemia > 250 mg/dL"
                 ae16 = "Non-infectious pancreatitis"
                 ae17 = "Encephalopathy" 
                 hyper = "Hyperglycemia"
				hypo = "Hypoglycemia";
run;

proc print data = glnd.ae_patients;
run;

title 'Total patients with each AE'; 
proc sort data= glnd.ae_patients; by center; run;
 proc freq data = glnd.ae_patients;
 	by center;
             tables ae1-ae17 hyper hypo;
	run;

/* by case */

* add treatment labels to each AE;
data aes_by_patient_center;
	merge aes_by_patient (in = has_AE)
		 trt;
	by id;
	if ~has_AE then delete;

	center = int(id/10000) ; * returns first digit of center ;
      format center center.;

run;

proc sort data= aes_by_patient_center; by center treatment  id; run;

* get sums overall and by center and treatment , for each AE; 
proc means data= aes_by_patient_center noprint;
	class center treatment;
	var sum_ae1-sum_ae17 sum_hyper sum_hypo;
*	output out = glnd.ae_cases sum = ae1-ae17 sum(sum_hyper sum_hypo) = hyper hypo;; 
output out = ae_cases sum = ae1-ae17 sum(sum_hyper sum_hypo) = hyper hypo;;



data glnd.ae_cases_by_center ;
	set ae_cases;

		* change all non-occurences of AEs to 0;
        array ae(17);
        do i=1 to 17;
           if ae(i)=. then ae(i)=0;
        end;
        if hyper = . then hyper = 0;
			if hypo = . then hypo = 0;

      label ae1 = "Respiratory distress"
                 ae2 = "Tracheostomy"
                 ae3 = "Significant pulmonary aspiration"
                 ae4 = "Pneumothorax"
                 ae5 = "Pulmonary emboli"
                 ae6 = "Wound dehiscence"
                 ae7 = "New onset significant hemorrhage"
                ae8 = "Mechanical intestinal obstr."
                 ae9 = "Worsening renal function"
                 ae10 = "Worsening hepatic function"
                 ae11 = "Myocardial infarction"
                 ae12 = "Cerebrovascular accident"
                 ae13 = "Re-admission to ICU/SICU"
                 ae14 = "New onset significant skin rash"
                 ae15 = "Hyperglycemia > 250 mg/dL"
                 ae16 = "Non-infectious pancreatitis"
                 ae17 = "Encephalopathy" hyper = "Hyperglycemia"
				hypo = "Hypoglycemia"
		;
	
	keep ae1-ae17 treatment hyper hypo;

title 'Total cases of AEs'; 
proc print data= glnd.ae_cases_by_center label;

* also report overall above;
* then by center (first digit of ID) ; 
