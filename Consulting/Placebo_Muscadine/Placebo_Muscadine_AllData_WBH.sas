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

proc print;run;

proc format;
	value group 1='Muscadine'
			 	0='Placebo'
		 ;
	value id  1='MGS-001'
			  3='MGS-003'
			  4='MGS-004'
		 ;
	value dd 0=" " 2=" " 3=" " 5=" "
			1='Pre-challenge'
			4='Post-challenge'
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
run;

data id;
	set id1 id3 id4;
run;

proc print;run;

%macro PM(dataset,var);
ods output Mixed.LSMeans=&var;
proc MIXED data=&dataset; *plots=boxplot(observed);
class id index;
model &var=index; 
repeated /type=cs subject=id;
lsmeans index /pdiff cl;
run;

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
	ind2=ind-0.1;

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

axis1 	label=(f=zapf h=3 "Time") value=(f=zapf h=2) order= (0 to 15 by 1) minor=none offset=(0 in, 0 in);

%if &var=CySS %then %do;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) order= (60 to 150 by 10) ;
%end;

%if &var=Cys %then %do;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) order= (5 to 25 by 1) ;
%end;

%if &var=GSH %then %do;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) order= (0 to 6 by 1) ;
%end;


%if &var=GSSG %then %do;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) order= (-0.04 to 0.20 by 0.02) ;
%end;


%if &var=GSSG_GSH %then %do;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) order= (-200 to 0 by 20) ;
%end;

%if &var=CySS_Cys %then %do;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) order= (-100 to -60 by 10) ;
%end;

symbol1 i=HILOCTJ ci=black value=dot h=1 w=2;
symbol2 i=dot ci=red value=dot h=1 w=2;
symbol3 i=circle ci=green value=dot h=1 w=2;
symbol4 i=square ci=blue value=dot h=1 w=2;
%if &var^=CySS_Cys %then %do;
legend1 across = 1 position=(top center inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=2 "Mean" "MGS-001" "MGS-003" "MGS-004") offset=(0, -0.4 in) frame;
%end;

%else %do;
legend1 across = 1 position=(bottom center inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=2 "Mean" "MGS-001" "MGS-003" "MGS-004") offset=(0, +0.4 in) frame;
%end;


title &var, "group=Placebo";
proc gplot data=&var._mean gout=cat;
	where group=0;
	plot amean*ind data1*ind2 data3*ind2 data4*ind2/overlay haxis = axis1 vaxis = axis2 legend=legend1;
run;

title &var, "group=Muscadine";
proc gplot data=&var._mean gout=cat;
	where group=1;
	plot amean*ind data1*ind2 data3*ind2 data4*ind2/overlay haxis = axis1 vaxis = axis2 legend=legend1;
run;

%mend;
proc print data=Cyss0;run;

%PM(id,CySS); quit;
%PM(id,Cys); quit;
%PM(id,GSH); quit;
%PM(id,GSSG); quit;
%PM(id,GSSG_GSH); quit;
%PM(id,CySS_Cys); quit;
/*
%PM(id,Total_GSH); quit;
%PM(id,Total_Cys); quit;
*/
proc print data=CySS;run;

data PM_data;
	set CySS0(in=CySS) Cys0(in=Cys) GSH0(In=GSH) GSSG0(in=GSSG) GSSG_GSH0(in=GSSG_GSH) CySS_Cys0(in=CySS_Cys); /*Total_GSH(in=Total_GSH) Total_Cys(in=Total_Cys);*/
	length var $10;
	if Cyss then var='CySS';
		if Cys then var='Cys';
			if GSH then var='GSH';
				if GSSG then var='GSSG';
					if GSSG_GSH then var='GSSG_GSH';
						if CySS_Cys then var='CySS_Cys';
							/*if Total_GSH then var='Total_GSH';
								if Total_Cys then var='Total_Cys';*/
	drop effect;
run;

options ORIENTATION="LANDSCAPE";
/*proc contents short varnum;run;*/
goptions reset=all  device=jpeg  ;
ods pdf file="PM_WBH.pdf" style=journal;
title 'Mixed Longitudinal Model Means for All Data Points';

proc print data=PM_data label noobs style(data)=[just=left];
var index group day t var data1 data3 data4 Estimate StdErr DF tValue Probt Alpha Lower Upper; 
label data1='MGS-001'
	  data3='MGS-003'
	  data4='MGS-004'
	  index='time'
	 ;
run;
proc greplay igout =cat tc=sashelp.templt template=whole nofs;
				list igout;
				treplay 1:1;  
				treplay 1:2;  
				treplay 1:3;  				
				treplay 1:4;  				
				treplay 1:5;  				
				treplay 1:6;  
				treplay 1:7;  
				treplay 1:8;  
				treplay 1:9;  				
				treplay 1:10;  				
				treplay 1:11;  				
				treplay 1:12;  
run;
ods pdf close;
quit;




