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
	if 5<_n_<59;
	if time='bsline' then time=0;
	t=time+0;
	drop  Sample_Set__B612 time F2-F10 vd;
	format date date9.;
run;

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

data REP;
	set Bdata;
	where t=0;
run;

data AUC;
	set Bdata;
	if day in(2,3) or t=6 then delete;
	drop sample;
run;

proc print;run;

%macro PM(dataset,var);
ods output Mixed.LSMeans=&var;
proc MIXED data=&dataset; *plots=boxplot(observed);
class id group day;
model &var=group day group*day; 
repeated /type=cs subject=id;
lsmeans group*day/pdiff cl;
run;

data &var._mean;
	set &var;
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
	format day dd. estimate 5.0;
run;

data &var.0 &var.1;
	set &var._mean;
	day0=day-0.05;
	day1=day+0.05;
	if group=0 then output &var.0; 
	if group=1 then output &var.1; 
run;

data  &var._PM;
	merge  &var.0(rename=(amean=amean0)) &var.1(rename=(amean=amean1)); by day;
run;

goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
%if &dataset=AUC %then %do;
axis1 	label=(f=zapf h=3 " ") value=(f=zapf h=3) order= (0 to 5 by 1) minor=none offset=(0 in, 0 in);
%end;
%if &dataset=REP %then %do;
axis1 	label=(f=zapf h=3 "Day") value=(f=zapf h=3) order= (0 to 5 by 1) minor=none offset=(0 in, 0 in);
%end;
axis2 	label=(f=zapf h=3 a=90 "&var") value=(f=zapf h=3) ;

symbol1 i=HILOCTJ ci=red value=dot h=1 w=2;
symbol2 i=HILOCTJ ci=blue value=dot h=1 w=2;

legend1 across = 1 position=(top center inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=2 "Placebo" "Muscadine") offset=(0, -0.4 in) frame;

proc gplot data=&var._PM gout=cat;
	plot amean0*day0 amean1*day1/overlay haxis = axis1 vaxis = axis2 legend=legend1;
	%if &dataset=AUC %then %do;	format day0 day1 dd.; %end;
run;

%mend;

%PM(AUC,CySS); quit;
%PM(AUC,Cys); quit;
%PM(AUC,GSH); quit;
%PM(AUC,GSSG); quit;
%PM(AUC,GSSG_GSH); quit;
%PM(AUC,CySS_Cys); quit;
%PM(AUC,Total_GSH); quit;
%PM(AUC,Total_Cys); quit;

data PM_data;
	set CySS(in=CySS) Cys(in=Cys) GSH(In=GSH) GSSG(in=GSSG) GSSG_GSH(in=GSSG_GSH) CySS_Cys(in=CySS_Cys) Total_GSH(in=Total_GSH) Total_Cys(in=Total_Cys);
	length var $10;
	if Cyss then var='CySS';
		if Cys then var='Cys';
			if GSH then var='GSH';
				if GSSG then var='GSSG';
					if GSSG_GSH then var='GSSG_GSH';
						if CySS_Cys then var='CySS_Cys';
							if Total_GSH then var='Total_GSH';
								if Total_Cys then var='Total_Cys';
	drop effect;
run;

/*proc contents short varnum;run;*/
goptions reset=all  device=jpeg  rotate=portrait;
ods pdf file="PM_data.pdf" style=journal;
title 'Mixed longitudinal model Means from Day1 and Day4 by Treatment';

proc print data=PM_data noobs style(data)=[just=left];
var  group day var Estimate StdErr DF tValue Probt Alpha Lower Upper; 
run;
proc greplay igout =cat tc=sashelp.templt template= l2r2 nofs;
				list igout;
				treplay 1:1 2:2 3:3 4:4; 
				treplay 1:5 2:6 3:7 4:8; 
run;
ods pdf close;
quit;




