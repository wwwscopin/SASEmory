/* concom_meds.sas 
 * 
 * merge concomitant meds plates, transpose all meds to one big listing
 */




data glnd.concom_meds;
	set glnd.plate18( keep = id
	  meds_1   med_code_1  meds_dose_1
        dt_meds_str_1  dt_meds_stp_1  meds_2   med_code_2  meds_dose_2
        dt_meds_str_2  dt_meds_stp_2  meds_3   med_code_3  meds_dose_3
        dt_meds_str_3  dt_meds_stp_3  meds_4   med_code_4  meds_dose_4
        dt_meds_str_4  dt_meds_stp_4  meds_5   med_code_5  meds_dose_5
        dt_meds_str_5  dt_meds_stp_5  meds_6   med_code_6  meds_dose_6
        dt_meds_str_6  dt_meds_stp_6  meds_7   med_code_7  meds_dose_7
        dt_meds_str_7  dt_meds_stp_7  meds_8   med_code_8  meds_dose_8
        dt_meds_str_8  dt_meds_stp_8  meds_9   med_code_9  meds_dose_9
        dt_meds_str_9  dt_meds_stp_9  meds_10   med_code_10
        meds_dose_10  dt_meds_str_10  dt_meds_stp_10  meds_11 
        med_code_11  meds_dose_11  dt_meds_str_11  dt_meds_stp_11
        meds_12   med_code_12  meds_dose_12  dt_meds_str_12
        dt_meds_stp_12  meds_13   med_code_13  meds_dose_13
        dt_meds_str_13  dt_meds_stp_13  meds_14   med_code_14
        meds_dose_14  dt_meds_str_14  dt_meds_stp_14  )

	glnd.plate19( keep = id
	  meds_1   med_code_1  meds_dose_1
        dt_meds_str_1  dt_meds_stp_1  meds_2   med_code_2  meds_dose_2
        dt_meds_str_2  dt_meds_stp_2  meds_3   med_code_3  meds_dose_3
        dt_meds_str_3  dt_meds_stp_3  meds_4   med_code_4  meds_dose_4
        dt_meds_str_4  dt_meds_stp_4  meds_5   med_code_5  meds_dose_5
        dt_meds_str_5  dt_meds_stp_5  meds_6   med_code_6  meds_dose_6
        dt_meds_str_6  dt_meds_stp_6  meds_7   med_code_7  meds_dose_7
        dt_meds_str_7  dt_meds_stp_7  meds_8   med_code_8  meds_dose_8
        dt_meds_str_8  dt_meds_stp_8  meds_9   med_code_9  meds_dose_9
        dt_meds_str_9  dt_meds_stp_9  meds_10   med_code_10
        meds_dose_10  dt_meds_str_10  dt_meds_stp_10  meds_11 
        med_code_11  meds_dose_11  dt_meds_str_11  dt_meds_stp_11
        meds_12   med_code_12  meds_dose_12  dt_meds_str_12
        dt_meds_stp_12  meds_13   med_code_13  meds_dose_13
        dt_meds_str_13  dt_meds_stp_13  meds_14   med_code_14
        meds_dose_14  dt_meds_str_14  dt_meds_stp_14  )


;

		
	if (med_code_1 ~= .) then do; meds= meds_1; 	med_code= med_code_1;	meds_dose= meds_dose_1;	dt_meds_str= dt_meds_str_1;  dt_meds_stp= dt_meds_stp_1; output; end;
	if (med_code_2 ~= .) then do; meds= meds_2; 	med_code= med_code_2;	meds_dose= meds_dose_2;	dt_meds_str= dt_meds_str_2;  dt_meds_stp= dt_meds_stp_2; output; end;
	if (med_code_3 ~= .) then do; meds= meds_3; 	med_code= med_code_3;	meds_dose= meds_dose_3;	dt_meds_str= dt_meds_str_3;  dt_meds_stp= dt_meds_stp_3; output; end;
	if (med_code_4 ~= .) then do; meds= meds_4; 	med_code= med_code_4;	meds_dose= meds_dose_4;	dt_meds_str= dt_meds_str_4;  dt_meds_stp= dt_meds_stp_4; output; end;
	if (med_code_5 ~= .) then do; meds= meds_5; 	med_code= med_code_5;	meds_dose= meds_dose_5;	dt_meds_str= dt_meds_str_5;  dt_meds_stp= dt_meds_stp_5; output; end;
	if (med_code_6 ~= .) then do; meds= meds_6; 	med_code= med_code_6;	meds_dose= meds_dose_6;	dt_meds_str= dt_meds_str_6;  dt_meds_stp= dt_meds_stp_6; output; end;
	if (med_code_7 ~= .) then do; meds= meds_7; 	med_code= med_code_7;	meds_dose= meds_dose_7;	dt_meds_str= dt_meds_str_7;  dt_meds_stp= dt_meds_stp_7; output; end;
	if (med_code_8 ~= .) then do; meds= meds_8; 	med_code= med_code_8;	meds_dose= meds_dose_8;	dt_meds_str= dt_meds_str_8;  dt_meds_stp= dt_meds_stp_8; output; end;
	if (med_code_9 ~= .) then do; meds= meds_9; 	med_code= med_code_9;	meds_dose= meds_dose_9;	dt_meds_str= dt_meds_str_9;  dt_meds_stp= dt_meds_stp_9; output; end;
	if (med_code_10 ~= .) then do; meds= meds_10; 	med_code= med_code_10;	meds_dose= meds_dose_10;	dt_meds_str= dt_meds_str_10;  dt_meds_stp= dt_meds_stp_10; output; end;
	if (med_code_11 ~= .) then do; meds= meds_11; 	med_code= med_code_11;	meds_dose= meds_dose_11;	dt_meds_str= dt_meds_str_11;  dt_meds_stp= dt_meds_stp_11; output; end;
	if (med_code_12 ~= .) then do; meds= meds_12; 	med_code= med_code_12;	meds_dose= meds_dose_12;	dt_meds_str= dt_meds_str_12;  dt_meds_stp= dt_meds_stp_12; output; end;
	if (med_code_13 ~= .) then do; meds= meds_13; 	med_code= med_code_13;	meds_dose= meds_dose_13;	dt_meds_str= dt_meds_str_13;  dt_meds_stp= dt_meds_stp_13; output; end;
	if (med_code_14 ~= .) then do; meds= meds_14; 	med_code= med_code_14;	meds_dose= meds_dose_14;	dt_meds_str= dt_meds_str_14;  dt_meds_stp= dt_meds_stp_14; output; end;

	format med_code med_code.;
	format dt_meds_str mmddyy.;
	format dt_meds_stp mmddyy.;

	label 
		dt_meds_str = "Start date"
		dt_meds_stp = "Stop date"
		meds = "Medication name"
		med_code = "Medication type"
		meds_dose = "Dose (mg)"
		;


	drop 	  meds_1   med_code_1  meds_dose_1
        dt_meds_str_1  dt_meds_stp_1  meds_2   med_code_2  meds_dose_2
        dt_meds_str_2  dt_meds_stp_2  meds_3   med_code_3  meds_dose_3
        dt_meds_str_3  dt_meds_stp_3  meds_4   med_code_4  meds_dose_4
        dt_meds_str_4  dt_meds_stp_4  meds_5   med_code_5  meds_dose_5
        dt_meds_str_5  dt_meds_stp_5  meds_6   med_code_6  meds_dose_6
        dt_meds_str_6  dt_meds_stp_6  meds_7   med_code_7  meds_dose_7
        dt_meds_str_7  dt_meds_stp_7  meds_8   med_code_8  meds_dose_8
        dt_meds_str_8  dt_meds_stp_8  meds_9   med_code_9  meds_dose_9
        dt_meds_str_9  dt_meds_stp_9  meds_10   med_code_10
        meds_dose_10  dt_meds_str_10  dt_meds_stp_10  meds_11 
        med_code_11  meds_dose_11  dt_meds_str_11  dt_meds_stp_11
        meds_12   med_code_12  meds_dose_12  dt_meds_str_12
        dt_meds_stp_12  meds_13   med_code_13  meds_dose_13
        dt_meds_str_13  dt_meds_stp_13  meds_14   med_code_14
        meds_dose_14  dt_meds_str_14  dt_meds_stp_14 ;
run;

proc print data = glnd.concom_meds;
