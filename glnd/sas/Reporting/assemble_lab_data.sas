/* assemble_lab_data.sas */

* formerly each lab data's analysis file would stack each set of data. now this is done centrally ;

	** Heat-shock proteins **;
		data glnd_ext.hsp;
   	       set 
				glnd_ext.hsp_dsmb_2_2008_redone (rename = (hsp70_ng_correct = hsp70_ng))
				glnd_ext.hsp_dsmb_3_2009
				glnd_ext.hsp_dsmb_9_2009;
   	      
   		      	* hsp27 is in pg while hsp70 is in ng. convert hsp27 as it is effectively ng in terms of magnitude ;
   		      	hsp27_ng = hsp27_pg / 1000;     
   		run;

		
			proc print data = glnd_ext.hsp;
			run;
		

	** Flag-LPS **;
		data glnd_ext.flag_lps;
			set 
				glnd_ext.flag_lps_dsmb_2_2008
				glnd_ext.flag_lps_ab_only_dsmb_3_2009 /** just antibodies! excluding flagellin and LPS antigen for now  **/
				glnd_ext.flag_lps_ab_only_dsmb_3_2010 /** just antibodies! excluding flagellin and LPS antigen for now  **/
				;  
		run;

	** Cytokines **;
		data glnd_ext.cytokines;
			set 
				glnd_ext.cytokines_dsmb_10_2007
				glnd_ext.cytokines_dsmb_7_2008
				glnd_ext.cytokines_dsmb_3_2009
			;
			
		run;

	** Redox **;
		data glnd_ext.redox;
			set
			 	glnd_ext.redox_dsmb_10_2007
				glnd_ext.redox_dsmb_7_2008 (rename = (cyss_concentration = cysss_concentration))
				glnd_ext.redox_dsmb_3_2009 (rename = (cyss_concentration = cysss_concentration))
				glnd_ext.redox_dsmb_3_2010 (rename = (cyss_concentration = cysss_concentration))
				;

			* Make corrections and adjustments; 
			if id = 32006 then delete;

			* 12/28/09;
			if id = 10009 then id = 11009;
			if id = 11026 then id = 12026;

			if visit = 27 then visit = 28;
		run;
proc print data = glnd_ext.redox;
	var id visit  replicate GSH_GSSG_redox Cys_CySS_redox Cys_concentration CysSS_concentration;
run;

	** Organ function chemistries **;
		data glnd_ext.chemistries;
			set glnd.plate46;

			* add day ;
			if dfseq = 1 then day = 0;
			if dfseq = 2 then day = 3;
			if dfseq = 3 then day = 7;
			if dfseq = 4 then day = 14;
			if dfseq = 5 then day = 21;
			if dfseq = 6 then day = 28;
	

			*** THIS PERSON HAS A VALUE OF 476, DETERMINED TO BE ERRONEOUS BY DR. ZIEGLER ON 8/30/2007. REMOVE THIS LATER! ***;
			if (id = 11014) & (dfseq = 5) then glucose = .;

		run;

		* 3/11/09: add in crp values that Gotham sent as a spreadsheet, rather than put on a CRF ;
			proc sort data = glnd_ext.chemistries;	by id day; run;
			proc sort data = glnd_ext.crp_dsmb_3_2009;	by id day; run;

			data glnd_ext.chemistries;
				merge 
					glnd_ext.chemistries (in = from_chem rename = (crp = crp_chem))
					glnd_ext.crp_dsmb_3_2009 (in = from_crp drop = crp_ng rename = (crp = crp_excel))
					;	
				by id day;

				if from_chem & from_crp then duplicate = 1; else duplicate = 0;

				* for now, if there are duplicates, keep the CRF version!;
				if (crp_chem ~= .) then crp = crp_chem; 
				else crp = crp_excel;
				

			run;
			/*proc print data = glnd_ext.chemistries;
				var id dfseq day duplicate crp_chem crp_excel crp;
			run;*/

	** Glutamine;


		data glnd_ext.glutamine;
			set 	glnd_ext.glutamine_dsmb_7_2007
				glnd_ext.glutamine_dsmb_11_2007
				glnd_ext.glutamine_dsmb_7_2008
				glnd_ext.glutamine_batch_4
				glnd_ext.glutamine_batch_5;

				* compute total glutamine;
				total_glutamine = GlutamicAcid + Glutamine;

				* An ID and visit was left out for one person, and I assigned this record to ID = 99999, day = 28,
				  - an email from Tisa on 1/15/2010 clarifies the correct ID ;
				if (id = 99999) & (day = 28) then id = 41090;		run;

		/******
			proc print data = glnd_ext.glutamine;
				var id day visit glutamine glutamicacid total_glutamine;
			run;
		******/

*** REPORT 1 (old style) - report on presence of any lab data for each enrolled GLND ID ***;

	* get all study IDs;	
	proc sort data = glnd.status; by id; run;

	data study_id;
		set glnd.status (keep = id dt_random);	
	run;

	proc sort data = glnd_ext.hsp; by id day; run;
	proc sort data = glnd_ext.flag_lps; by id day; run;
	proc sort data = glnd_ext.cytokines; by id day; run;
	proc sort data = glnd_ext.redox; by id day; run;
	proc sort data = glnd_ext.chemistries; by id day; run;
	proc sort data = glnd_ext.glutamine; by id day; run;

	* Track HSP 70 and 27 separately since we don't necessarily get both values on a person;
	data hsp_70_id;
		set glnd_ext.hsp;
		by id;
		where hsp70_ng ~= .;

		if ~first.id then delete;
	run;

	data hsp_27_id;
		set glnd_ext.hsp;
		by id;
		where hsp27_ng ~= .;

		if ~first.id then delete;
	run;

	data flag_lps_id;
		set glnd_ext.flag_lps;
		by id;

		if ~first.id then delete;
	run;

	data cytokines_id;
		set glnd_ext.cytokines;
		by id;

		if ~first.id then delete;
	run;

	data redox_id;
		set glnd_ext.redox;
		by id;

		if ~first.id then delete;
	run;

	data chemistries_id;
		set glnd_ext.chemistries;
		by id;

		if ~first.id then delete;
	run;

	* also monitor CRP separately;
	data crp_id;
		set glnd_ext.chemistries;
		by id;

		where crp ~= .;

		if ~first.id then delete;
	run;

	data glutamine_id;
		set glnd_ext.glutamine;
		by id;

		if ~first.id then delete;
	run;
	
	** merge all lab data and report! (i am not resolving to the day within person level. we assume that labs for a whole person
		are processed together ;

	proc format library = work;
		value pos_neg_alt
                 1 = "+"
                 0 = "-" ;

		value visit
		        1 = "Baseline"
	                2 = "Day 3"
	                3 = "Day 7"
	                4 = "Day 14"
	                5 = "Day 21"
	                6 = "Day 28"
	                7 = " "
		;

		value got_blood
			1 = "Yes"
			2 = "No"
			3 = "No CRF"
		;
	
	run;

	data lab_table;
		merge
			study_id (in = has_id)
			hsp_70_id	(in = has_hsp_70 keep = id)
			hsp_27_id	(in = has_hsp_27 keep = id)
			flag_lps_id (in = has_flag keep = id)
			cytokines_id	(in = has_cytokines keep = id)
			redox_id	(in = has_redox keep = id)
			chemistries_id	(in = has_chemistries keep = id )
			crp_id	(in = has_crp keep = id)
			glutamine_id	(in = has_glutamine keep = id)
		;
		by id;

		if has_id then correct_study_id = 1; else correct_study_id = 0;
		if has_hsp_70 then hsp_70 = 1; else hsp_70 = 0;
		if has_hsp_27 then hsp_27 = 1; else hsp_27 = 0;
		if has_flag then flag = 1; else flag = 0;
		if has_cytokines then cytokines = 1; else cytokines = 0;
		if has_redox then redox = 1; else redox = 0;
		if has_chemistries then chemistries = 1; else chemistries = 0;
		if has_crp then crp = 1; else crp = 0;
		if has_glutamine then glutamine= 1; else glutamine = 0;	
		
		label
			correct_study_id = "Actual GLND*Study ID?"
			hsp_70 = "HSP-70"
			hsp_27 = "HSP-27"
			flag = "Flag/LPS"
			cytokines = "Cytokines"
			redox = "Redox"
			chemistries = "Chemistries"
			crp = "CRP"
			glutamine = "Glutamine"
		;

		format correct_study_id hsp_70 hsp_27 flag cytokines redox chemistries crp glutamine pos_neg_alt.;
	run;

	data _NULL_;
		call symput("date", put(today(), mmddyy.));
	run;

	options nodate nonumber;
	title "GLND lab data summary as of &date";
	
	ods pdf file = "/glnd/sas/reporting/lab_data_summary.pdf" style = journal ;
		proc print data = lab_table split = "*" width = minimum;	
			var id  ;
			var correct_study_id hsp_70 hsp_27 flag cytokines redox chemistries glutamine crp/ style(data) = [just=center];
		run;

		proc means data = lab_table n sum maxdec=0;
			var hsp_70 hsp_27 flag cytokines redox chemistries glutamine crp;
		run;

	ods pdf close;
			


** Report 2 - Report on completeness of results for each blood draw **;


	* make blank table with each ID and visit;
	data full_lab_table;
		set study_id;

		num = _N_; 	* stamp each person number;

		do visit = 1 to 6; output; end;

		format visit visit.;
	run;

		
	proc sort data = full_lab_table; by id visit;
	proc sort data = glnd.plate15; by id dfseq; run;
	proc sort data = glnd_ext.hsp; by id visit; run;
	proc sort data = glnd_ext.flag_lps; by id visit; run;
	proc sort data = glnd_ext.cytokines; by id visit; run;
	proc sort data = glnd_ext.redox; by id visit; run;
	proc sort data = glnd_ext.chemistries; by id dfseq; run;  *** uses DFEQ since originates from CRFs;
	proc sort data = glnd_ext.glutamine; by id visit; run;

	* split out HSP by 70 and 27;
	data hsp_70;
		set glnd_ext.hsp;
		where hsp70_ng ~= .;
	run;

	data hsp_27;
		set glnd_ext.hsp;
		where hsp27_ng ~= .;
	run; 

	* separate out CRP;
	data crp;
		set glnd_ext.chemistries;
		where crp ~= .;
		rename dfseq = visit;
	run;

	* redox has replicates. keep just first observation ;
	data redox;
		set glnd_ext.redox;
		where replicate = 1;
	run;

	data all_labs;
		merge 
			hsp_70	(in = has_hsp_70 keep = id visit)
			hsp_27	(in = has_hsp_27 keep = id visit)
			glnd_ext.flag_lps (in = has_flag keep = id visit)
			glnd_ext.cytokines	(in = has_cytokines keep = id visit)
			redox	(in = has_redox keep = id visit)
			glnd_ext.glutamine	(in = has_glutamine keep = id visit)
		;
		by id visit;

			if visit = 0 then visit = 1;
			else if visit = 3 then visit = 2;
			else if visit = 7 then visit = 3;
			else if visit = 14 then visit = 4;
			else if visit = 21 then visit = 5;
			else if visit = 28 then visit = 6;

		* check for each lab value;
		if has_hsp_70 then hsp_70 = 1; else hsp_70 = 0;
		if has_hsp_27 then hsp_27 = 1; else hsp_27 = 0;
		if has_flag then flag = 1; else flag = 0;
		if has_cytokines then cytokines = 1; else cytokines = 0;
		if has_redox then redox = 1; else redox = 0;
		if has_glutamine then glutamine= 1; else glutamine = 0;	
	run;

	data all_labs;
		merge 	all_labs
			glnd_ext.chemistries	(in = has_chemistries keep = id dfseq rename = (dfseq = visit) )
			crp	(in = has_crp keep = id visit)
		;
		by id visit;

		* check for each lab value;
		if has_chemistries then chemistries = 1; else chemistries = 0;
		if has_crp then crp = 1; else crp = 0;
	run;
	proc sort data = all_labs; by id visit; run;


	data full_lab_table;
		merge 
			full_lab_table (in = has_id)
			glnd.plate15 (in = has_form keep = id dfseq missed_blood_drw dt_bld_str rename = (dfseq = visit))	
			all_labs
		;
		by id visit;

		* determine in have blood draw and if it was missed;
		if (has_form & ~missed_blood_drw) then got_blood = 1;
		else if (has_form & missed_blood_drw) then got_blood = 2;
		else if ~(has_form) then got_blood = 3;

		if has_id then correct_study_id = 1; else correct_study_id = 0;

		
		label	num = '00'x
			got_blood = "Got blood?"
			correct_study_id = "Actual GLND*Study ID?"
			hsp_70 = "HSP-70"
			hsp_27 = "HSP-27"
			flag = "Flag/LPS"
			cytokines = "Cytokines"
			redox = "Redox"
			chemistries = "Chemistries"
			crp = "CRP"
			glutamine = "Glutamine"
		;

		format  hsp_70 hsp_27 flag cytokines redox chemistries crp glutamine pos_neg_alt.
 			got_blood got_blood. correct_study_id yn.;

	run;

	proc sort data = full_lab_table; by id visit; run;

options orientation = landscape;
ods pdf file = "/glnd/sas/reporting/lab_data_complete_summary.pdf" style = journal ;
	title "GLND: Complete lab data summary as of &date";
	proc print data = full_lab_table noobs label width=minimum split="*";
		by id correct_study_id;
		id id correct_study_id;
		var visit got_blood dt_bld_str;
		var hsp_70 hsp_27 flag cytokines redox chemistries glutamine crp/ style(data) = [just=center];

	run;
ods pdf close;


* Print out all lab data for examination;
ods pdf file = "/glnd/sas/reporting/lab_data_complete_listing.pdf" style = journal;
	title "HSP"; proc print data = glnd_ext.hsp; by id; id id; run;
	title "Flag and LPS"; proc print data = glnd_ext.flag_lps; by id; id id; run;
	title "Cytokines"; proc print data = glnd_ext.cytokines; by id; id id; run;
	title "Redox"; proc print data = glnd_ext.redox; by id; id id; run;
	title "Chemistries"; proc print data = glnd_ext.chemistries; by id; id id; run;  *** uses DFEQ since originates from CRFs;
	title "Glutamine"; proc print data = glnd_ext.glutamine; by id; id id; run;

ods pdf close;
	
