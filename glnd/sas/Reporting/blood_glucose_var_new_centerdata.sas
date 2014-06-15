
 
 * turn macros on;
 proc options option = macro;  run;
 options spool;
 

proc sort data= glnd.followup_all_long; by id day; run;


		
		data glu;
				set glnd.followup_all_long(keep=id day gluc_eve eve_gluc_src rename=(gluc_eve=gluc eve_gluc_src=src) in=C)
				 glnd.followup_all_long(keep=id day gluc_aft aft_gluc_src rename=(gluc_aft=gluc aft_gluc_src=src) in=B)
				 glnd.followup_all_long(keep=id day gluc_mrn mrn_gluc_src rename=(gluc_mrn=gluc mrn_gluc_src=src) in=A);
                
                if A then gt=1; if B then gt=2; if C then gt=3;
                if gluc>600 then glucose=.;
    	run;	

        proc sort; by id day;run;
        
        data glu;
		  merge glu glnd.info(keep=id apache_2 hospital_death)
		  glnd.george (keep = id treatment); by id;
          center = floor(id/10000);
           if gluc=. then delete;
    	run;
    	

proc sort data=glu out=all_glucose_id nodupkey; by id; run;

data center_glucose;
    merge glnd_ext.chemistries glnd.george (keep = id treatment); by id;
    if glucose>600 then delete;
    if glucose=. then delete;  
run;

proc sort data=center_glucose out=center_glucose_id nodupkey; by id; run;

data glu;
    merge glu(in=loc) center_glucose_id(in=cent keep=id); by id;
    if loc and cent;
    rename gluc=glu;
run;

proc means data=glu n mean median min max maxdec=2;
    types () treatment;
    class treatment;
    var glu;
run;

	   proc mixed data=glu empirical covtest;
	       class id;
	       model glu=;
	       repeated / subject = id r;
	       random intercept/subject=id type=un;
	   run;

		proc mixed data = glu empirical covtest;
			class id treatment;
			model glu = treatment day treatment*day; 
			repeated / subject = id group=treatment r;
			random int /type=un subject=id group=treatment g;
		run;
    	

         
data glu;
    merge glnd_ext.chemistries glnd.george (keep = id treatment); by id;
    rename glucose=glu;
    if glucose>360 then glucose=.;
    if glucose=. then delete;
    *glu=log(glucose);
    rename glucose=glu;
run;

proc means data=glu n mean median min max maxdec=2;
    types () treatment;
    class treatment;
    var glu;
run;

	   proc mixed data=glu empirical covtest;
	       class id;
	       model glu=;
	       repeated / subject = id r;
	       random intercept/subject=id type=un;
	   run;

		proc mixed data = glu empirical covtest;
			class id treatment;
			model glu = treatment day treatment*day; 
			repeated / subject = id group=treatment r;
			random int /type=un subject=id group=treatment g;
		run;
