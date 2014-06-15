
* positive IgM ;
data igm; set cmv.moc_sero; if igmtestresult = 2; keep id; run; 

* positive NAT at enrollment ;
data nat; set cmv.moc_nat; if dfseq = 1; if nattestresult = 2 | nattestresult = 3 | nattestresult = 4; keep id nattestresult; run; 

* tested for IgG at enrollment ;
data igg1; set cmv.plate_215 (rename = (iggtestresult = iggtestresult1)); if dfstatus~=0; keep id iggtestresult1; run;  

* unscheduled test for IgG ;
data igg2; set cmv.plate_209 (rename = (iggtestresult = iggtestresult2)); keep id iggtestresult2; run;  


proc sort data = igm; by id; run;
proc sort data = nat; by id; run;
proc sort data = igg1; by id; run;
proc sort data = igg2; by id; run;

data sero; merge igm(in=a) nat(in=d) igg1(in=b) igg2(in=c); by id;
	if a then igm = 1; else igm = 0;
	if b then igg1 = 1; else igg1 = 0;
	if c then igg2 = 1; else igg2 = 0;
	if ~d then nattestresult = 1;

	label 	igm = "IgM+ at enrollment"
				igg1 = "IgG tested at enrollment"
				igg2 = "IgG tested unscheduled"
				nattestresult = "NAT result at enrollment"
				iggtestresult1 = "IgG test result at enrollment"
				iggtestresult2 = "IgG test result unscheduled"
	;

	format igm igg1 igg2 yn. iggtestresult1 iggtestresult2 MOCSeroResult. nattestresult CMVNATResult.;
run;

options nodate orientation = portrait;
ods rtf file = "&output./igm.rtf"  style=journal;
	proc print data = sero label noobs;
		var id igm nattestresult igg1 iggtestresult1 igg2 iggtestresult2;
	run;
ods rtf close;
