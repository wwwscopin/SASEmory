
data x;
 merge glnd.plate5 glnd.plate6;
	 by id;
	if id = 42006;

proc print ;
	format age_score chron_health;
