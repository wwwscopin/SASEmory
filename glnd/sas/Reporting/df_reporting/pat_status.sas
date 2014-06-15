proc format;
	value wdraw 0="No" 1="Yes";
	value died 0="No" 1="Yes";
	value on_study 0="No" 1="Yes";
	value comp_study 0="No" 1="Yes";
	value lost_to_followup 0="No" 1="Yes";
run;


data pat_status;
	merge glnd.status(rename=(mortality_6mo=died still_on_study_pn=on_study)) 
	glnd_df.submission(keep=id phone_6mo) glnd.plate51(keep=id wdraw_cons dt_wdraw_cons)
	glnd.plate43 (where=(DFSEQ = 44) keep = dfseq id dt_phn_call); by id;
	if id=41091 then lost_to_followup=0;

	if phone_6mo=1 and not died and not lost_to_followup then comp_study=1; else comp_study=0;
	if wdraw_cons then wdraw=1;else wdraw=0;
	if comp_study or wdraw or died or lost_to_followup then on_study=0; else on_study=1;

	lost_day=dt_last_contact-dt_random;
	day_study=dt_phn_call-dt_random;
	wdraw_day=dt_wdraw_cons-dt_random;
		
	format center center. wdraw wdraw. died died. on_study on_study. comp_study comp_study. lost_to_followup lost_to_followup.;
	keep id center wdraw died on_study comp_study lost_to_followup dt_random /*dt_lost_last_contact*/ 
	dt_last_contact lost_day day_study phone_6mo dt_phn_call dt_wdraw_cons wdraw_day phone_6mo;
run;


proc print;
var id center phone_6mo comp_study wdraw died lost_to_followup lost_day dt_random dt_wdraw_cons wdraw_day;
format dt_lost_last_contact mmddyy10.;
run;





data temp;
    set pat_status;
    if comp_study;
    if day_study>180 then day_study=180;
    if day_study<0 then day_study=.;
run;
/*
proc print;
var id phone_6mo dt_phn_call dt_random day_study;
run;
*/

proc means data=temp n median min max;
var day_study;
run;




ods pdf file="pat_listing.pdf" style=journal;
proc print data=pat_status noobs label style(data)=[just=center];
by center;
id id;
var center wdraw died on_study comp_study lost_to_followup;
run;
ods pdf close;


ods output Freq.Table1.CrossTabFreqs=tab1(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table2.CrossTabFreqs=tab2(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table3.CrossTabFreqs=tab3(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table4.CrossTabFreqs=tab4(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table5.CrossTabFreqs=tab5(drop=table  _TYPE_  _TABLE_ Missing);

proc freq data=pat_status;
	table center*(wdraw died on_study comp_study lost_to_followup)/nopercent nocol norow;
run;

data tab_n;
	set tab1(rename=(frequency=n));
	where wdraw=.;
	if center=. then center=100;
	keep center n;
run; 



%macro tab(var,index);
data tab&index;
	set tab&index;
	*item=&index;
	if center=. then center=100;
	where &var=1;
	drop &var;
	rename frequency=&var;
run;

proc sort data=tab&index; by center;run;
%mend tab;


%tab(wdraw,1);
%tab(died,2);
%tab(on_study,3);
%tab(comp_study,4);
%tab(lost_to_followup,5);


data glnd.stat;
	merge tab1 tab2 tab3 tab4 tab5 tab_n; by center;

  length gr $ 25;


/*
  if center=1 then gr="Emory (n="||put(n,2.)||")";
  if center=2 then gr="Miriam (n="||put(n,2.)||")" ;
  if center=3 then gr="Vanderbilt (n="||put(n,2.)||")";
  if center=4 then gr="Colorado (n="||put(n,2.)||")";
  if center=5 then gr="Wisconsin (n="||put(n,2.)||")";
  if center=100 then gr="Total (n="||put(n,3.)||")"; 
*/
	format center center.;
	label wdraw='Withdrew Consent'
         died='Died'
			on_study='On Study'
	 		comp_study='Completed Study'
			lost_to_followup='Lost to Follow-up'
			center='Center'
			gr='Center'
			n='Total'
	;

run;


title "Patient Study Status";

ods pdf file="pat.pdf" style=journal;

proc print data=glnd.stat noobs label split="*" style(data)=[just=center];
*id center;

var center wdraw died comp_study lost_to_followup n;

run;
