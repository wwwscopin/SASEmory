proc contents data=cmv.km; run;
proc print data=cmv.km; 
where bellstage2^=.;
var id bellstage2;
run;
