/* sae_cases_patients.sas
 *
 * returns two SAS datasets:	one which reports the total number of cases by sae, the other the number and proportion of people 
 * 							with that sae.
 *
 */


/* reference for sae codes 
   	sae_type   99 = "Blank"
                 1 = "Death"
                 2 = "Anaphylactic reaction"
                 3 = "Seizure"
                 4 = "Cardiopulmonary arrest"
                 5 = "Re-hospitalization w/in 30 days"
                 6 = "Re-operation w/in 30 days"
                 7 = "New cancer diagnosis"
                 8 = "Congenital anomaly/disorder" ;
*/;



/* by patient */

data sae_temp;
	set glnd.plate203;
	
	array sae(8);

	* mark saes that do occur, for the patient group with saes. will be "." for the saes that they do not have.;
	do i=1 to 8;
 		if sae_type=i then sae(i)=1;
	end;
  
	keep id sae1-sae8 ;
run;

proc sort; by id; run;

* for each patient, go through each sae and determine whether they've had it and also sum up the number of saes for later reporting of cases;
proc means noprint;
	by id;
	var sae1-sae8;
	output out=saes_by_patient max=sae1-sae8 sum = sum_sae1-sum_sae8;
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

* assemble people with each sae, all IDs, treatments;      
data glnd.sae_patients;
       merge r saes_by_patient trt;
        by id;

		* change all non-occurences of saes to 0;
        array sae(8);
        do i=1 to 8;
           if sae(i)=. then sae(i)=0;
        end;

      keep id sae1-sae8 treatment;
      format sae1-sae8 yn.;
      label sae1 = "Death"
                 sae2 = "Anaphylactic reaction"
                 sae3 = "Seizure"
                 sae4 = "Cardiopulmonary arrest"
                 sae5 = "Re-hospitalization w/in 30 days"
                 sae6 = "Re-operation w/in 30 days"
                 sae7 = "New cancer diagnosis"
                 sae8 = "Congenital anomaly/disorder" ;
           
           
title 'Total patients with each SAE'; 
 proc freq data = glnd.sae_patients;
             tables sae1-sae8;


/* by case */

* add treatment labels to each sae;
data saes_by_patient;
	merge saes_by_patient (in = has_sae)
		 trt;
	by id;
	if ~has_sae then delete;
	
run;

* get sums overall and by treatment, for each sae; 
proc sort data= trt; by treatment; run;
proc means data= saes_by_patient noprint;
	class treatment;
	var sum_sae1-sum_sae8;
	output out = glnd.sae_cases sum = sae1-sae8; 

data glnd.sae_cases;
	set glnd.sae_cases;

		* change all non-occurences of saes to 0;
        array sae(8);
        do i=1 to 8;
           if sae(i)=. then sae(i)=0;
        end;

      label sae1 = "Death"
                 sae2 = "Anaphylactic reaction"
                 sae3 = "Seizure"
                 sae4 = "Cardiopulmonary arrest"
                 sae5 = "Re-hospitalization w/in 30 days"
                 sae6 = "Re-operation w/in 30 days"
                 sae7 = "New cancer diagnosis"
                 sae8 = "Congenital anomaly/disorder" ;

	keep sae1-sae8 treatment;

title 'Total cases of SAEs'; 
proc print data= glnd.sae_cases label;  
  


