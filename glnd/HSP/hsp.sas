libname hsp "H:\SAS_Emory\HSP";

data hsp;
	set hsp.hsp_dsmb_2_2008_redone(rename = (hsp70_ng_correct = hsp70_ng))
	hsp.hsp_dsmb_3_2009
	hsp.hsp_dsmb_9_2009
	hsp.hsp
	;
	hsp27_ng = hsp27_pg / 1000;
	keep id day hsp70_ng hsp27_ng;
run;

proc print;run;

data hsp27;
	set hsp;
	where day=0 and hsp27_ng^=.;
	keep id hsp27_ng;
run;

proc sort data=hsp27 nodup; by id;run;
proc print data=hsp27;run;

data hsp70;
	set hsp;
	where day=0 and hsp70_ng^=.;
	keep id;
run;

proc sort data=hsp70 nodup; by id;run;
proc print data=hsp70;run;
