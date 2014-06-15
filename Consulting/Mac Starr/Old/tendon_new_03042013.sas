
options ls=80 orientation=portrait;

data temp;
	input group tendon rupt;
	cards;
	1 1245	72
	2 131	3
    3 36	0.5
	;
run;

proc format; 
	value gp 1="Strand Repair=2"
			 2="Strand Repair=4"
			 3="Strand Repair=6"
			 ;
	value rupt 0="Non_Rupture" 1="Rupture";
run;

data tend;
	set temp(keep=group rupt rename=(rupt=count) in=A) 
		  temp(keep=group tendon rupt); by group;
	if A then rupture=1; else rupture=0; 
	if not A then count=tendon-rupt;
	format group gp. rupture rupt.;
	keep group rupture count;
run;
proc freq data=tend;
	weight count;
	table group*rupture/relrisk fisher;
run;

proc freq data=tend(where=(group in(1,2)));
	weight count;
	table group*rupture/relrisk fisher;
run;
proc freq data=tend(where=(group in(1,3)));
	weight count;
	table group*rupture/relrisk fisher;
run;
proc freq data=tend(where=(group in(2,3)));
	weight count;
	table group*rupture/relrisk fisher;
run;
