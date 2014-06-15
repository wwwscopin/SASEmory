PROC IMPORT OUT= WORK.arti0 
            DATAFILE= "H:\SAS_Emory\Consulting\George\Bone Loss\articulating_group_gg.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:AJ36"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data arti0;
	set arti0(rename=(replant_probs=replant_probs0));
	replant_probs=replant_probs0+0;
	drop replant_probs0;
run;

PROC IMPORT OUT= WORK.static0 
            DATAFILE= "H:\SAS_Emory\Consulting\George\Bone Loss\static_group_gg.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:AH23"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


proc format;
	value evidence 1="I" 2="II" 3="III" 4="IV";
	value mobile   0="Static" 1="Mobile" 2="Mobile + Static";
	value trt 0="Static" 1="Articulate";
	value gender 1="Male" 0="Female";
	value YN 0="No" 1="Yes";
run;
data arti;
	set arti0(rename=(__knees=knee time_of_spacer__weeks_=week _articulating_spacers=spacer
		complex_non_complex=complex _complications=complication	Compl__Comp=comp_comp compl__Type=comp_type mean_f_u=fu 
		reinfection__=reinfect developed_bone_loss_during_space=bone_loss_spacer Prexisting_bone_loss=pre_bone_loss) 
		drop=reimplant_probs type reimplant_probs1 type1 replant_probs type2
			Outcome_measure  clinic_out__Pre clin_out_post_ outcome_measure_2 clinc_out_pre clin_out_post);

	if level_of_evidence="II" then evidence=2;
		else if level_of_evidence="III" then evidence=3;
		else if level_of_evidence="IV" then evidence=4;
	if static_mobile_comp="mobile" then mobile=1; else mobile=2;

	complication_rate=complication/(male+female)*100;


	keep study study1 evidence age BMI knee male female week mobile spacer complex pre_ROM interim_ROM ROM_post complication 
	complication_rate comp_comp comp_type	fu reinfect comp_reinfect bone_loss_spacer pre_bone_loss;
	format evidence evidence. mobile mobile.;
run;

data arti_score;
	set arti0(keep=study1 Outcome_measure  clinic_out__Pre clin_out_post_ rename=(Outcome_measure=outcome clinic_out__Pre=pre_clinic clin_out_post_=post_clinic))
		arti0(keep=study1 outcome_measure_2 clinc_out_pre clin_out_post rename=(outcome_measure_2=outcome clinc_out_pre=pre_clinic clin_out_post=post_clinic))
		; by study1;

	keep study1 outcome pre_clinic post_clinic;
run;
proc sort nodupkey; by study1 outcome; run;

data arti_replant;
	set arti0(keep=study1 reimplant_probs  type rename=(reimplant_probs=reimplant))
		arti0(keep=study1 reimplant_probs1 type1 rename=(reimplant_probs1=reimplant type1=type))
		arti0(keep=study1 replant_probs type2 rename=(replant_probs=reimplant type2=type)); by study1;

	keep study1 reimplant type;
	if reimplant=0 then reimplant=.;
run;
proc sort nodupkey; by study1 type; run;


data static;
	set static0(rename=(_knees=knee time_of_spacer=week _static_spacers=spacer
		complex_non_complex=complex  _complications=complication	Compl__Comp=comp_comp compl__Type=comp_type mean_f_u=fu 
		reinfect__=reinfect compl_reinfect=comp_reinfect developed_bone_loss_during_space=bone_loss_spacer)
		drop=reimplant_probs type replant_probs type1 Outcome_measure clinic_out__Pre clin_out_post_ outcome_measure_2 clin_out_pre clin_out_post);
	if level_of_evidence="II" then evidence=2;
		else if level_of_evidence="III" then evidence=3;
		else if level_of_evidence="IV" then evidence=4;
	if static_mobile_comp="mobile" then mobile=1; else mobile=2;

	pre_bone_loss=pre_existing_bone_loss+0;
	complication_rate=complication/(male+female)*100;

	keep study study1 evidence age BMI knee male female week mobile spacer complex pre_ROM interim_ROM ROM_post complication 
	complication_rate comp_comp comp_type	fu reinfect comp_reinfect bone_loss_spacer pre_bone_loss;
	format evidence evidence. mobile mobile.;
run;
data static_score;
	length type $20;
	set static0(keep=study1 Outcome_measure clinic_out__Pre clin_out_post_ rename=(Outcome_measure=outcome clinic_out__Pre=pre_clinic clin_out_post_=post_clinic))
		static0(keep=study1 outcome_measure_2 clin_out_pre clin_out_post   rename=(outcome_measure_2=outcome clin_out_pre=pre_clinic clin_out_post=post_clinic2)); 
	by study1;

	keep study1 outcome pre_clinic post_clinic;
run;
proc sort nodupkey; by study1 outcome; run;

data static_replant;
	length type $20;
	set static0(keep=study1 reimplant_probs  type rename=(reimplant_probs=reimplant))
		static0(keep=study1 replant_probs type1 rename=(replant_probs=reimplant type1=type)); by study1;

	keep study1 reimplant type;
	if reimplant=0 then reimplant=.;
run;
proc sort nodupkey; by study1 type; run;


data bone_loss;
	length comp_type $70 type $12;
	set arti(in=A) static;
	if A then trt=1; else trt=0;
	num=male+female;
	comp_reinfect_rate=comp_reinfect/complex*100;
	bone_loss_spacer_rate=bone_loss_spacer/(male+female)*100;
	pre_bone_loss_rate=pre_bone_loss/(male+female)*100;
	format trt trt.;
run;

ods rtf file="demo.rtf" style=journal bodytitle ;
proc print noobs label;
var study trt num male female;
where num^=.;
label study="Study"
	trt="Treatment"
	num="Patient Num"
	male="Male"
	female="Female";
run;
ods rtf close;

proc print data=bone_loss;
	where comp_reinfect^=. or complex^=.;
	var study1 trt comp_reinfect complex comp_reinfect_rate;
run;

data score;
	length outcome $20;
	set arti_score(in=A) static_score;
	if A then trt=1; else trt=0;
	format trt trt.;
	if outcome="KSS (func)" then outcome="KSS";
run;

proc freq data=score;
	tables outcome;
run;
proc means data=score(where=(outcome="HSS")) n mean stderr median clm;
	class trt;
	var pre_clinic post_clinic;
run;

proc npar1way data=score(where=(outcome="HSS"));
	class trt;
	var pre_clinic post_clinic;
run;
	

Proc mixed data=score(where=(outcome="KSS"));
Class trt study1;
Model pre_clinic=trt;
Random study1;
Lsmeans trt/cl;
Run;


data replant;
	length type $20;
	set arti_replant(in=A) static_replant;
	if A then trt=1; else trt=0;
	format trt trt.;
	if type="constrained pros." or type="quad snip" or type="snip" then reimplant=.;
run;

proc freq data=replant;
	tables type;
run;

/*
knee male female complex spacer complication comp_comp reimplant comp_reinfect bone_loss_spacer pre_bone_loss
*/
proc means data=bone_loss sum maxdec=0;
	class trt;
	var male female knee complex spacer complication comp_comp comp_reinfect bone_loss_spacer pre_bone_loss;
run;
proc means data=replant sum maxdec=0;
	class trt type;
	var reimplant;
run;

proc means data=replant sum maxdec=0;
	class trt ;
	var reimplant;
run;


Proc mixed data=replant ;
Class trt study1;
Model reimplant=trt;
Random study1;
Lsmeans trt/cl;
Run;

data fake;
	input gender trt m;
	cards;
	0 1 468
	1 1 388
	0 0 333
	1 0 268
	;
run;

proc freq data=fake;
	weight m;
	tables gender*trt/chisq fisher;
	format gender gender. trt trt.;
run;

data bone_loss_spacer;
	input loss trt m;
	cards;
	0 1 100
	1 1 73
	0 0 69
	1 0 111
	;
run;

proc freq data=bone_loss_spacer;
	weight m;
	tables loss*trt/chisq fisher;
	format trt trt.;
run;

data pre_bone_loss;
	input loss trt m;
	cards;
	0 1 683
	1 1 173
	0 0 421
	1 0 180
	;
run;

proc freq data=pre_bone_loss;
	weight m;
	tables loss*trt/chisq fisher;
	format trt trt.;
run;

data complex;
	input Pre_Bone_loss trt m;
	cards;
	0 1 27
	1 1 99
	0 0 16
	1 0 65
	;
	*label reimplan="developed bone loss";
	*label reimplan="pre-existing bone loss";
run;

proc freq data=complex;
	weight m;
	tables Pre_Bone_loss*trt/chisq fisher;
	format trt trt. Pre_Bone_loss yn.;
run;

Proc mixed data=bone_loss;
Class trt study1;
Model comp_reinfect_rate=trt;
Random study1;
Lsmeans trt/cl;
Run;

/*
age bmi week pre_clinic1 post_clinic1 pre_clinic2 post_clinic2 pre_ROM interim_ROM ROM_post
complication_rate fu reinfect comp_reinfect bone_loss_spacer pre_bone_loss
*/

Proc mixed data=bone_loss;
Class trt study1;
Model comp_reinfect=trt;
Random study1;
Lsmeans trt/cl;
Run;

proc freq data=bone_loss;
	tables trt*(evidence mobile)/chisq fisher;
run;
