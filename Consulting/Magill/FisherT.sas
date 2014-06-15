data suv;
	input Q fc take count;
	cards;
	1 1 1 11
	1 1 0 1
	1 2 1 19
	1 2 0 6
	1 3 1 32
	1 3 0 10

	2 1 1 1
	2 1 0 1
	2 2 1 2
	2 2 0 4
	2 3 1 9
	2 3 0 4
	2 4 1 50
	2 4 0 8

	3 1 1 9
	3 1 0 5
	3 0 1 53
	3 0 0 12

	4 1 1 32
	4 1 0 10
	4 0 1 30
	4 0 0 7

	5 1 1 11
	5 1 0 2
	5 0 1 51
	5 0 0 15

	6 1 1 32
	6 1 0 1
	6 2 1 25
	6 2 0 10
	6 3 1 5
	6 3 0 6
	;
run;

proc format; 
value Q  1="Q1" 2="Q2" 3="Q3" 4="Q4" 5="Q5" 6="Q6";
value take 1="Take Call" 0="Don't";
run;

proc freq data=suv order=data;
	by Q;
	weight count;
	tables fc*take/chisq fisher;
run;
