%let path=H:\SAS_Emory\Consulting\Blake\;
filename stinger "&path.stingerResults.xls";

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
	set tmp;
	if _n_<305;
	i=_n_;
	BMI=weight/2.2/(height*0.0254)**2;

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
		9="Do you paticipate in a neck strengthing program?"
		10="--Has the program helped your neck strength?"
		11="Have you ever had a spinal injury?"
		12="Have you ever had any orthopedic injuries?"
		13="Have you been diagnosed with a spinal cord abnormality?"
		14="Have you been diagnosed with a herniated disc?"
		15="Have you ever had a condition called 'transient quadriplegia'?"
		16="Have you been diagnosed with any other neurologic disorders?"
		17="Have you had a concussion?"
		18="--Concussion number"
		/*19="Have you ever had a 'stinger' or 'burner' injury where after contact you feel a burning/stinging senstation tavelling from your neck down your arm into your fingers?"*/
		19="Have you ever had a 'stinger' or 'burner' injury?"
		20="Did the injury happen in a game or pratice?"
		/*21="--Where did you have the most pain from the injury?"*/
		21="How long after contact did the pain start?"
		22="How long did the pain last?"

		23="Did you feel weakness in your arm or hand after the injury?"
		/*24="--Where was the weakness?"*/
		24="--How long after contact did the weakness start?"
		25="--How long did the weakness last?"

		/*28="--Did you feel numbness or a 'pins and needles' sensation in your arm after the injury?"*/
		26="Did you feel numbness or a 'pins and needles' sensation?"
		27="--How long after contact did the numbness start?"
		28="--How long did that last?"
		/*29="==What area went numb?"*/

		/*30="--Did you stretch your neck and arms before the game or practice when you had the injury?"*/
		29="Did you stretch your neck and arms before the game or practice?"
		30="What Surface were you playing on?"
		31="What position where you playing at the time of the injury?"
		32="At the time of the injury were you"
		33="Were you wearing any neck protective gear at the time of your injury?"
		34="--If Yes, what type?"
		35="What happened to cause the injury?"
		36="Did you tell a coach or team medical personnel about the injury?"
/*
		37="==Who evaluated your injury?"
		37="==Who treated your injury?"
		37="==What did they have you do for immediate treatment?"
*/
		37="--Did you return to competition the same day?"
		38="==If Yes, How long after the injury did you return to competition?"
		39="==If No, How long after the injury did you return to competition?"

		40="Did you get physical theray for the injury?"
		41="--If Yes, was the physical therapy directed at strengthing, stretching or both?"
		42="Did you wear protective neack geat for the next game or practice?"
		43="--If Yes, what type?"
		44="How many stingers have you had in your career?"
		45="Did you play any other sports?"
		46="Have you ever had a stinger in any of the other sports?"
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
		8="Wide reciever"
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


%macro pos(data);
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

%pos(tmp);

proc contents;run;

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
			table &var/norow nocol;
			ods output OneWayFreqs = tab&i;
		run;
		*ods trace off;

	data tab&i;
		set tab&i;
		item=&i;
		if &var=. then delete;
		rename &var=code;
	run;

	data &out;
		length item0 $100 code0 $50;
		set &out tab&i;
		f=frequency/&n*100;
		nf=frequency||"("||put(f,5.1)||"%)";
		item0=put(item, item.); 
		if item=1 then do; code0=put(code, level.); end;
		if item in(2,18,44) then do; code0=put(code, yy.);    end;
		if item in(4,31) then do; code0=put(code, pos.);   end;
		if item in(6,34,43) then do; code0=put(code, gear.);  end;
		if item in (3,5,7,8,9,10,11,12,13,14,15,16,17,19,23,26,29,33,36,37,40,42,45,46) then do; code0=put(code, yn.);  end;
		if item=20 then do; code0=put(code, stinger.);  end;
		if item in(21,24,27) then do; code0=put(code, set.);  end;
		if item=22 then do; code0=put(code, pain.);  end;
		if item=25 then do; code0=put(code, weak.);  end;
		if item=28 then do; code0=put(code, numb.);  end;
		if item=30 then do; code0=put(code, surface.);  end;
		if item=32 then do; code0=put(code, injury_activity.);  end;
		if item=35 then do; code0=put(code, gear_injury.);  end;
		if item=38 then do; code0=put(code, tt.);  end;
		if item=39 then do; code0=put(code, dd.);  end;
		if item=41 then do; code0=put(code, pt.);  end;

		keep code code0 frequency percent item item0 f nf;
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
			table &var/norow nocol;
			ods output OneWayFreqs = tab&i;
		run;
		*ods trace off;

	data tab&i;
		set tab&i;
		item=&i;
		if &var=. then delete;
		rename &var=code;
	run;

	data &out;
		length item0 $100 code0 $50;
		set &out tab&i;
		f=frequency/&n*100;
		nf=frequency||"("||put(f,5.1)||"%)";
		%if &out=pos %then %do; item=4; item0="What position(s) do you play?"; code0=put(code, pos.); %end;
		%if &out=pain %then %do; item=21; item0="Where did you have the most pain from the injury"; code0=put(code, painp.); %end;	
		%if &out=weak %then %do; item=24; item0="--Where was the weakness?"; code0=put(code, weakp.); %end;	
		%if &out=numb %then %do; item=29; item0="--What area went numb?"; code0=put(code, numbarea.); %end;	
		%if &out=eval %then %do; item=37; item0="--Who evaluated your injury?"; code0=put(code, med.); %end;
		%if &out=trt %then %do; item=37;  item0="--Who treated your injury?"; code0=put(code, med.); %end;	
		%if &out=immedtrt %then %do; item=37; item0="--What did they have you do for immediate treatment?"; code0=put(code, trt.); %end;
		
		keep code code0 frequency percent item item0 f nf;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend pos;

%let varlist1=current_level_of_competition years_played formal_instruction primary_position protective_neck_gear type_gear 
gear_reason gear_effective strengthening_program strength_program_helped spinal_injury orthopedic_injury spinal_cord_abnormality
herniated_disc transient_quadriplegia neurologic_disorders concussion concussion_number stinger stinger_setting pain_onset 
pain_duration weakness weakness_onset weakness_duration numb numb_onset numb_duration stretch surface position_at_injury 
injury_activty gear_injury gear_type_injury injury_mechanism medical return_same_day return_time_same return_time_different_day
PT PT_type next_time_gear next_time_gear_type num_stingers other_sports stinger_other_sports;

%let varlist2=current_level_of_competition years_played formal_instruction primary_position protective_neck_gear type_gear 
gear_reason gear_effective strengthening_program strength_program_helped spinal_injury orthopedic_injury spinal_cord_abnormality
herniated_disc transient_quadriplegia neurologic_disorders concussion concussion_number other_sports stinger_other_sports;


%tab(stinger, stinger_tab, &varlist1);
%let varpos=pos1 pos2 pos3 pos4 pos5 pos6 pos7 pos8 pos9 pos10; 
%pos(stinger, pos, &varpos);

%let varpain=pain1 pain2 pain3 pain4 pain5; 
%pos(stinger, pain, &varpain);

%let varweak=wk1 wk2 wk3 wk4; 
%pos(stinger, weak, &varweak);

%let varnumb=na1 na2 na3 na4 na5 na6 na7 na8; 
%pos(stinger, numb, &varnumb);

%let vareval=eval1 eval2 eval3; 
%pos(stinger, eval, &vareval);

%let vartrt=trt1 trt2 trt3; 
%pos(stinger, trt, &vartrt);

%let varimmedtrt=immed_trt1 immed_trt2 immed_trt3; 
%pos(stinger, immedtrt, &varimmedtrt);

data stinger_tab;	
	set stinger_tab(where=(item in(1,2,3))) pos 
		stinger_tab(where=(item in(4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20))) pain
		stinger_tab(where=(item in(21,22,23))) weak
		stinger_tab(where=(item in(24,25,26,27,28))) numb
		stinger_tab(where=(item in(29,30,31,32,33,34,35,36))) eval trt immedtrt 
		stinger_tab(where=(item in(37,38,39,40,41,42,43,44,45,46)));
	if item=5  and code=1 then do; call symput("ngear",compress(frequency));end;
	if item=9  and code=1 then do; call symput("nstreng",compress(frequency));end;
	if item=17 and code=1 then do; call symput("nconcussion",compress(frequency));end;
	if item=19 and code=1 then do; call symput("nstinger",compress(frequency));end;
	if item=23 and code=1 then do; call symput("nweak",compress(frequency));end;
	if item=26 and code=1 then do; call symput("nnumb",compress(frequency));end;
	if item=33 and code=1 then do; call symput("ninjury",compress(frequency));end;
	if item=36 and code=1 then do; call symput("ntell",compress(frequency));end;
	if item=37 and code=1 then do; call symput("nreturn",compress(frequency));end;
	if item=40 and code=1 then do; call symput("npt",compress(frequency));end;
	if item=42 and code=1 then do; call symput("nnext",compress(frequency));end;
	if item=45 and code=1 then do; call symput("nother",compress(frequency));end;
run;

data stinger_tab;	
	length nf $25;
	set stinger_tab;
	if item in(6,7,8) then do; f=frequency/&ngear*100; nf=frequency||"/"||"&ngear"||"("||put(f,5.1)||"%)"; end;
	if item=10 then do; f=frequency/&nstreng*100; nf=frequency||"/"||"&nstreng"||"("||put(f,5.1)||"%)"; end;
	if item=18 then do; f=frequency/&nconcussion*100; nf=frequency||"/"||"&nconcussion"||"("||put(f,5.1)||"%)"; end;
	if item in(20,21,22,23,26,29,30,31,32,33,35,36,40,42,44) then do; f=frequency/&nstinger*100; nf=frequency||"/"||"&nstinger"||"("||put(f,5.1)||"%)"; end;
	if item in(24,25) then do; f=frequency/&nweak*100; nf=frequency||"/"||"&nweak"||"("||put(f,5.1)||"%)"; end;
	if item in(27,28,29) then do; f=frequency/&nnumb*100; nf=frequency||"/"||"&nnumb"||"("||put(f,5.1)||"%)"; end;
	if item in(34) then do; f=frequency/&ninjury*100; nf=frequency||"/"||"&ninjury"||"("||put(f,5.1)||"%)"; end;
	if item in(37) then do; f=frequency/&ntell*100; nf=frequency||"/"||"&ntell"||"("||put(f,5.1)||"%)"; end;
	if item in(38,39) then do; f=frequency/&nreturn*100; nf=frequency||"/"||"&nreturn"||"("||put(f,5.1)||"%)"; end;
	if item in(41) then do; f=frequency/&npt*100; nf=frequency||"/"||"&npt"||"("||put(f,5.1)||"%)"; end;
	if item in(43) then do; f=frequency/&nnext*100; nf=frequency||"/"||"&nnext"||"("||put(f,5.1)||"%)"; end;
	if item in(46) then do; f=frequency/&nother*100; nf=frequency||"/"||"&nother"||"("||put(f,5.1)||"%)"; end;
	if code=. then delete;
run;

data stinger_tab;
	set stinger_tab;
	where item in(20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44);
run;

proc sort data=stinger_tab; by item;run;

data stinger_tab;
	set stinger_tab; by item ;
	output;
	if last.item then do; tmp=item; Call missing( of _all_ ) ; item=tmp; output; end;
run;
proc print data=stinger_tab;run;

options /*orientation=landscape*/ ls=120 nobyline;
ods rtf file="stinger_only.rtf" style=journal startpage=no;
proc print data=stinger_tab split="*" noobs label style(data)=[just=left]; 
	title "Questonnarie for Player with Stinger Only (n=&yes)";
	by item0 notsorted;
	id item0;
	var code0;
	var nf/style(data)=[just=right];
	label item0="Question"
		code0="Resutls"
		nf="N(%)";
run;
ods rtf close;
