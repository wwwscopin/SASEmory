data temp;
	input time group rupt total;
	cards;
	1 0	13 403
	1 1	14 230
	2 0	17 410
	2 1	27 486
	3 0	5  100
	3 1	24 451
	4 0	10 121
	4 1	10 229
	5 0	9  484
	5 1	2  71
	;
run;

proc format;
	value tint 1="1987-1991" 2="1992-1996" 3="1997-2001" 4="2002-2006" 5="2007-2011";
	value idx  1="1992-2001" 2="2002-2011";
	value group 0="Passive" 1="Active";
	value rupture 0="Non-Rupture" 1="Rupture";
run;


data rupt0;
	set temp;
	non_rupt=total-rupt;
	if time in(2,3) then idx=1;
	if time in(4,5) then idx=2;
	format time tint. idx idx. group group.;
run;
proc sort; by time group;run;

data rupt;
	set rupt0(keep=time group idx rupt rename=(rupt=count) in=A)
		  rupt0(keep=time group idx non_rupt rename=(non_rupt=count)); by time group;
	if A then rupture=1; else rupture=0;
	format rupture rupture.;
run;

proc freq data=rupt;
	weight count;
	tables time*group*rupture/chisq fisher relrisk cmh;
	tables idx*group*rupture/chisq fisher relrisk cmh;
run;
/*
data rupt;
	set rupt;
	where group=1;
run;
*/
proc sql;
	create table rupt_overall as
		select time, rupture, sum(count) as new_count
		from rupt
		group by time, rupture
		order by time, rupture;
quit;

proc freq data=rupt_overall;
	weight new_count;
	tables rupture*time/trend measures cl  plots=freqplot(twoway=stacked);
	exact trend / maxtime=60;
run;

data rupt_temp;
	set rupt_overall;
	if time in (2,3) then idx=1;
	if time in (4,5) then idx=2;
run;


proc sql;
	create table rupt_overall1 as
		select idx, rupture, sum(new_count) as count
		from rupt_temp
		group by idx, rupture
		order by idx, rupture;
quit;


proc freq data=rupt_overall1;
	weight count;
	tables rupture*idx/fisher trend measures cl  plots=freqplot(twoway=stacked);
	exact trend / maxtime=60;
run;
