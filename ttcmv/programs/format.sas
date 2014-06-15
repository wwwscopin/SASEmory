proc format library=library ; 
	value DFSTATv	
							0 = "lost"
							1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" 
	;

	value DFSCRNv	
							0 = "blank"
							1 = "clean"
							2 = "dirty"
							3 = "error" 
	;

	value yn			
							0 = "No"
							1 = "Yes" 
	;

	value na   	   
							0 = "No"
							1 = "Yes"
							2 = "N/A"
	;




* LBWI Eligibility/Screening/Enrollment ;

	value eligible 			/* Neeta hidden variable - actually indicates if LBWI enrolled or not, not whether eligible */
                 9 = "Not enrolled"
                 1 = "Enrolled" 
	;

	value screen_elig_enroll	
							1 = "Screened - Not eligible"
							2 = "Eligible - Did not consent"
							3 = "Enrolled"
	;


 * LBWI demographic form ;
  value gender   
                 1 = "Male"
                 2 = "Female"
                 3 = "Ambiguous" ;
  value race   
                 1 = "Black"
                 2 = "American Indian or Alaskan Native"
                 3 = "White"
                 4 = "Native Hawaiian or Other Pacific Islander"
                 5 = "Asian"
                 6 = "More than one race"
                 7 = "Other" ;

	value bloodgastype
							1 = "Venous"
							2 = "Arterial"
							99 = "(missing)"
	;

	value bw_cat
							1 = "Extremely Low (<1000g)"
							2 = "Very Low (1000-1500g)"
							3 = "Greater than 1500g"
	;

 * RBC ;
  value abo_group   
                 1 = "A"
                 2 = "AB"
                 3 = "B"
                 4 = "O" ;

  value rh_group   
                 1 = "Positive"
                 2 = "Negative" ;

  value unit_cmv  
                 1 = "Negative"
                 2 = "Unknown" ;

  value stor_sol   
                 1 = "AS-1"
                 2 = "AS-3"
                 3 = "AS-5"
                 4 = "CPDA-1" ;

 * platelets;
 value platelet_type
                 1 = "Concentrate"
                 2 = "Apheresis" ;

 * BLOOD UNIT DATABASE;
  value unit_type
                 1 = "RBC"
                 2 = "FFP"
                 3 = "Cryo"
                 4 = "Platelet"
                 5 = "Granulocytes" 
							99 = "(missing)" ;

  value unit_CMV_NAT   
                 1 = "Not detected"
                 2 = "Low positive ( < 300 copies/ml)"
                 3 = "Positive ( > 300 copies/ml)"
                 4 = "Indeterminate" ;


 value center
	0 ="OVERALL"
	1 = "Midtown"
	2 = "Grady"
	3 = "Northside"
	4 = "Egleston"
	5 = "Scottish Rite"	
	8 = "OVERALL"
	9='Test'
   100='Total'
	99=" "
	999 = "TOTAL:"; 

* MOC demo format;


value MOC_race  99 = "Blank"
                 1 = "Black"
                 2 = "American Indian"
                 3 = "White"
                 4 = "Native Hawain or Other pacific islander"
                 5 = "Asian"
                 6 = "More than one race"
                 7 = "Other" ;


  value MaritalStatus   99 = "Blank"
                 1 = "Married"
                 2 = "Un-married" ;


  value Education   99 = "Blank"
                 1 = "No high school degree"
                 2 = "High school degree or equivalent"
                 3 = "Some college"
                 4 = "College degree"
                 5 = "Some graduate degree or higher" ;

  value Insurance   99 = "Blank"
                 1 = "Medicaid"
                 2 = "Private"
                 3 = "Self-pay/uninsured" ;


  value UseCigarettes   99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "Don't Know"
                 3 = "Refused to answer" ;


  value  UseAlcohol  99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "Don't know"
                 3 = "Refused to answer" ;


  value UseDrugs  99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "Don't know"
                 3 = "Refused to answer" ;


  value DiaperCare    99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "Don't know"
                 3 = "Refused to answer" ;


value  DeliveryMode   99 = "Blank"
                 1 = "Vaginal vertex"
                 2 = "Ceasarean section"
                 3 = "Vaginal breech"
                 4 = "Vaginal NOS" ;


* transfusion formats;

value ABOGroup   99 = "Blank"
                 1 = "A"
                 2 = "AB"
                 3 = "B"
                 4 = "O" ;
  value RHGroup   99 = "Blank"
                 1 = "Positive"
                 2 = "Negative" ;
  
  value UnitSerostatus  99 = "Blank"
                 1 = "Negative"
                 2 = "Unknown" ;

  value UnitStorageSolution   99 = "Blank"
                 1 = "AS-1"
                 2 = "AS-3"
                 3 = "AS-5"
                 4 = "CPDA-1" ;


* NEC ;

value portionresected		1 = "Small intestine"
										2 = "Large intestine"
										3 = "Both";


value imagetype  
                 1 = "MRI"
                 2 = "CT Scan"
                 3 = "Ultrasound"
                 4 = "X-ray" ;


* PDA format;

value PDAEcho   99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "No Echo Taken" ;


value PDAXray   99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "No x-ray Taken" ;


* CMV NAT Result format ;

value CMVNATResult   99 = "Blank"
                 1 = "Not detected"
                 2 = "Low positive (<300 copies/ml)"
                 3 = "Positive"
                 4 = "Indeterminate" ;


* MOC Sero Result format ;

value MOCSeroResult   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inconclusive" ;



* Blood Unit WBC Results;

value leuko_failure
							0 = "< 5x10`6/unit"
							1 = "Leukoreduction Failure"
;

* endofstudy;
value eosreason   99 = "Blank"
                 1 = "Day 90 on study"
                 2 = "Discharged home"
                 3 = "Transferred to non-study hospital"
                 4 = "Family withdrawl of consent"
                 5 = "Physician's decision" ;

    	
* mech vent log;
 value vent   99 = "--Any Vent Type--"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;


  value bmfreshfrozen   	99 = "Blank"
                 				1 = "Fresh"
                 				2 = "Frozen"
                 				3 = "Both" ;

  value MedCode  1 = "Aminoglycoside"
                 2 = "Ampicilline/Penicillin"
                 3 = "Analgesics/Anesthetic/Anamnestic"
                 4 = "Bicarbonate"
                 5 = "Caffeine/Theophylline"
                 6 = "Electrolyte"
                 7 = "Cephalosporin"
                 8 = "Cardiac"
                 9 = "Anti-convulsant"
                 10 = "Diuretic"
                 11 = "Flagyl(Metronidazole)"
                 12 = "Ganciclovir"
                 13 = "Ibuprofin"
                 14 = "Indomethicin/Indocin"
                 15 = "Insulin"
                 16 = "Immunoglobin"
                 17 = "Steroid"
                 18 = "Surfactant"
                 19 = "Vancomycin"
                 20 = "Valganciclovir" 
						 21 = "Other"
						 22 = "Other antibotic";

  value indication 1 = "CMV"
                 2 = "NEC"
                 3 = "IVH"
                 4 = "BPD"
                 5 = "PDA(for prophylaxis)"
                 6 = "PDA(for treatment)"
                 7 = "ROP" 
						 8 = "Other"						
						 9 = "Sepsis(Suspected)"
						 10= "Sepsis(Confirmed)"
;

  value unit     1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq"
 						99 = "Unknown"
						;

	value InfecConfirm 
			0="No"
			1="Yes"
			99=" "
			;

	value CultureYes 
			0="No"
			1="Yes"
			99=" "
			;

	value CulturePositive 
			0="No"
			1="Yes"
			99=" "
			;

	value CultureSite 
			1="Blood"
			2="Urine"
			3="Wound"
			4="Sputum/Tracheal Aspirate"
			5="BAL"
			6="CSF"
			7="Stool"
			8="Catheter Tip"
			9="Other"
			99="-- Any Culture Site --"
			100="== Any Culture Site =="
			;

	value CultureOrg 
			1="Staphylococcus epidermidis"
			2="Methicillin-susceptible Staphylococcus aureus (MSSA)"
			3="Methicillin-resistant Staphylococcus aureus (MRSA)"
			4="Vancomycin-susceptible Enterococcus faecalis"
			5="Vancomycin-resistant Enterococcus faecalis"
			6="Vancomycin-susceptible Enterococcus faecium"
			7="Vancomycin-resistant Enterococcus faecium"
			8="Klebsiella pneumoniae"
			9="Pseudomonas aeruginosa"
			10="Streptococcus pneumoniae"
			11="Streptococcus viridans"
			12="Streptococcus agalactiae"
			13="Escherichia coli"
			14="Acinetobacter baumannii"
			15="Enterobacter cloace"
			16="Enterobacter aerogenes"			
			17="Clostridium difficila"
			18="Candida albicans"
			19="Candida glabrata"
			20="Candida tropicalis"
			21="Influenza"
			22="Henoch-Schonlein Purpura"
			23="Respiratory Syncytial Virus"
			24="Epstain_barr Virus"
			25="Enterovirus"
			26="Adenovirus"
			27="Other Culture"
			99="-- Any Culture Organism --"
			100="== Any Culture Organism =="
			;
	value CulturePos
			1="Positive Culture 1"
			2="Positive Culture 2"
			3="Positive Culture 3"
			4="Positive Culture 4"
			5="Positive Culture 5"
			6="Positive Culture 6"
			;

	value site
			1="Bloodstream"
			2="Central Nervous System"
			3="Cardiovascular System"
			4="Lower respiratory tract"
			5="Gastrointestinal System"
			6="Surgical site"
			7="Urinary tract"
			8="Other"
			9=" "
			99=" "
		;

	value but
			1="RBC"
			2="Fresh frozen plasma"
			3="Cryoprecipitate"
			4="Platelet"
			5="Granulocytes"
			99="N/A"
		;

	value abo
			1="A"
			2="B"
			3="AB"
			4="O"
			99="N/A"
		;

	value rh
			1="Negative"
			2="Positive"
			99="No Answer"
		;

	value sero
			1="Negative"
			2="Unknown"
			99="N/A"
		;

	value storage
			1="AS-1"
			2="AS-3"
			3="AS-5"
			4="CPDA-1"
			99="N/A"
		;

	value plt
			1="Concentrate"
			2="Apheresis"
			99="N/A"
		;

	value fresh 
			0=" " 
			1="Fresh"
	;

	value frozen 
			0=" " 
			1="Frozen"
	;

	value moc 
			0=" " 
			1="MOC"
	;

	value donor 
			0=" " 
			1="Donor"
	;
	value wk
			1="Week 1"			
			2="Week 2"
			3="Week 3"			
			4="Week 4"
			5="Week 5"			
			6="Week 6"
			7="Week 7"			
			8="Week 8"
			9="Week 9"			
			10="Week 10"
			11="Week 11"			
			12="Week 12"
			13="Week 13"
			100="-- Any Week --"
		;

 run;
