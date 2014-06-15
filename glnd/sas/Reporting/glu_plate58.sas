/*
proc contents data=glnd.plate58;run;
proc print data=glnd.plate58;run;
*/

data glu_plate58;
	set glnd.plate58;

	keep id glutamic_acid_base glutamic_acid_day3 glutamic_acid_day7 glutamic_acid_day14 glutamic_acid_day21 glutamic_acid_day28
	glutamine_base  glutamine_day3  glutamine_day7 glutamine_day14 glutamine_day21 glutamine_day28;

run;

proc transpose data=glu_plate58 out=glu_plate58;
	by id;
run;

data glu_plate58_amine;
	set glu_plate58;
	if _NAME_='glutamine_base'  then do; day=0;  glutamine=COL1; end;
	if _NAME_='glutamine_day3'  then do; day=3;  glutamine=COL1; end;
	if _NAME_='glutamine_day7'  then do; day=7;  glutamine=COL1; end;
	if _NAME_='glutamine_day14' then do; day=14; glutamine=COL1; end;
	if _NAME_='glutamine_day21' then do; day=21; glutamine=COL1; end;
	if _NAME_='glutamine_day28' then do; day=28; glutamine=COL1; end;
	
	if day=. then delete;
	keep id day glutamine;
run;

proc sort;by id day;run;

data glu_plate58_acid;
	set glu_plate58;

	if _NAME_='glutamic_acid_base'  then do; day=0; glutamicacid=COL1; end;
	if _NAME_='glutamic_acid_day3'  then do; day=3; glutamicacid=COL1; end;
	if _NAME_='glutamic_acid_day7'  then do; day=7; glutamicacid=COL1; end;
	if _NAME_='glutamic_acid_day14' then do; day=14; glutamicacid=COL1; end;
	if _NAME_='glutamic_acid_day21' then do; day=21; glutamicacid=COL1; end;
	if _NAME_='glutamic_acid_day28' then do; day=28; glutamicacid=COL1; end;
	
	if day=. then delete;
	keep id day glutamicacid;
run;

proc sort;by id day;run;

data glnd.glu_plate58;
	merge glu_plate58_amine glu_plate58_acid;
	by id day;
	visit=day;
run;

proc print;run;
