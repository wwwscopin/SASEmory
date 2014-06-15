libname hsp "D:\Emory\HSP";
data eli_hsp;
set hsp.hsp_dsmb_2_2008_redone(rename = (hsp70_ng_correct = hsp70_ng))
	hsp.hsp_dsmb_3_2009
	hsp.hsp_dsmb_9_2009
;
run;

proc sort data=eli_hsp;by id day;run;

data hsp;
	merge eli_hsp	hsp.hsp	;
	by id day;
	hsp27_ng = hsp27_pg / 1000;
	keep id day hsp70_ng hsp27_ng;
run;
proc sort;by id day;run;
data hsp27;
set hsp;
where day=0 and hsp27_ng^=.;
run;

proc print;run;

