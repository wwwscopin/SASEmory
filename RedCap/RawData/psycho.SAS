%let path=H:\SAS_Emory\RedCap;
libname brent "&path.\data";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\psycho.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat marital_status best32. ;
	informat safe_sex___1 best32. ;
	informat safe_sex___2 best32. ;
	informat safe_sex___3 best32. ;
	informat safe_sex___4 best32. ;
	informat safe_sex___5 best32. ;
	informat safe_condom___1 best32. ;
	informat safe_condom___2 best32. ;
	informat safe_sex_other $500. ;
	informat practice_safe best32. ;
	informat partners $500. ;
	informat partners_live $500. ;
	informat partners_test $500. ;
	informat partners_pos $500. ;
	informat partners_arv $500. ;
	informat children $500. ;
	informat children_care $500. ;
	informat children_test $500. ;
	informat children_pos $500. ;
	informat family_hiv $500. ;
	informat family_died $500. ;
	informat knows_hiv___1 best32. ;
	informat knows_hiv___2 best32. ;
	informat knows_hiv___3 best32. ;
	informat knows_hiv___4 best32. ;
	informat knows_hiv___5 best32. ;
	informat knows_other $500. ;
	informat emotional_supp $500. ;
	informat support_live best32. ;
	informat treat_support best32. ;
	informat support_relate $500. ;
	informat abuse best32. ;
	informat abuse_type___1 best32. ;
	informat abuse_type___2 best32. ;
	informat abuse_type___3 best32. ;
	informat abuse_type___4 best32. ;
	informat abuse_type___5 best32. ;
	informat abuse_sex best32. ;
	informat abuse_whom best32. ;
	informat abuse_other $500. ;
	informat abuse_acts best32. ;
	informat abuse_acts_whom best32. ;
	informat acts_other $500. ;
	informat abuse_sex_time best32. ;
	informat drugs best32. ;
	informat drugs_specify $500. ;
	informat alcohol best32. ;
	informat alcohol_type___1 best32. ;
	informat alcohol_type___2 best32. ;
	informat alcohol_type___3 best32. ;
	informat alcohol_type___4 best32. ;
	informat alcohol_type___5 best32. ;
	informat drinking_stop best32. ;
	informat drinking_crit best32. ;
	informat drinking_guilt best32. ;
	informat drinking_morning best32. ;
	informat smoke best32. ;
	informat smoke_type___1 best32. ;
	informat smoke_type___2 best32. ;
	informat smoke_type___3 best32. ;
	informat smoke_type___4 best32. ;
	informat cigarette_num $500. ;
	informat cigar_num $500. ;
	informat pipe_num $500. ;
	informat dagga_num $500. ;
	informat hiv_educate best32. ;
	informat arv_train best32. ;
	informat train_help best32. ;
	informat train_no $500. ;
	informat session_num best32. ;
	informat session_help best32. ;
	informat session_no $500. ;
	informat support best32. ;
	informat support_form $500. ;
	informat services best32. ;
	informat services_spec___1 best32. ;
	informat services_spec___2 best32. ;
	informat services_spec___3 best32. ;
	informat services_spec___4 best32. ;
	informat services_spec___5 best32. ;
	informat services_spec___6 best32. ;
	informat services_spec___7 best32. ;
	informat services_spec___8 best32. ;
	informat services_spec___9 best32. ;
	informat services_oth $500. ;
	informat tired best32. ;
	informat nervous best32. ;
	informat nervous_rate best32. ;
	informat hopeless best32. ;
	informat restless best32. ;
	informat restless_sit best32. ;
	informat depressed best32. ;
	informat depressed_cheer best32. ;
	informat effort best32. ;
	informat worthless best32. ;
	informat total_score best32. ;
	informat arvs_difficult $5000. ;
	informat health_difficult $5000. ;
	informat hc_difficult $5000. ;
	informat share_counselor best32. ;
	informat share_doctor best32. ;
	informat comments_ref $5000. ;
	informat psychosocial_factors_complete best32. ;

	format patient_id $500. ;
	format marital_status best12. ;
	format safe_sex___1 best12. ;
	format safe_sex___2 best12. ;
	format safe_sex___3 best12. ;
	format safe_sex___4 best12. ;
	format safe_sex___5 best12. ;
	format safe_condom___1 best12. ;
	format safe_condom___2 best12. ;
	format safe_sex_other $500. ;
	format practice_safe best12. ;
	format partners $500. ;
	format partners_live $500. ;
	format partners_test $500. ;
	format partners_pos $500. ;
	format partners_arv $500. ;
	format children $500. ;
	format children_care $500. ;
	format children_test $500. ;
	format children_pos $500. ;
	format family_hiv $500. ;
	format family_died $500. ;
	format knows_hiv___1 best12. ;
	format knows_hiv___2 best12. ;
	format knows_hiv___3 best12. ;
	format knows_hiv___4 best12. ;
	format knows_hiv___5 best12. ;
	format knows_other $500. ;
	format emotional_supp $500. ;
	format support_live best12. ;
	format treat_support best12. ;
	format support_relate $500. ;
	format abuse best12. ;
	format abuse_type___1 best12. ;
	format abuse_type___2 best12. ;
	format abuse_type___3 best12. ;
	format abuse_type___4 best12. ;
	format abuse_type___5 best12. ;
	format abuse_sex best12. ;
	format abuse_whom best12. ;
	format abuse_other $500. ;
	format abuse_acts best12. ;
	format abuse_acts_whom best12. ;
	format acts_other $500. ;
	format abuse_sex_time best12. ;
	format drugs best12. ;
	format drugs_specify $500. ;
	format alcohol best12. ;
	format alcohol_type___1 best12. ;
	format alcohol_type___2 best12. ;
	format alcohol_type___3 best12. ;
	format alcohol_type___4 best12. ;
	format alcohol_type___5 best12. ;
	format drinking_stop best12. ;
	format drinking_crit best12. ;
	format drinking_guilt best12. ;
	format drinking_morning best12. ;
	format smoke best12. ;
	format smoke_type___1 best12. ;
	format smoke_type___2 best12. ;
	format smoke_type___3 best12. ;
	format smoke_type___4 best12. ;
	format cigarette_num $500. ;
	format cigar_num $500. ;
	format pipe_num $500. ;
	format dagga_num $500. ;
	format hiv_educate best12. ;
	format arv_train best12. ;
	format train_help best12. ;
	format train_no $500. ;
	format session_num best12. ;
	format session_help best12. ;
	format session_no $500. ;
	format support best12. ;
	format support_form $500. ;
	format services best12. ;
	format services_spec___1 best12. ;
	format services_spec___2 best12. ;
	format services_spec___3 best12. ;
	format services_spec___4 best12. ;
	format services_spec___5 best12. ;
	format services_spec___6 best12. ;
	format services_spec___7 best12. ;
	format services_spec___8 best12. ;
	format services_spec___9 best12. ;
	format services_oth $500. ;
	format tired best12. ;
	format nervous best12. ;
	format nervous_rate best12. ;
	format hopeless best12. ;
	format restless best12. ;
	format restless_sit best12. ;
	format depressed best12. ;
	format depressed_cheer best12. ;
	format effort best12. ;
	format worthless best12. ;
	format total_score best12. ;
	format arvs_difficult $5000. ;
	format health_difficult $5000. ;
	format hc_difficult $5000. ;
	format share_counselor best12. ;
	format share_doctor best12. ;
	format comments_ref $5000. ;
	format psychosocial_factors_complete best12. ;

input
		patient_id $
		marital_status
		safe_sex___1
		safe_sex___2
		safe_sex___3
		safe_sex___4
		safe_sex___5
		safe_condom___1
		safe_condom___2
		safe_sex_other $
		practice_safe
		partners $
		partners_live $
		partners_test $
		partners_pos $
		partners_arv $
		children $
		children_care $
		children_test $
		children_pos $
		family_hiv $
		family_died $
		knows_hiv___1
		knows_hiv___2
		knows_hiv___3
		knows_hiv___4
		knows_hiv___5
		knows_other $
		emotional_supp $
		support_live
		treat_support
		support_relate $
		abuse
		abuse_type___1
		abuse_type___2
		abuse_type___3
		abuse_type___4
		abuse_type___5
		abuse_sex
		abuse_whom
		abuse_other $
		abuse_acts
		abuse_acts_whom
		acts_other $
		abuse_sex_time
		drugs
		drugs_specify $
		alcohol
		alcohol_type___1
		alcohol_type___2
		alcohol_type___3
		alcohol_type___4
		alcohol_type___5
		drinking_stop
		drinking_crit
		drinking_guilt
		drinking_morning
		smoke
		smoke_type___1
		smoke_type___2
		smoke_type___3
		smoke_type___4
		cigarette_num $
		cigar_num $
		pipe_num $
		dagga_num $
		hiv_educate
		arv_train
		train_help
		train_no $
		session_num
		session_help
		session_no $
		support
		support_form $
		services
		services_spec___1
		services_spec___2
		services_spec___3
		services_spec___4
		services_spec___5
		services_spec___6
		services_spec___7
		services_spec___8
		services_spec___9
		services_oth $
		tired
		nervous
		nervous_rate
		hopeless
		restless
		restless_sit
		depressed
		depressed_cheer
		effort
		worthless
		total_score
		arvs_difficult $
		health_difficult $
		hc_difficult $
		share_counselor
		share_doctor
		comments_ref $
		psychosocial_factors_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label marital_status='1a. What is your marital status?';
	label safe_sex___1='1b. Which forms of safe sex do you practice? (choice=Abstinence (1))';
	label safe_sex___2='1b. Which forms of safe sex do you practice? (choice=Condoms (2))';
	label safe_sex___3='1b. Which forms of safe sex do you practice? (choice=Pull out (3))';
	label safe_sex___4='1b. Which forms of safe sex do you practice? (choice=None (4))';
	label safe_sex___5='1b. Which forms of safe sex do you practice? (choice=Other (5))';
	label safe_condom___1='Which type of condoms? (choice=Male (1))';
	label safe_condom___2='Which type of condoms? (choice=Female (2))';
	label safe_sex_other='Other form of safe sex';
	label practice_safe='1c. In the last 6 months, how often did you practice safe sex?';
	label partners='2a. How many current partners do you have?';
	label partners_live='How many partners are currently living with you?';
	label partners_test='2b. How many partners do you know have been tested for HIV?';
	label partners_pos='How many partners do you know are HIV positive?';
	label partners_arv='2c. How many partners do you know are taking ARVs?';
	label children='3a. How many biological children do you have?';
	label children_care='How many children are you currently taking care of?';
	label children_test='3b. How many children in your care do you know have been tested for HIV?';
	label children_pos='How many children in your care do you know are HIV positive?';
	label family_hiv='4. How many additional family members do you know are HIV positive?';
	label family_died='How many have died?';
	label knows_hiv___1='5. Who knows you are living with HIV? (choice=Partner/spouse (1))';
	label knows_hiv___2='5. Who knows you are living with HIV? (choice=Family member(s)(2))';
	label knows_hiv___3='5. Who knows you are living with HIV? (choice=Friends (3))';
	label knows_hiv___4='5. Who knows you are living with HIV? (choice=Employer (4))';
	label knows_hiv___5='5. Who knows you are living with HIV? (choice=Other (5))';
	label knows_other='Other person who knows (for example church community, pastor)';
	label emotional_supp='6. Who is the person most emotionally supportive of you?';
	label support_live='Do they live with you?';
	label treat_support='7a. Do you have someone who is a treatment supporter/partner?';
	label support_relate='What is your relationship?';
	label abuse='8a. Have you ever been hurt by someone?';
	label abuse_type___1='8b. How have you been hurt? (choice=Physical (1))';
	label abuse_type___2='8b. How have you been hurt? (choice=Sexual (2))';
	label abuse_type___3='8b. How have you been hurt? (choice=Verbal (3))';
	label abuse_type___4='8b. How have you been hurt? (choice=Psychological (4))';
	label abuse_type___5='8b. How have you been hurt? (choice=Other (5))';
	label abuse_sex='8c. Has anyone ever physically forced your to have sex even when you did not want?';
	label abuse_whom='Whom?';
	label abuse_other='Other person   ';
	label abuse_acts='8d. Has anyone ever forced you to perform any sexual acts you did not want to?';
	label abuse_acts_whom='Whom?';
	label acts_other='Other person';
	label abuse_sex_time='8e. When was the last time you were hurt sexually?';
	label drugs='9. In the past 4 weeks, did you use street drugs?';
	label drugs_specify='Which one(s)? (These may include woonga, cocaine, heroin, dagga, ecstasy, etc.)';
	label alcohol='10a. How often do you drink alcohol?';
	label alcohol_type___1='10b. What type of alcohol? (choice=Mqombothi (1))';
	label alcohol_type___2='10b. What type of alcohol? (choice=Cider (2))';
	label alcohol_type___3='10b. What type of alcohol? (choice=Wine (3))';
	label alcohol_type___4='10b. What type of alcohol? (choice=Spirits (4))';
	label alcohol_type___5='10b. What type of alcohol? (choice=Beer (5))';
	label drinking_stop='10c. Have you ever felt you should cut down on your drinking?';
	label drinking_crit='10d. Hae people annoyed you by criticizing your drinking?';
	label drinking_guilt='10e. Have you ever felt bad or guilty about your drinking?';
	label drinking_morning='10f. Have you ever had a drink first thing in the morning to steady your nerves or get rid of a hangover (eye-opener)?';
	label smoke='11a. Do you smoke?';
	label smoke_type___1='11b. What do you smoke? (choice=Cigarettes (1))';
	label smoke_type___2='11b. What do you smoke? (choice=Cigars (2))';
	label smoke_type___3='11b. What do you smoke? (choice=Pipe (3))';
	label smoke_type___4='11b. What do you smoke? (choice=Dagga (4))';
	label cigarette_num='How many per day?';
	label cigar_num='How many per day?';
	label pipe_num='How many per day?';
	label dagga_num='How many per day?';
	label hiv_educate='12. How much education do you feel  you have received about HIV?';
	label arv_train='13a. How many pre-ARV training sessions did you receive?';
	label train_help='13b. Were these sessions helpful?';
	label train_no='Why not?';
	label session_num='14. In the last 12 months, how many 1-on-1 adherence counseling sessions have you received?';
	label session_help='Were the sessions helpful to you?';
	label session_no='Why not?';
	label support='15a. Would you like additional support for your illness (i.e. financial, emotional, spiritual)?';
	label support_form='15b. What other forms of support would you like to receive?';
	label services='16. Do you feel you have access to all the services you need?';
	label services_spec___1='17. Which services would you like to access more? (choice=Health Education (1))';
	label services_spec___2='17. Which services would you like to access more? (choice=Counseling (2))';
	label services_spec___3='17. Which services would you like to access more? (choice=Doctors (3))';
	label services_spec___4='17. Which services would you like to access more? (choice=Pharmacy (4))';
	label services_spec___5='17. Which services would you like to access more? (choice=Physiotherapy (5))';
	label services_spec___6='17. Which services would you like to access more? (choice=Social Work (6))';
	label services_spec___7='17. Which services would you like to access more? (choice=Psychiatry/Psychology (7))';
	label services_spec___8='17. Which services would you like to access more? (choice=Prayer/Minister (8))';
	label services_spec___9='17. Which services would you like to access more? (choice=Other (9))';
	label services_oth='Other services';
	label tired='a. During the past month, about how often did you feel tired out for no good reason?';
	label nervous='b. During the past month, about how often did you feel nervous?';
	label nervous_rate='c. So nervous that nothing could calm you down?';
	label hopeless='d. During the past month, about how often did you feel hopeless?';
	label restless='e. During the past month, about how often did you feel restless or fidgety?';
	label restless_sit='f. So restless you could not sit still?';
	label depressed='g. During the past month, about how often did you feel sad or depressed?';
	label depressed_cheer='h. So depressed that nothing could cheer you up?';
	label effort='i. During the past month, about how often did you feel that everything was an effort?';
	label worthless='j. During the past month, about how often did you feel worthless?';
	label total_score='30a. Total Score';
	label arvs_difficult='19. What makes it difficult for you to take your ARVs?';
	label health_difficult='20. What makes it difficult for you to improve your health (i.e. weight, think and think at night, worries you)?';
	label hc_difficult='21. What makes it difficult for you to access healthcare (i.e. getting to the clinic/pharmacy, childcare)?';
	label share_counselor='Would you like me to share your responses with your adherence counselor?';
	label share_doctor='Would you like me to share your responses with your doctor?';
	label comments_ref='Comments';
	label psychosocial_factors_complete='Complete?';
	run;

proc format;
	value marital_status_ 1='Married (1)' 2='Divorced (2)' 
		3='Single living with partner (3)' 4='Single not living with partner (4)' 
		5='Single no partner (5)' 6='Widowed (6)' 
		7='Separated (7)';
	value safe_sex___1_ 0='Unchecked' 1='Checked';
	value safe_sex___2_ 0='Unchecked' 1='Checked';
	value safe_sex___3_ 0='Unchecked' 1='Checked';
	value safe_sex___4_ 0='Unchecked' 1='Checked';
	value safe_sex___5_ 0='Unchecked' 1='Checked';
	value safe_condom___1_ 0='Unchecked' 1='Checked';
	value safe_condom___2_ 0='Unchecked' 1='Checked';
	value practice_safe_ 1='Always (100%)(1)' 2='Often (>50%)(2)' 
		3='Sometimes (< 50%)(3)' 4='Rarely (< 25%)(4)' 
		5='Never, or none (0%)(5)' 9='Declined to answer (9)';
	value knows_hiv___1_ 0='Unchecked' 1='Checked';
	value knows_hiv___2_ 0='Unchecked' 1='Checked';
	value knows_hiv___3_ 0='Unchecked' 1='Checked';
	value knows_hiv___4_ 0='Unchecked' 1='Checked';
	value knows_hiv___5_ 0='Unchecked' 1='Checked';
	value support_live_ 1='Yes' 2='No';
	value treat_support_ 1='Yes' 2='No';
	value abuse_ 1='Frequently (>=3x/wk)(1)' 2='Sometimes (>=1x/mo)(2)' 
		3='Rarely (>=1/yr)(3)' 4='Never (4)';
	value abuse_type___1_ 0='Unchecked' 1='Checked';
	value abuse_type___2_ 0='Unchecked' 1='Checked';
	value abuse_type___3_ 0='Unchecked' 1='Checked';
	value abuse_type___4_ 0='Unchecked' 1='Checked';
	value abuse_type___5_ 0='Unchecked' 1='Checked';
	value abuse_sex_ 1='Often (1)' 2='Sometimes (2)' 
		3='Not at all (3)';
	value abuse_whom_ 1='Partner (1)' 2='Other (2)';
	value abuse_acts_ 1='Often (1)' 2='Sometimes (2)' 
		3='Not at all (3)';
	value abuse_acts_whom_ 1='Partner (1)' 2='Other (2)';
	value abuse_sex_time_ 1='< 1 mo (1)' 2='1-6 mo (2)' 
		3='>6-12 mo (3)' 4='>12 mo (4)';
	value drugs_ 1='Yes' 2='No';
	value alcohol_ 1='Daily (1)' 2='4-5 times/week (2)' 
		3='Weekends (3)' 4='3-4 times/month (4)' 
		5='Once/month (5)' 6='< Once/month (6)' 
		7='Never (7)';
	value alcohol_type___1_ 0='Unchecked' 1='Checked';
	value alcohol_type___2_ 0='Unchecked' 1='Checked';
	value alcohol_type___3_ 0='Unchecked' 1='Checked';
	value alcohol_type___4_ 0='Unchecked' 1='Checked';
	value alcohol_type___5_ 0='Unchecked' 1='Checked';
	value drinking_stop_ 1='Yes' 2='No';
	value drinking_crit_ 1='Yes' 2='No';
	value drinking_guilt_ 1='Yes' 2='No';
	value drinking_morning_ 1='Yes' 2='No';
	value smoke_ 1='Yes' 2='No';
	value smoke_type___1_ 0='Unchecked' 1='Checked';
	value smoke_type___2_ 0='Unchecked' 1='Checked';
	value smoke_type___3_ 0='Unchecked' 1='Checked';
	value smoke_type___4_ 0='Unchecked' 1='Checked';
	value hiv_educate_ 1='Much (1)' 2='Some (2)' 
		3='Little (3)' 4='None (4)';
	value arv_train_ 1='0(1)' 2='1-2 (2)' 
		3='3-5 (3)' 4='>5 (4)';
	value train_help_ 1='Yes' 2='No';
	value session_num_ 0='0' 1='1' 
		2='2' 3='3' 
		4='4' 5='5' 
		6='6' 7='7' 
		8='10+';
	value session_help_ 1='Yes' 2='No';
	value support_ 1='Yes' 2='No';
	value services_ 1='Yes' 2='No';
	value services_spec___1_ 0='Unchecked' 1='Checked';
	value services_spec___2_ 0='Unchecked' 1='Checked';
	value services_spec___3_ 0='Unchecked' 1='Checked';
	value services_spec___4_ 0='Unchecked' 1='Checked';
	value services_spec___5_ 0='Unchecked' 1='Checked';
	value services_spec___6_ 0='Unchecked' 1='Checked';
	value services_spec___7_ 0='Unchecked' 1='Checked';
	value services_spec___8_ 0='Unchecked' 1='Checked';
	value services_spec___9_ 0='Unchecked' 1='Checked';
	value tired_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value nervous_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value nervous_rate_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value hopeless_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value restless_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value restless_sit_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value depressed_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value depressed_cheer_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value effort_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value worthless_ 1='None of the time (1)' 2='A little of the time (2)' 
		3='Some of the time (3)' 4='Most of the time (4)' 
		5='All of the time (5)';
	value share_counselor_ 1='Yes' 2='No';
	value share_doctor_ 1='Yes' 2='No';
	value psychosocial_factors_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format marital_status marital_status_.;
	format safe_sex___1 safe_sex___1_.;
	format safe_sex___2 safe_sex___2_.;
	format safe_sex___3 safe_sex___3_.;
	format safe_sex___4 safe_sex___4_.;
	format safe_sex___5 safe_sex___5_.;
	format safe_condom___1 safe_condom___1_.;
	format safe_condom___2 safe_condom___2_.;
	format practice_safe practice_safe_.;
	format knows_hiv___1 knows_hiv___1_.;
	format knows_hiv___2 knows_hiv___2_.;
	format knows_hiv___3 knows_hiv___3_.;
	format knows_hiv___4 knows_hiv___4_.;
	format knows_hiv___5 knows_hiv___5_.;
	format support_live support_live_.;
	format treat_support treat_support_.;
	format abuse abuse_.;
	format abuse_type___1 abuse_type___1_.;
	format abuse_type___2 abuse_type___2_.;
	format abuse_type___3 abuse_type___3_.;
	format abuse_type___4 abuse_type___4_.;
	format abuse_type___5 abuse_type___5_.;
	format abuse_sex abuse_sex_.;
	format abuse_whom abuse_whom_.;
	format abuse_acts abuse_acts_.;
	format abuse_acts_whom abuse_acts_whom_.;
	format abuse_sex_time abuse_sex_time_.;
	format drugs drugs_.;
	format alcohol alcohol_.;
	format alcohol_type___1 alcohol_type___1_.;
	format alcohol_type___2 alcohol_type___2_.;
	format alcohol_type___3 alcohol_type___3_.;
	format alcohol_type___4 alcohol_type___4_.;
	format alcohol_type___5 alcohol_type___5_.;
	format drinking_stop drinking_stop_.;
	format drinking_crit drinking_crit_.;
	format drinking_guilt drinking_guilt_.;
	format drinking_morning drinking_morning_.;
	format smoke smoke_.;
	format smoke_type___1 smoke_type___1_.;
	format smoke_type___2 smoke_type___2_.;
	format smoke_type___3 smoke_type___3_.;
	format smoke_type___4 smoke_type___4_.;
	format hiv_educate hiv_educate_.;
	format arv_train arv_train_.;
	format train_help train_help_.;
	format session_num session_num_.;
	format session_help session_help_.;
	format support support_.;
	format services services_.;
	format services_spec___1 services_spec___1_.;
	format services_spec___2 services_spec___2_.;
	format services_spec___3 services_spec___3_.;
	format services_spec___4 services_spec___4_.;
	format services_spec___5 services_spec___5_.;
	format services_spec___6 services_spec___6_.;
	format services_spec___7 services_spec___7_.;
	format services_spec___8 services_spec___8_.;
	format services_spec___9 services_spec___9_.;
	format tired tired_.;
	format nervous nervous_.;
	format nervous_rate nervous_rate_.;
	format hopeless hopeless_.;
	format restless restless_.;
	format restless_sit restless_sit_.;
	format depressed depressed_.;
	format depressed_cheer depressed_cheer_.;
	format effort effort_.;
	format worthless worthless_.;
	format share_counselor share_counselor_.;
	format share_doctor share_doctor_.;
	format psychosocial_factors_complete psychosocial_factors_complete_.;
	run;

proc contents data=redcap;
data brent.psycho;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;

proc contents data=brent.psycho short varnum; run;
