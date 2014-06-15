%include "&include./annual_toc.sas";

libname cmv "/ttcmv/sas/data";

ods rtf   file = "&output./annual/neeta_donor_summary.rtf"  style=journal
toc_data startpage = yes bodytitle ;


Title " Unit Trracking result";

proc freq data=cmv.plate_001_bu;
tables unitserostatus;

run;

Title " Unit WBC result";
proc freq data=cmv.plate_002_bu;
tables wbc_result1;

run;

Title " Unit Detectable WBC result";
proc freq data=cmv.plate_002_bu;
tables wbc_count1;

run;


proc means data=cmv.plate_002_bu n mean Median	Minimum	Maximum	 p25 p75;
var wbc_count1;

run;

Title " Unit NAT result";
proc freq data=cmv.plate_003_bu;
tables unitresult;



run;

ods rtf close;
quit;
