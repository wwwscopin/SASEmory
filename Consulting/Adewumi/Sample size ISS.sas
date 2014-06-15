PROC IMPORT OUT= WORK.TMP 
            DATAFILE= "H:\SAS_Emory\Consulting\Adewumi\Radiation Exposure Data_Round 2_Stats Analysis_v2.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="data$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents data=tmp; run;
proc print data=tmp(firstobs=280 );run;
*/

proc format;
value LOS 0="0 nights" 1="1-3 nights"  2="4-6 nights" 3="7-9 nights" 4="10+ nights";
value Age 1="0-10yo" 2="11-20yo" 3="21-30yo" 4="31-40yo";
value Sex 0="M" 1="F";
value ap 0="absent" 1="present";
value Mechanism 0 ="Penetrating/Blunt" 1="Penetrating" 2="Blunt" 3="Neither";
value GCS 1="(3-5)"  2="(6-8)" 3="(9-12)"  4="(13-15)" 5="(not assessed)";
value ISS 0="ISS<16"  1="ISS >/= 16";
value loc 1="head" 2="face" 3="chest" 4="abdomen" 5="extremity" 6="external";
value group 1="MVC/MCA" 2="GSW";
value idx 1="LOS" 2="Age" 3="Sex" 4="GCS" 5="ISS" 6="Mechanism" 7="Injury" 8="Group";
run;

data rad0;
	set tmp(rename=(total_iss=total_iss0) drop=iss);
	MM=MVC_MCA_+0; if mm=. then mm=0;
	face=f13+0; if face=. then face=0;
	chest=f14+0; if chest=. then chest=0;
	external=f17+0; if external=. then external=0;
	total_iss=total_iss0+0;

	if f15=. then f15=0;
	if f16=. then f16=0;
	if gsw_=. then gsw_=0;

	if _n_>1;
	if Encounter__=. then delete;
	if Injury_Location_=. then Injury_Location_=0;

	/*if Duration_of_Stay=0 then los=0; else if Duration_of_Stay<=3 then los=1; else if Duration_of_Stay<=6 then los=2;
		else if Duration_of_Stay<=9 then los=3; else if Duration_of_Stay>=10 then los=4;
	*/

	if 0<age<=10 then gage=1;  else if 10<age<=20 then gage=2; else if 20<age<=30 then gage=3;  else if 30<age<=40 then gage=4; 

	if 3<=GCS_at_adm<=5 then gcs=1;  else if 5<GCS_at_adm<=8 then gcs=2; else if 8<GCS_at_adm<=12 then gcs=3;  
		else if 12<GCS_at_adm<=15 then gcs=4; else gcs=5;

	if  total_iss>=16 then iss=1; else iss=0;

	if mechanism=. then mechanism=0;

	if f54=0 then f54=.; 
	if f77=0 then f77=.; 
	if rad=0 then rad=.;

	if LOS_Group=13 then los_group=4;
	keep Encounter__  Age gage sex Mechanism GSW_ Injury_Location_ TOTAL_RAD__mSv_ total_iss iss
		face chest external f15-f16 f53-f54 f76-f77 mm Duration_of_Stay LOS_Group GCS_at_adm gcs Age_Group;
	rename Encounter__=id GSW_=gsw Injury_Location_=head TOTAL_RAD__mSv_=rad F15=Abdomen F16=Extremity f53=xray 
		f54=dose_xray f76=ct f77=dose_ct LOS_Group=los;
run;


data rad;
	set rad0;
	format los los. gage age_group age. gcs gcs. sex sex.  mechanism mechanism.  mm gsw head face chest abdomen extremity external ap. iss iss. ;
	if nmiss(of id los age sex gcs mechanism  mm gsw head face chest abdomen extremity external iss xray dose_xray ct dose_ct rad ) then idx=1; else idx=0;
	pct=dose_ct/rad*100;
run;


data size;
	set rad;
	keep id los age sex gcs iss mechanism head face chest abdomen extremity external gage mm gsw Age_Group;
run;

proc print;run;

proc means data=size n mean std maxdec=1;
	class sex gage;
	var age;
run;
proc means data=size n mean std maxdec=1;
	class mm;
	var age;
run;


proc means data=rad n mean std median Q1 Q3 min max maxdec=2;
	var dose_xray dose_ct rad pct;
run;

data rad_long1;
	set rad(where=(head=1) keep=head rad dose_xray dose_ct in=A)
		rad(where=(face=1) keep=face rad dose_xray dose_ct in=B)
		rad(where=(chest=1) keep=chest rad dose_xray dose_ct in=C)
		rad(where=(abdomen=1) keep=abdomen rad dose_xray dose_ct in=D)
		rad(where=(extremity=1) keep=extremity rad dose_xray dose_ct in=E)
		rad(where=(external=1) keep=external rad dose_xray dose_ct in=F)
		;
	 if A then loc=1;
	 if B then loc=2;
	 if C then loc=3;
	 if D then loc=4;
	 if E then loc=5;
	 if F then loc=6;
	 format loc loc.;
run;

data rad_long2;
	set rad(where=(mm=1) keep=mm rad dose_xray dose_ct in=A)
		rad(where=(gsw=1) keep=gsw rad dose_xray dose_ct in=B)
		;
	 if A then group=1;
	 if B then group=2;
	 format group group.;
run;


proc corr data=rad spearman;
	var xray dose_xray ct dose_ct;
run;

%let pm=%sysfunc(byte(177)); 

%macro rad(data, gvar, var, idx);
proc means data=&data mean stddev Q1 median Q3 min max maxdec=1;
	class &gvar;
	var &var;
	output out=tab n(&var)=rn mean(&var)=rmean std(&var)=rstd median(&var)=rmedian q1(&var)=rQ1 q3(&var)=rQ3 min(&var)=rmin max(&var)=rmax;
run;

*ods trace on/label listing;
proc npar1way data=&data wilcoxon;
	class &gvar;
	var &var;
	ods output KruskalWallisTest=wp;
run;
*ods trace off;

data tab&idx;
	length code mean_std mq mm $20 cvalue1 $10;
	merge tab(where=(_type_=1)) wp(firstobs=3 keep=cValue1);
	idx=&idx;
	drop _type_ _FREQ_;
	format mean std median Q1 Q3 min max 5.1 idx idx.; 
	if &idx=1 then code=put(&gvar, los.);
	if &idx=2 then code=put(&gvar, age.);
	if &idx=3 then code=put(&gvar, sex.);
	if &idx=4 then code=put(&gvar, gcs.);
	if &idx=5 then code=put(&gvar, iss.);
	if &idx=6 then code=put(&gvar, mechanism.);
	if &idx=7 then code=put(&gvar, loc.);
	if &idx=8 then code=put(&gvar, group.);

	mean_std=compress(put(rmean,5.1))||" &pm "|| compress(put(rstd,5.1));
	mQ=compress(put(rmedian,5.1))||"["||compress(put(rQ1,5.1))||" - "||compress(put(rQ3,5.1))||"]";
	mm=compress(put(rmin,5.1))||" - "||compress(put(rmax,5.1));
	keep idx code rn mean_std mq mm cvalue1;
run;

%mend rad;

%rad(rad,los,dose_xray, 1);
%rad(rad,gage, dose_xray,2);
%rad(rad,sex,dose_xray,3);
%rad(rad,gcs,dose_xray,4);
%rad(rad,iss,dose_xray,5);
%rad(rad,mechanism,dose_xray,6);
%rad(rad_long1,loc,dose_xray,7);
%rad(rad_long2,group,dose_xray,8);
quit;

data tab;
	set tab1 tab2 tab3 tab4 tab5 tab6 tab7 tab8;
run;


options orientation=portrait nodate;
ods rtf file="rad_xray_corr.rtf" style=journal startpage=no bodytitle;
 proc report data=tab nowindows split="*" style(column)=[just=center];
      title 'Test of Association of X-Ray';
	  column idx code rn mean_std mq mm cvalue1;
	  define idx/"Variable" order=internal group format=idx.;
	  define code/" " ;
	  define rn/"n";
	  define mean_std/"Mean &pm STD";
	  define mq/"Median[Q1-Q3]";
	  define mm/"Min-Max";
	  define cvalue1/"p value";
  run;
ods rtf close;

%rad(rad,los,dose_ct, 1);
%rad(rad,gage, dose_ct,2);
%rad(rad,sex,dose_ct,3);
%rad(rad,gcs,dose_ct,4);
%rad(rad,iss,dose_ct,5);
%rad(rad,mechanism,dose_ct,6);
%rad(rad_long1,loc,dose_ct,7);
%rad(rad_long2,group,dose_ct,8);
quit;

data tab;
	set tab1 tab2 tab3 tab4 tab5 tab6 tab7 tab8;
run;


options orientation=portrait nodate;
ods rtf file="rad_ct_corr.rtf" style=journal startpage=no bodytitle;
 proc report data=tab nowindows split="*" style(column)=[just=center];
      title 'Test of Association of CT';
	  column idx code rn mean_std mq mm cvalue1;
	  define idx/"Variable" order=internal group format=idx.;
	  define code/" " ;
	  define rn/"n";
	  define mean_std/"Mean &pm STD";
	  define mq/"Median[Q1-Q3]";
	  define mm/"Min-Max";
	  define cvalue1/"p value";
  run;
ods rtf close;



%rad(rad,los,rad, 1);
%rad(rad,gage, rad,2);
%rad(rad,sex,rad,3);
%rad(rad,gcs,rad,4);
%rad(rad,iss,rad,5);
%rad(rad,mechanism,rad,6);
%rad(rad_long1,loc,rad,7);
%rad(rad_long2,group,rad,8);
quit;

data tab;
	set tab1 tab2 tab3 tab4 tab5 tab6 tab7 tab8;
run;


options orientation=portrait nodate;
ods rtf file="rad_rad_corr.rtf" style=journal startpage=no bodytitle;
 proc report data=tab nowindows split="*" style(column)=[just=center];
      title 'Test of Association of Total RAD(X-ray + CT)';
	  column idx code rn mean_std mq mm cvalue1;
	  define idx/"Variable" order=internal group format=idx.;
	  define code/" " ;
	  define rn/"n";
	  define mean_std/"Mean &pm STD";
	  define mq/"Median[Q1-Q3]";
	  define mm/"Min-Max";
	  define cvalue1/"p value";
  run;
ods rtf close;