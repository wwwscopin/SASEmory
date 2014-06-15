options nofmterr;
%let path=H:\SAS_Emory\Consulting\Blake\;
filename stinger "&path.stingerResults.xls";
%let pm=%sysfunc(byte(177));  

PROC IMPORT OUT= tmp 
            DATAFILE= stinger 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents short varnum;run;
*/
data tmp;
	set tmp(rename=(stinger_other_sports=stinger_other_sports0));
	if _n_<305;
	i=_n_;
	BMI=weight/2.2/(height*0.0254)**2;
	stinger_other_sports=stinger_other_sports0+0;

	keep i height weight BMI current_level_of_competition years_played formal_instruction positions_played
primary_position protective_neck_gear type_of_neck_gear neck_gear_reason neck_gear_effective
strengthening_program strength_program_helped spinal_injury orthopedic_injury
orthopedic_injury_types spinal_cord_abnormality herniated_disc transient_quadriplegia
neurologic_disorders concussion concussion_number stinger stinger_setting pain_location
pain_onset pain_duration weakness weakness_location weakness_onset weakness_duration numb
numb_onset numb_duration numb_area stretch surface position_at_injury injury_activty
injury_activity_other gear_injury gear_type_at_injury injury_mechanism injury_mechanism_other
medical evaluator treated immediate_treatment return_same_day return_time_same
return_time_different_day PT PT_type next_time_gear next_time_gear_type
next_time_gear_type_other num_stingers other_sports stinger_other_sports stinger_in_which_sports
;

/*
primary_position1 BMI weight_kg_ height_m_ bmiStinger BMInonStinger stingerCount nonStingerCount
stingerCount1 stingerCount2 stingerCount3 stingerCount4 stingerCount5 stingerCount6
stingerCount7 stingerCount8 stingerCount9 stretch1 strengthening_1_strengthening_an F80 F81;
*/
	call symput("n", compress(_n_));
	format BMI 5.2;
run;
proc contents;run;
proc print data=tmp;
var stinger_other_sports;
run;

proc freq data=tmp;
	table stinger;
	ods output OneWayFreqs =wbh;
run;

data _null_;
	set wbh;
	if stinger=1 then call symput("yes", compress(frequency));
	if stinger=2 then call symput("no", compress(frequency));
run;
%put &yes;

proc format;
	value item
		1="What is your current level of competition?"
		2="How many years have you played football?"
		3="Have you had formal instruction in the proper way to tackle?"
		/*4="What position(s) do you play?"*/
		4="What position do you play the most?"
		5="Do you routinely wear any protective neck gear?"
		6="--What type?"
		7="--Do you wear this gear because of the stingers that you've experienced?"
		8="--Is this protective gear effective at limiting the occurance of your stingers?"
		9="Do you participate in a neck strengthening program?"
		10="--Has the program helped your neck strength?"
		11="Have you ever had a spinal injury?"
		12="Have you ever had any orthopedic injuries?"
		13="Have you been diagnosed with a spinal cord abnormality?"
		14="Have you been diagnosed with a herniated disc?"
		15="Have you ever had a condition called 'transient quadriplegia'?"
		16="Have you been diagnosed with any other neurologic disorders?"
		17="Have you had a concussion?"
		18="--Concussion number"

		19="Did you play any other sports?"
		20="--Have you ever had a stinger in any of the other sports?"
		50="Height(inches)"
		51="--Mean &pm SD"
		52="--Median"
		53="--Interquartile Range"
		54="Weight(Lbs)"
		55="--Mean &pm SD"
		56="--Median"
		57="--Interquartile Range"
		58="BMI"
		59="--Mean &pm SD"
		60="--Median"
		61="--Interquartile Range"
		;


	value level
		1="High school varsity athlete"
		2="Collegiate athelete"
		3="Professional athelete";

	value yn
		1="Yes"
		2="No";

	value stinger
		1="Game"
		2="Practice";

	value pos
		1="Offensive Line"
		2="Defensive Line"
		3="Linebacker"
		4="Defensive secondary"
		5="Running back"
		6="Quarter back"
		7="Kicker"
		8="Wide receiver"
		9="Tight end"
		10="Snapper";

	value gear
		1="Cowboy collar"
		2="Neck roll"
		3="Other";

	value painp
		1="Shoulder"
		2="Arm"
		3="Forearm"
		4="Hand"
		5="Neck";

	value set
		1="Immediate"
		2="Less than 5 mins"
		3="More than 5 mins";

	value pain
		1="Less than 1 min"
		2="1-5 mins"
		3="6-30 mins"
		4="30-60 mins"
		5="1-24 hours"
		6="1-7 days"
		7="I still have pain";

	value weakp
		1="Shoulder"
		2="Arm"
		3="Forearm"
		4="Hand";

	value weak
		1="Less than 1 min"
		2="1-5 mins"
		3="6-30 mins"
		4="30-60 mins"
		5="1-24 hours"
		6="1-7 days"
		7="I still have weakness";

	value numb
		1="Less than 1 min"
		2="1-5 mins"
		3="6-30 mins"
		4="30-60 mins"
		5="1-24 hours"
		6="1-7 days"
		7="I still have numbness";

	value numbarea
		1="Shoulder"
		2="Arm"
		3="Forearm"
		4="Thumb"
		5="Index finger"
		6="Long finger"
		7="Ring finger"
		8="Little finger";

	value surface
		1="Natural grass"
		2="Artificial surface";

	value injury_activity
	 	1="Making a tackle"
		2="Making a block"
		3="Being tackled"
		4="Being blocked"
		5="Other";

	value gear_injury
		1="Neck bent back"
		2="Neck bent forward"
		3="Neck bent sideways"
		4="Other"
		5="Shoulder displaced";

	value med
		1="Doctor"
		2="Trainer"
		3="Physical therapist";

	value trt
		1="Ice"
		2="Anit-inflammatory medicine"
		3="Medrol dose pack"
		4="Physical therapy"
		5="Other";

	value tt
		1="Immdeiately (less than 5 mins)"
		2="5-10 mins"
		3="10-30 mins"
		4="30+ mins";

	value dd
		1="1 day"
		2="2 days"
		3="3 days"
		4="4 days-1 week"
		5="Longer than 1 week";

	value pt
		1="Strengthening"
		2="Stretching"
		3="Both";

	value sport
		1="Basketball"
		2="Baseball"
		3="Socer"
		4="Track"
		5="Other";

	value yy
		1="1" 2="2"	3="3" 4="4" 5="5" 6="6"	7="7" 8="8" 9="9" 10="10+";

	value group
		0="Overall"
		1="Stigner=Yes"
		2="Stinger=No" 
		;
	value var
		1="Height"
		2="Weight"
		3="BMI" 
		;
run;


%macro wbh(data);
	data stinger;
		set  &data;
		gear_type_injury= gear_type_at_injury+0;
		gear_reason=neck_gear_reason+0; gear_effective=neck_gear_effective+0;
		type_gear=type_of_neck_gear+0;

		%do i=1 %to 9;
			if find(positions_played,"&i") then pos&i=&i; 
			if find(numb_area ,"&i") then na&i=&i; 
		%end;
		if find(positions_played,"10") then pos10=10; 
		if find(numb_area,"9") then do; na1=1; na2=2; na3=3; na4=4; na5=5;  na6=6; na7=7;  na8=8;  end;

		%do i=1 %to 5;
			if find(pain_location,"&i") then pain&i=&i; 
			if find(immediate_treatment,"&i") then immed_trt&i=&i; 
		%end;

		%do i=1 %to 4;
			if find(weakness_location,"&i") then wk&i=&i; 
		%end;

		%do i=1 %to 3;
			if find(evaluator,"&i") then eval&i=&i; 
			if find(treated,"&i") then trt&i=&i; 
		%end;
			if evaluator=4 then do; eval1=1; eval3=3; end;
			if evaluator=5 then do; eval1=1; eval2=2; eval3=3; end;
			if treated=4 then do; trt1=1; trt3=3; end;
			if treated=5 then do; trt1=1; trt2=2; trt3=3; end;
		output;

		format 
		current_level_of_competition level. pos1-pos10 primary_position position_at_injury pos. 
		type_gear gear_type_injury next_time_gear_type gear. pain1-pain5 painp. 
		formal_instruction protective_neck_gear gear_reason gear_effective strengthening_program strength_program_helped
		spinal_injury orthopedic_injury spinal_cord_abnormality herniated_disc transient_quadriplegia neurologic_disorders 
		concussion stinger weakness numb stretch gear_injury medical return_same_day pt next_time_gear other_sports 
		stinger_other_sports yn.
		pain_onset weakness_onset numb_onset set. numb_duration numb.
		pain_duration pain. wk1-wk4 weakp. weakness_duration weak.  
		pain1-pain5 painp.
		na1-na9 numbarea.
		stinger_setting stinger.
		surface surface.
		injury_activty injury_activity.
		injury_mechanism
		eval1-eval3 trt1-trt3 med.
		immed_trt1-immed_trt5 trt.
		return_time_same tt.
		return_time_different_day dd.
		PT_type pt.
		years_played concussion_number yy.;
		;

		drop  gear_type_at_injury immediate_treatment evaluator treated numb_area positions_played type_of_neck_gear
		neck_gear_reason neck_gear_effective pain_location weakness_location;
	run;
%mend;

%wbh(tmp);

/*
proc freq; 
	table current_level_of_competition years_played formal_instruction positions_played
primary_position protective_neck_gear type_of_neck_gear neck_gear_reason neck_gear_effective
strengthening_program strength_program_helped spinal_injury orthopedic_injury
orthopedic_injury_types spinal_cord_abnormality herniated_disc transient_quadriplegia
neurologic_disorders concussion concussion_number stinger stinger_setting pain_location
pain_onset pain_duration weakness weakness_location weakness_onset weakness_duration numb
numb_onset numb_duration numb_area stretch surface position_at_injury injury_activty
injury_activity_other gear_injury gear_type_at_injury injury_mechanism injury_mechanism_other
medical evaluator treated immediate_treatment return_same_day return_time_same
return_time_different_day PT PT_type next_time_gear next_time_gear_type
next_time_gear_type_other num_stingers other_sports stinger_other_sports stinger_in_which_sports; 
run;
*/

*********************************************************************************************************************************;
%macro tab(data, out, varlist)/ parmbuff ;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		*ods trace on;
		proc freq data=&data;
			table &var*stinger/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		%if &i=11 or &i=16 %then %do;
		proc freq data=&data(where=(&var=2) );
 			table stinger/binomial(p=.5);exact binomial; 
			ods output binomialproptest= p&i;
		run;
		%end;
		*ods trace off;

		%if &i=11 or &i=16 %then %do;
		data p&i;
			set p&i;
			if _n_=8;
			item=&i;
			pvalue= cValue1+0;
			keep item pvalue;
		run;
		%end;
		%else %do;

		data p&i;
			XP2_FISH=.;
			set p&i;
			item=&i;
			pvalue=XP2_FISH+0; ttt=pvalue;
			if pvalue=. then pvalue= P_PCHI+0;
			
			or=_MHOR_+0; range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			/*if or=. or or=0 then do; or= _LGOR_+0;  range=put(L_LGOR,4.2)||"--"||compress(put(U_LGOR,4.2)); end;*/
			if or=. or or=0 or ttt^=. then do; or= .;  range=" "; end;
			keep item pvalue or range;
			format pvalue or 4.2;
		run;

		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue) p&i(firstobs=2 keep=item or range); by item;
		run;
		%end;

	proc sort data=tab&i; by &var;run;
	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(stinger=1) keep=&var stinger frequency  RowPercent rename=(frequency=ny)) 
		tab&i(where=(stinger=2) keep=&var stinger frequency rename=(frequency=no)); 
		by &var;

		item=&i;
		if &var=. then delete;
		fy=ny/&yes*100; 		fn=no/&no*100;
		nfy=ny||"("||put(fy,5.1)||"%)";			nfn=no||"("||put(fn,5.1)||"%)";
		rename &var=code;

		tmp=ny+no;
		rpct=ny||"/"||compress(tmp)||"("||put(rowpercent,4.1)||"%)";

		drop stinger;
	run;

	data tab&i;
		merge tab&i p&i; by item;
		if fy<5 and fn<5 then pvalue=.;
		if not first.item then do; pvalue=.; or=.; range=" ";end;
	run;

	data &out;
		length item0 $100 code0 $50;
		set &out tab&i;
		item0=put(item, item.); 
		if item=1 then do; code0=put(code, level.); end;
		if item in(2,18) then do; code0=put(code, yy.);    end;
		if item in(4) then do; code0=put(code, pos.);   end;
		if item in(6) then do; code0=put(code, gear.);  end;
		if item in (3,5,7,8,9,10,11,12,13,14,15,16,17,19,20) then do; code0=put(code, yn.);  end;

		keep code code0 item item0 ny no fy fn nfy nfn rpct or range pvalue;
		format RowPercent 5.1;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%macro pos(data, out, varlist)/ parmbuff ;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		*ods trace on;
		proc freq data=&data;
			table &var*stinger/nocol nopercent chisq ;
			ods output crosstabfreqs = tab&i;
		run;
		*ods trace off;

		proc freq data=&data(where=(&var=&i) );
 			table stinger/binomial(p=.5);exact binomial; 
			ods output binomialproptest= pp&i;
		run;

		data pp&i;
			set pp&i;
			if _n_=8;
			item=&i;
			pvalue= cValue1+0;
			keep item pvalue;
			format pvalue 4.2;
		run;
		
	proc sort data=tab&i; by &var;run;
	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(stinger=1) keep=&var stinger frequency RowPercent rename=(frequency=ny)) 
		tab&i(where=(stinger=2) keep=&var stinger frequency rename=(frequency=no)); 
		by &var;
		item=&i;
		if &var=. then delete;
		fy=ny/&yes*100; 		fn=no/&no*100;
		nfy=ny||"("||put(fy,5.1)||"%)";			nfn=no||"("||put(fn,5.1)||"%)";
		tmp=ny+no;
		rpct=ny||"/"||compress(tmp)||"("||put(rowpercent,4.1)||"%)";

		rename &var=code;
		drop stinger;
	run;

	data tab&i;
		merge tab&i /*pp&i*/; by item;
	run;


	data &out;
		length item0 $100 code0 $50;
		set &out tab&i;
		%if &out=pos %then %do; item=4; item0="What position(s) do you play?"; code0=put(code, pos.); %end;
		keep code code0 item item0 ny no fy fn nfy nfn rpct pvalue;
		format RowPercent 5.1;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend pos;


*ods listing close;

ods listing;

%let varlist1=current_level_of_competition years_played formal_instruction primary_position protective_neck_gear type_gear 
gear_reason gear_effective strengthening_program strength_program_helped spinal_injury orthopedic_injury spinal_cord_abnormality
herniated_disc transient_quadriplegia neurologic_disorders concussion concussion_number other_sports stinger_other_sports;


%tab(stinger, stinger_tab, &varlist1);
proc print data=p4;run;
proc print data=tab4;run;
%let varpos=pos1 pos2 pos3 pos4 pos5 pos6 pos7 pos8 pos9 pos10; 
%pos(stinger, pos, &varpos);

data tmp;
	set	stinger_tab(where=(item in(4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)));
	item=item+1;
run;

data stinger_tab;	
	set stinger_tab(where=(item in(1,2,3))) pos tmp;
		/*stinger_tab(where=(item in(4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)));*/
	if item=6  and code=1 then do; call symput("ngear1",compress(ny)); call symput("ngear2",compress(no));end;
	if item=10 and code=1 then do; call symput("nstreng1",compress(ny)); call symput("nstreng2",compress(no));end;
	if item=18 and code=1 then do; call symput("nconcussion1",compress(ny)); call symput("nconcussion2",compress(no));end;
	if item=20 and code=1 then do; call symput("nother1",compress(ny)); call symput("nother2",compress(no));end;
run;
%put &ngear1;

data stinger_tab;	
	length nf $25;
	set stinger_tab; by item;
	if item in(7,8,9) then do;
			fy=ny/&ngear1*100; nfy=ny||"/"||"&ngear1"||"("||put(fy,5.1)||"%)"; 
			fn=no/&ngear2*100; nfn=no||"/"||"&ngear2"||"("||put(fn,5.1)||"%)"; 
	end;
	if item=11 then do; 
			fy=ny/&nstreng1*100; nfy=ny||"/"||"&nstreng1"||"("||put(fy,5.1)||"%)"; 
			fn=no/&nstreng2*100; nfn=no||"/"||"&nstreng2"||"("||put(fn,5.1)||"%)"; 
	end;
	if item=19 then do; 
			fy=ny/&nconcussion1*100; nfy=ny||"/"||"&nconcussion1"||"("||put(fy,5.1)||"%)"; 
			fn=no/&nconcussion2*100; nfn=no||"/"||"&nconcussion2"||"("||put(fn,5.1)||"%)"; 
	end;
	if item=21 then do; 
			fy=ny/&nother1*100; nfy=ny||"/"||"&nother1"||"("||put(fy,5.1)||"%)"; 
			fn=no/&nother2*100; nfn=no||"/"||"&nother2"||"("||put(fn,5.1)||"%)"; 
	end;

	if or^=. then if fy<5 and fn<5 then do;or=.; range=" "; end;
	
	if item=3 then do; or=.; range=" "; pvalue=.; end;
	
	if item in(12,17) then do; pvalue=.; end;
	
run;

%let pm=%sysfunc(byte(177));  
%macro stat(data, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data noprint;
		class stinger;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1));
		range=put(Q1,5.1)||" - "||compress(put(Q3,5.1));
		if stinger=. then delete;
		format median 5.1;
		keep stinger mean0 median range;
	run;

	proc transpose data=tab&i out=tab&i;
		var stinger mean0 median range;
	run;

	data tab&i;
		set tab&i(rename=(col1=nfy col2=nfn));
		if _name_='stinger' then do; item=50+4*(&i-1); nfy=" "; nfn=" "; end;
		if _name_='mean0' then do; item=51+4*(&i-1); end;
		if _name_='median' then do; item=52+4*(&i-1); end;
		if _name_='range' then do; item=53+4*(&i-1); end;
		item0=put(item, item.); 
		format item item.;
		keep item item0 nfy nfn;
	run;

	proc npar1way data = &data wilcoxon;
  		class stinger;
  		var &var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		set wp&i;
		if _n_=10;
		item=50+4*(&i-1);
		pvalue=cvalue1+0;
		keep item pvalue;
	run;

	data tab&i;
		merge tab&i wp&i; by item;
	run;

	data stat;
		set stat tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
%mend stat;	
%let varlist=height weight bmi;
%stat(stinger, &varlist);

proc sort data=stinger_tab; by item;run;

data stinger_tab;
	set stinger_tab(where=(item not in(7,8,9,11,19,21))); by item ;
	output;
	if last.item then do; Call missing( of _all_ ) ; output; end;
run;

data stinger_tab;
	set stinger_tab stat; 
run;


data stinger;
	set stinger;
	if primary_position in (1,2,3,4,5,8);
run;
ods graphics on;
/*
proc logistic descending data=stinger;
	class current_level_of_competition years_played(param=ref ref=first) primary_position protective_neck_gear strengthening_program 
		 orthopedic_injury concussion other_sports/param=ref ref=last order=internal;
	model stinger= current_level_of_competition years_played primary_position protective_neck_gear strengthening_program 
		  orthopedic_injury concussion other_sports/aggregate scale=none rsquare outroc=roc1;
run;

proc logistic descending data=stinger;
	class current_level_of_competition years_played(param=ref ref=first) primary_position protective_neck_gear strengthening_program 
		  concussion/param=ref ref=last order=internal;
	model stinger= current_level_of_competition years_played primary_position protective_neck_gear strengthening_program 
		  concussion /aggregate scale=none rsquare outroc=roc1;
run;

proc logistic descending data=stinger;
	class years_played(param=ref ref=first) primary_position protective_neck_gear strengthening_program 
		  concussion/param=ref ref=last order=internal;
	model stinger= years_played primary_position protective_neck_gear strengthening_program 
		  concussion /aggregate scale=none rsquare outroc=roc1;
run;

proc logistic descending data=stinger;
	class years_played(param=ref ref=first) primary_position protective_neck_gear concussion/param=ref ref=last order=internal;
	model stinger= years_played primary_position protective_neck_gear concussion /aggregate scale=none rsquare outroc=roc1;
run;

proc logistic descending data=stinger;
	class years_played(param=ref ref=first) primary_position protective_neck_gear /param=ref ref=last order=internal;
	model stinger= years_played primary_position protective_neck_gear /aggregate scale=none rsquare outroc=roc1;
run;
*/

proc logistic descending data=stinger;
	class years_played(param=ref ref=first) primary_position /param=ref ref=last order=internal;
	model stinger= years_played primary_position /aggregate scale=none rsquare outroc=roc1;
run;
ods graphics off;

%macro orp(data,out,varlist);
data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
proc logistic descending data=&data;
	%if &var= years_played %then %do;
	class &var(param=ref ref=first)/param=ref ref=last order=internal;
	%end;

	%else %do;
	class &var/param=ref ref=last order=internal;
	%end;

	model stinger= &var;
	ods output  Logistic.OddsRatios=or&i;
	ods output  Logistic.ParameterEstimates=pv&i;
run;

data or&i;	set or&i;	id=_n_; run;
data pv&i;	set pv&i(firstobs=2);	id=_n_; run;

data orp&i;
	length effect $60;
	merge or&i pv&i; by id;
	range="["||compress(put(lowerCL,4.2))||"-"||compress(put(upperCL,4.2))||"]";
	keep effect  OddsRatioEst LowerCL UpperCL id  ProbChiSq range;
	format  OddsRatioEst 5.2 ProbChiSq 5.3; 
run;

data &out;
	set &out orp&i;
run;
	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
%end;
%mend;
%let varlist=years_played primary_position;
%orp(stinger, orp, &varlist);

options /*orientation=landscape*/ ls=120;
ods rtf file="stinger_nosub.rtf" style=journal startpage=no bodytitle;
proc print data=stinger_tab split="*" noobs label style(data)=[just=center]; 
	title "Stinger Questonnarie (n=&n)";
	by item0 notsorted;
	id item0;
	var code0/style(data)=[just=left cellwidth=1in] ;
	var nfy nfn/style(data)=[just=right cellwidth=1in] style(head)=[just=center];
	var rpct/style(data)=[just=right cellwidth=1.2in] style(head)=[just=center];
	var or range pvalue/style(data)=[just=right];
	label 
		item0="Question"
		code0="Resutls"
		rpct="Percent with *Stinger(%)"
		or="Odds Ratio"
		range="95% CI"
		nfy="Stinger=Yes * (n=&yes)"
		nfn="Stinger=No * (n=&no)"
		pvalue="*P value";
run;

proc print data=orp split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Odds Ratio";
	by effect notsorted;
	id effect;
	var OddsRatioEst range ProbChiSq/style(data)=[just=center cellwidth=1in] ;
	label 
		effect="Effect"
		OddsRatioEst="Odds Ratio"
		Range="95% CI"
		ProbChiSq="P value";
run;
ods rtf close;
