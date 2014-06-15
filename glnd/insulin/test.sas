proc format;

value group 0='A'
				 1='B'	
				 2='C'	
				 3='D'
				 4='E'
				;
run;


data insulin;
	set glnd.followup_all_long(keep=id day gluc_mrn gluc_aft gluc_eve tot_insulin);
	center=floor(id/10000);
	format center center.;
	gluc_mean=mean(gluc_mrn,gluc_aft,gluc_eve);
	where gluc_mrn^=. or gluc_aft^=. or gluc_eve^=. or tot_insulin^=.;
run;

proc sort data=insulin;by id;run;

data insulin_group;
	set insulin(keep=id);
run;

proc sort data=insulin_group nodup;by id;run;

data insulin_group;
	set insulin_group;
   group=floor(ranuni(2000)*5);
   format group group.;
run;

data insulin;
	merge insulin insulin_group; 
	by id;
run;
