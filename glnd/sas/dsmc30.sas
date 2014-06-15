***** printout to rtf in one report the dsmc_recruitment overall and 
30 day version;
ods pdf file='dsmc30.pdf';
options ls=92 ps=53;
ods ps file='dsmc30.ps';
ods rtf file='dsmc30.rtf' sasdate;
data glnd.dsmc_recruitment;
 set glnd.dsmc_recruitment;

	if center = 1 then irbdate=mdy(11,1,2006); * Emory ;
	else if center = 2 then irbdate=mdy(1,1,2007); * Miriam ;
	else if center = 3 then irbdate=mdy(1,1,2007); * Vandy ;
	else if center = 4 then irbdate=mdy(2,1,2007); * Colorado; 
	else if center = 5 then irbdate=mdy(11,2,2009); * Wisconsin;
	else if center = 100 then irbdate=.; * total;

irb=put(irbdate,mmddyy8.);
label irb='Date IRB Approved';
format irbdate mmddyy8.;
label irbdate='Date IRB Approved';
proc print label noobs;
var center irbdate nscreened e r;
title Cumulative Patient Screening and Enrollment;
run;
proc print label noobs data= glnd.dsmc_recruitment30;
title Patient Screening and Enrollment Within Last 30 Days;
run;
%inc'30dayreasons.sas';

ods rtf close;
ods pdf close;

ods ps close;
