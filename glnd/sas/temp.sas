proc contents data=glnd.sae_patients;
proc contents data=glnd.sae_cases;

data tmp;
	set glnd.sae_patients;
	if sae1=1 or sae2=1 or sae3=1 or sae4=1 or sae5=1 or sae6=1 or sae7=1 or sae8=1;
run;

proc sort nodupkey; by id; run;

proc print;run;
