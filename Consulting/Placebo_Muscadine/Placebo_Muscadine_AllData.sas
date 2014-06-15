%let path=H:\SAS_Emory\Placebo_Muscadine;
*%let path=D:\Emory\Placebo_Muscadine;
%put &path;

PROC IMPORT OUT= B572
            DATAFILE= "&path\B572_GMS_TZ(2).xls" 
            DBMS=EXCEL REPLACE;
     SHEET="Data Summary"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

Data BDataA;
	set B572;
	Date=mdy(04,11,10);
	sample= scan(Sample_Set__B572,1,' ');
	vd= scan(Sample_Set__B572,2,' ');
	visit=substr(vd,2,1)+0;
	day=substr(vd,4,1)+0;
	time=compress(scan(Sample_Set__B572,3,' '),'hr');
	CySS=F2+0; Cys=F3+0; CySGSH=F4+0; GSH=F5+0; GSSG=F6+0; GSSG_GSH=F7+0;	CySS_Cys=F8+0; Total_GSH=F9+0; Total_Cys=F10+0;
	if 5<_n_<34;
	if time='bsln' then time=0;
	if time='1/2' then time=0.5;
	t=time+0;
	if t=. then t=0;
	drop  Sample_Set__B572 time F2-F10 vd;
	format date date9.;
run;


PROC IMPORT OUT= B612
            DATAFILE= "&path\B612(1).xls" 
            DBMS=EXCEL REPLACE;
     SHEET="Data Summary"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

Data BDataB;
	set B612;
	Date=mdy(09,22,10);
	sample= scan(Sample_Set__B612,1,' ');
	vd= scan(Sample_Set__B612,2,' ');
	if substr(vd,1,3)='vid' then vd='v1d'||substr(vd,4,1);
	visit=substr(vd,2,1)+0;
	day=substr(vd,4,1)+0;
	time=compress(scan(Sample_Set__B612,3,' '),'hr');
	CySS=F2+0;	Cys=F3+0; CySGSH=F4+0; GSH=F5+0; GSSG=F6+0; GSSG_GSH=F7+0; CySS_Cys=F8+0; Total_GSH=F9+0; Total_Cys=F10+0;
	if 5<_n_<62;
	if time='bsline' then time=0;
	t=time+0;
	drop  Sample_Set__B612 time F2-F10 vd;
	format date date9.;
run;

proc format;
	value group 1='Muscadine'
			 	0='Placebo'
		 ;
	value var 1='CySS'
			  2='Cys'
			  3='GSH'
			  4='GSSG'
			  5='GSSG-GSH'
			  6='CySS-Cys'
			  7='Total-GSSG'
			  8='Total-Cys'
		 ;
	value id  1='MGS-001'
			  3='MGS-003'
			  4='MGS-004'
		 ;
	value dd 0=" " 2=" " 3=" " 5=" "
			1='Pre-challenge'
			4='Post-challenge'
		;
	value index 0=" " 1='d1*b' 2='d1*0.5h' 3='d1*1h' 4='d1*2h' 5='d1*4h' 6='d1*6h' 7='d2*b' 8='d3*b' 9='d4*b' 10='d4*0.5h' 
				11='d4*1h' 12='d4*2h' 13='d4*4h' 14='d4*6h' 15='d1*b' 16='d1*0.5h' 17='d1*1h' 18='d1*2h' 19='d1*4h' 20='d1*6h' 
				21='d2*b' 22='d3*b' 23='d4*b' 24='d4*0.5h' 25='d4*1h' 26='d4*2h' 27='d4*4h' 28='d4*6h' 29=" "
			;
run;

Data Bdata;
	set BdataA BDataB;
	if sample='MGS001' then 
	do;
		sample='MGS-001';
		id=1;
		if visit=1 then group=1;
		if visit=2 then group=0;
	end;

	if sample='MGS-003' then 
	do;
		id=3;
		if visit=1 then group=0;
		if visit=2 then group=1;
	end;

	if sample='MGS-004' then 
	do;
		id=4;
		if visit=1 then group=1;
		if visit=2 then group=0;
	end;
	
	format group group. id id.;
run;

proc sort data=Bdata; by id group day t;run;

data id1 id3 id4;
	set Bdata;
	if id=1 then output id1;
	if id=3 then output id3;
	if id=4 then output id4;
run;

data id1;
	set id1;
	index=_n_;
run;

data id3;
	set id3;
	index=_n_;
run;

data id4;
	set id4;
	index=_n_;
	/*if index=26 then do; Cys=.; CySS_Cys=.; end;*/
run;

data id;
	set id1 id3 id4;
run;

proc print;run;
*ods trace on/label listing;

%macro PM(dataset,var);
ods output Mixed.Tests3=p;
ods output Mixed.Estimates=E_&var;
ods output Mixed.Contrasts=C_&var;
ods output Mixed.LSMeans=&var;
proc MIXED data=&dataset; *plots=boxplot(observed);
class id index;
model &var=index; 
repeated /type=cs subject=id;
lsmeans index /pdiff cl;

contrast 'Placebo Day1[b,0.5,1,2,4hr] vs Placebo Day4[b,0.5,1,2,4hr]' index 1   1   1   1   1   0 0 0 -1   -1   -1   -1   -1   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
*estimate 'Placebo Day1[b,0.5,1,2,3,4hr] vs Placebo Day4[b,0.5,1,2,3,4hr]' index 0.2 0.2 0.2 0.2 0.2 0 0 0 -0.2 -0.2 -0.2 -0.2 -0.2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;

contrast 'Muscadine Day1[b,0.5,1,2,4hr] vs Muscadine Day4[b,0.5,1,2,4hr]' index 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1   1   1   1   1   0 0 0 -1   -1   -1   -1   -1   0;
*estimate 'Muscadine Day1[b,0.5,1,2,3,4hr] vs Muscadine Day4[b,0.5,1,2,3,4hr]' index 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0.2 0.2 0.2 0.2 0 0 0 -0.2 -0.2 -0.2 -0.2 -0.2 0;

* for day1 between placebo and muscadine;
contrast 'Pre- Placebo Day1[b,0.5,1,2,4hr] vs Pre- Muscadine Day1[b,0.5,1,2,4hr]' index 1   1   1   1   1   0 0 0 0 0 0 0 0 0 -1   -1   -1   -1   -1   0 0 0 0 0 0 0 0 0;
estimate 'Placebo Day1[b,0.5,1,2,4hr]' intercept 1 index 0.2 0.2 0.2 0.2 0.2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
estimate 'Muscadine Day1[b,0.5,1,2,4hr]' intercept 1 index 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0.2 0.2 0.2 0.2 0 0 0 0 0 0 0 0 0;
*estimate 'Placebo Day1[b,0.5,1,2,3,4hr] vs Muscadine Day1[b,0.5,1,2,3,4hr]' index 0.2 0.2 0.2 0.2 0.2 0 0 0 0 0 0 0 0 0 -0.2 -0.2 -0.2 -0.2 -0.2 0 0 0 0 0 0 0 0 0;

* check the mean for part of the data;
*estimate 'Day1 Mean for Placebo' intercept 1 index 0.2 0.2 0.2 0.2 0.2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;

* for day4 between placebo and muscadine;
contrast 'Post- Placebo Day4[b,0.5,1,2,4hr] vs Post- Muscadine Day4[b,0.5,1,2,4hr]' index 0 0 0 0 0 0 0 0 1   1   1   1   1   0 0 0 0 0 0 0 0 0 -1   -1   -1   -1   -1   0;
estimate 'Placebo Day4[b,0.5,1,2,4hr]' intercept 1 index 0 0 0 0 0 0 0 0 0.2 0.2 0.2 0.2 0.2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
estimate 'Muscadine Day4[b,0.5,1,2,4hr]' intercept 1 index 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0.2 0.2 0.2 0.2 0;
*estimate 'Placebo Day4[b,0.5,1,2,3,4hr] vs Muscadine Day4[b,0.5,1,2,3,4hr]' index 0 0 0 0 0 0 0 0 0.2 0.2 0.2 0.2 0.2 0 0 0 0 0 0 0 0 0 -0.2 -0.2 -0.2 -0.2 -0.2 0;

/*
* for baseline between placebo and muscadine;
contrast 'Baseline between Placebo and Muscadine' index 1    0 0 0 0 0 1    1    1    0 0 0 0 0 -1    0 0 0 0 0 -1    -1    -1    0 0 0 0 0;
estimate 'Baseline between Placebo and Muscadine' index 0.25 0 0 0 0 0 0.25 0.25 0.25 0 0 0 0 0 -0.25 0 0 0 0 0 -0.25 -0.25 -0.25 0 0 0 0 0;
*/



run;

data _null_;
	set p;
	%if &var=Cys or &var=CySS_Cys %then %do; call symput('p', compress(put(probF,5.3))); %end;
	%else %do; call symput('p', compress(put(probF,4.2))); %end;
run;

/*
proc sort data=E_&var; by label;run;
proc sort data=C_&var; by label;run;

Data  E_&var;
	merge E_&var(drop=DF Probt) C_&var(keep=label FValue ProbF); by label;
run;
*/

data &var;
	set &var;
	index=_n_;
run;

data &var.0;
	merge id1(keep=group day t &var index rename=(&var=data1)) id3(keep=index &var rename=(&var=data3))
	id4(keep=index &var rename=(&var=data4)) &var; by index;
run;

data &var._mean;
	set &var.0;
	*index2= (index - .2) + .4*uniform(3654);
	index1= (index + .1) ;
	index2= (index - .1) ;
	
	ind=index;
	if index>14 then ind=index-14;

	amean=upper;
	seq=1;
	output;
	amean=lower;
	seq=2;
	output;
	amean=estimate;
	seq=3;
	output;
	drop upper lower estimate;
	format estimate 5.0;
run;

goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

axis1 	label=(f=zapf h=3 "Day and Hours") split="*"  value=(f=zapf h=1.6) order= (0 to 29 by 1) minor=none offset=(0 in, 0 in);

axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) ;

symbol1 i=HILOCTJ ci=black value=dot h=1 w=2;
symbol2 i=none ci=red value=circle h=2 w=2;
symbol3 i=none ci=green value=triangle h=2 w=2;
symbol4 i=none ci=blue value=square h=2 w=2;
%if &var^=CySS_Cys %then %do;
legend1 across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=2 "Mean" "MGS-001" "MGS-003" "MGS-004") offset=(0.4in, -0.4 in) frame;
%end;

%else %do;
legend1 across = 1 position=(bottom center inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=2 "Mean" "MGS-001" "MGS-003" "MGS-004") offset=(0, +0.4 in) frame;
axis2 	label=(f=zapf h=3 a=90 "&var") split="*"  value=(f=zapf h=3) order= (-100 to -60 by 5);
%end;
/*
%if &var=Cys %then %do;
legend1 across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=2 "Mean" "MGS-001" "MGS-003" "MGS-004") offset=(0.4in, -0.4 in) frame;
%end;
*/

title &var (mV) (p=&p);
footnote justify=c font=zapf color=black height=3 pct                          
     "First d1-d4, Data from Placebo; Second d1-d4, Data from Muscadine.";                     
run;  

proc gplot data=&var._mean gout=cat;
	plot amean*index data1*index2 data3*index2 data4*index2/overlay haxis = axis1 vaxis = axis2 legend=legend1;
	*plot amean*index/haxis = axis1 vaxis = axis2 legend=legend1;
	format index index.;
run;
title " ";
footnote " ";
%mend;
%PM(id,CySS); quit;
%PM(id,Cys); quit;
%PM(id,GSH); quit;
%PM(id,GSSG); quit;
%PM(id,GSSG_GSH); quit;
%PM(id,CySS_Cys); quit;
*ods listing close;
/*%PM(id,CySS_Cys); quit;*/
/*
%PM(id,Total_GSH); quit;
%PM(id,Total_Cys); quit;
*/

data PM_data;
	set CySS0(in=CySS) Cys0(in=Cys) GSH0(In=GSH) GSSG0(in=GSSG) GSSG_GSH0(in=GSSG_GSH) CySS_Cys0(in=CySS_Cys); /*Total_GSH(in=Total_GSH) Total_Cys(in=Total_Cys);*/
	if Cyss then var=1;
		if Cys then var=2;
			if GSH then var=3;
				if GSSG then var=4;
					if GSSG_GSH then var=5;
						if CySS_Cys then var=6;
							/*if Total_GSH then var=7;
								if Total_Cys then var=8;*/
	CI="("||compress(put(Lower,5.2))||", "||compress(put(Upper,5.2))||")";
	drop effect;
	format estimate StdErr Lower Upper 6.2 var var.;
run;


data C_Contrast;
	set C_CySS(in=CySS) C_Cys(in=Cys) C_GSH(In=GSH) C_GSSG(in=GSSG) C_GSSG_GSH(in=GSSG_GSH) C_CySS_Cys(in=CySS_Cys); /*Total_GSH(in=Total_GSH) Total_Cys(in=Total_Cys);*/
	if Cyss then var=1;
		if Cys then var=2;
			if GSH then var=3;
				if GSSG then var=4;
					if GSSG_GSH then var=5;
						if CySS_Cys then var=6;
							/*if Total_GSH then var=7;
								if Total_Cys then var=8;*/
	format ProbF 4.2 var var.;
run;
proc sort;by var;run;

data E_Contrast;
	set E_CySS(in=CySS) E_Cys(in=Cys) E_GSH(In=GSH) E_GSSG(in=GSSG) E_GSSG_GSH(in=GSSG_GSH) E_CySS_Cys(in=CySS_Cys); /*Total_GSH(in=Total_GSH) Total_Cys(in=Total_Cys);*/
	if Cyss then var=1;
		if Cys then var=2;
			if GSH then var=3;
				if GSSG then var=4;
					if GSSG_GSH then var=5;
						if CySS_Cys then var=6;
							/*if Total_GSH then var=7;
								if Total_Cys then var=8;*/
	format estimate StdErr 6.2 var var.;
run;
proc sort;by var;run;


data _null_;
	set E_contrast;
	if var=2 then do;
	if label='Placebo Day1[b,0.5,1,2,4hr]' then call symput('pd1_2',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	if label='Placebo Day4[b,0.5,1,2,4hr]' then call symput('pd4_2',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	if label='Muscadine Day1[b,0.5,1,2,4hr]' then call symput('md1_2',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	if label='Muscadine Day4[b,0.5,1,2,4hr]' then call symput('md4_2',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	end;

	if var=6 then do;
	if label='Placebo Day1[b,0.5,1,2,4hr]' then call symput('pd1_6',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	if label='Placebo Day4[b,0.5,1,2,4hr]' then call symput('pd4_6',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	if label='Muscadine Day1[b,0.5,1,2,4hr]' then call symput('md1_6',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	if label='Muscadine Day4[b,0.5,1,2,4hr]' then call symput('md4_6',put(estimate, 6.2)||"±"||compress(put(stderr, 6.2)));
	end;

run; 

%put &md4_2;

data Contrast;
	set C_contrast;
	if var=2 then do;
	if label='Placebo Day1[b,0.5,1,2,4hr] vs Placebo Day4[b,0.5,1,2,4hr]' then item="&pd1_2"||" vs "||"&pd4_2";
	if label='Muscadine Day1[b,0.5,1,2,4hr] vs Muscadine Day4[b,0.5,1,2,4hr]' then item="&md1_2"||" vs "||"&md4_2";
	if label='Pre- Placebo Day1[b,0.5,1,2,4hr] vs Pre- Muscadine Day1[b,0.5,1,2,4hr]' then item="&pd1_2"||" vs "||"&md1_2";
	if label='Post- Placebo Day4[b,0.5,1,2,4hr] vs Post- Muscadine Day4[b,0.5,1,2,4hr]' then item="&pd4_2"||" vs "||"&md4_2";
	end;

	if var=6 then do;
	if label='Placebo Day1[b,0.5,1,2,4hr] vs Placebo Day4[b,0.5,1,2,4hr]' then item="&pd1_6"||" vs "||"&pd4_6";
	if label='Muscadine Day1[b,0.5,1,2,4hr] vs Muscadine Day4[b,0.5,1,2,4hr]' then item="&md1_6"||" vs "||"&md4_6";
	if label='Pre- Placebo Day1[b,0.5,1,2,4hr] vs Pre- Muscadine Day1[b,0.5,1,2,4hr]' then item="&pd1_6"||" vs "||"&md1_6";
	if label='Post- Placebo Day4[b,0.5,1,2,4hr] vs Post- Muscadine Day4[b,0.5,1,2,4hr]' then item="&pd4_6"||" vs "||"&md4_6";
	end;

	label item='Mean ± SEM';

run;

proc print;run;


options ORIENTATION="LANDSCAPE";
/*proc contents short varnum;run;*/
goptions reset=all  device=jpeg  ;
ods pdf file="PM.pdf" style=journal;
title 'Mixed Longitudinal Model Means for All Data Points';

proc greplay igout =cat tc=sashelp.templt template= whole nofs;
				list igout;
				treplay 1:1;  
				treplay 1:2;  
				treplay 1:3;  				
				treplay 1:4;  				
				treplay 1:5;  				
				treplay 1:6;  
run;

proc print data=PM_data label noobs style(data)=[just=left];
var index group day t var data1 data3 data4 Estimate StdErr CI; 
label data1='MGS-001'
	  data3='MGS-003'
	  data4='MGS-004'
	  index='Measurement'
	  var='Variable'
	  group='Treatment'
	  Estimate='Mean'
	  CI='95% CI'
	 ;
	format estimate StdErr 6.2;
run;


title 'Comparison between Placebo and Muscadine';
proc print data=Contrast label noobs style(data)=[just=left];
where var in (2,6);
var  var Label item ProbF; 
label Label='Contrast'
	  ProbF='p-Value'
	  var='Variable'
	 ;
	format ProbF 4.2;
run;
/*
title 'Data for Comparison between Placebo and Muscadine';
proc print data=E_Contrast label noobs style(data)=[just=left];
where var in(2,6);
var  var Label Estimate StdErr; 
label Label='Contrast'
	  Estimate='Mean'
	  var='Variable'
	 ;
	format estimate StdErr 6.2 ;
run;
*/
ods pdf close;
quit;




