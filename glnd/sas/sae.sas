/* sae.sas 
 *
 * Merge the two plates of SAE reports by id and visit (seqno), which is the SAE counter within an individual
 */
 
 proc sort data = glnd.plate203;
 	by id DFSEQ;
 run;
 
 proc sort data = glnd.plate204;
 	by id DFSEQ;
 run;
 
 data glnd.sae;
 	merge glnd.plate203 glnd.plate204;	

proc print data = glnd.sae;
run;