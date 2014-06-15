%let path=H:\SAS_Emory\RedCap;
libname brent "&path.\data";

%macro removeOldFile(bye);
%if %sysfunc(exist(&bye.)) %then %do;
proc delete data=&bye.;
run;
%end;
%mend removeOldFile;
%removeOldFile(work.redcap);

data REDCAP;
%let _EFIERR_ = 0;
infile "&path\CSV\alt_spirit.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat faith best32. ;
	informat faith_specify___1 best32. ;
	informat faith_specify___2 best32. ;
	informat faith_specify___3 best32. ;
	informat faith_specify___4 best32. ;
	informat faith_specify___5 best32. ;
	informat faith_other $500. ;
	informat faith_christian $500. ;
	informat faith_active best32. ;
	informat faith_arvs_stop best32. ;
	informat traditional_ever best32. ;
	informat traditional_time best32. ;
	informat trad1_name $500. ;
	informat trad1_plant best32. ;
	informat trad1_raw best32. ;
	informat trad1_process best32. ;
	informat trad1_package best32. ;
	informat trad1_form best32. ;
	informat trad1_form_oth $500. ;
	informat trad1_route___1 best32. ;
	informat trad1_route___2 best32. ;
	informat trad1_route___3 best32. ;
	informat trad1_route___4 best32. ;
	informat trad1_route___5 best32. ;
	informat trad1_color $500. ;
	informat trad1_reason $500. ;
	informat trad1_where___1 best32. ;
	informat trad1_where___2 best32. ;
	informat trad1_where___3 best32. ;
	informat trad1_where___4 best32. ;
	informat trad1_where___5 best32. ;
	informat trad1_where___6 best32. ;
	informat trad1_where___7 best32. ;
	informat trad1_where___8 best32. ;
	informat trad1_where___9 best32. ;
	informat trad1_where___10 best32. ;
	informat trad1_where_oth $500. ;
	informat trad1_feel best32. ;
	informat trad2_name $500. ;
	informat trad2_plant best32. ;
	informat trad2_raw best32. ;
	informat trad2_process best32. ;
	informat trad2_package best32. ;
	informat trad2_form best32. ;
	informat trad2_form_oth $500. ;
	informat trad2_route___1 best32. ;
	informat trad2_route___2 best32. ;
	informat trad2_route___3 best32. ;
	informat trad2_route___4 best32. ;
	informat trad2_route___5 best32. ;
	informat trad2_color $500. ;
	informat trad2_reason $500. ;
	informat trad2_where___1 best32. ;
	informat trad2_where___2 best32. ;
	informat trad2_where___3 best32. ;
	informat trad2_where___4 best32. ;
	informat trad2_where___5 best32. ;
	informat trad2_where___6 best32. ;
	informat trad2_where___7 best32. ;
	informat trad2_where___8 best32. ;
	informat trad2_where___9 best32. ;
	informat trad2_where___10 best32. ;
	informat trad2_where_oth $500. ;
	informat trad2_feel best32. ;
	informat trad3_name $500. ;
	informat trad3_plant best32. ;
	informat trad3_raw best32. ;
	informat trad3_process best32. ;
	informat trad3_package best32. ;
	informat trad3_form best32. ;
	informat trad3_form_oth $500. ;
	informat trad3_route___1 best32. ;
	informat trad3_route___2 best32. ;
	informat trad3_route___3 best32. ;
	informat trad3_route___4 best32. ;
	informat trad3_route___5 best32. ;
	informat trad3_color $500. ;
	informat trad3_reason $500. ;
	informat trad3_where___1 best32. ;
	informat trad3_where___2 best32. ;
	informat trad3_where___3 best32. ;
	informat trad3_where___4 best32. ;
	informat trad3_where___5 best32. ;
	informat trad3_where___6 best32. ;
	informat trad3_where___7 best32. ;
	informat trad3_where___8 best32. ;
	informat trad3_where___9 best32. ;
	informat trad3_where___10 best32. ;
	informat trad3_where_oth $500. ;
	informat trad3_feel best32. ;
	informat meds_arvs best32. ;
	informat trad_side_effect best32. ;
	informat spec_side_effect $500. ;
	informat chemist best32. ;
	informat chemist_names $500. ;
	informat chemist_feel best32. ;
	informat alt_treat best32. ;
	informat alt_treat_spec $500. ;
	informat alt_treat_feel best32. ;
	informat clinic_rec___1 best32. ;
	informat clinic_rec___2 best32. ;
	informat clinic_rec___3 best32. ;
	informat clinic_rec___4 best32. ;
	informat clinic_rec___5 best32. ;
	informat clinic_rec___6 best32. ;
	informat clinic_rec___7 best32. ;
	informat clinic_rec_other $500. ;
	informat alt_treatmentspiritu_v_0 best32. ;

	format patient_id $500. ;
	format faith best12. ;
	format faith_specify___1 best12. ;
	format faith_specify___2 best12. ;
	format faith_specify___3 best12. ;
	format faith_specify___4 best12. ;
	format faith_specify___5 best12. ;
	format faith_other $500. ;
	format faith_christian $500. ;
	format faith_active best12. ;
	format faith_arvs_stop best12. ;
	format traditional_ever best12. ;
	format traditional_time best12. ;
	format trad1_name $500. ;
	format trad1_plant best12. ;
	format trad1_raw best12. ;
	format trad1_process best12. ;
	format trad1_package best12. ;
	format trad1_form best12. ;
	format trad1_form_oth $500. ;
	format trad1_route___1 best12. ;
	format trad1_route___2 best12. ;
	format trad1_route___3 best12. ;
	format trad1_route___4 best12. ;
	format trad1_route___5 best12. ;
	format trad1_color $500. ;
	format trad1_reason $500. ;
	format trad1_where___1 best12. ;
	format trad1_where___2 best12. ;
	format trad1_where___3 best12. ;
	format trad1_where___4 best12. ;
	format trad1_where___5 best12. ;
	format trad1_where___6 best12. ;
	format trad1_where___7 best12. ;
	format trad1_where___8 best12. ;
	format trad1_where___9 best12. ;
	format trad1_where___10 best12. ;
	format trad1_where_oth $500. ;
	format trad1_feel best12. ;
	format trad2_name $500. ;
	format trad2_plant best12. ;
	format trad2_raw best12. ;
	format trad2_process best12. ;
	format trad2_package best12. ;
	format trad2_form best12. ;
	format trad2_form_oth $500. ;
	format trad2_route___1 best12. ;
	format trad2_route___2 best12. ;
	format trad2_route___3 best12. ;
	format trad2_route___4 best12. ;
	format trad2_route___5 best12. ;
	format trad2_color $500. ;
	format trad2_reason $500. ;
	format trad2_where___1 best12. ;
	format trad2_where___2 best12. ;
	format trad2_where___3 best12. ;
	format trad2_where___4 best12. ;
	format trad2_where___5 best12. ;
	format trad2_where___6 best12. ;
	format trad2_where___7 best12. ;
	format trad2_where___8 best12. ;
	format trad2_where___9 best12. ;
	format trad2_where___10 best12. ;
	format trad2_where_oth $500. ;
	format trad2_feel best12. ;
	format trad3_name $500. ;
	format trad3_plant best12. ;
	format trad3_raw best12. ;
	format trad3_process best12. ;
	format trad3_package best12. ;
	format trad3_form best12. ;
	format trad3_form_oth $500. ;
	format trad3_route___1 best12. ;
	format trad3_route___2 best12. ;
	format trad3_route___3 best12. ;
	format trad3_route___4 best12. ;
	format trad3_route___5 best12. ;
	format trad3_color $500. ;
	format trad3_reason $500. ;
	format trad3_where___1 best12. ;
	format trad3_where___2 best12. ;
	format trad3_where___3 best12. ;
	format trad3_where___4 best12. ;
	format trad3_where___5 best12. ;
	format trad3_where___6 best12. ;
	format trad3_where___7 best12. ;
	format trad3_where___8 best12. ;
	format trad3_where___9 best12. ;
	format trad3_where___10 best12. ;
	format trad3_where_oth $500. ;
	format trad3_feel best12. ;
	format meds_arvs best12. ;
	format trad_side_effect best12. ;
	format spec_side_effect $500. ;
	format chemist best12. ;
	format chemist_names $500. ;
	format chemist_feel best12. ;
	format alt_treat best12. ;
	format alt_treat_spec $500. ;
	format alt_treat_feel best12. ;
	format clinic_rec___1 best12. ;
	format clinic_rec___2 best12. ;
	format clinic_rec___3 best12. ;
	format clinic_rec___4 best12. ;
	format clinic_rec___5 best12. ;
	format clinic_rec___6 best12. ;
	format clinic_rec___7 best12. ;
	format clinic_rec_other $500. ;
	format alt_treatmentspiritu_v_0 best12. ;

input
		patient_id $
		faith
		faith_specify___1
		faith_specify___2
		faith_specify___3
		faith_specify___4
		faith_specify___5
		faith_other $
		faith_christian $
		faith_active
		faith_arvs_stop
		traditional_ever
		traditional_time
		trad1_name $
		trad1_plant
		trad1_raw
		trad1_process
		trad1_package
		trad1_form
		trad1_form_oth $
		trad1_route___1
		trad1_route___2
		trad1_route___3
		trad1_route___4
		trad1_route___5
		trad1_color $
		trad1_reason $
		trad1_where___1
		trad1_where___2
		trad1_where___3
		trad1_where___4
		trad1_where___5
		trad1_where___6
		trad1_where___7
		trad1_where___8
		trad1_where___9
		trad1_where___10
		trad1_where_oth $
		trad1_feel
		trad2_name $
		trad2_plant
		trad2_raw
		trad2_process
		trad2_package
		trad2_form
		trad2_form_oth $
		trad2_route___1
		trad2_route___2
		trad2_route___3
		trad2_route___4
		trad2_route___5
		trad2_color $
		trad2_reason $
		trad2_where___1
		trad2_where___2
		trad2_where___3
		trad2_where___4
		trad2_where___5
		trad2_where___6
		trad2_where___7
		trad2_where___8
		trad2_where___9
		trad2_where___10
		trad2_where_oth $
		trad2_feel
		trad3_name $
		trad3_plant
		trad3_raw
		trad3_process
		trad3_package
		trad3_form
		trad3_form_oth $
		trad3_route___1
		trad3_route___2
		trad3_route___3
		trad3_route___4
		trad3_route___5
		trad3_color $
		trad3_reason $
		trad3_where___1
		trad3_where___2
		trad3_where___3
		trad3_where___4
		trad3_where___5
		trad3_where___6
		trad3_where___7
		trad3_where___8
		trad3_where___9
		trad3_where___10
		trad3_where_oth $
		trad3_feel
		meds_arvs
		trad_side_effect
		spec_side_effect $
		chemist
		chemist_names $
		chemist_feel
		alt_treat
		alt_treat_spec $
		alt_treat_feel
		clinic_rec___1
		clinic_rec___2
		clinic_rec___3
		clinic_rec___4
		clinic_rec___5
		clinic_rec___6
		clinic_rec___7
		clinic_rec_other $
		alt_treatmentspiritu_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label faith='1. Do you have a religious faith?';
	label faith_specify___1='Which one(s)? (choice=Christian)';
	label faith_specify___2='Which one(s)? (choice=Traditional African)';
	label faith_specify___3='Which one(s)? (choice=Hindu)';
	label faith_specify___4='Which one(s)? (choice=Muslim)';
	label faith_specify___5='Which one(s)? (choice=Other)';
	label faith_other='Other religion';
	label faith_christian='Which Christian denomination?';
	label faith_active='2. How active are you in practicing your religion?';
	label faith_arvs_stop='3. Have you ever stopped your ARVs because of your religious beliefs or teachings?';
	label traditional_ever='4. Did you EVER take any Traditional Medications or herbs (African/muthi, Chinese, Indian)?';
	label traditional_time='How long ago?';
	label trad1_name='1. Name';
	label trad1_plant='Did the remedy come in the form of a plant?';
	label trad1_raw='Raw material';
	label trad1_process='Partially processed';
	label trad1_package='Did the remedy come in the form of a packaged medicine?';
	label trad1_form='Form of package';
	label trad1_form_oth='Other form of remedy';
	label trad1_route___1='How did you take it (route)? (choice=Skin/Topical (i.e. poultice, lotion, ointment, scarification))';
	label trad1_route___2='How did you take it (route)? (choice=Mouth/Oral)';
	label trad1_route___3='How did you take it (route)? (choice=Rectal/Anal (i.e. enema, sitz bath))';
	label trad1_route___4='How did you take it (route)? (choice=Inhaled (incense, vapor bath))';
	label trad1_route___5='How did you take it (route)? (choice=Multiple ways (infusions/decoctions))';
	label trad1_color='What color was it?';
	label trad1_reason='What reason did you get this remedy?';
	label trad1_where___1='Where did you get this remedy? (choice=Traditional healer/Isangoma)';
	label trad1_where___2='Where did you get this remedy? (choice=Herbalist/Inyanga)';
	label trad1_where___3='Where did you get this remedy? (choice=Chemist/Pharmacist)';
	label trad1_where___4='Where did you get this remedy? (choice=Fortune Teller)';
	label trad1_where___5='Where did you get this remedy? (choice=Diviner)';
	label trad1_where___6='Where did you get this remedy? (choice=Faith Healer)';
	label trad1_where___7='Where did you get this remedy? (choice=Herbal Shop)';
	label trad1_where___8='Where did you get this remedy? (choice=Street Vendor)';
	label trad1_where___9='Where did you get this remedy? (choice=Chinese Practioner)';
	label trad1_where___10='Where did you get this remedy? (choice=Other)';
	label trad1_where_oth='Other location';
	label trad1_feel='How did you feel with this remedy?';
	label trad2_name='2. Name';
	label trad2_plant='Did the remedy come in the form of a plant?';
	label trad2_raw='Raw material';
	label trad2_process='Partially processed';
	label trad2_package='Did the remedy come in the form of a packaged medicine?';
	label trad2_form='Form of package';
	label trad2_form_oth='Other form of remedy';
	label trad2_route___1='How did you take it (route)? (choice=Skin/Topical (i.e. poultice, lotion, ointment, scarification))';
	label trad2_route___2='How did you take it (route)? (choice=Mouth/Oral)';
	label trad2_route___3='How did you take it (route)? (choice=Rectal/Anal (i.e. enema, sitz bath))';
	label trad2_route___4='How did you take it (route)? (choice=Inhaled (incense, vapor bath))';
	label trad2_route___5='How did you take it (route)? (choice=Multiple ways (infusions/decoctions))';
	label trad2_color='What color was it?';
	label trad2_reason='What reason did you get this remedy?';
	label trad2_where___1='Where did you get this remedy? (choice=Traditional healer/Isangoma)';
	label trad2_where___2='Where did you get this remedy? (choice=Herbalist/Inyanga)';
	label trad2_where___3='Where did you get this remedy? (choice=Chemist/Pharmacist)';
	label trad2_where___4='Where did you get this remedy? (choice=Fortune Teller)';
	label trad2_where___5='Where did you get this remedy? (choice=Diviner)';
	label trad2_where___6='Where did you get this remedy? (choice=Faith Healer)';
	label trad2_where___7='Where did you get this remedy? (choice=Herbal Shop)';
	label trad2_where___8='Where did you get this remedy? (choice=Street Vendor)';
	label trad2_where___9='Where did you get this remedy? (choice=Chinese Practioner)';
	label trad2_where___10='Where did you get this remedy? (choice=Other)';
	label trad2_where_oth='Other location';
	label trad2_feel='How did you feel with this remedy?';
	label trad3_name='3. Name';
	label trad3_plant='Did the remedy come in the form of a plant?';
	label trad3_raw='Raw material';
	label trad3_process='Partially processed';
	label trad3_package='Did the remedy come in the form of a packaged medicine?';
	label trad3_form='Form of package';
	label trad3_form_oth='Other form of remedy';
	label trad3_route___1='How did you take it (route)? (choice=Skin/Topical (i.e. poultice, lotion, ointment, scarification))';
	label trad3_route___2='How did you take it (route)? (choice=Mouth/Oral)';
	label trad3_route___3='How did you take it (route)? (choice=Rectal/Anal (i.e. enema, sitz bath))';
	label trad3_route___4='How did you take it (route)? (choice=Inhaled (incense, vapor bath))';
	label trad3_route___5='How did you take it (route)? (choice=Multiple ways (infusions/decoctions))';
	label trad3_color='What color was it?';
	label trad3_reason='What reason did you get this remedy?';
	label trad3_where___1='Where did you get this remedy? (choice=Traditional healer/Isangoma)';
	label trad3_where___2='Where did you get this remedy? (choice=Herbalist/Inyanga)';
	label trad3_where___3='Where did you get this remedy? (choice=Chemist/Pharmacist)';
	label trad3_where___4='Where did you get this remedy? (choice=Fortune Teller)';
	label trad3_where___5='Where did you get this remedy? (choice=Diviner)';
	label trad3_where___6='Where did you get this remedy? (choice=Faith Healer)';
	label trad3_where___7='Where did you get this remedy? (choice=Herbal Shop)';
	label trad3_where___8='Where did you get this remedy? (choice=Street Vendor)';
	label trad3_where___9='Where did you get this remedy? (choice=Chinese Practioner)';
	label trad3_where___10='Where did you get this remedy? (choice=Other)';
	label trad3_where_oth='Other location';
	label trad3_feel='How did you feel with this remedy?';
	label meds_arvs='5b. Do you take these medicines with your ARVs or instead of your ARVs?';
	label trad_side_effect='5c. Have you had any side effects/adverse events to any of these remedies?';
	label spec_side_effect='Which remedy and side effect?';
	label chemist='6a. In the last 6 mos, did you take meds or supplements from a chemist/pharmacist not prescribed by a doctor, herbalist, or healer?';
	label chemist_names='6b. What is/are the name(s)? (i.e. Immune Boost, Modul8)';
	label chemist_feel='6c. How did you feel with this medication?';
	label alt_treat='7a. In the last 6 mos, did you use any other alternative treatment (for example but not limited to faith healing/prophet, Reikki, massage, sound/music, thermal, reflexology, chiropractic, acupuncture)?';
	label alt_treat_spec='7b. What is/are the treatment(s)?';
	label alt_treat_feel='7c. How did you feel with this treatment?';
	label clinic_rec___1='8. Who first recommended you to go to an HIV clinic? (choice=Provider (doctor or nurse)(1))';
	label clinic_rec___2='8. Who first recommended you to go to an HIV clinic? (choice=Traditional Healer (Isangoma)(2))';
	label clinic_rec___3='8. Who first recommended you to go to an HIV clinic? (choice=Herbalist (Inyanga)(3))';
	label clinic_rec___4='8. Who first recommended you to go to an HIV clinic? (choice=Friend (4))';
	label clinic_rec___5='8. Who first recommended you to go to an HIV clinic? (choice=Family (5))';
	label clinic_rec___6='8. Who first recommended you to go to an HIV clinic? (choice=Member of religious faith (6))';
	label clinic_rec___7='8. Who first recommended you to go to an HIV clinic? (choice=Other (7))';
	label clinic_rec_other='Other who recommended';
	label alt_treatmentspiritu_v_0='Complete?';
	run;

proc format;
	value faith_ 1='Yes' 2='No';
	value faith_specify___1_ 0='Unchecked' 1='Checked';
	value faith_specify___2_ 0='Unchecked' 1='Checked';
	value faith_specify___3_ 0='Unchecked' 1='Checked';
	value faith_specify___4_ 0='Unchecked' 1='Checked';
	value faith_specify___5_ 0='Unchecked' 1='Checked';
	value faith_active_ 1='Very active (1)' 2='Somewhat active (2)' 
		3='Not active (3)';
	value faith_arvs_stop_ 1='Yes' 2='No';
	value traditional_ever_ 1='Yes' 2='No';
	value traditional_time_ 1='< 1 week (1)' 2='1 wk-1month (2)' 
		3='> 1 month-6 months (3)' 4='> 6 mos (4)';
	value trad1_plant_ 1='Yes' 2='No';
	value trad1_raw_ 1='Root' 2='Bark' 
		3='Bulb' 4='Whole plant' 
		5='Leaves/stems' 6='Tubers' 
		7='Mixture';
	value trad1_process_ 1='Chopped' 2='Ground';
	value trad1_package_ 1='Yes' 2='No';
	value trad1_form_ 1='Powder' 2='Liquid' 
		3='Tablet' 9='Other';
	value trad1_route___1_ 0='Unchecked' 1='Checked';
	value trad1_route___2_ 0='Unchecked' 1='Checked';
	value trad1_route___3_ 0='Unchecked' 1='Checked';
	value trad1_route___4_ 0='Unchecked' 1='Checked';
	value trad1_route___5_ 0='Unchecked' 1='Checked';
	value trad1_where___1_ 0='Unchecked' 1='Checked';
	value trad1_where___2_ 0='Unchecked' 1='Checked';
	value trad1_where___3_ 0='Unchecked' 1='Checked';
	value trad1_where___4_ 0='Unchecked' 1='Checked';
	value trad1_where___5_ 0='Unchecked' 1='Checked';
	value trad1_where___6_ 0='Unchecked' 1='Checked';
	value trad1_where___7_ 0='Unchecked' 1='Checked';
	value trad1_where___8_ 0='Unchecked' 1='Checked';
	value trad1_where___9_ 0='Unchecked' 1='Checked';
	value trad1_where___10_ 0='Unchecked' 1='Checked';
	value trad1_feel_ 1='Same' 2='Better' 
		3='Worse';
	value trad2_plant_ 1='Yes' 2='No';
	value trad2_raw_ 1='Root' 2='Bark' 
		3='Bulb' 4='Whole plant' 
		5='Leaves/stems' 6='Tubers' 
		7='Mixture';
	value trad2_process_ 1='Chopped' 2='Ground';
	value trad2_package_ 1='Yes' 2='No';
	value trad2_form_ 1='Powder' 2='Liquid' 
		3='Tablet' 9='Other';
	value trad2_route___1_ 0='Unchecked' 1='Checked';
	value trad2_route___2_ 0='Unchecked' 1='Checked';
	value trad2_route___3_ 0='Unchecked' 1='Checked';
	value trad2_route___4_ 0='Unchecked' 1='Checked';
	value trad2_route___5_ 0='Unchecked' 1='Checked';
	value trad2_where___1_ 0='Unchecked' 1='Checked';
	value trad2_where___2_ 0='Unchecked' 1='Checked';
	value trad2_where___3_ 0='Unchecked' 1='Checked';
	value trad2_where___4_ 0='Unchecked' 1='Checked';
	value trad2_where___5_ 0='Unchecked' 1='Checked';
	value trad2_where___6_ 0='Unchecked' 1='Checked';
	value trad2_where___7_ 0='Unchecked' 1='Checked';
	value trad2_where___8_ 0='Unchecked' 1='Checked';
	value trad2_where___9_ 0='Unchecked' 1='Checked';
	value trad2_where___10_ 0='Unchecked' 1='Checked';
	value trad2_feel_ 1='Same' 2='Better' 
		3='Worse';
	value trad3_plant_ 1='Yes' 2='No';
	value trad3_raw_ 1='Root' 2='Bark' 
		3='Bulb' 4='Whole plant' 
		5='Leaves/stems' 6='Tubers' 
		7='Mixture';
	value trad3_process_ 1='Chopped' 2='Ground';
	value trad3_package_ 1='Yes' 2='No';
	value trad3_form_ 1='Powder' 2='Liquid' 
		3='Tablet' 9='Other';
	value trad3_route___1_ 0='Unchecked' 1='Checked';
	value trad3_route___2_ 0='Unchecked' 1='Checked';
	value trad3_route___3_ 0='Unchecked' 1='Checked';
	value trad3_route___4_ 0='Unchecked' 1='Checked';
	value trad3_route___5_ 0='Unchecked' 1='Checked';
	value trad3_where___1_ 0='Unchecked' 1='Checked';
	value trad3_where___2_ 0='Unchecked' 1='Checked';
	value trad3_where___3_ 0='Unchecked' 1='Checked';
	value trad3_where___4_ 0='Unchecked' 1='Checked';
	value trad3_where___5_ 0='Unchecked' 1='Checked';
	value trad3_where___6_ 0='Unchecked' 1='Checked';
	value trad3_where___7_ 0='Unchecked' 1='Checked';
	value trad3_where___8_ 0='Unchecked' 1='Checked';
	value trad3_where___9_ 0='Unchecked' 1='Checked';
	value trad3_where___10_ 0='Unchecked' 1='Checked';
	value trad3_feel_ 1='Same' 2='Better' 
		3='Worse';
	value meds_arvs_ 1='with ARVs (1)' 2='Instead of ARVs (2)';
	value trad_side_effect_ 1='Yes' 2='No';
	value chemist_ 1='Yes' 2='No';
	value chemist_feel_ 1='Same (1)' 2='Better (2)' 
		3='Worse (3)';
	value alt_treat_ 1='Yes' 2='No';
	value alt_treat_feel_ 1='Same (1)' 2='Better (2)' 
		3='Worse (3)';
	value clinic_rec___1_ 0='Unchecked' 1='Checked';
	value clinic_rec___2_ 0='Unchecked' 1='Checked';
	value clinic_rec___3_ 0='Unchecked' 1='Checked';
	value clinic_rec___4_ 0='Unchecked' 1='Checked';
	value clinic_rec___5_ 0='Unchecked' 1='Checked';
	value clinic_rec___6_ 0='Unchecked' 1='Checked';
	value clinic_rec___7_ 0='Unchecked' 1='Checked';
	value alt_treatmentspiritu_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format faith faith_.;
	format faith_specify___1 faith_specify___1_.;
	format faith_specify___2 faith_specify___2_.;
	format faith_specify___3 faith_specify___3_.;
	format faith_specify___4 faith_specify___4_.;
	format faith_specify___5 faith_specify___5_.;
	format faith_active faith_active_.;
	format faith_arvs_stop faith_arvs_stop_.;
	format traditional_ever traditional_ever_.;
	format traditional_time traditional_time_.;
	format trad1_plant trad1_plant_.;
	format trad1_raw trad1_raw_.;
	format trad1_process trad1_process_.;
	format trad1_package trad1_package_.;
	format trad1_form trad1_form_.;
	format trad1_route___1 trad1_route___1_.;
	format trad1_route___2 trad1_route___2_.;
	format trad1_route___3 trad1_route___3_.;
	format trad1_route___4 trad1_route___4_.;
	format trad1_route___5 trad1_route___5_.;
	format trad1_where___1 trad1_where___1_.;
	format trad1_where___2 trad1_where___2_.;
	format trad1_where___3 trad1_where___3_.;
	format trad1_where___4 trad1_where___4_.;
	format trad1_where___5 trad1_where___5_.;
	format trad1_where___6 trad1_where___6_.;
	format trad1_where___7 trad1_where___7_.;
	format trad1_where___8 trad1_where___8_.;
	format trad1_where___9 trad1_where___9_.;
	format trad1_where___10 trad1_where___10_.;
	format trad1_feel trad1_feel_.;
	format trad2_plant trad2_plant_.;
	format trad2_raw trad2_raw_.;
	format trad2_process trad2_process_.;
	format trad2_package trad2_package_.;
	format trad2_form trad2_form_.;
	format trad2_route___1 trad2_route___1_.;
	format trad2_route___2 trad2_route___2_.;
	format trad2_route___3 trad2_route___3_.;
	format trad2_route___4 trad2_route___4_.;
	format trad2_route___5 trad2_route___5_.;
	format trad2_where___1 trad2_where___1_.;
	format trad2_where___2 trad2_where___2_.;
	format trad2_where___3 trad2_where___3_.;
	format trad2_where___4 trad2_where___4_.;
	format trad2_where___5 trad2_where___5_.;
	format trad2_where___6 trad2_where___6_.;
	format trad2_where___7 trad2_where___7_.;
	format trad2_where___8 trad2_where___8_.;
	format trad2_where___9 trad2_where___9_.;
	format trad2_where___10 trad2_where___10_.;
	format trad2_feel trad2_feel_.;
	format trad3_plant trad3_plant_.;
	format trad3_raw trad3_raw_.;
	format trad3_process trad3_process_.;
	format trad3_package trad3_package_.;
	format trad3_form trad3_form_.;
	format trad3_route___1 trad3_route___1_.;
	format trad3_route___2 trad3_route___2_.;
	format trad3_route___3 trad3_route___3_.;
	format trad3_route___4 trad3_route___4_.;
	format trad3_route___5 trad3_route___5_.;
	format trad3_where___1 trad3_where___1_.;
	format trad3_where___2 trad3_where___2_.;
	format trad3_where___3 trad3_where___3_.;
	format trad3_where___4 trad3_where___4_.;
	format trad3_where___5 trad3_where___5_.;
	format trad3_where___6 trad3_where___6_.;
	format trad3_where___7 trad3_where___7_.;
	format trad3_where___8 trad3_where___8_.;
	format trad3_where___9 trad3_where___9_.;
	format trad3_where___10 trad3_where___10_.;
	format trad3_feel trad3_feel_.;
	format meds_arvs meds_arvs_.;
	format trad_side_effect trad_side_effect_.;
	format chemist chemist_.;
	format chemist_feel chemist_feel_.;
	format alt_treat alt_treat_.;
	format alt_treat_feel alt_treat_feel_.;
	format clinic_rec___1 clinic_rec___1_.;
	format clinic_rec___2 clinic_rec___2_.;
	format clinic_rec___3 clinic_rec___3_.;
	format clinic_rec___4 clinic_rec___4_.;
	format clinic_rec___5 clinic_rec___5_.;
	format clinic_rec___6 clinic_rec___6_.;
	format clinic_rec___7 clinic_rec___7_.;
	format alt_treatmentspiritu_v_0 alt_treatmentspiritu_v_0_.;
	run;

proc contents data=redcap;

data brent.trt;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


proc contents data=brent.trt short varnum; run;
proc print;
var patient_id faith;
run;
