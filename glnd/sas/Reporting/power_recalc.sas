/*	power_recalc.sas
 * 
 *	create a dataset with information useful for power recalculation for GLND - to be provided to Kirk and Ji 
 *
 * we provide data on mortality and infections for those patients currently discharged from the hospital
 *
 */


proc sort data = glnd.status; by id; run;

data glnd.power_recalc;
	set 
		glnd.status (keep = id apache_2 center treatment dt_random dt_death dt_discharge still_in_hosp
						deceased mortality_28d mortality_6mo)
		;

	where ~still_in_hosp;

	if deceased & (dt_death <= dt_discharge) then mortality_hosp = 1; 
	else if ~deceased | (dt_death > dt_discharge) then mortality_hosp = 0; * otherwise, sets to missing;
	



	format still_in_hosp deceased mortality_28d mortality_6mo mortality_hosp yn. center center.;

	drop still_in_hosp;

run;

proc print data= glnd.power_recalc;
run;

proc freq data = glnd.power_recalc;
	tables 	apache_2 deceased mortality_hosp mortality_6mo 
				(mortality_hosp mortality_6mo)*(apache_2 treatment) ;
run;

