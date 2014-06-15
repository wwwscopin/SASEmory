
data cmv.listing;
	merge 	cmv.rbctxn_summary (keep = id evertxn in=a)
				cmv.lbwi_demo (keep = id birthweight gestage)
	;	by id; if a;
	format evertxn yn.
run;

options nodate nonumber;
ods rtf file = "&output./txn_listing.rtf" style=journal;
	title "End of Study - Ever given RBC TXN?";
	proc print data = cmv.listing label noobs; run;
ods rtf close;
