proc power;
	onecorr dist=fisherz
	nullc=0
	corr=0.1 0.2 0.3 0.4 0.5 0.6
	ntotal=1000
	power=.;
run;

proc power;
	onecorr dist=fisherz
	nullc=0
	corr=0.1 0.2 0.3 0.4 0.5 0.6
	ntotal=.
	power=0.9;
run;

proc power;
	onecorr dist=t
	npartialvars=0
	corr=0.1 0.2 0.3 0.4 0.5 0.6 
	ntotal=1000
	power=.;
run;

proc power;
	onecorr dist=t
	npartialvars=0
	corr=0.1 0.2 0.3 0.4 0.5 0.6
	ntotal=.
	power=0.90;
run;
