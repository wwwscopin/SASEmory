PROC IMPORT OUT= WORK.temp0 
            DATAFILE= "H:\SAS_Emory\Consulting\Scott Tanaka\Cadaver New.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data temp1;
	set temp0;
	retain specimen_num plane0;
	if cadaver_5667^=" " then	specimen_num=cadaver_5667;
	if F2^=" " then plane0=F2;
	if prefusion=. then delete;
	rename F3=measure;
	keep specimen_num plane0 F3 prefusion post_fusion post_scaphoid_excision;
run;

proc format;
	value plane 1="Lateral" 2="PA";
	value type  1="Abduction" 2="Adduction";
data cadaver;
	set temp1;
	if plane0="lateral" then plane=1; 
	if plane0="PA" then plane=2; 
	if measure="abduc" then type=1; 
	if measure="adduc" then type=2; 
	format plane plane. type type.;
	idx=compress(specimen_num,'d', 'a')+0;
	diff_pre_post=post_fusion-prefusion;
	diff_pre_post_se=post_scaphoid_excision-prefusion;
	diff_post_post_se=post_scaphoid_excision-post_fusion;

	drop plane0 measure;
run;
proc sort; by idx plane type;run;
proc univariate data = cadaver;
  class plane type;
  var diff_pre_post diff_pre_post_se diff_post_post_se;
run;
proc means data = cadaver n mean std median clm maxdec=1;
  class plane type;
  var diff_pre_post diff_pre_post_se diff_post_post_se;
run;
/*
data rom; set cadaver; run;
proc sort; by plane type;run;
proc univariate data = rom;
  by plane;
  var diff_pre_post diff_pre_post_se diff_post_post_se;
run;
proc means data = rom n mean std median clm maxdec=1;
  by plane;
  var diff_pre_post diff_pre_post_se diff_post_post_se;
run;
*/

data cadaver1;
	merge cadaver (where=(type=1) keep=idx type plane prefusion post_fusion post_scaphoid_excision) 
		  cadaver (where=(type=2) keep=idx type plane prefusion post_fusion post_scaphoid_excision 
				   rename=(prefusion=prefusion0 post_fusion=post_fusion0 post_scaphoid_excision=post_scaphoid_excision0));
		  by idx plane;
	tam_prefusion=prefusion-prefusion0;
	tam_postfusion=post_fusion-post_fusion0;
	tam_post_scaphoid_excision=post_scaphoid_excision-post_scaphoid_excision0;
	drop type;
	diff_tam_pre_post=tam_postfusion-tam_prefusion;
	diff_tam_pre_post_se=tam_post_scaphoid_excision-tam_prefusion;
	diff_tam_post_post_se=tam_post_scaphoid_excision-tam_postfusion;
	post_pre=tam_postfusion/tam_prefusion*100;
	post_se_pre=tam_post_scaphoid_excision/tam_prefusion*100;
	diff_post_pre=post_se_pre-post_pre;
run;

proc univariate data = cadaver1;
  class plane;
  var diff_tam_pre_post diff_tam_pre_post_se diff_tam_post_post_se diff_post_pre;
run;

proc means data = cadaver1 n mean std median clm maxdec=1;
  class plane;
  var diff_tam_pre_post diff_tam_pre_post_se diff_tam_post_post_se diff_post_pre;
run;
