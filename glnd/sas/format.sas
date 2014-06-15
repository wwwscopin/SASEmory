proc format library=library ; *noreplace <- removed by Eli;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;

  value yn   	   
                 0 = "No"
                 1 = "Yes" ;
  value na   	   
                 0 = "No"
                 1 = "Yes"
					2 = "N/A"
			 ;

  value op   99 = "Blank"
                 1 = "CABG"
                 2 = "Cardiac valve"
                 3 = "Vascular"
                 4 = "Intestinal resection" 
                 5='Peritonitis'
                 6='Upper GI resection'
;
value opc  99 = "Blank"
                 1 = "CABG"
                 2 = "Cardiac valve"
                 3 = "Vascular"
                 4 = "Intestinal resection"
                5='Peritonitis'
                 6='Upper GI resection'
;
  value nonic   99 = "Blank"
                 1 = "Patient death"
                 2 = "Patient did not wish"
                 3 = "Other" ;
  value apache   99 = "Blank"
                 1 = "APACHE <=15"
                 2 = "APACHE >15" ;
  value apache_other   99 = "Blank"
                 1 = "<=15"
                 2 = ">15" ;


  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;
value apa1v   99 = "Blank"
                 1 = ">=41"
                 2 = "39.0-40.9"
                 3 = "38.5-38.9"
                 4 = "36.0-38.4"
                 5 = "34.0-35.9"
                 6 = "32.0-33.9"
                 7 = "30.0-31.9"
                 8 = "<=29.9" ;
  value apa2v   99 = "Blank"
                 1 = ">=160"
                 2 = "130-159"
                 3 = "110-129"
                 4 = "70-109"
                 5 = "50-69"
                 6 = "<=49" ;
  value apa3v   99 = "Blank"
                 1 = ">=180"
                 2 = "140-179"
                 3 = "110-139"
                 4 = "70-109"
                 5 = "55-69"
                 6 = "<=39"
                 7 = "7" ;
  value apa4v   99 = "Blank"
                 1 = ">=50"
                 2 = "35-49"
                 3 = "25-34"
                 4 = "12-24"
                 5 = "10-11"
                 6 = "6-9"
                 7 = "<=5" ;
  value apa5a   99 = "Blank"
                 1 = ">=500"
                 2 = "350-499"
                 3 = "200-349"
                 4 = "<200" ;
  value apa5b   99 = "Blank"
                 1 = "PO2>70"
                 2 = "PO2 61-70"
                 3 = "PO2 55-60"
                 4 = "PO2<55" ;
  value apa5c   99 = "Blank"
                 1 = ">=52"
                 2 = "41.0-51.9"
                 3 = "32.0-40.9"
                 4 = "22.0-31.9"
                 5 = "18.0-21.9"
                 6 = "15.0-17.9"
                 7 = "<15" ;
  value apa6v   99 = "Blank"
                 1 = ">=7.7"
                 2 = "7.60-7.69"
                 3 = "7.50-7.59"
                 4 = "7.33-7.49"
                 5 = "7.25-7.32"
                 6 = "7.15-7.24"
                 7 = "<7.15" ;
  value apa7v   99 = "Blank"
                 1 = ">=180"
                 2 = "160-179"
                 3 = "155-159"
                 4 = "150-154"
                 5 = "130-149"
                 6 = "120-129"
                 7 = "111-119"
                 8 = "<=110" ;
  value apa8v   99 = "Blank"
                 1 = ">=7"
                 2 = "6.0-6.9"
                 3 = "5.5-5.9"
                 4 = "3.5-5.4"
                 5 = "3.0-3.4"
                 6 = "2.5-2.9"
                 7 = "<=2.5" ;
  value apa9v   99 = "Blank"
                 1 = ">=3.5"
                 2 = "2.0-3.4"
                 3 = "1.5-1.9"
                 4 = "0.6-1.4"
                 5 = "<0.6" ;
  value apa10v   99 = "Blank"
                 1 = ">=60"
                 2 = "50.0-59.9"
                 3 = "46.0-46.9"
                 4 = "30.0-45.9"
                 5 = "20.0-29.9"
                 6 = "<20" ;
  value apa11v   99 = "Blank"
                 1 = ">=40"
                 2 = "20.0-39.9"
                 3 = "15.0-19.9"
                 4 = "3.0-14.9"
                 5 = "1.0-2.9"
                 6 = "<1.0" ;
  value gcs1v   99 = "Blank"
                 1 = "1 Point"
                 2 = "2 Points"
                 3 = "3 Points"
                 4 = "4 Points" ;
  value gcs2v   99 = "Blank"
                 1 = "1 Point"
                 2 = "2 Points"
                 3 = "3 Points"
                 4 = "4 Points"
                 5 = "5 Points" ;
  value gcs3v   99 = "Blank"
                 1 = "1 Point"
                 2 = "2 Points"
                 3 = "3 Points"
                 4 = "4 Points"
                 5 = "5 Points"
                 6 = "6 Points" ;
  value gcs4v   99 = "Blank"
                 1 = "0 Points"
                 2 = "2 Points"
                 3 = "3 Points"
                 4 = "5 Points"
                 5 = "6 Points" ;                
    value gcs38v   99 = "Blank"
                 1 = "5 points"
                 2 = "2 points"
                 3 = "0 points" ;


 value center
	1='Emory'
	2='Miriam'
	3='Vanderbilt'
	4='Colorado'
	5='Wisconsin'
	99='Test'
   100='Total'
	999 = "TOTAL:"; 
	
	* added - plate 9;
value gender   99 = "Blank"
                 1 = "Male"
                 2 = "Female" ;
                 
 
  value race   99 = "Blank"
                 1 = "American Indian / Alaskan Native"
                 2 = "Asian"
                 3 = "Black or African American"
                 4 = "Native Hawaiian or Pacific Islan"
                 5 = "White"
                 6 = "More than one race"
                 7 = "Other" ;

	* added - plate 10;


	/* THIS FORMAT IS OUTDATED. use demo_diag instead
  value diagnosi   99 = "Blank"
                 1 = "CAD"
                 2 = "CHF"
                 3 = "Valve malfunction"
                 4 = "Intestinal trauma"
                 5 = "Intestinal ischemia"
                 6 = "Inflammatory bowel disease"
                 7 = "Benign intestinal tumors"
                 8 = "Intestinal perforation"
                 9 = "Intestinal fistula/stricture/adh"
                 10 = "Diverticulitis"
                 11 = "Vascular stenosis"
                 12 = "Vascular aneurysm"
                 13 = "Other" ;*/
  value nutr_sta   99 = "Blank"
                 1 = "No malnutrition"
                 2 = "Mild to moderate malnutrition"
                 3 = "Severe malnutrition" ;

  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;	
	
	* added - plate 12;
	value pos_neg   99 = "Blank"
                 1 = "+"
                 2 = "-" ;
  	value inf_hrs   99 = "Blank"
                 1 = "10 hours"
                 2 = "12 hours" ;
                 
        * for questions where the field is not required, but it can be marked if some event occurs;
        * perhaps change to better text label?;
        value mark_box 0 = "0"
        	1 = "1" ;
    
        	
   * added - plate 203 - SAE form, page 1/2;  	
   value sae_type   99 = "Blank"
                 1 = "Death"
                 2 = "Anaphylactic reaction"
                 3 = "Seizure"
                 4 = "Cardiopulmonary arrest"
                 5 = "Re-hospitalization w/in 30 days"
                 6 = "Re-operation w/in 30 days"
                 7 = "New cancer diagnosis"
                 8 = "Congenital anomaly/disorder" 
                 9='Any SAE'
;
  
  * perhaps make 0/1 variables' labels more descriptive;
  value related_treat   99 = "Blank"
                 1 = "Definitely related"
                 2 = "Possibly related"
                 3 = "Unsure"
                 4 = "Probably not related"
                 5 = "Definitely not related" ;

  value treatment   99 = "Blank"
                 1 = "AG-PN"
                 2 = "STD-PN" ;
 value trt
 1='A'
2='B';                 
   value ae   99 = "Blank"
                 1 = "Respiratory distress"
                 2 = "Tracheostomy"
                 3 = "Significant pulmunary aspiration"
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
                 15 = "Hyperglycemia or Hypoglycemia"
                 16 = "Non-infectious pancreatitis"
                 17 = "Encephalopathy"
                 18 = "Hyperglycemia >250(mg/dL)"
                 19 = "Hypoglycemia <50(mg/dL)"
                 20 = "Hypoglycemia <40(mg/dL)";
                  ;
	* yes/no/missing recoded ;
  value ynm      . = "Blank"
                 0 = "No"
                 1 = "Yes" ;

	* plate 103;
  value infect_confirm   99 = "Blank"
                 1 = "Yes, both site & type"
                 2 = "Yes site but not type"
                 3 = "No"
                 4 = "Undetermined" ;
	
  value bsi_bld_cult   99 = "Blank"
                 2 = "N/A"
                 0 = "No"
                 1 = "Yes" ;

	* Death form;
  value autop_performed  . = "Blank"
                 1 = "No"
                 2 = "Yes"
                 3 = "Unknown" ;

	* endpoint.sas ;
	value infect_onset 0 = "Prevalent"	
					 1= "Incident";


	value nosocomial 	0 = "Not nosocomial"	
					 1= "Nosocomial - Pneumonia"
					2= "Nosocomial - Other"
					3 = "Undetermined whether nosocomial";
					
	* source of glucose measurements - follow-up forms;
	value gluc_src   99 = "Blank"
                	1 = "lab"
               		2 = "accucheck" ;
	/* demo form - new version (as of 6/13/07) */
  value demo_diag   99 = "Blank"
                 1 = "CAD"
                 2 = "Intestinal perforation"
                 3 = "CHF"
                 4 = "Intestinal fistula/stricture/adh"
                 5 = "Valve malfunction"
                 6 = "Intestinal obstruction"
                 7 = "Intestinal ischemia"
                 8 = "Diverticulitis"
                 9 = "Inflammatory bowel disease"
                 10 = "Vascular stenosis"
                 11 = "Benign intestinal tumors"
                 12 = "Vascular aneurysm"
                 13 = "Other" ;

	
	 value op_a  99 = "Blank"
                 1 = "CABG"
                 2 = "Cardiac valve"
                 3 = "Vascular"
                 4 = "Intestinal resection"
                5='Peritonitis'
                 6='Upper GI resection'
;

   value concom_subseq   99 = "Blank"
                 1 = "Concomitant"
                 2 = "Susequent" ;

  value ileus   99 = "Blank"
                 1 = "Illeus" ;
  value ischemic_b   99 = "Blank"
                 1 = "Ischemic bowel" ;
  value hemo_inst   99 = "Blank"
                 1 = "Hemodynamic instability" ;
  value intol_ent   99 = "Blank"
                 1 = "Intolerence to enteral feeding" ;
  value bowel_obst   99 = "Blank"
                 1 = "Bowel obstruction" ;
  value other_indic   99 = "Blank"
                 1 = "Other" ;

* blood collection forms;
  value typ_bld_draw   99 = "Blank"
                 1 = "Arterial"
                 2 = "Venous" ;

* follow-up phone call form;
  value info_src   99 = "Blank"
                 1 = "Patient and/or family"
                 2 = "Primary care physician's office"
                 3 = "Other" ;

 * Nosocomial infection form; 
	* plates 101 and 102;
	value cult_org_code
				1 = "Methicillin-susceptible Staphylococcus aureus (MSSA)"
				2 = "Methicillin-resistant Staphylococcus aureus (MRSA)"
				3 = "Coagulase-negative Staphylococcus species" 
				4 = "Vancomycin-susceptible Enterococcus faecalis" 
				5 = "Vancomycin-resistant Enterococcus faecalis" 
				6 = "Vancomycin-susceptible Enterococcus faecium" 
				7 = "Vancomycin-resistant Enterococcus faecium" 
				8 = "Klebsiella pneumoniae" 
				9 = "Other Klebsiella species" 
				10 = "Pseudomonas aeruginosa" 
				11 = "Streptococcus pneumoniae" 
				12 = "Escherichia coli" 
				13 = "Acinetobacter baumannii" 
				14 = "Enterobacter cloace" 
				15 = "Enterobacter aerogenes" 
				16 = "Clostridium difficile" 
				17 = "Candida albicans" 
				18 = "Candida glabrata" 
				19 = "Candida tropicalis" 
				20 = "Other fungal species" 
				21 = "Other gram + species"
           22 = "Other gram - species"
           23 = "Other"
				;
	
	value cult_site_code
				1 = "Blood" 
				2 = "Urine"
				3 = "Wound" 
				4 = "Sputum / Tracheal Aspirate" 
				5 = "BAL" 
				6 = "CSF"
				7 = "Stool" 
				8 = "Catheter Tip" po
				9 = "Other" 
			;
	
	* plate 103;
	value $site_code	
				"UTI"=	"Urinary Tract Infection"
				"SSI"=	"Surgical Site Infection"
				"PNEU"= "Pneumonia "
				"BSI" =	"Bloodstream Infection"
				"BJ"	=	"Bone and Joint Infection"
				"CNS" =	"Central Nervous System Infection"
				"CVS" =	"Cardiovascular System Infection"
				"EENT"=	"Eye, Ear, Nose, Throat, or Mouth Infection"
				"GI"	=	"Gastrointestinal System Infection"
				"LRI"=	"Lower Respiratory Tract Infection, Other Than Pneumonia"
				"REPR" = "Reproductive Tract Infection"
				"SST"=	"Skin and Soft Tissue Infection"
				"SYS" = "Systemic Infection"
				
					"Over" = "Overall total:"
					"Site" = "Totals by site:"
					"Emor" = "Emory"
					"Miri" = "Miriam"
					"Vand" = "Vanderbilt"
					"Colo" = "Colorado"
					"Wisc" = "Wisconsin"	;
				;
				
;
	value $type_code
				"SUTI"= "Symptomatic urinary tract infection"
				"ASB"=	"Asymptomatic bacteriuria" 
				"OUTI"=	"Other infections of the urinary tract"
                                "SIP" = "Superficial incisional primary SSI"
                                "SIS" = "Superficial incisional secondary SSI"
                                "DIP" = "Deep incisional primary SSI"
                                "DIS" = "Deep incisional secondary SSI"
                             	"SKNC"= "Superficial incisional infection at chest incision site, after CBGB"
				"SKNL"= "Superficial incisional infection at vein donor site, after CBGB."
				"STC"=   "After CBGB, report STC for deep incisional surgical site infection at chest incision site."
				"STL"= 	 "After CBGB, report STL for deep incisional surgical site infection at vein donor site."
				"PNU1"= "PNU1 - Clinically defined pneumonia"
				"PNU2"= "PNU2 - Pneumonia with specific lab findings"
				"PNU3"= "PNU3 - Pneumonia in immunocompromised patient"	
				"LCBI"=  "Laboratory-confirmed bloodstream infection"
				"CSEP"=	"Clinical sepsis"
				"BONE"=	"Osteomyelitis"
				"JNT"=	"Joint or bursa"
				"DSC" = "Disc space"
				"IC"=	"Intracranial infection"
				"MEN"=	"Menitigitis or ventriculitis"
				"SA"=	"Spinal abscess without meningitis"
				"VASC"=	"Arterial or venous infection"
				"ENDO"=	"Endocarditis"
				"CARD"=	"Myocarditis or pericarditis"
				"MED"=	"Mediastinitis"
				"CONJ"= "Conjuctivitis"
				"EYE"=	"Eye other than conjunctivitis"
				"EAR"= "Ear, mastoid"
				"ORAL"=	"Oral Cavity (mouth, tongue, or gums)"
				"SINU"=	"Sinusitis"
				"UR"=	"Upper respiratory tract, pharyngitis, laryngitis, epiglottitis"
				"GE"=	"Gastroenteritis"
				"GIT"=	"Gastrointestinal (GI) tract"
				"HEP"=	"Hepatitis"
				"IAB"= 	"Intra-abdominal, not specified elsewhere"
				"NEC" = "Necrotizing enterocolitis"
				"BRON"=	"Bronchitis, tracheobronchitis, tracheitis, without evidence of pneumonia"
				"LUNG"=	"Other infections of the lower respiratory tract"
				"EMET"= "Endometritis"
				"EPIS"= "Episiotomy"
				"VCUF"= "Vaginal cuff"
				"OREP"= "Other infections of the male or female reproductive tract"
				"SKIN"= "Skin"
				"ST"=   "Soft tissue"
				"DECU"=	"Decubitus ulcer"
				"BURN"= "Burn"
                                "BRST"= "Breast abscess or mastitis"
                                "UMB" = "Omphalitis"
                                "PUST"= "Pustulosis"
                                "CIRC"= "Newborn circumcision"
                                "DI"  = "Disseminated infection"
                                "NA" = " . "
												"UNK"="Unknown"
                                ;
                                

                                
	;

	
	**** added form for on patient_status printout;
	value form
	1='Pharmacy Conf'
	2='PN Calc'
	3='Demo.'
	4='Day 3 F/U'
	5='Day 7 F/U'
	6='Day 14 F/U'
	7='Day 21 F/U'
	8='Day 28 F/U'
	9='Baseline Blood Coll.'
	10='Day 3 Blood Coll.'
	11='Day 7 Blood Coll.'
        12='Day 14 Blood Coll.'
        13='Day 21 Blood Coll.'
        14='Day 28 Blood Coll.'
        15='Day 28 Vital Assess.'
        16='2-Month F/U Call'
        17='4-Month F/U Call'
        18='6-Month F/U Call'
        19='30-Day Post-Drug F/U';

	* concomitant meds codes ;
	value med_code
		1= "Activated Protein C (Xygris)"
		2= "Antibiotics - Antibacterial agents"
         3= "Antibiotics - Antifungal agents"
		4= "Corticosteroids"
		5= "H2 Blockers or Proton Pump Inhibitor"
		6= "Hypoglycemics"
		7= "Paralytics"
		8= "Vasopressors"
		;
value day_nut 
			7 = "through day 7"
			14 = "through day 14"
			21 = "through day 21"
			28 = "through day 28"
			99 = "overall"
		;

* hypo/hyperglycemia changed on AE form;
  value ae_glycemia   99 = "Blank"
                 1 = "Hyperglycemia > 250 mg/dL"
                 2 = "Hypoglycemia < 50 mg/dL"                  
		 3 = "Hypoglycemia < 40 mg/dL" ;

* plate 57 - source of bsi;
  value prim_second  99 = "Blank"
                 1 = "Primary"
                 2 = "Secondary" ;



  value second_source   99 = "Blank"
                 1 = "Lower respiratory tract"
                 2 = "Urinary tract"
                 3 = "GI tract"
                 4 = "Surgical site"
                 5 = "Cardiovascular system"
                 6 = "Other" ;
                 
                 
    * for other_mortality table;
    value age_cat
    	1 = "<= 50 years"
    	2 = "50 - 60 years"
    	3 = "60 - 70 years"
    	4 = "> 70 years"
    	;
    	
 value dayc
 7='By Day 7'
 14='By Day 14'
 21='Through Day 21'
 28='Through Day 28'
 99='Overall';

    	
    	
    	
                 run;
