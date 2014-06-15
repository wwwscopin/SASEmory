%let path=H:\SAS_Emory\Consulting\George\leg\;
filename brad "&path.LLD Bradbury.xls";
filename eren "&path.LLD Erens.xls";

PROC IMPORT OUT= brad 
            DATAFILE= brad 
            DBMS=EXCEL REPLACE;
	 RANGE="Bradbury and Smith 1.6.12$Q2:Z71"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= eren 
            DATAFILE= eren 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$Q2:Y72"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data leg; 
	set brad(in=A) eren(in=B);
	if A then gp=1;  else if B then gp=0;
	rename F1=post_lesser F2=post_greater F3=c_lesser F4=c_greater F8=non_op F9=post_op;
	lesser=F3-F1;
	greater=F4-F2;
	offset=F8-F9;

	Keep F1-F4 F8 F9 lesser greater offset gp;
run;

proc npar1way data=leg wilcoxon; 
class gp; 
var greater offset;
run;

proc ttest data=leg; 
class gp; 
var greater offset;
run;


proc means data=leg n mean std stderr median min max Q1 Q3 maxdec=1; 
	class gp; 
	var lesser greater offset; 
run;

data leg1;
        set leg(keep=greater gp) leg(keep=offset gp rename=(offset=greater) in=B);
        if B then idx=2; else idx=1;
		gd=round(greater/2);
run;
    
proc freq data=leg1(where=(gp=0)) noprint;
        tables gd*idx /out=sumpyr /*outpct*/;
run;

proc univariate data=leg(where=(gp=0));
        var greater offset;
run;


data leg2;
        set sumpyr;
        if idx=1 then count=-count;
		if gd=. then delete;
run;

proc format; 
	value gd -15="-30" -14="-28" -13="-26"  -12="-24" -11="-22" -10="-20"  -9="-18" -8="-16" -7="-14"  -6="-12" -5="-10" -4="-8" -3="-6"  -2="-4" -1="-2"
	15="30" 14="28" 13="26"  12="24" 11="22" 10="20"  9="18" 8="16" 7="14" 6="12" 5="10" 4="8" 3="6" 2="4" 1="2" 0="0";

title1 'Bar chart for Leg Length Accuracy and Offset';
axis1 label=(a=90 h=1 c=black "Leg Length/Offset(mm)") order=(-15 to 15 by 1) value=(h= 1) minor=none;
axis2 order=(-10 to 10 by 1) label=("# of Patients") minor = none
value = ("10" "9" "8" "7" "6" "5" "4" "3" "2" "1" "0" '1' '2' "3" '4' '5' "6" '7' '8' "9" "10");

Legend1 value=(color=black height=2.5 "Leg Length" "Offset") label=none;


proc gchart data=leg2;
hbar gd/ discrete freq nostats sumvar=count space=0.25
   subgroup=idx raxis=axis2 maxis=axis1 legend=legend1;
   format gd gd.;
run;
quit;

proc freq data=leg1(where=(gp=1)) noprint;
        tables gd*idx /out=sumpyr /*outpct*/;
run;

proc univariate data=leg(where=(gp=1));
        var greater offset;
run;
  
data leg3;
        set sumpyr;
        if idx=1 then count=-count;
		if gd=. then delete;
run;

proc gchart data=leg3;
hbar gd/ discrete freq nostats sumvar=count space=0.25
   subgroup=idx raxis=axis2 maxis=axis1 legend=legend1;
   format gd gd.;
run;
quit;
