options ORIENTATION="LANDSCAPE" nonumber nodate;
libname wbh "/ttcmv/sas/porgrams";	
%let mu=%sysfunc(byte(181));



**********************************************************************************************;
data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.completedstudylist(in=comp);
	by id;
	if comp;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
    keep id ivh imagedate;
run;


***********************************************************************************************;


data rbc;
	set cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime in=A);
	rename DateTransfusion=dt_rbc;
run;
proc sort; by id dt_rbc; run;

data plt;
	set cmv.plate_033(keep=id DateTransfusion plt_TxStartTime in=B);
		rename DateTransfusion=dt_plt;
run;
proc sort; by id dt_plt; run;

data tx; 
    merge rbc(in=A) plt(in=B) ivh2 cmv.completedstudylist(in=comp); by id;
    if ivh=. then ivh=0;
    if A then rbc=1; else rbc=0;
    if B then plt=1; else plt=0;
    
    if ivh and rbc then day_rbc=imagedate-dt_rbc;
    if ivh and plt then day_plt=imagedate-dt_plt;
    if comp;
    
    keep id ivh rbc plt day_rbc day_plt imagedate;
run;

data sub; 
    set tx; 
    if  ivh and plt;
run;


proc sort nodupkey; by id; run;

proc print;run;
