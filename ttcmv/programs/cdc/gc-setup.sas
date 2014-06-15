
/*
AGEMOS  		Child's age in months.
SEX 
HEIGHT 			Child's recumbent length or standing height in centimeters.
RECUMBNT 		Indicator of child's height measurement. 1 for recumbent length and 0 for standing height.
WEIGHT 			Child's weight in kilograms.
HEADCIR
*/


proc sort data = cmv.lbwi_demo; by id; 
proc sort data = cmv.med_review; by id;
	run;

data anthro_data; merge

	cmv.lbwi_demo	(	keep 	= id lbwidob gender
								rename 	= (gender = SEX)
								)
	cmv.med_review	(	keep 	= id dfseq AnthroMeasureDate HeightDate WeightDate HeadDate htlength weight headcircum
								rename 	= (htlength = HEIGHT headcircum = HEADCIR)
								)
	;
	by id;
run;

data cmv.height; set anthro_data;

	if HeightDate = . then HeightDate = AnthroMeasureDate;
	age_days = datdif(lbwidob, HeightDate, 'act/act');
	AGEMOS = age_days / 30;

	RECUMBNT = 1;

	keep id dfseq AGEMOS SEX RECUMBNT HEIGHT;

run;

data cmv.weight ; set anthro_data;

	if WeightDate = . then WeightDate = AnthroMeasureDate;
	age_days = datdif(lbwidob, WeightDate, 'act/act');
	AGEMOS = age_days / 30;

	WEIGHT = weight / 1000 ;

	keep id dfseq AGEMOS SEX WEIGHT;

run;

data cmv.headcir; set anthro_data;

	if HeadDate = . then HeadDate = AnthroMeasureDate;
	age_days = datdif(lbwidob, HeadDate, 'act/act');
	AGEMOS = age_days / 30;

	keep id dfseq AGEMOS SEX HEADCIR;

run;

data cmv.anthro; set anthro_data;

	age_days = datdif(lbwidob, AnthroMeasureDate, 'act/act'); *use just one date;
	AGEMOS = age_days / 30;

	WEIGHT = weight / 1000 ;
	RECUMBNT = 1;

	keep id dfseq AGEMOS SEX HEIGHT RECUMBNT WEIGHT HEADCIR; 

run;
	

/** WEIGHT *******************************************************************************************************/

%let datalib="/ttcmv/sas/data";				   									*subdirectory for your existing dataset;
%let datain=weight;     																*the name of your existing SAS dataset;
%let dataout=weight;   																	*the name of the dataset you wish to put the results into;
%let saspgm="/ttcmv/sas/programs/cdc/gc-calculate-BIV.sas"; 	*subdirectory for the downloaded program gc-calculate-BIV.sas;

Libname mydata &datalib;

data _INDATA; set mydata.&datain;

%include &saspgm;

data mydata.&dataout; set _INDATA;
proc means;

run;


data cmv.weight; set cmv.weight;
	keep id dfseq AGEMOS SEX WEIGHT WTPCT WAZ _BIVWT;

	label	AGEMOS = "Age in Months"
				SEX = "Sex"
				Weight = "Weight"
				WTPCT = "Percentile for weight-for-age"
				WAZ = "Z-score for weight-for-age"
				_BIVWT = "Outlier variable for weight-for-age (0  acceptable normal range; 1  too low; 2  too high)"
	;
run;	



/** HEADCIR *******************************************************************************************************/

%let datalib="/ttcmv/sas/data";				   									*subdirectory for your existing dataset;
%let datain=headcir;     																*the name of your existing SAS dataset;
%let dataout=headcir;    																*the name of the dataset you wish to put the results into;
%let saspgm="/ttcmv/sas/programs/cdc/gc-calculate-BIV.sas"; 	*subdirectory for the downloaded program gc-calculate-BIV.sas;

Libname mydata &datalib;

data _INDATA; set mydata.&datain;

%include &saspgm;

data mydata.&dataout; set _INDATA;
proc means;

run;


data cmv.headcir; set cmv.headcir;
	keep id dfseq AGEMOS SEX HEADCIR HCPCT HCZ;

	label 	AGEMOS = "Age in Months"
				SEX = "Sex"
				Headcir = "Head Circumference"
				HCPCT = "Percentile for head circumference-for-age"
				HCZ = "Z-score for head circumference-for-age"
	;
run;



/** HEIGHT *******************************************************************************************************/

%let datalib="/ttcmv/sas/data";				   									*subdirectory for your existing dataset;
%let datain=height;     																*the name of your existing SAS dataset;
%let dataout=height;    																*the name of the dataset you wish to put the results into;
%let saspgm="/ttcmv/sas/programs/cdc/gc-calculate-BIV.sas"; 	*subdirectory for the downloaded program gc-calculate-BIV.sas;

Libname mydata &datalib;

data _INDATA; set mydata.&datain;

%include &saspgm;

data mydata.&dataout; set _INDATA;
proc means;

run;


data cmv.height; set cmv.height;
	keep id dfseq AGEMOS SEX HEIGHT HTPCT HAZ _BIVHT;

	label 	AGEMOS = "Age in Months"
				SEX = "Sex"
				HEIGHT = "Height"
				HTPCT = "Percentile for height-for-age"
				HAZ = "Z-score for height-for-age"
				_BIVHT = "Outlier variable for height-for-age (0  acceptable normal range; 1  too low; 2  too high)"
	;
run;



/** ALL **********************************************************************************************************/

%let datalib="/ttcmv/sas/data";				   									*subdirectory for your existing dataset;
%let datain=anthro;     																*the name of your existing SAS dataset;
%let dataout=anthro;   																	*the name of the dataset you wish to put the results into;
%let saspgm="/ttcmv/sas/programs/cdc/gc-calculate-BIV.sas"; 	*subdirectory for the downloaded program gc-calculate-BIV.sas;

Libname mydata &datalib;

data _INDATA; set mydata.&datain;

%include &saspgm;

data mydata.&dataout; set _INDATA;
proc means;

run;


data cmv.anthro; set cmv.anthro;
	keep 
		id dfseq AGEMOS SEX HEIGHT RECUMBNT WEIGHT HEADCIR
		HTPCT HAZ WTPCT WAZ WHPCT WHZ BMIPCT BMIZ BMI HCPCT HCZ _BIVHT _BIVWT _BIVWHT _BIVBMI
	; 

	label	AGEMOS = "Age in Months"
				SEX = "Sex"

				Weight = "Weight"
				WTPCT = "Percentile for weight-for-age"
				WAZ = "Z-score for weight-for-age"
				_BIVWT = "Outlier variable for weight-for-age (0  acceptable normal range; 1  too low; 2  too high)"

				Headcir = "Head Circumference"
				HCPCT = "Percentile for head circumference-for-age"
				HCZ = "Z-score for head circumference-for-age"

				HEIGHT = "Height"
				HTPCT = "Percentile for height-for-age"
				HAZ = "Z-score for height-for-age"
				_BIVHT = "Outlier variable for height-for-age (0  acceptable normal range; 1  too low; 2  too high)"

				BMI = "Calculated body mass index value [weight(kg)/height(m)2]"
				BMIPCT = "Percentile for body mass index-for-age"
				BMIZ = "Z-score for body mass index-for-age"
				_BIVBMI = "Outlier variable for body mass index-for-age (0  acceptable normal range; 1  too low; 2  too high)"

				WHPCT = "Percentile for weight-for-height"	
				WHZ = "Z-score for weight-for-height"	
				_BIVWHT = "Outlier variable for weight-for-height (0  acceptable normal range; 1  too low; 2  too high)"
	;
run;
