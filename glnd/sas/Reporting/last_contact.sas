/* last_contact.sas
 *
 * this program takes patient mortality status and follow-up time from status
 * and produces KM Survival plots
 */

/**	END TIME OF PEOPLE IN HOSPITAL SET TO AUGUST 20, 2007. CHANGE FOR NEXT DSMB REPORT!	**/

proc sort data = glnd.status; by id; run;

proc print data= glnd.status  ; run;

ods ps file='/glnd/sas/reporting/survival.ps' ;
ods pdf file='/glnd/sas/reporting/survival.pdf' ;
ods graphics on;
ods select survival;
	proc lifetest data= glnd.status plot=(s) nocensplot;
		time followup_days*deceased(0);
	run;
ods graphics off;
ods ps close;
ods pdf close;

