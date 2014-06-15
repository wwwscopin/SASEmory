data glu;
	merge glnd_ext.glutamine glnd.status(keep=id treatment apache_2); by id;
	keep id GlutamicAcid Glutamine visit treatment apache_2;
run;

proc means data=glu(where=(visit=0)) n mean stddev median min max maxdec=1;
class apache_2;
var glutamicacid glutamine;
run;
