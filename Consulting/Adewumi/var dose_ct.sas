PROC IMPORT OUT= WORK.TMP 
            DATAFILE= "H:\SAS_Emory\Consulting\Adewumi\Variatbility in CT doses data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$B3:K340"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents data=tmp; run;
proc contents data=tmp short varnum; run;
proc print data=tmp(firstobs=280 );run;
*/


data ct;
	set tmp(rename=(Head_ED__mSv_=Head_ED Neck_DLP=Neck_DLP0 Chest_DLP=Chest_DLP0 Abdomen_Pelvis_DLP=Abdomen_Pelvis_DLP0 Extrem_DLP=Extrem_DLP0));
	Head_DLP=Head_DLP__mGy_cm_+0;
	Neck_DLP=Neck_DLP0+0;
	Chest_DLP=Chest_DLP0+0;
	Abdomen_Pelvis_DLP=Abdomen_Pelvis_DLP0+0;
	Extrem_DLP=Extrem_DLP0+0;

	if Head_DLP=0 then Head_DLP=.;  
	if Head_ED=0 then Head_ED=.;
	if Neck_DLP=0 then Neck_DLP=.;
	if Neck_ED=0 then neck_ED=.;
	if Chest_DLP=0 then Chest_DLP=.;
	if Chest_ED=0 then Chest_ED=.;
	if Abdomen_Pelvis_DLP=0 then Abdomen_Pelvis_DLP=.;
	if Abdomen_Pelvis_ED=0 then Abdomen_Pelvis_ED=.;
	if Extrem_DLP=0 then Extrem_DLP=.;
	if Extrem_ED=0 then Extrem_ED=.;
	keep Head_DLP Head_ED Neck_DLP Neck_ED Chest_DLP Chest_ED Abdomen_Pelvis_DLP Abdomen_Pelvis_ED Extrem_DLP Extrem_ED;
run;

proc means data=ct n mean std median Q1 Q3 min max maxdec=2;
	var Head_DLP Head_ED Neck_DLP Neck_ED Chest_DLP Chest_ED Abdomen_Pelvis_DLP Abdomen_Pelvis_ED Extrem_DLP Extrem_ED;
run;
