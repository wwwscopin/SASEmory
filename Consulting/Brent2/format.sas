libname library "H:/SAS_Emory/Consulting/Brent2";		

proc format library=library; 
value group 
		1="DEMOGRAPHICS/GENERAL INFORMATION"
		2="SOCIOECONOMIC STATUS/ACCESSING HEALTHCARE"
		3="MEDICATION ADHERENCE"
		4="ALTERNATIVE TREATMENTS/SPIRITUAL FACTORS"
		5="PSYCHOSOCIAL FACTORS"
		6="Feeling in the last four weeks"
		7="Share with ?"
		;

value idx 0="Control" 1="CASE";
value tdf 0="No TDF" 1="TDF";

value demo
		1="Age"
		2="Gender"
		3="Race/Ethnicity "
		4="Ethnic group and/or Nationality for Black"
		5="Last grade of school/education"
		6="Can you read?"
		7="Can you understand?"
		8="Can you speak?"
		9="Any problems with --"
		;

value soci
		1="Have an income?"
		2="How many people (other than yourself) do you support?"
		3="Employment Status"
		4="What type of work?"
		5="Receive money from other source?"
		6="What sources?"
		7="Where do you stay?"
		8="Ever lived in an informal settlement since starting ARVs?"
		9="Current living arrangement"
		10="How many people live with you?"
		11="What facility?"
		12="What wall?"
		13="What floor?"
		14="Do you have --?"
		15="Enough food in past 4weeks?"
		16="Amount of food in past 4weeks?"
		17="How many times go without food?"
		18="What clinic(s) do you currently attend?"
		19="Where did you first start ARVs?"
		20="How long does it take to get to clinic?"
		21="Transport to clinic--"
		22="How do you pay for clinic and meds?"
		23="How do you feel about coming to clinic?"
		24="Heard-A healthcare worker not wanting to touch someone because they have HIV"
		25="Heard-People being treated poorly by hospital/clinic/healthcare workers because of HIV"
		26="Heard-People being rejected at hospital/clinic because of HIV"
		27="Heard-A healthcare worker talking out loud about a patient with HIV"
		28="Reasone stop you from getting to the clinic/pharmacy--Cost of visit"
		29="Reasone stop you from getting to the clinic/pharmacy--Cost of transport"
		30="Reasone stop you from getting to the clinic/pharmacy--Time off work"
		31="Reasone stop you from getting to the clinic/pharmacy--Childcare"
		32="Reasone stop you from getting to the clinic/pharmacy--Being ill"
		33="Reasone stop you from getting to the clinic/pharmacy--Family Circumstances"
		;

	value qmed

		1="How many doses have you missed in the last week"
		2="How many doses have you missed in the last month"
		3="How many doses did you take more than one hour late in the last week?"
		4="How many doses did you take more than one hour late in the last month?"
		5="How do you remember to take your meds"
		6="How do you remember to come for your drug collection appt"
		7="You were away from home--"
		8="You were busy with other things--"
		9="You forgot to take pills--"
		10="You had too many pills to takee--"
		11="You had wanted to avoid side effects --"
		12="You did not want others to see you taking ARVs--"
		13="You had a change in what you do every day--"
		/*14="You felt like the drug could hurt/harm you--"*/
		14="You fell asleep through dose time--"
		15="You felt sick or ill--"
		/*17="You felt depressed or stressed--"*/
		16="You had a problem taking pills at certain times--"
		17="You forgot to obtain meds--"
		18="You ran out of pills--"
		19="You did not have money for ARVs--"
		20="You were tired of ARVs--"
		21="You don’t like taking pills--"
		22="You have difficulty swallowing ARVs--"
		/*25="You thought you did not need more ARVs because you felt good--"
		26="Receiving treatment from Traditional Healer--" 
		27="You had too much alcohol--"
		28="You were taking street drugs--"
		29="Other--" */
		;

	value faith
		1="Do you have a religious faith?"
		2="If yes, which?"
		3="If Christian, which denomination?"
		4="How active are you in practicing your religion"
		5="Have you ever stopped your ARVs because of your religious beliefs or teachings?"
		6="Did you EVER take any Traditional Medications or Herbs"
		7="If yes, how long ago?"
		8="Did you take these medicines with your ARVs or instead of your ARVs?"
		/*9="Have you had any side effects/adverse events to any of these remedies"*/
		9="Take meds or supplements In the last 6 months? "
		10="If yes, what is/are the name(s)? "
		11="How did you feel with this medication"
		12="Use any other alternative treatment in the past 6 months?"
		13="How did you feel with this treatment?"
		14="Who first recommended you to go to an HIV clinic"
		;

	value psy
		1="Marital status"
		2="Which forms of safe sex do you practice"
		3="How often did you practice safe sex in past 6 months?"
		4="How many current partners do you have?"
		5="How many partners are currently living with you?"
		6="How many partners do you know have been tested for HIV?"
		7="How many partners do you know are HIV positive?"
		8="How many partners do you know are taking ARVs?"
		9="How many biological children do you have?"
		10="How many children are you currently taking care of?"
		11="How many children in your care do you know have been tested for HIV?"
		12="How many children in your care do you know are HIV positive?"
		13="How many additional family members do you know are HIV positive?"
		14="How many have died?"
		15="Who knows you are living with HIV?"
		16="Who is the person most emotionally supportive to you?"
		17="Do they live with you?"
		18="Do you have someone who is a treatment supporter/partner"
		19="If yes, what is your relationship?"
		20="Have you ever been hurt by someone?"
		21="How have you been hurt?"
		22="Has anyone ever physically forced you to have sex even when you did not want?"
		23="--Whom?"
		24="Has anyone ever forced you to perform any sexual acts you did not want to do?"
		25="--Whom?"
		26="When was the last time you were hurt sexually?"
		27="Did you use street drugs in the past 4 weeks?"
		28="How often do you drink alcohol?"
		29="What type of alcohol?"
		/*30="Have you ever felt you should cut down on your drinking? "
		31="Have people annoyed you by criticizing your drinking?"
		32="Have you ever felt bad or guilty about your drinking?"
		33="Have you ever had a drink first thing in the morning to steady your nerves or get rid of a hangover?" */
		30="Do you smoke"
		31="What do you smoke?"
		32="How much education do you feel you have received about HIV"
		33="How many pre-ARV training sessions did you receive?"
		34="Were these sessions helpful"
		35="In the last 12 months, how many 1-on-1 adherence counseling sessions have you received?"
		36="Were these sessions beneficial?"
		37="Would you like any additional support for your illness"
		38="If ”Yes”, what other forms of support would you like to receive"
		39="Do you feel you have access to all the services you need"
		40="If “No”, which services would you like to access more "
		;

	value scale
		1="During the past month, about how often did you feel tired out for no good reason? "
		2="During the past month, about how often did you feel nervous? "
		3="So nervous that nothing could calm you down?"
		4="During the past month, about how often did you feel hopeless? "
		5="During the past month, about how often did you feel restless or fidgety? "
		6="So restless you could not sit still? "
		7="During the past month, about how often did you feel sad or depressed? "
		8="So depressed that nothing could cheer you up? "
		9="During the past month, about how often did you feel that everything was an effort? "
		10="During the past month, about how often did you feel worthless? "
		11="TOTAL SCORE"
		12="Is TOTAL SCORE = 20 OR HIGHER"
		13="Would you like me to share your responses with your adherence counselor?"
		14="Would you like me to share your responses with your doctor?"
		;


	value Gender 
		0="Male" 1="Female" .="Unknown";

	value clinical
		1="Disease with AIDS on"
		2="Disease without AIDS"
		3="Current ARV"
		4="ARV prior to enrollment(days)"
		5="CD4"
		6="VL"
		7="Religion"
		8="Triditional Herb Meds"
		9="If 'Yes', then When?"
		10="Marital Status"
		11="Alcohol";

	value yn 0="No" 1="Yes" -77="NA(-77)";
	value race 1="Black" 2="Colored"  3="White" 4="Indian";
	value eth 1="Zulu" 2="Xhosa" 3="Malawian" 4="Other" -77="NA";
	value lang 1="Zulu"  2="English"  3="Other" 4="No" 12="Zulu/English"  13="Zulu/Other" 23="English/Other" 123="Zulu/English/Other";
	value Employ 1="Full time"  2="Employed part-time"   3="Self-employed"   4="Attending school"    5="Disabled"
		6="Unemployed seeking work"  7="Unemployed not seeking work"    8="Retired" 58="Disabled/Retired";

	value sense 1="Hearing" 2="Seeing"  3="Voice"  4="None" 12="Hearing/Seeing";
	value reside 1="House"  2="Flat"  3="Shack" 4="Other";
	value live 1="Own home"  2="Rent"   3="Stay with family"   4="Stay with friends" 5="Stay with employer";
	value fac 1="Electricity" 2="Working radio" 3="Toilet indoors" 4="Television" 5="Tap water indoors" 6=" None of these";
	value tool 1="Car or bakkie" 3="Motorcycle" 2="Bicycle" 4="None of these";
	value food 1="Never"   2="Rarely (1-2 times/mo)"  3="Sometimes (3-10 times/mo)"  4="Often  (>10 times/mo)";
	value amount 1="Enough to eat" 2="Sometimes not enough to eat" 3="Often not enough to eat";
	value nofood 1="Never" 2="Rarely (1-2 times/mo)"  3="Sometimes (3-10 times/mo)" 4="Often (>10 times/mo)";
	value clin 1="Sinikithemba"    2="Other" 12="Sinikithemba/Other";
	value arv 1="Sinikithemba (Ridge House)"   2="Siyaphila Inpatient Ward"  3="Private Provider" 4="DOH Clinic" 5="Other";
	value tclin 1="Less than 30 min"  2="30-60 min"   3="More than 60 min";
	value tranclin 1="Your car"  2="Friend/relative car" 3="Meter Taxi"   4="Mini Bus/Bus"  5="Walk"  6="Other" 
			24="Friend/relative car or Mini Bus/Bus";

	value payclin 1="Sponsor"	2="Grant"	3="Employer" 4="Self-pay"	5="Family Member" 6="Spouse" 7="Other";
	value feelclin 1="Pleased"  2="Worried" 3="Ashamed"  4="Neutral"  5="Other";
	value freq  0="Never" 1="Rarely" 2="Sometimes" 3="frequently";

	value rem_med 1="Pill box"   2="Clock/Watch alarm"  3="Cell phone" 4="Partner" 5="Calendar"  6="Chart"  
			7="Media (TV/Radio)" 8="Daily Schedule"  9="Other";

	value rem_apt 1="Appointment card" 2="Partner/friend" 3="Cellphone"  4="Other"
			12="Appointment card or Partner/friend" 13="Appointment card or Cellphone" 14="Appointment card or other";

	value pra_rel 1="Very active"  2="Somewhat active"  3="Not active"  4="N/A";
 	value when 1="< 1 week"  2="1 wk to 1 month"  3=">1 month to 6 mos"  4="> 6 mos" 5="N/A";
	value how_med 1="with ARVs"  2="Instead of ARVs" -77="NA";
	value how_feel 1="The same"   2="Better"  3="Worse" 4="N/A";
	value recom 1="Provider (doctor or nurse)" 2="Traditional Healer (Isangoma)"  3="Herbalist (Inyanga)" 4="Friend" 
		5="Family"   6="Member of religious faith"  7="Other" 45="Friend/Family";

	value mar 1="married" 2="divorced" 3="single living with partner" 4="single not living with partner"
			  5="single no partner"  6="widowed" 246="divorced/single not living with partner/widowed";

	value safe_sex 1="Abstinence"  2="Condoms"  21="Condoms-Male" 22="Condoms-Female"  3="Pull out"  4="None" 5="Other" -99="NA(-99)";
	value how_oft 1="Always(100%)" 2="Often(>50%)" 3="Sometimes(less than 50%)"  4="Rarely(less than 25%)"  5="Never(0%)" -99="NA(-99)";
	value who_hiv 1="Partner/spouse)"	2="Family member(s)" 3="Friends" 4="Employer" 5="Other" 45="Employer/Other";
	value have_hurt 1="Frequently(>3x/wk)" 2="Sometimes(>1x/mo)"  3="Rarely(>1x/yr)" 4="Never";
	value how_hurt  1="physical" 2="sexual"  3="verbal"   4="psychological"   5="other" 6="N/A"  12="physical/sexual"  13="physical/verbal";
	value force_sex 1="Often" 2="Sometimes" 3="Not at all" 4="N/A";
	value whom 1="Partner"	2="Other" -77="NA(-77)";
	value when_las 1="<1 mo"  2="1-6 mo" 3=">6-12 mo"   4="> 12 mo" 5="N/A";
	value alcohol 1="Daily" 2="4-5 times/week" 3="Weekends" 4="3-4 times/month" 5="Once/month" 6="< Once/month"	7="Never";
	value typ_alc 1="Mqombothi"  2="Cider" 3="Wine" 4="Spirits" 5="Beer"	6="N/A" 245="Cider/Spirits/Beer";
	value what_smoke 1="Cigarettes" 2="Cigars"	3="Pipe" 	4="Dagga"	5="N/A";
	value hiv_edu 1="Much"  2="Some"  3="Little" 4="None";
	value pre_arv 1="0"  2="1-2"  3="3-5"  4=">5";
	value adh_coun 1="1" 2="3" 3="3" 4="4" 5="5" 6="5-10" 7="10+";
	value what_ser 1="Health Education" 2="Counseling" 3="Doctors" 4="Pharmacy" 5="Physiotherapy" 6="Social Work"
			7="Psychiatry/Psychology" 8="Prayer/Minister" 9="Other" -77="NA(-77)" 78="Psychiatry/Psychology or Prayer/Minister";

	value tt 1="None of the time"	2="A little of the time" 3="Some of the time" 4="Most of the time"	5="All of the time";
	value aids 	1="Diag/Dis 1" 2="Num_Epis 1" 3="Cur_Diag 1" 4="Diag/Dis 2" 5="Num_Epis 2" 6="Cur_Diag 2" 
				7="Diag/Dis 3" 8="Num_Epis 3" 9="Cur_Diag 3";

	value med 	1="Med 1" 2="Med 2" 3="Med 3" 4="Med 4" 5="Med 5" 6="Med 6" 7="Med 7" 8="Med 8" 9="Med 9" 
				10="Med 10" 11="Med 11" 12="Med 12" 13="Med 13" 14="Med 14" 15="Med 15" 16="Med 16"
				17="Med 17" 18="Med 18" 19="Med 19" 20="Med 20" 21="Med 21" 22="Med 22";

	value curarvs 1="ARVS 1" 2="ARVS 2"	3="ARVS 3"; 
	value prearvs 1="ARVS 1" 2="ARVS 2"	3="ARVS 3" 4="ARVS 4" 5="ARVS 5";
	value lab     1="CD4 1" 2="VL 1" 3="CD4 3" 4="VL 3" 5="CD4 3" 6="VL 4" 7="CD4 4" 8="VL 4" 9="CD4 5" 10="VL 5";	
	value symptom  1="FATIGUE" 2="FEV_CHIL" 3="FEEL_DIZ" 4="PAIN_TIN" 5="TRO_REM" 6="NAUS_VOM" 7="DIARRHEA" 8="SAD_DEPR"
				10="NERV_ANX" 11="DIF_SLPN" 12="SKIN_PRB" 13="COUGH" 14="HEADACHE" 15="LOSS_APE" 
				16="BLOATING" 17="MUSC_ACH" 18="PROB_SEX" 19="CHA_BODY" 20="PROB_WEI" 21="CHA_HAIR" 22="OTHER";

	value last 1="CAU_ARVS" 2="HAR_ARVS" 3="ADD_COMM";
	value gp 1="AIDS_CON" 2="NON_AIDS" 3="CON_MEDS" 4="CUR_ARVS" 5="PRE_ARVS" 6="LAB_DATA" 7="SYMPTOMS" 8="Other" 9="Adherence";
	value tq 1="Dispens Per Day" 2="Tertile by 80%-95%";
	value adh 1="<80%" 2="80-95%" 3=">=95%";
run;
