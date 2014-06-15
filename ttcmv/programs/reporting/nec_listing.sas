



proc sort data = cmv.nec out = nec; by id dfseq; run;

data nec; set nec;
	if laparotomydone = 1 | abdominaldrain = 1 | bowelresecdone = 1 then surgical = 1; else surgical = 0;
	keep id mocinit necdate surgical; 
	format surgical yn.; 
	label id = "Patient ID"
				necdate = "Date of NEC diagnosis"
				surgical = "Surgical NEC?"
	;
run;

proc sort data = cmv.lbwi_demo out = demo; by id; run;
data demo; set demo; 
	keep id mocinit lbwidob gender race; 
	format gender gender. race race.;
run; 
data nec; merge nec (in=a) demo; by id mocinit; if a; run;


proc sort data = cmv.transfer out = transfer; by id; run;
data transfer; set transfer; if i=1; run;

data nec; merge nec (in=a) transfer (in=b); by id; if a;
	if b then transfer = 1; else transfer = 0; 
	format transfer yn.; 
	label transfer = "Patient transferred?"
				TransferHosp = "Transfer hospital"
				TransferDate = "Transfer date"
				TransferDOL = "DOL at transfer"
	;
run;


proc sort data = cmv.plate_031 out = rbc; by id; run;
data rbc; set rbc; by id; retain numtxns;
	if first.id then numtxns = 1; 
	else numtxns = numtxns + 1;
	if last.id;
run;

data nec; merge nec (in=a) rbc (in=b keep=id numtxns); by id; 
	if a; if b then txnd = 1; else txnd = 0; 
	label txnd = "pRBC TXN?"
				numtxns = "#TXNs"
	;
	format txnd yn.; 
run;


proc sort data = cmv.plate_100 out = death1; by id; run;
proc sort data = cmv.plate_101 out = death2; by id; run;
data death1; set death1; keep id deathdate deathcause; run;
data death2; set death2; keep id deathdate deathcausemore; if deathdate ~= .; run;
data death; set death1 death2; run;
proc sort data = death; by id; run;

data nec; merge nec (in=a) death (in=b); by id; if a;
	if b then death = 1; else death = 0; 

	* consolidate cause of death from AE and SAE forms ;
	cause = deathcausemore;
	if deathcause = 5 then cause = "NEC";

	format death yn.; 
	label death = "Patient died?"
				deathdate = "Date of death"
				cause = "Cause of death"
	; 
run;

data nec; set nec; center = floor(id/1000000); format center center.; run;

options orientation = landscape; 
	ods rtf file = "&output./listing_nec.rtf" style=journal;
		title "Listing of NEC patients as of 09/06/11";
		proc print data = nec label noobs; 
			by center;
			var id mocinit lbwidob gender race necdate surgical transfer TransferHosp TransferDate txnd numtxns death cause deathdate; 
		run; 
	ods rtf close;
