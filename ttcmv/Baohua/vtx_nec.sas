options ORIENTATION=portrait nodate nonumber;
libname wbh "/ttcmv/sas/programs";	
%let wbh=/ttcmv/sas/programs;

proc format; 
    value nec 0="non-NEC" 1="NEC";
run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate NECResolveDate;
run;

data nec;
	merge nec0 cmv.comp_pat(in=comp keep=id dob) cmv.endofstudy(keep=id StudyLeftDate); by id;
	if comp;
	if necdate=. then nec=0; else nec=1;
	retain ndate;
	if first.id then ndate=necdate;

	format ndate mmddyy8.;
run;

data rbc;
	merge cmv.plate_031(in=tx keep = id datetransfusion rbc_TxStartTime rbc_TxEndTime rbcvolumetransfused bodyweight) nec(in=in_nec); by id;
	
	if in_nec;
	if nec and tx then if datetransfusion<ndate;
	if nec then day=datetransfusion-ndate; else day=datetransfusion-StudyLeftDate;
	if day>0 or day=. then delete;
	
    wk=floor(day/7);
    if wk=0 then wk=-1;
run;


data rbc;
    set rbc; by id;

    hr=intck('minute', input(rbc_TxStartTime, time8.), input(rbc_TxendTime, time8.))/60;
    if hr<0 then hr=intck('minute', input(rbc_TxStartTime, time8.), input(rbc_TxendTime, time8.))/60+24;
    retain ntx sumvol; 
	if first.id then do; sumvol = rbcvolumetransfused; ntx=1;end;   else do; sumvol = sumvol + rbcvolumetransfused; ntx+1; end;
    if last.id then avevol = sumvol / ntx; 
    
    volume=rbcvolumetransfused/bodyweight*1000;
    if nec=0 then do; day0=day;volume0=volume; hr0=hr; end;
    if nec=1 then do; day1=day;volume1=volume; hr1=hr; end; 
run;

  
ODS PDF FILE ="rbc_nec.pdf"; 

PROC sgplot DATA=rbc;
SCATTER X = day0 Y = volume0/ LEGENDLABEL = 'Non-NEC' MARKERATTRS=(size=8 SYMBOL=circle color=blue);
SCATTER X = day1 Y = volume1/ LEGENDLABEL = 'NEC' MARKERATTRS=(size=8 SYMBOL=circlefilled color=red);
yaxis label="Volume of RBC Transfusion(ml/kg)"  grid values=(0 to 40 by 5) offsetmin=0 offsetmax=0;
xaxis label="Days before NEC or Days before End of Study(Non-NEC)" grid values=(-100 to 0 by 20) offsetmin=0 offsetmax=0;
RUN;



PROC sgplot DATA=rbc;
SCATTER X = day0 Y = hr0/LEGENDLABEL = 'Non-NEC' MARKERATTRS=(size=8 SYMBOL=circle color=blue);
SCATTER X = day1 Y = hr1/LEGENDLABEL = 'NEC' MARKERATTRS=(size=8 SYMBOL=circlefilled color=red);
 yaxis label="Length of RBC Transfusion(hr)"  grid values=(0 to 10 by 2) offsetmin=0 offsetmax=0;
 xaxis label="Days before NEC or Days before End of Study(Non-NEC)" grid values=(-100 to 0 by 20) offsetmin=0 offsetmax=0;
RUN;

ods pdf close;


*ods trace on/label listing;
proc means data=rbc n mean stderr median;
    class nec wk;
    var volume hr; 
    ods output Means.Summary=temp;
run;
*ods trace off;


data temp;
    set temp;
    v_lower=volume_mean-1.96*volume_stderr;
    v_upper=volume_mean+1.96*volume_stderr;
    hr_lower=hr_mean-1.96*hr_stderr;
    hr_upper=hr_mean+1.96*hr_stderr;
    if nec then wk=wk+0.1;
    keep nec wk volume_n volume_mean volume_stderr volume_median hr_n hr_mean hr_stderr hr_median v_lower v_upper hr_lower hr_upper;
    rename volume_n=v_n volume_mean=v_mean volume_stderr=v_stderr volume_median=v_median;
    format nec nec.;
run;
  
ODS PDF FILE ="rbc_nec_mean.pdf";  
proc sgplot data=temp(where=(v_stderr^=.));

scatter x=wk y=v_mean / group=nec
yerrorlower=v_lower yerrorupper=v_upper
markerattrs=(symbol=circlefilled)
name="scat";

series x=wk y=v_mean / group=nec 
lineattrs=(pattern=solid);
xaxis integer values=(-14 to 0 by 1)
label="Weeks before NEC or End of Study(non-NEC)";
yaxis integer values=(10 to 25 by 1)
label="Volume of RBC Transfusion(ml/kg)";
keylegend "scat" / title="" noborder;
run;

proc sgplot data=temp(where=(hr_stderr^=.));
scatter x=wk y=hr_mean / group=nec
yerrorlower=hr_lower yerrorupper=hr_upper
markerattrs=(symbol=circlefilled)
name="scat";
series x=wk y=hr_mean / group=nec
lineattrs=(pattern=solid);
xaxis integer values=(-14 to 0 by 1)
label="Weeks before NEC or End of Study(non-NEC)";
yaxis integer values=(2.5 to 4.2 by 0.1)
label="Length of RBC Transfusion(hr)";
keylegend "scat" / title="" noborder;
run;
ods pdf close;


