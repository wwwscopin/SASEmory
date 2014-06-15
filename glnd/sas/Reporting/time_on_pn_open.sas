/*
 *
 * produce a listing of time on PN for each patient, as well as summary statistics
 *
 *
 */;


** 	First, compute the time on PN using solely the pn start information and the stop times from the follow-up forms. If somebody is started and stopped multiple times,
	then we will use plate 48 to supercede this**;


data time_on_pn;
	set glnd.status (keep = id dt_drug_str time_drug_str 
							still_on_study_pn dt_study_pn_stopped time_study_pn_stopped 
							dt_random apache_2);

	*days_on_pn = dt_study_pn_stopped - dt_random; **** missing value created for those whose data reflect being still on PN and thus they are excluded from analyses ;

	datetime_start = dhms(dt_drug_str, hour(time_drug_str), minute(time_drug_str), 0);
	datetime_stop = dhms(dt_study_pn_stopped, hour(time_study_pn_stopped), minute(time_study_pn_stopped), 0);
	if time_study_pn_stopped=. and dt_study_pn_stopped^=. then 	datetime_stop = dhms(dt_study_pn_stopped, 0, 0, 0);
	
	* compute exact raw time on PN;
	days_on_pn = (datetime_stop - datetime_start) / (3600 * 24); * convert from seconds to days; 

	if (id =  12118) then days_on_pn = 0; * patient died before drug started - start date will always be missing;

	center = floor(id/10000);
	
	format still_on_study_pn yn. center center. datetime_start datetime_stop datetime. days_on_pn 4.1;

	label 
		dt_random = "Date Randomized"
		still_on_study_pn = "Patient still on study PN?"
		days_on_pn = "Days on study PN"
		;	
run;

proc print data = time_on_pn;
run;

** USE PN ON/OFF TO DETERMINE TIME ON PN FOR THOSE WITH MULTIPLE ON/OFFs. THEN MERGE THIS DATA BACK INTO TIME_ON_PN **;


proc sort data = time_on_pn; by id; run;
proc sort data = glnd.plate48; by id; run;

data multi_pn;
	merge 	time_on_pn (keep = id datetime_start center)
		glnd.plate48 (in = has_multi);
	by id;
	
	if ~has_multi then DELETE;
	
	*** need to use 'input' commands to convert time to integer. similar to this from plat39.sas -> informat time_study_pn_stp time5.; 
		pn_stop_time_1 = input(pn_inter_start_time_1, time5.);
		pn_stop_time_2 = input(pn_inter_start_time_2, time5.);
		pn_stop_time_3 = input(pn_inter_start_time_3, time5.);
		pn_stop_time_4 = input(pn_inter_start_time_4, time5.);
		pn_stop_time_5 = input(pn_inter_start_time_5, time5.);
	
		pn_start_time_2 = input(pn_restart_time_2, time5.);
		pn_start_time_3 = input(pn_restart_time_3, time5.);
		pn_start_time_4 = input(pn_restart_time_4, time5.);
		pn_start_time_5 = input(pn_restart_time_5, time5.);

	*** make datetimes (stored in seconds) from the day time ;
		pn_stop_1 = dhms(pn_inter_start_day_1, hour(pn_stop_time_1), minute(pn_stop_time_1), 0);
		pn_stop_2 = dhms(pn_inter_start_day_2, hour(pn_stop_time_2), minute(pn_stop_time_2), 0);	
		pn_stop_3 = dhms(pn_inter_start_day_3, hour(pn_stop_time_3), minute(pn_stop_time_3), 0);	
		pn_stop_4 = dhms(pn_inter_start_day_4, hour(pn_stop_time_4), minute(pn_stop_time_4), 0);	
		pn_stop_5 = dhms(pn_inter_start_day_5, hour(pn_stop_time_5), minute(pn_stop_time_5), 0);
	
		pn_start_2 = dhms(pn_restart_day_2, hour(pn_start_time_2), minute(pn_start_time_2), 0);	
		pn_start_3 = dhms(pn_restart_day_3, hour(pn_start_time_3), minute(pn_start_time_3), 0);	
		pn_start_4 = dhms(pn_restart_day_4, hour(pn_start_time_4), minute(pn_start_time_4), 0);	
		pn_start_5 = dhms(pn_restart_day_5, hour(pn_start_time_5), minute(pn_start_time_5), 0);
	
	* compute individual time intervals;
		days_on_pn_1 = (pn_stop_1 - datetime_start) / (3600 * 24); 
		days_on_pn_2 = (pn_stop_2 - pn_start_2) / (3600 * 24); 
		days_on_pn_3 = (pn_stop_3 - pn_start_3) / (3600 * 24); 
		days_on_pn_4 = (pn_stop_4 - pn_start_4) / (3600 * 24); 
		days_on_pn_5 = (pn_stop_5 - pn_start_5) / (3600 * 24); 
	
	* zero out missing times and sum them up ;
		if (days_on_pn_1 = .) then days_on_pn_1 = 0;
		if (days_on_pn_2 = .) then days_on_pn_2 = 0;
		if (days_on_pn_3 = .) then days_on_pn_3 = 0;
		if (days_on_pn_4 = .) then days_on_pn_4 = 0;
		if (days_on_pn_5 = .) then days_on_pn_5 = 0;
		
	*days_on_pn = days_on_pn_1 + days_on_pn_2 + days_on_pn_3 + days_on_pn_4 + days_on_pn_5  ;
	days_on_pn = sum(days_on_pn_1, days_on_pn_2, days_on_pn_3, days_on_pn_4, days_on_pn_5) ;
	
	format pn_stop_1 pn_stop_2 pn_stop_3 pn_stop_4 pn_stop_5 pn_start_2 pn_start_3 pn_start_4 pn_start_5 datetime.;
run;

proc print data = multi_pn; 
	var id datetime_start pn_stop_1 pn_start_2 pn_stop_2 pn_start_3 pn_stop_3 pn_stop_4 pn_stop_4 pn_stop_5 pn_stop_5 days_on_pn  ;
run;

**** merge back in!;
data time_on_pn;
	merge 	
		time_on_pn
		multi_pn (keep = id days_on_pn rename = (days_on_pn = days_on_pn_multi) in = has_multi)
	;
	by id;
	if has_multi then days_on_pn = days_on_pn_multi ;

	drop days_on_pn_multi;
run;

proc print data = time_on_pn; 
run;

data time_on_pn;
	merge 
		time_on_pn
		glnd.status (keep = id apache_2) ;
	by id;

	center = floor(id/10000);
		
	format center center. ;
	label 
		days_on_pn = "Days on study PN"
		;	
run;


options ls=80 nodate nonumber;
ods pdf file = "/glnd/sas/reporting/time_on_pn_open.pdf" startpage = yes style = journal;
	title "GLND: Time on Study PN";
	proc print data = time_on_pn label ;
		var id days_on_pn; *dt_random still_on_study_pn ;
	run;

	ods pdf text = " "; 	* blank line;

;
	proc means data = time_on_pn n mean median q1 q3 min max maxdec = 1 fw= 6 ;
		var days_on_pn;
		output out=overall n=n mean=mean median=median q1=q1 q3=q3 min=min max=max;
	run;

	ods pdf startpage = no;

	proc means data = time_on_pn n mean median q1 q3 min max maxdec = 1 fw= 6 ;
		class apache_2;
		var days_on_pn;
		output out=apache n=n mean=mean median=median q1=q1 q3=q3 min=min max=max;
		
	run;

	proc means data = time_on_pn n mean median q1 q3 min max maxdec = 1 fw= 6 ;
		class center;
		var days_on_pn;
		output out=center n=n mean=mean median=median q1=q1 q3=q3 min=min max=max;
	run;

	proc means data = time_on_pn n mean median q1 q3 min max maxdec = 1 fw= 6 ;
		class center apache_2;
		var days_on_pn;
	run;

ods pdf close;


data o;
 set overall;
 length gr $ 22;
  gr="Overall (n="||put(n,3.)||")";
  keep gr  mean median q1 q3 min max;
  data a;
   set apache;
   length gr $ 22;
   if apache_2=1 then gr="APACHE  < 16 (n="||put(n,2.)||")";
      if apache_2=2 then gr="APACHE  > 15 (n="||put(n,2.)||")";
    keep gr  mean median q1 q3 min max;
 data c;
  set center;
  length gr $ 22;
  if center=1 then gr="Emory (n="||put(n,2.)||")";
  if center=2 then gr="Miriam (n="||put(n,2.)||")" ;
  if center=3 then gr="Vanderbilt (n="||put(n,2.)||")";
  if center=4 then gr="Colorado (n="||put(n,2.)||")";
  if center=5 then gr="Wisconsin (n="||put(n,2.)||")";
    keep gr  mean median q1 q3 min max;
   data glnd_rep.studypn;
   
    set o a c;
    if gr='' then delete;
    label gr='Subset'
         
         mean='Mean'
         median='Median'
         q1='Lower Quartile'
         q3='Upper Quartile'
         min='Minimum'
         max='Maximum';
         run;
      
    proc print label;
quit;


title "Days on Study PN";
ods ps file="studypn.ps" style=journal;

proc print data=glnd_rep.studypn noobs label split="*" style(data)=[just=center];
id gr;
var n mean median q1 q3  min max;
run;

ods escapechar='^' ;
		ods ps text = " ";
		ods ps text = "^S={font_size=11pt font_style= slant just=left}* the minimum time on PN of 0 days was observed in a patient that died before PN was started";

ods ps close;
quit;    
  
data glnd_rep.time_on_pn;
  set time_on_pn;
keep id days_on_pn;
run;
