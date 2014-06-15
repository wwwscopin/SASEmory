/* Med_review.sas
 *
 * Med_review form - TTCMV
 *
 */

proc sort data = cmv.plate_015; by id; run;
proc sort data = cmv.plate_016; by id; run;

data cmv.Med_review;
	merge 
			cmv.plate_015
			cmv.plate_016
	;
	by id dfseq;
run;



/*
proc sql;

create table cmv.Med_review as
select a.* , b.*
from cmv.plate_015 as a
left join
cmv.plate_016 as b
on a.id=b.id and a.dfseq=b.dfseq
;

quit;
*/
/* create missing data */
data cmv.Med_review; set cmv.Med_review; 

total_anthro=3; total_chem=18; this_anthro_gt25=0;this_chem_gt25=0;
this_anthro=0; this_chem=0;

if HtLength <> . then this_anthro=this_anthro+1; 
if  Weight <> . then this_anthro=this_anthro+1; 
if  HeadCircum <> . then this_anthro=this_anthro+1; 

if  glucose <> . then this_chem=this_chem+1; 
if  platelet <> . then this_chem=this_chem+1; 
if  HCT <> . then this_chem=this_chem+1;   
if  Hb <> . then this_chem=this_chem+1;
if  Absneutrophil <> . then this_chem=this_chem+1;  
if  lympho <> . then this_chem=this_chem+1; 
if  ALT <> . then this_chem=this_chem+1;   
if  AST <> . then this_chem=this_chem+1; 
if  Albumin <> . then this_chem=this_chem+1; 
if  TotalBilirubin <> . then this_chem=this_chem+1;
if  DirectBilirubin <> . then this_chem=this_chem+1;
if  BUN <> . then this_chem=this_chem+1;
if  creatinine <> . then this_chem=this_chem+1;
if  potassium <> . then this_chem=this_chem+1;
if  sodium <> . then this_chem=this_chem+1;
if  chloride <> . then this_chem=this_chem+1;
if  bicarbonate <> . then this_chem=this_chem+1;
if  glucose <> . then this_chem=this_chem+1;

this_anthro_pct=this_anthro/total_anthro*100;
this_chem_pct=this_chem/total_chem*100;
pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

anthro_nonmiss=compress(this_anthro) || "/" || compress(total_anthro);
chem_nonmiss=compress(this_chem) || "/" || compress(total_chem);

if this_anthro_pct >=25 then this_anthro_gt25 =1;
if this_chem_pct >=25 then this_chem_gt25 =1;
run;
run;

proc print;
run;
	
