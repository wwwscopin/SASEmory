data load;
	infile cards;
	input Ant post;
	diff=ant-post;
	cards ;
	76.2 78.4
	80.6 73.2
	86.0 99.6
	87.0 69.8
	85.4 115.8
	90.4 27.2
	;
run;
proc print;run;

proc means data=load mean std median min max;
 var ant post diff;
run;

proc corr data=load;
	var ant post;
run;

proc univariate data=load plot normal;
   var diff;
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 6.9
  std = 32.2 
  corr = -0.31327
  npairs = 6 
  power = .;
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 6.9
  std = 32.2 
  corr = -0.31327
  npairs = . 
  power = 0.8;
run;
