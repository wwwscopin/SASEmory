/* demo_his.sas 
 * merge plates 9, 10, and 22 to form one 'demographics/history form' dataset
 */
 
 proc sort data = glnd.plate9; by id; run;
 
 proc sort data = glnd.plate10; by id; run;
 proc sort data = glnd.plate22; by id; run;
 
 data glnd.demo_his;
 	merge glnd.plate9 glnd.plate10 glnd.plate22;
 	by id;
 
        center=int(id/10000);
        format center center.;	
 	* drop DataFax plate-specific variables;
 	drop  dfc DFSTATUS DFVALID DFRASTER DFSTUDY DFPLATE DFSEQ ; 
 run;
 
 data temp;
    merge glnd.plate9 glnd.george(keep=id treatment) glnd.status(keep=id dt_random); by id;
    pre_hosp_day=dt_random-dt_admission;
 runl;
 
 proc means data=temp n mean stddev median maxdec=1;
    var pre_hosp_day  days_sicu_prior;
 run;

 proc means data=temp n mean stddev median maxdec=1;
    class treatment;
    var pre_hosp_day  days_sicu_prior;
 run; 
