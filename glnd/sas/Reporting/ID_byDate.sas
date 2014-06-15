libname wbh "/home/bwu2/data";

proc format library= work;
	value center
		1='Emory'
		2='Miriam'
		3='Vanderbilt'
		4='Colorado'
		5='Wisconsin'
		9='Total'
	;

	value item
		0='Total'
		1='Chem'
		2='CRP'
		3='Cytokines'
		4='Redox'
		5='HSP-27'
		6='HSP-70'
		7='Flag/LPS'
		8='Immune'		
		9='GLU'
	;
	value chem
      1 = "."
      0 = "+" ;
	value crp
      1 = "."
      0 = "+" ;
	value cyto
      1 = "."
      0 = "+" ;
	value redox
      1 = "."
      0 = "+" ;
	value hsp27A
      1 = "."
      0 = "+" ;
	value hsp70A
      1 = "."
      0 = "+" ;
	value flag_lps
      1 = "."
      0 = "+" ;
	value immune
      1 = "."
      0 = "+"
		 2 ="-";
	value glu
      1 = "."
      0 = "+" ;
run;

data recruit_id;
	set glnd.status(keep=id dt_random);
	item=0;
	center=floor(id/10000);
	format center center. item item.;
run;

proc sort data=recruit_id nodupkey; by id;run;

%macro lab_id(dataset, var, lib=glnd_ext);*/

*********************************************************************;	
	%if &dataset =chem %then 
	%do;
		data lab_id_&var;
			set &lib..chemistries(keep=id bun creatinine bilirubin sgot_ast sgpt_alt alk_phos glucose crp);
			%if &var=chem %then
					%do;
						where bun^=. or creatinine^=. or bilirubin^=. or sgot_ast^=. or sgpt_alt^=. or alk_phos^=. or glucose^=.;
						item=1;
					%end;
			%else %if	&var=crp %then 
			%do;
				where crp^=.; item=2;
			%end;			
		run;
	%end;
*********************************************************************;
	%if &dataset=redox %then
	%do;
		data lab_id_&var;
			set &lib..&dataset(keep=id GSH_GSSG_redox Cys_CySS_redox GSH_concentration GSSG_concentration Cys_concentration CysSS_concentration);
			where id ^= 32006 and GSH_GSSG_redox^=. or Cys_CySS_redox^=. or GSH_concentration^=. or GSSG_concentration^=. or Cys_concentration^=. or CysSS_concentration^=.;
			item=4;
		run;
	%end;

*********************************************************************;
	%if &dataset =hsp %then %do;
		data lab_id_&var;
			set &lib..&dataset(drop=center);
			%if &var=hsp70 %then 
				%do; 
					where hsp70_ng^=.; item=6;
				%end;
			%else %if &var=hsp27 %then
				%do;
					where hsp27_ng^=.; item=5;
				%end;
		run;
	%end;
*********************************************************************;

	%if &dataset =flag_lps %then %do;
		data lab_id_&var;
			set &lib..&dataset;
			%if &var=flag_lps %then 
			%do;
				where anti_flag_IgG^=. or anti_flag_IgA^=. or anti_flag_IgM^=. or anti_lps_IgG^=. or anti_lps_IgA^=. or anti_lps_IgM^=.;
				item=7;
			%end;
		run;
	%end;
*********************************************************************;

	%if &dataset =immune %then %do;
		data lab_id_&var data_immune;
			set &lib..plate47;
			%if &var=immune %then 
				%do; */
					where ros_prod_stim^=. or ros_prod_cont^=. or phago_stim^=. or phago_cont^=.; item=8;
				%end;
		run;
	%end;
*********************************************************************;
	%if &dataset =cytokines %then %do;
		data lab_id_&var;
			set &lib..&dataset;
			%if &var=cytokines %then 
				%do; 
					where il6^=. or il8^=.; item=3;
				%end;
		run;
	%end;

*********************************************************************;
	%if &dataset =glutamine %then %do;
   	data lab_id_&var;
			set &lib..&dataset;
			%if &var=glu %then 
				%do; 
					where GlutamicAcid^=. or Glutamine^=.; item=9;
				%end;
		run;
	%end;

*********************************************************************;

      	data id_list_&var;
      		merge lab_id_&var(keep=id in=lab) recruit_id; by id;
				if lab;
     	run;
%mend;

/* Here use the macro the create the dataset for each item such as "chem", "redox"...*/
***************************************************************************************;
/* var=chem or crp*/
%lab_id(chem, chem);
%lab_id(chem, crp);

/* var=redox*/
%lab_id(redox, redox);

/* var=hsp70, hsp27*/
%lab_id(hsp, hsp70);
%lab_id(hsp, hsp27);

/* var=flag_lps*/
%lab_id(flag_lps, flag_lps);

/* var=glu*/
%lab_id(glutamine, glu);

%lab_id(cytokines, cytokines);

/* immune*/
%lab_id(immune, immune,lib=glnd);

proc print data=lab_id_glu;run;

data lab_id;
	set id_list_chem id_list_crp id_list_redox id_list_hsp27 id_list_hsp70 id_list_flag_lps id_list_glu id_list_cytokines id_list_immune;
	by id;
	format item item.;
run;

proc sort data=lab_id; by center item dt_random id;run;
data lab_id;
	set lab_id; by center item;
     	retain No; 
		if first.item then No=0;
		No=No+1;
run;

data freq_id;
	set recruit_id lab_id;
run;

/* To check the names from ods output of the frequency table*/
**************************************************************;
*ods trace on/label listing;

proc freq data=freq_id; tables center*item/norow nocol nocum nopercent; run;
data count;
	set count(keep=center item frequency);
	if center=. then center=9;
	where item^=.;
	ods output Freq.Table1.CrossTabFreqs=count;
run;

proc sort data=count; by center;run;

proc transpose data=count out=lab_id_summary(where=(_NAME_^='item')); by center;run;

data lab_id_summary;
	set lab_id_summary(drop=_NAME_  _LABEL_);	
	if center in (1,9) then col9=col9-12;
	rename COL1=Total COL2=Chem  COL3=CRP  COL4=Cytokines COL5=Redox COL6=HSP27 COL7=HSP70 COL8=Flag_LPS COL9=Immune COL10=GLU;
run;


data id_chem id_crp id_cyto id_redox id_hsp27 id_hsp70 id_flag_lps id_immune id_glu;
	set lab_id;
	select (item);
	when (1) output id_chem;
	when (2) output id_crp;
	when (3) output id_cyto;
	when (4) output id_redox;
	when (5) output id_hsp27;
	when (6) output id_hsp70;
	when (7) output id_flag_lps;
	when (8) output id_immune;
	when (9) output id_glu;
	end;
run;

proc sort data=id_chem; by id dt_random; run;
proc sort data=id_crp; by id dt_random; run; 
proc sort data=id_cyto; by id dt_random ; run; 
proc sort data=id_redox; by id dt_random ; run; 
proc sort data=id_hsp27; by id dt_random; run; 
proc sort data=id_hsp70; by id dt_random; run; 
proc sort data=id_flag_lps; by id dt_random; run; 
proc sort data=id_immune; by id dt_random ; run; 
proc sort data=id_glu; by id dt_random; run;  


data incomplete_id;
	merge id_chem(rename=(item=chem)) id_crp(rename=(item=crp)) id_cyto(rename=(item=cyto)) id_redox(rename=(item=redox)) 
			 id_hsp27(rename=(item=hsp27A)) id_hsp70(rename=(item=hsp70A)) id_flag_lps(rename=(item=flag_lps)) 
			 id_immune(rename=(item=immune)) id_glu(rename=(item=glu));
	by id dt_random;
	drop center No;

	if chem=. then chem=0; else chem=1;
	if crp=. then crp=0; else crp=1;
	if cyto=. then cyto=0; else cyto=1;
	if redox=. then redox=0; else redox=1;
	if hsp27A=. then hsp27A=0; else hsp27A=1;
	if hsp70A=. then hsp70A=0; else hsp70A=1;
	if flag_lps=. then flag_lps=0; else flag_lps=1;
	if immune^=. then immune=1; else if 10000<id<20000 then immune=0; else immune=2;
	if id in(11009,11012,11023,12026,12275,12206,12207,11116,12118,11122,11141,12383) then immune=2;
	if glu=. then glu=0; else glu=1;
	format chem chem.;
	format crp crp.;
	format cyto cyto.;
	format redox redox.;
	format hsp27A hsp27A.;
	format hsp70A hsp70A.;
	format flag_lps flag_lps.;
	format immune immune.;
	format glu glu.;
run;


	proc sql;
		create table full_id as
   		select *
      		from recruit_id
			except corr
			select *
				from incomplete_id;

data full_id;
	set full_id;
	chem=0; crp=0; cyto=0; redox=0; hsp27A=0; HSP70A=0; flag_lps=0; glu=0;
	if 10000<id<20000 then immune=0; else immune=2;
	format chem chem.;
	format crp crp.;
	format cyto cyto.;
	format redox redox.;
	format hsp27A hsp27A.;
	format hsp70A hsp70A.;
	format flag_lps flag_lps.;
	format immune immune.;
	format glu glu.;
run;

proc sort data=full_id; by id dt_random;run;

data all_id;
	set incomplete_id full_id;
run;

proc sort data=all_id; by id dt_random; run; 

proc print data=all_id;run;

/******************************************/
ods pdf file="incomplete_lab_data_ID_listing_New.pdf" style=journal;
title "Incomplete ID Summary"; 

proc print data=lab_id_summary noobs label;
	label Total='No. Recruit ID';
	label Flag_LPS='Flag/LPS';
	label HSP27='HSP-27';
	label HSP70='HSP-70';
	label center='Center';
run;

title "Incomplete ID Listing"; 

*proc print data=incomplete_id label;
proc print data=all_id label;
	var id dt_random chem crp cyto redox hsp27A hsp70A flag_lps immune glu/style(data) = [just=center];
	label chem="Chem";	
	label crp="CRP";
	label cyto="Cytokines";
	label redox="Redox";
	label hsp27A="HSP-27";
	label hsp70A="HSP-70";
	label flag_lps="Flag/LPS";
	label immune="Immune";
	label glu="GLU";
	label dt_random="Randomized Date";
run;

		ods escapechar='^' ;
		ods pdf text = " ";
		ods pdf text = "^S={font_size=11pt font_style= slant just=center}Note: '+' --> Completed, '-' --> Not required, '.' --> Incomplete!";

ods pdf close;
/**********************************************/







