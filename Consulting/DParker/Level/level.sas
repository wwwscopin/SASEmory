proc import out=level
			datafile="H:\SAS_Emory\Consulting\DParker\Level\study 1.xls"
			DBMS=EXCEL REPLACE;
			sheet="sheet1";
			mixed=yes;
			getnames=No;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;

%macro data(dataset);
data tmp;
	set &dataset;

	length name $10;
	if 44>=_n_>=3;
	name=compress(F1);
	%do i=1 %to 12;
		%let j=%eval(2*&i);	%let k=%eval(&j+1);
		group=0;
		level=&i;
		v=F&j+0; RL=0; output;
		v=F&k+0; RL=1; output;
	%end;

	%do i=1 %to 5;
		group=1;
		level=&i;
		%let j=%eval(2*(&i+12)); %let k=%eval(&j+1);
		v=F&j+0; RL=0; output;
		v=F&k+0; RL=1; output;
	%end;
		drop F1-F35;
run;
%mend;
%data(level); quit;

proc format;
	value group 0="Thoracic" 1="Lumbar";
	value RL 0="Right" 1="Left";
run;

data park;
	set tmp;
	if v=. and group=2 and level=5 and RL=1 then delete;
	format group group. RL RL.;
run;

proc sort data=park out=park0; by group level; run;

* For Question 1, to know the difference between each level; 
* Here the Thoracic and Lumbar are treated no difference;
data park1;
	set park0; 
	if group=1 then level=level+12;
run;

proc glm data=park1; 
class level;
model v=level;
lsmeans level / pdiff cl
adjust=t/*tukey*/;
run;
* For Question 1, to know the difference between each level; 
* Here the Thoracic and Lumbar are treated seperately;
/*
proc glm data=park0; 
by group;
class level;
model v=level;
lsmeans level / pdiff cl
adjust=t;
run;
*/

* For Question 2, to know the right and left difference for each level;  
proc ttest data=park0; 
by group level;
class RL;
var v;
run;

* For Question 3, to know the realibality of interobservers; 
data int_obs;
	set park;
	where name='zamora' or name="lanman";
run;

data int0 int1;
	set int_obs;
	if _n_<=68 then output int0; else output int1;
run;

proc sql; 
	create table int as
	select a.*, b.v as v1, b.v-a.v as diff, (a.v+b.v)/2 as avg
	from int0 as a, int1 as b
	where a.name=b.name and a.group=b.group and a.level=b.level and a.rl=b.rl
	;
proc print;run;

proc means data=int;
	var diff;
run;

proc ttest data=int;
paired v*v1;
run;

axis1 order=(-2 to 2 by 0.5);
proc gplot data=int;
	symbol1 v=dot c=red i=none;
	plot diff*avg/vaxis=axis1 vref=-0.2197 1.3028 -1.7423 lv=3 c=black;;
run;
