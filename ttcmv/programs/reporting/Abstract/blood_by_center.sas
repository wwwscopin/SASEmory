
	ods rtf file = "&output./april2011abstracts/blood_by_center.rtf" style=journal;
		proc sort data = cmv.km out = km; by center; run;
		proc sort data = cmv.age_of_blood out = age_of_blood; by center; run;

*** No. txns, No. patients txn'ed by site, No. patients by site ;

	proc freq data = age_of_blood compress noprint; tables center / nocum out = out; run;
		proc print data = out; run;

	proc freq data = km compress noprint; where evertxn = 1; tables center / nocum out = out; run;
		proc print data = out; run;

	proc freq data = km compress noprint; tables center / nocum out = out; run;
		proc print data = out; run;


*** BIN ;

		data age_of_blood; set age_of_blood;	
			if age_of_blood ~= . & age_of_blood >= 14 then everage14 = 1; else everage14 = 0;
			if days_irradiated ~= . & days_irradiated >= 7 then everirr7 = 1; else everirr7 = 0;
			format center center.;
		run;

		data km; set km; 
			if oldestage ~= . & oldestage >= 14 then everage14 = 1; else everage14 = 0;
			if oldestirr ~= . & oldestirr >= 7 then everirr7 = 1; else everirr7 = 0;
			format center center.;
		run;


		proc freq data = km compress noprint; by center; tables has_nec / nocum out = out; run;
		proc print data = out; where has_nec = 1; run;


		proc freq data = age_of_blood compress noprint; by center; tables everage14 / nocum out = out; run;
		proc print data = out; where everage14 = 1; run;
		proc freq data = km compress noprint; by center; tables everage14 / nocum out = out; run;
		proc print data = out; where everage14 = 1; run;
		proc freq data = age_of_blood compress noprint; by center; tables everirr7 / nocum out = out; run;
		proc print data = out; where everirr7 = 1; run;
		proc freq data = km compress noprint; by center; tables everirr7 / nocum out = out; run;
		proc print data = out; where everirr7 = 1; run;

*** MEANS ;

		data km; set km; 
			if numrbctxns = 0 then numrbctxns = .;
			if numrbcdonors = 0 then numrbcdonors = .; 
		run;

		data age_of_blood; set age_of_blood; if age_of_blood < 0 then age_of_blood = .; if days_irradiated < 0 then days_irradiated = .; run;
	
		proc means data = km noprint maxdec=1; var numrbctxns; by center; 
		output out = out 	
			n(numrbctxns)=n mean(numrbctxns)=mean stddev(numrbctxns)=stddev median(numrbctxns)=median min(numrbctxns)=min max(numrbctxns)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;

		proc means data = km noprint maxdec=1; var numrbcdonors; by center; 
		output out = out 	
			n(numrbcdonors)=n mean(numrbcdonors)=mean stddev(numrbcdonors)=stddev median(numrbcdonors)=median min(numrbcdonors)=min max(numrbcdonors)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = age_of_blood noprint maxdec=1; var age_of_blood; by center; 
		output out = out 	
			n(age_of_blood)=n mean(age_of_blood)=mean stddev(age_of_blood)=stddev median(age_of_blood)=median min(age_of_blood)=min max(age_of_blood)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = km noprint maxdec=1; var oldestage; by center; 
		output out = out 	
			n(oldestage)=n mean(oldestage)=mean stddev(oldestage)=stddev median(oldestage)=median min(oldestage)=min max(oldestage)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = age_of_blood noprint maxdec=1; var days_irradiated; by center; 
		output out = out 	
		n(days_irradiated)=n mean(days_irradiated)=mean stddev(days_irradiated)=stddev median(days_irradiated)=median min(days_irradiated)=min max(days_irradiated)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = km noprint maxdec=1; var oldestirr; by center; 
		output out = out 	
		n(oldestirr)=n mean(oldestirr)=mean stddev(oldestirr)=stddev median(oldestirr)=median min(oldestirr)=min max(oldestirr)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = age_of_blood noprint maxdec=1; var rbcvolumetransfused; by center; 
		output out = out 	
			n(rbcvolumetransfused)=n mean(rbcvolumetransfused)=mean stddev(rbcvolumetransfused)=stddev median(rbcvolumetransfused)=median min(rbcvolumetransfused)=min max(rbcvolumetransfused)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = km noprint maxdec=1; var avevol; by center; 
		output out = out 	
			n(avevol)=n mean(avevol)=mean stddev(avevol)=stddev median(avevol)=median min(avevol)=min max(avevol)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = age_of_blood noprint; var txnlength; by center; 
		output out = out 	
			n(txnlength)=n mean(txnlength)=mean stddev(txnlength)=stddev median(txnlength)=median min(txnlength)=min max(txnlength)=max; 
		run;
		data out; set out; format center center. run;
		proc print data = out; run;


		proc means data = km noprint; var avelength; by center; 
		output out = out 	
			n(avelength)=n mean(avelength)=mean stddev(avelength)=stddev median(avelength)=median min(avelength)=min max(avelength)=max; 
		run;
		data out; set out; format center center. run;
		proc print data = out; run;



		proc means data = age_of_blood noprint maxdec=1; var hb_txn; by center; 
		output out = out 	
			n(hb_txn)=n mean(hb_txn)=mean stddev(hb_txn)=stddev median(hb_txn)=median min(hb_txn)=min max(hb_txn)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;


		proc means data = age_of_blood noprint maxdec=1; var hct_txn; by center; 
		output out = out 	
			n(hct_txn)=n mean(hct_txn)=mean stddev(hct_txn)=stddev median(hct_txn)=median min(hct_txn)=min max(hct_txn)=max; 
		run;
		data out; set out; format center center. n 3.0 mean stddev median min max 4.1; run;
		proc print data = out; run;



	
		goptions reset=global rotate=landscape gunit=pct noborder ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;
		
		axis1 label=(a=90 h=4 c=black "# Patients") minor=none;

		proc sql; select max(numrbctxns) into :max_numrbctxns from km;

		title1 f=zapf "Number of RBC Transfusions, by patient";
		axis2 label=(a=0 h=4 c=black "# RBC Transfusions") value=(h= 2.5) minor=none;
		pattern1 color=orange;
		Proc gchart data=km;
			vbar numrbctxns / midpoints=(1 to &max_numrbctxns by 1) raxis=axis1 maxis=axis2 space=0.5 coutline=black width=2;
		run;

		proc sql; select max(numrbcdonors) into :max_numrbcdonors from km;

		title1 f=zapf "Number of Donors, by patient";
		axis2 label=(a=0 h=4 c=black "# Donors") value=(h= 2.5) minor=none;
		pattern1 color=blue;
		Proc gchart data=km;
			vbar numrbcdonors / midpoints=(1 to &max_numrbcdonors by 1) raxis=axis1 maxis=axis2 space=0.5 coutline=black width=2;
		run;


	ods rtf close;
