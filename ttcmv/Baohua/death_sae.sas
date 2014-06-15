
libname wbh "/ttcmv/sas/data";

proc format; 	
	value DeathCause 
		1="CMV disease"
		2="IVH"
		3="Infection/Sepsis"
		4="Transfusion reaction"
		5="NEC"
		6="BPD"
		7="PDA"
		;
	value check
		0="No"
		1="Yes"
		99=" "
		;	
run;

data tmp;
	length deathcausetext $100 deathcause0 $100;
	set cmv.plate_101(rename=(DeathCausemore=DeathCause0));
	if CNS=1 then dt1="CNS/"; 
	if cardio=1 then dt2="Cardiovascular/"; 
	if digestive=1 then dt3="Digestive/"; 
	if endocrine=1 then dt4="Endocrine/"; 
	if hemat=1 then dt5="Hematologic/"; 
	if metabolic=1 then dt6="Metabolic/"; 
	if musculo=1 then dt7="Musculoskeletal/"; 
	if renal=1 then dt8="Renal/"; 
	if resp=1 then dt9="Respiratory/"; 
	if urogenital=1 then dt10="Urogenital"; 
	dt=compress(dt1||dt2||dt3||dt4||dt5||dt6||dt7||dt8||dt9||dt10);
	DeathCauseText="Body System Affected: "||dt;

	if deathdate^=. then do; death=1; end; else do; death=0; end;
	if DeathCauseText=" " then do; DeathCauseText="not specified";	DeathContCause=0;	end;
		else DeathContCause=1;

	
	if id=1003111 then deathcause0="Patient Was Extubated And Unable To Suivive Without ventilatory support";
	keep id death DeathDate DeathCause0 DeathContCause DeathCauseText Autopsy;
run;


proc sql;

create table death as
select a.*  , gender, race, LBWIDOB as dob 
from 
tmp as a
left join
cmv.plate_005 as b
on a.id =b.id;
quit;

data wbh.sae;
	set death;
	age=DeathDate-dob;
	format Autopsy check. gender gender. race race.;
	label age="Age at death*(days)"
			DeathCauseText="Contributing cause* of death"
			Autopsy="Autopsy*performed?"
			gender="Gender"
			race="Race"
	;
run;

proc print;run;
