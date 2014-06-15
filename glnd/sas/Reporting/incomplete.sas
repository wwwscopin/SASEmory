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
	value miss
      0 = "." 
      1 = "+";

	value immune
      1 = "+"
      0 = "."
		 2 ="NA"
		 3='NA';
run;

data recruit_id;
	set glnd.status(keep=id dt_random);
	center=floor(id/10000);
run;

proc sort data=recruit_id nodupkey; by id;run;

/*
proc sort data=glnd.plate47 output=tmp nodupkey; by id;run;
proc print data=tmp;var id;run;
*/

%macro lab(varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

data lab&i;
	%if &var=chem %then %do;
		set glnd_ext.chemistries(keep=id bun creatinine bilirubin sgot_ast sgpt_alt alk_phos glucose);
		where bun^=. or creatinine^=. or bilirubin^=. or sgot_ast^=. or sgpt_alt^=. or alk_phos^=. or glucose^=.; 
	%end;
	%if &var=crp %then %do;	set glnd_ext.chemistries(keep=id crp);	where crp^=.; %end;	
	%if &var=cytokines %then %do;	set glnd_ext.cytokines;	where il6^=. or il8^=.;  %end;	

	%if &var=redox %then %do;
		set glnd_ext.redox(keep=id GSH_GSSG_redox Cys_CySS_redox GSH_concentration GSSG_concentration Cys_concentration CysSS_concentration);
		where id ^= 32006 and GSH_GSSG_redox^=. or Cys_CySS_redox^=. or GSH_concentration^=. or GSSG_concentration^=. or Cys_concentration^=. or CysSS_concentration^=.;
	%end;	

	%if &var=hsp70 %then %do;	set glnd_ext.hsp(drop=center); where hsp70_ng^=.; 	%end;	
	%if &var=hsp27 %then %do;	set glnd_ext.hsp(drop=center); where hsp27_ng^=.; 	%end;	
	%if &var=flag_lps %then %do;	set glnd_ext.flag_lps; 			
		where anti_flag_IgG^=. or anti_flag_IgA^=. or anti_flag_IgM^=. or anti_lps_IgG^=. or anti_lps_IgA^=. or anti_lps_IgM^=.; %end;	
	%if &var=immune %then %do;	set glnd.plate47; 	where ros_prod_stim^=. or ros_prod_cont^=. or phago_stim^=. or phago_cont^=.;  %end;	
	%if &var=glutamine %then %do;	set glnd_ext.glutamine; where /*GlutamicAcid^=. or*/ Glutamine^=.; %end;	
run;
     
data lab&i;
	merge lab&i(keep=id in=tmp) recruit_id; by id;
	if dt_random=. then delete;
	if tmp then lab_&var=1; else lab_&var=0;
	keep id lab_&var;
run;

proc sort nodupkey; by id;run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend;

%let varlist=chem crp cytokines redox hsp27 hsp70 flag_lps immune glutamine;
%lab(&varlist);


data lab_2;
	set lab2;
	if lab_crp=1;
run;

proc print data=lab_2;run;

data lab;
	merge recruit_id lab1 lab2 lab3 lab4 lab5 lab6 lab7 lab8 lab9; by id;

	if id>20000 then lab_immune=2;
	if id in(11009,11012,11023,12026,12275,12206,12207,11116,12118,11122,11141,12383) then lab_immune=3;

format center center. lab_chem lab_crp lab_cytokines lab_redox lab_hsp27 lab_hsp70 lab_flag_lps lab_glutamine miss. lab_immune immune.;
run;

proc sort; by dt_random id;run;


proc freq; 
tables center*(lab_chem lab_crp lab_cytokines lab_redox lab_hsp27 lab_hsp70 lab_flag_lps lab_immune lab_glutamine)/nocol norow nopct;
ods output Freq.Table1.CrossTabFreqs=tab1(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table2.CrossTabFreqs=tab2(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table3.CrossTabFreqs=tab3(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table4.CrossTabFreqs=tab4(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table5.CrossTabFreqs=tab5(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table6.CrossTabFreqs=tab6(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table7.CrossTabFreqs=tab7(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table8.CrossTabFreqs=tab8(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table9.CrossTabFreqs=tab9(drop=table  _TYPE_  _TABLE_ Missing);
run;

proc sort data=tab1; by center;run;
proc sort data=tab2; by center;run;
proc sort data=tab3; by center;run;
proc sort data=tab4; by center;run;
proc sort data=tab5; by center;run;
proc sort data=tab6; by center;run;
proc sort data=tab7; by center;run;
proc sort data=tab8; by center;run;
proc sort data=tab9; by center;run;

data nolab;
	merge tab1(where=(lab_chem=.) rename=(frequency=n))
			 tab1(where=(lab_chem=0) rename=(frequency=n1))
			 tab2(where=(lab_crp=0) rename=(frequency=n2))
			 tab3(where=(lab_cytokines=0) rename=(frequency=n3))
			 tab4(where=(lab_redox=0) rename=(frequency=n4))
			 tab5(where=(lab_hsp27=0) rename=(frequency=n5))
			 tab6(where=(lab_hsp70=0) rename=(frequency=n6))
			 tab7(where=(lab_flag_lps=0) rename=(frequency=n7))
			 tab8(where=(lab_immune=0) rename=(frequency=n8))
			 tab9(where=(lab_glutamine=0) rename=(frequency=n9))
				;	by center;
			if center=. then center=9;
			if n8=. then n8=0;
	keep center n n1-n9;
	fromat center center.;
run;

proc sort; by center;run;


/******************************************/
ods pdf file="incomplete.pdf" style=journal;
title "Incomplete ID Summary"; 

proc print data=nolab noobs label;
	label n='No. Recruit ID';
	label n1='Chem';
	label n2='CRP';
	label n3='Cytokines';
	label n4='Redox';
	label n5='HSP-27';
	label n6='HSP-70';
	label n7='Flag/LPS';
	label n8='Immune';
	label n9='Glutamine';
	label center='Center';
run;

title "Incomplete ID Listing"; 

proc print data=lab label;
	var id dt_random lab_chem lab_crp lab_cytokines lab_redox lab_hsp27 lab_hsp70 lab_flag_lps lab_immune lab_glutamine/style(data) = [just=center];
	label lab_chem="Chem";	
	label lab_crp="CRP";
	label lab_cytokines="Cytokines";
	label lab_redox="Redox";
	label lab_hsp27="HSP-27";
	label lab_hsp70="HSP-70";
	label lab_flag_lps="Flag/LPS";
	label lab_immune="Immune";
	label lab_glutamine="Glutamine";
	label dt_random="Randomized Date";
run;

		ods escapechar='^' ;
		ods pdf text = " ";
		ods pdf text = "^S={font_size=11pt font_style= slant just=center}Note: '+' --> Completed, '.' --> Incomplete!";

ods pdf close;
/**********************************************/


ods tagsets.excelxp file="hsp_missing.xls";
ods tagsets.excelxp
options(sheet_name="hsp");
proc print data=lab noobs label split="*";
where lab_hsp27=0 or lab_hsp70=0;
var id lab_hsp27 lab_hsp70;
Run;
ods tagsets.excelxp close;

