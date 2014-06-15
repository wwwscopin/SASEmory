
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait;

%let mu=%sysfunc(byte(181));

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

proc sort data= glnd.george; by id; run;
proc sort data= glnd.followup_all_long; by id; run;


data sofa;
	merge 	glnd.followup_all_long
			glnd.george (keep = id treatment)
			;
	by id;
run;

data hsp;
	merge 	glnd_ext.hsp
			glnd.george (keep = id treatment)
			;
	by id;
run;

data redox;
	merge 	glnd_ext.redox
			glnd.george (keep = id treatment)
			;
	by id;
	where id ~= 32006;
	log_gsh_conc = log(gsh_concentration);
	log_gssg_conc = log(gssg_concentration);

    if Cys_concentration>200 then Cys_concentration=.;
   	rename visit=day;

	keep visit id treatment GSH_GSSG_redox Cys_CySS_redox log_gsh_conc log_gssg_conc Cys_concentration CysSS_concentration;
run;

data cyto;
   	merge glnd_ext.cytokines(drop=day) glnd.george (keep = id treatment); by id;
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 
	rename visit=day;
run;

proc format;
    value src 1="Lab" 2="Accucheck";
run;

data all_glucose;
    set glnd.followup_all_long(keep=id day gluc_eve eve_gluc_src rename=(gluc_eve=gluc_all eve_gluc_src=src))
        glnd.followup_all_long(keep=id day gluc_mrn mrn_gluc_src rename=(gluc_mrn=gluc_all mrn_gluc_src=src))
        glnd.followup_all_long(keep=id day gluc_aft aft_gluc_src rename=(gluc_aft=gluc_all aft_gluc_src=src));
run;

proc sort; by id day; run;

data all_glucose;
    merge all_glucose glnd.george (keep = id treatment); by id;
    label gluc_all="Glucose";
    format src src.;
    if gluc_all=. then delete;
run;

proc sgplot data=all_glucose;
title "Local Data";
where id in(22042,42008,51071);
series x=day y=gluc_all/group=id;
scatter x=day y=gluc_all/group=id;
run;

data center_glucose;
    merge glnd_ext.chemistries glnd.george (keep = id treatment); by id;
run;

proc sgplot data=center_glucose;
title "Centeral Data";
where id in(22042,42008,51071);
series x=day y=glucose/group=id;
scatter x=day y=glucose/group=id;
run;

ods rtf file="glucose_data.rtf" style=journal bodytitle;
proc print data=all_glucose noobs label;
where id in(22042,42008);
var id treatment day gluc_all;
run;

proc print data=center_glucose noobs label;
where id in(22042,42008);
var id treatment day glucose;
run;
ods rtf close;
