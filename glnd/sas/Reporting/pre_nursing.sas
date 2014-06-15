/*
proc contents data=glnd.plate43;run;
proc print data=glnd.plate43;run;
*/

data pre_nursing;
	set glnd.plate43(keep=id nursing_home);
	where nursing_home=1;
run;

proc sort nodupkey; by id;run;
proc print;run;

data pre_nursing;
	set glnd.plate43(keep=id nursing_home);
	where nursing_home=2;
run;

proc sort nodupkey; by id;run;
proc print;run;




/*
data phone;
	set glnd_df.submission;
	keep id center phone_6mo;
run;

proc print;
where center=4 and phone_6mo=0;
run;

proc freq; 
table phone_6mo*center/out= phone_6mo sparse;
run;

proc print;run;

proc sort; by center;run;

data c;
				set phone_6mo;
				retain old_val old_count;

				by center;
				

				* not received;
				if phone_6mo = 0 then do; 
					old_val= phone_6mo; 
					old_count= count; 
					DELETE; * remove this record;
				end;
	
				* received;
				else if phone_6mo = 1 then do; 
					if old_count = . then old_count = 0; * in case of 100% submission, make the number of non-submitted = 0 ;
					expected = count + old_count; 
					received = count;
					pct_received = (received / expected) * 100;
				end;
	
				else if phone_6mo = 2 then DELETE; * remove this record - not expected ;	
	
				*keep center form received expected pct_received order;
			run;

proc print;run;
*/
			
