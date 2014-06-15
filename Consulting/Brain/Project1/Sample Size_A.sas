data load;
	infile cards;
	input load position;
	cards ;
	76.2 0
	80.6 0
	86.0 0
	87.0 0
	85.4 0
	90.4 0
	78.4 1
	73.2 1
	99.6 1
	69.8 1
   115.8 1
	27.2 1
	;
run;
proc format;
	value pos 0="Anterior"
			  1="Posterior"
			  ;
run;
proc univariate data=load plot normal;
   var load;
run;


data load;
	set load;
	*if load=27.2 then delete;
	format position pos.;
run;

proc print;run;
proc means data=load mean std median min max;
var load;
run;

proc power;
      onesamplemeans
	     nullmean = 150 200 250 
         mean   = 80.8 
		 stddev = 21.0
		 ntotal = 6 12
		 power=.;
run;

proc power;
      onesamplemeans
	     nullmean = 150 200 250 
         mean   = 80.8
		 stddev = 21.0
         power  = 0.5 0.6 0.7 0.8 0.9 0.95
		 ntotal = .;
run;
/*
proc power;
      onesamplemeans
	     nullmean = 150 200 250 
         mean   = 85.7 
		 stddev = 13.0
		 ntotal = 6 12
		 power=.;
run;

proc power;
      onesamplemeans
	     nullmean = 150 200 250 
         mean   = 85.7
         stddev = 13.0
         power  = 0.5 0.6 0.7 0.8 0.9
		 ntotal = .;
run;
*/
