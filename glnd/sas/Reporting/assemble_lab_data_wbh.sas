/* assemble_lab_data.sas */

* formerly each lab data's analysis file would stack each set of data. now this is done centrally ;

	** Heat-shock proteins **;

data eli_hsp;	
  	       set 
				glnd_ext.hsp_dsmb_2_2008_redone (rename = (hsp70_ng_correct = hsp70_ng))
				glnd_ext.hsp_dsmb_3_2009
				glnd_ext.hsp_dsmb_9_2009
    			;
run;

proc sort data=eli_hsp; by id day;run;

		data hsp;
   	       set eli_hsp(in=eli) glnd_ext.hsp_ex(in=wbh); by id day;
 		      	* hsp27 is in pg while hsp70 is in ng. convert hsp27 as it is effectively ng in terms of magnitude ;
   		      	hsp27_ng = hsp27_pg / 1000;  
					if hsp70_ng=. and hsp27_ng=. then delete;   
   		run;


data hsp27;set hsp;where hsp27_ng^=.;run;
proc sort nodupkey;by id day;run;


data hsp70;set hsp;where hsp70_ng^=.;run;
proc sort nodupkey;by id day;run;


data glnd_ext.hsp;
	merge hsp27(drop=hsp70_ng) hsp70(drop=hsp27_ng); by id day;
run;


	** Flag-LPS **;
		data glnd_ext.flag_lps;
			set 
				glnd_ext.flag_lps_dsmb_2_2008
				glnd_ext.flag_lps_ab_only_dsmb_3_2009 /** just antibodies! excluding flagellin and LPS antigen for now  **/
				glnd_ext.flag_lps_ab_only_dsmb_3_2010 /** just antibodies! excluding flagellin and LPS antigen for now  **/
				glnd_ext.flag_lps_ex
				;  
		run;
	

	** Cytokines **;
		data glnd_ext.cytokines;
			set 
				glnd_ext.cytokines_ex
			;
			
		run;
	

	** Redox **;
		data glnd_ext.redox;
			set

			 	glnd_ext.redox_dsmb_10_2007
				glnd_ext.redox_dsmb_7_2008 (rename = (cyss_concentration = cysss_concentration))
				glnd_ext.redox_dsmb_3_2009 (rename = (cyss_concentration = cysss_concentration))
				glnd_ext.redox_dsmb_3_2010 (rename = (cyss_concentration = cysss_concentration))

				glnd_ext.redox_ex
				;

			* Make corrections and adjustments; 
			if id = 32006 then delete;

			* 12/28/09;
			if id = 10009 then id = 11009;
			if id = 11026 then id = 12026;

			if visit = 27 then visit = 28;
		run;
		
		title "xxx";
		proc print;
		where id= 32064;
		var id visit replicate Cys_concentration dt_run;
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


	** Glutamine;


		data glutamine;
			set 	
				
				glnd_ext.glutamine_dsmb_7_2007
				glnd_ext.glutamine_dsmb_11_2007
				glnd_ext.glutamine_dsmb_7_2008
				glnd_ext.glutamine_batch_4
				glnd_ext.glutamine_batch_5
				
				glnd_ext.glu_ex
				glnd.glu_plate58
				glnd_ext.glut_corrected(in=A rename=(visit=day) keep=id visit GlutamicAcid Glutamine)
				;

				* compute total glutamine;
				total_glutamine = GlutamicAcid + Glutamine;

				* An ID and visit was left out for one person, and I assigned this record to ID = 99999, day = 28,
				  - an email from Tisa on 1/15/2010 clarifies the correct ID ;
				if (id = 99999) & (day = 28) then id = 41090;		
				
				if A then idx=0; else idx=1;
				if A then visit=day;
				keep id day visit glutamine glutamicacid idx;			
		run;

proc sort; by id day idx; run;

data  glnd_ext.glutamine;
    set  glutamine; by id day idx;
    if first.day;
    if glutamine=0 then glutamine=.;
    if glutamicacid=0 then glutamicacid=.;
    /*
    if id=51071 and day=21 then GlutamicAcid=.;
    if id=12244 and day=7 then GlutamicAcid=.;
    if id=11109 and day=28 then GlutamicAcid=.;
    if id=41032 and day=3 then GlutamicAcid=.;
    if id=42026 and day=21 then GlutamicAcid=.;
    if id=51071 and day=21 then GlutamicAcid=.;
    
    if id=52049 and day=14 then glutamine=.;
    if id=12207 and day=0 then glutamine=.;
    if id=12115 and day=7 then glutamine=.;
    if id=42026 and day=21 then glutamine=.;
    if id=22042 and day=21 then glutamine=.;
    */
    format glutamicacid glutamine 7.1;
run;


*** REPORT 1 (old style) - report on presence of any lab data for each enrolled GLND ID ***;

	* get all study IDs;	
	proc sort data = glnd.status; by id; run;

	data study_id;
		set glnd.status (keep = id dt_random);	
	run;


	proc sort data = glnd_ext.hsp nodupkey; by id day; run;
	proc sort data = glnd_ext.flag_lps nodupkey; by id day; run;
	proc sort data = glnd_ext.cytokines nodupkey; by id day; run;
	proc sort data = glnd_ext.redox nodupkey; by id day; run;
	proc sort data = glnd_ext.chemistries nodupkey; by id day; run;
	proc sort data = glnd_ext.glutamine nodupkey; by id day; run;

data glnd_ext.flag_lps;	merge glnd_ext.flag_lps(in=A) glnd.status(keep=id treatment in=B); by id; if A and B;run;
data glnd_ext.cytokines;	merge glnd_ext.cytokines(in=A) glnd.status(keep=id treatment in=B); by id; if A and B;run;
data glnd_ext.redox;	merge glnd_ext.redox(in=A) glnd.status(keep=id treatment in=B); by id; if A and B;run;
data glnd_ext.chemistries;	merge glnd_ext.chemistries(in=A) glnd.status(keep=id treatment in=B); by id; if A and B;run;
data glnd_ext.glutamine;	merge glnd_ext.glutamine(in=A) glnd.status(keep=id treatment in=B); by id; if A and B;run;

proc export data=glnd_ext.glutamine(keep=id visit glutamicacid glutamine) outfile='glutamine.xls' dbms=xls replace; sheet='glutamine'; run;

proc print;
where glutamicacid>1000 or glutamine>1000;
format glutamicacid glutamine 7.1;
var id treatment day glutamicacid glutamine;
run;
data glnd_ext.hsp;	merge glnd_ext.hsp(in=A) glnd.status(keep=id treatment in=B); by id; if A and B;run;
