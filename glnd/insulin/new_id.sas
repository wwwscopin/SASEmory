data new_id;

	set glnd.status(keep=id dt_random);
	where dt_random>='01Mar10'd;

run;

proc print;run;
