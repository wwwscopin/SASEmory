libname wbh "H:\SAS_Emory\Data";

proc format library= work;
	value center
		9='Total'
		1='Emory'
		2='Miriam'
		3='Vanderbilt'
		4='Colorado'
		5='Wisconsin'
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
run;

data cytokines;
	set wbh.cytokines_ex(keep=id);
		item=3;
run;
proc sort data=cytokines nodup; by id;run;


data flag_lps;
	set wbh.flag_lps_ex(keep=id);
		item=7;
run;
proc sort data=flag_lps nodup; by id;run;


data glu;
	set wbh.glu_ex(keep=id);
		item=9;
run;
proc sort data=glu nodup; by id;run;


data hsp70;
	set wbh.hsp_ex(keep=id hsp70_ng);
		item=6;
	where hsp70_ng^=.;
	drop hsp70_ng;
run;
proc sort data=hsp70 nodup; by id;run;


data hsp27;
	set wbh.hsp_ex(keep=id hsp27_pg);
		item=5;
	where hsp27_pg^=.;
	drop hsp27_pg;
run;
proc sort data=hsp27 nodup; by id;run;


data redox;
	set wbh.redox_ex(keep=id);
		item=4;
run;
proc sort data=redox nodup; by id;run;

Data wbh.LabData;
	set  cytokines flag_lps glu hsp27 hsp70 redox;
	format item item.;
run;

data _null_;
	set wbh.LabData;
	file 'LabData.txt';
	put id item;
run;

data  temp;
set wbh.Labdata;
where item=5;
run;
