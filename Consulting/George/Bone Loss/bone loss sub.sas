
proc print data=bone_loss;
    var study1 trt comp_reinfect complex comp_reinfect_rate;
run;
data presub;
	input study trt spacer tibia1 tibia2 tibia3 femur1 femur2 femur3;
	cards;
	10 1 11 1  7  3  5  2  3  
	17 1 47 28 16 3  6  29 3  
	20 1 21 11 8  2  11 8  2  
	25 1 13 .  13 .  .  13 .  
	44 1 34 17 13 4  18 16 0  
	45 0 81 30 38 13 16 49 16 
	;
run;


proc means data=presub sum maxdec=0;
	class trt;
	var spacer tibia1 tibia2 tibia3 femur1 femur2 femur3;
run;

data fake;
	input loss trt m;
	cards;
	0 1 118
	1 1 8
	0 0 65
	1 0 16
	;
run;

proc freq data=fake;
	weight m;
	tables loss*trt/chisq fisher;
	format trt trt.;
run;

/*
Proc mixed data=presub;
Class trt study;
Model tibia_rate1=trt;
Random study;
Lsmeans trt/cl;
Run;
*/

data spacersub;
	input study trt spacer tibia femur combined tibia_mm femur_mm;
	cards;
	03 0 20 10 13  15  .    .    
	05 1 21 03 02  05  0.62 0.33 
	05 0 07 07 07  07  7.7  6.0  
	41 0 25 10 11  15  6.2  12.8 
	;
run;


proc means data=spacersub sum maxdec=0;
	class trt;
	var spacer tibia femur combined;
run;

data fake;
	input loss trt m;
	cards;
	0 1 16
	1 1 5
	0 0 15
	1 0 37
	;
run;

proc freq data=fake;
	weight m;
	tables loss*trt/chisq fisher;
	format trt trt.;
run;
