libname wbh "/ttcmv/sas/data";
*libname wbh "/ttcmv/sas/programs/reporting/april2011abstracts";

data valid_id;
	set cmv.valid_ids;
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;

proc sql;
	create table tmp as
	select a.*, gender, race, LBWIDOB as dob
	from 
	valid_id as a
  	left join
	cmv.plate_005 as b
	on a.id=b.id
	;

proc sql;
	create table tmp as
	select a.*, GestAge, BirthWeight, Length, HeadCircum
	from 
	tmp as a
  	left join
	cmv.plate_006 as b
	on a.id=b.id
	;

proc sql;
	create table cmv.pat as
	select a.*, SNAPTotalScore
	from 
	tmp as a
  	left join
	wbh.snap as b
	on a.id=b.id
	;

proc sort nodupkey; by id; run;

proc print;run;

data comp_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
run;

proc sql;
	create table cmv.comp_pat as
	select a.id, b.*, studyleftdate, studyleftdate-dob as age 
	from 
	comp_pat as a
  	left join
	cmv.pat as b
	on a.id=b.id
	;

proc print;run;
      






