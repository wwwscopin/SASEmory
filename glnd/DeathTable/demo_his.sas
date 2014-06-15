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
 
 proc print data= glnd.demo_his;
 run;
proc freq;
 tables center; 
 quit;
