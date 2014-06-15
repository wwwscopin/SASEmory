data a;
input X      Y      Z$;
cards;
2005    1      A      
2005    1      A 
2005    1      B
2005    1      B
2005    1      B
2005    2      A
2005    2      A
2005    2      B
;
run;
proc print;run;

/*
proc sql;
	create table wbh as 
	select x, y, z, count(distinct (z)) as f, sum(z) as g
	from a;
run;

proc print;run;
*/

proc sort; by x y z;run;

data b;
	set a; by x y z;
	if first.z then temp=0; 
	temp+1;
	if last.z;
run;

proc print;run;

%let a= %str( b, c, d, e, f);
%let b= %str( b c d e f);
options mprint symbolgen;

data x;
b=2 ; c=3 ; d=4; e=.; f=6;
z=mean (of _numeric_);
y=mean (of &b);
x=mean(&a);
run;

proc print;run;
