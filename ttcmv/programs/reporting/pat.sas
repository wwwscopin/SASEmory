
data valid_id;
	set cmv.completedstudylist;
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
	create table tmp1 as
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
	tmp1 as a
  	left join
	cmv.snap as b
	on a.id=b.id
	;
	
	
proc sort nodupkey; by id; run;

data comp_pat;
	set cmv.endofstudy;
	*where reason In (1,2,3,6);
	if reason^=5;
run;


proc sql;
	create table cmv.comp_pat as
	select b.*, studyleftdate, studyleftdate-dob as age 
	from 
	comp_pat as a
  	right join
	cmv.pat as b
	on a.id=b.id
	;


proc sort; by id; run;


