/* recruitment.sas
 *
 * makes a recruitment curve for the GRAC study
 */

%let date = 12_02_2009;
%let path = S:\Eli_Rosenberg\Conn\QC\;

libname grac "&path&date\download";
libname library "&path&date\download";

options nodate nonumber;

data recruitment;
	set grac.treatment (keep = id date_randomized);

	where (id ~= 75); * patient accidentally enrolled twice (is basically #53), and is more or less removed from the database;

	* make a new variable that maps the date of randomization to the first day of that month;

	new_date = datepart(date_randomized) - day(datepart(date_randomized)) + 1;

	format new_date mmddyy.;
run;

	* 4/4/08 ONLY: make 2 corrections. one person is missing a treatment assignment and the other has an errneous date of rand;
/*	data new_obs;
		id = 16; new_date = '01Jul07'd;
	run;
	data recruitment;
		set recruitment new_obs;

		if id = 46 then new_date = '01Jan08'd; * this was erroneously 2007 ;
	run;
*/
proc sort data = recruitment; by new_date id; run;

	* compute number recruited each month;
	proc means data= recruitment noprint;
		class new_date;
		output out = total_recruit n(id) = num_recruit;
	run;


	* compute cum. sum. at each month;
	data total_recruit;
		set total_recruit;
		where _type_ = 1;
		retain sum_recruit;

		if _N_ = 1 then sum_recruit = num_recruit;
		else sum_recruit = sum_recruit + num_recruit;
	run;

	* capture the total # recruited;
	data total_recruit;
		set total_recruit;
		by new_date;

		if last.new_date then call symput('act_sum', compress(put(sum_recruit, 3.0))); * store the last sum of patients recruited for later display;;

		format new_date monyy5.;
	run;


		/** 5/15/09 - TEMPRORARY **/
	/** add 0's for april and may ;  
	data extra_mo;

		new_date = mdy(4,1,2009); sum_recruit = 104; output;
		new_date = mdy(5,1,2009); sum_recruit = 104; output;
		format new_date monyy5.;

	run;

	data total_recruit;
		set total_recruit
			extra_mo;
	run;

	*/

* PLOT recruitment ;
	
		title1; title2; footnote1; footnote2;
		goptions reset=all rotate=landscape  gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;

		symbol1 value = "dot" h=2 i=join;
 		axis1 	label=(f=zapf h=3 'Study Month' ) value=(f=zapf h=2) 
					/*order= (17302 to 18262 by 30)*/	major=(h=3 w=2) minor=none ; * 17113 to 18253;
 		axis2 	label=(f=zapf h=3 a=90 'Patients Recruited' ) 	value=(f=zapf h=3) 
					order= (0 to 150 by 10) 	major=(h=1.5 w=2) minor=(number=4 h=1) ;

		title1 f=zapf h=3 justify=center "GRAC Patient Recruitment Summary - FINAL";
 		title2 f=zapf h=2.5 justify=center "&act_sum patients recruited";

	ods pdf file = "&path&date\recruitment.pdf" style = journal;
		proc gplot data = total_recruit;
			plot sum_recruit*new_date /haxis=axis1 vaxis=axis2 nolegend;
			format new_date monyy5. sum_recruit 3.0;

		run;

		title2 ;
		proc print data = total_recruit label noobs;
			var new_date num_recruit sum_recruit;
			
			label 
				new_date = "Month"
				num_recruit = "Patients recruited"
				sum_recruit = "Total patients in study"
				;
			footnote "note: 1 patient was erroneously recruited twice, and thus 105 randomizations ocurred";
		run;
	ods pdf close;
quit;
