PROC IMPORT OUT= HK 
            DATAFILE= "H:\SAS_Emory\Consulting\lovenox_combined.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="sheet2"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc format;
	/*value hip_or_knee 0="TKA B"  1 ="TKA R" 2="THA R" 3="THA B" 4="THA U";*/
	value hip_or_knee 0=hip 1=knee;
	value gender 0="F" 1="M";
	value Hormone 0="No" 1="Yes";
	value Smoker 0="No" 1="Yes";
	value DVT 0="No" 1="Yes";
	value PE 0="No" 1="Yes";
	value death 0="No" 1="Yes";
	value hemorrhage 0="No" 1="Yes";
	value wound_problem  0="No" 1="Yes";
	value diagnosis 0="OA" 1="AVN" 2="RA" 3="DDH" 4="Traum arth" 5="Other";
	value risk 0="None" 1="IDDM" 2="HIV" 3="reduction" 4="Autoinmune" 5="Renal disease" 6="Liver" 7="Heart disease" 8="Other";
	*value hip_knee 0="knee" 1="hip";
	value group 0="Study" 1="Control";
	;
run;



data HK;
	set HK;
	diagnosis=dg+0;
    risk= risk_factors+0;
	/*if hip_or_knee in (0, 1) then hip_knee=0; else hip_knee=1;*/
	if _n_<501  then group=1;
	if _n_>504 then group=0;
	if pt=" " or pt="pt" then delete;
	format hip_or_knee hip_or_knee. gender gender.  Hormone Hormone. Smoker Smoker. DVT DVT. PE PE. 
	death death. hemorrhage hemorrhage. wound_problem wound_problem.  diagnosis diagnosis. group group. risk risk.
	;
run;

proc contents;run;

proc print;run;

Proc freq data=HK;
	tables group*gender group*smoker group*hip_or_knee group*hormone group*DVT group*PE 
	group*hemorrhage group*wound_problem group*death/nocol nocum nopercent; 
run;
