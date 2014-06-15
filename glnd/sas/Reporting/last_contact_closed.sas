/* last_contact_closed.sas
 *
 * ADDS TREATMENT DATA TO THE FINAL TABLE - changes occur at line 80. everything beforehand is the same
 *
 * this program takes patient mortality status and follow-up time from status
 * and produces KM Survival plots
 */

	/* ADD TREATMENT INFO */
	proc sort data = glnd.status; by apache_2 id; run;

goptions rotate = landscape;
ods pdf file='survival_closed.pdf' ;
ods ps file='survival_closed.ps' ;
ods graphics on;
ods select survival;
	proc lifetest plot=(s) nocensplot;
		* by apache_2 ; 	* STRATIFYING BY APACHE APPEARS TO BRING OUT AN EFFECT IN THE hi apache group! (eli 2/27/09);
		time followup_days*deceased(0);
		strata treatment;
   	format treatment trt.;
	run;
ods graphics off;
ods ps close;
ods pdf close;

proc sort data = glnd.status; by id; run;

	
