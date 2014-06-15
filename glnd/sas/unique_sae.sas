proc contents data=glnd.sae_patients;

proc print data=glnd.sae_cases;run;



data tmp;
	set glnd.sae_patients;
	sum=sum(of sae1-sae8);
	*if sum>0;
run;


proc freq; tables sum;run;

proc freq; tables sae1-sae8;run;

/*
proc means n sum;
var sae1-sae8;
run;
*/
