/* MOC_demo.sas
 *
 * MOC_Demo form - TTCMV
 *
 */

proc sort data = cmv.plate_007; by id; run;
proc sort data = cmv.plate_008; by id; run;


data cmv.MOC_demo;
	merge 
			cmv.plate_007
			cmv.plate_008
			cmv.plate_009
	;
	by id;
run;


data cmv.moc_demo; set cmv.moc_demo; 
	if dfstatus = 0 then delete; 
run;


* variable names too long, rename ;
data cmv.moc_demo; set cmv.moc_demo (rename = (deliverysteroidbetamethasone = betamethasone deliverysteroiddexamethasone = dexamethasone)); run;

/*
proc sql;

create table cmv.MOC_demo as
select a.* , b.*
from cmv.plate_007 as a
left join
cmv.plate_008 as b
on a.id=b.id and a.dfseq=b.dfseq
;

quit; */

proc print;
run;
	
