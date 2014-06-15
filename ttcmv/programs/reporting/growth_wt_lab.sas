options orientation=portrait nodate nobyline nonumber;
libname wbh "/ttcmv/sas/programs";	
%let pm=%sysfunc(byte(177)); 
%let ds=%sysfunc(byte(167)); 
%let one=%sysfunc(byte(185)); 
%let two=%sysfunc(byte(178)); 

proc means data=cmv.plate_012 median;
var SNAPTotalScore;
output out=tmp median(SNAPTotalScore)=median;
run;

data _null_;
    set tmp;
    call symput("median",compress(median));
run;


proc format; value tx 0="No"	1="Yes";
       
value item 0="--"
           1="Gender"
           2="Race(only for Black and White)"
           3="Center"
           4="Anemia(Hemoglobin<=9 g/dL) before 1st pRBC transfusion"
           5="Anemia(Hemoglobin<=8 g/dL) before 1st pRBC transfusion"
           6="Gestational Age Group"
           7="Gestational Age by Median"
           8="SNAP at Birth"
           9="Any breast milk fed before 1st pRBC transfusion"
           10="Caffeine used before 1st pRBC transfusion"
           ;
value Anemic 0="Not Anemic" 1="Anemic";
value snapg  0="SNAP Score <=Median(&median)" 1="SNAP Score >Median";

    value group 1="SGA"  2="AGA"  3="LGA";

run;

data hwl0;
	merge cmv.plate_008(keep=id MultipleBirth) 
    cmv.plate_006(keep=id gestage) 
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(rename=(dfseq=day))
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	center=floor(id/1000000);
	if SNAPTotalScore>&median then snapg=1;else snapg=0;
	
		if id=2002711 and dfseq=28 then weight=.;
		if id=3023511 and dfseq=21 then weight=.;
		
	if gestage>=28 then gesta=0; else gesta=1;
	
	retain bw; 
	if day=1 then bw=Weight;
	
	keep id day Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth SNAPTotalScore
			LBWIDOB Gender  IsHispanic  Race RaceOther Hb HbDate Center snapg bw gestage gesta;
	rename SNAPTotalScore=snap LBWIDOB=dob;
run;

data tmp;
    merge cmv.plate_015 cmv.comp_pat(in=A); by id;
    if A;
    if dfseq=1;
run;

proc means data=tmp n mean median min max;
    var hb;
run;
