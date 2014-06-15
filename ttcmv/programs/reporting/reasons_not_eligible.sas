%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";

 data reasons_not_elig;
	set cmv.plate_001 (rename = (isEligible = enrolled));

	* keep in dataset if not eligible ;
	if inweight = 0 | inlife = 0 | exlifeexpect = 1 | exabnor = 1 | extx = 1 | exmocprevenrolled = 1 ; 

	center = floor(id/1000000);

	format date monname.;
	date = mdy(month(screeningdate), 1, year(screeningdate));

	format center center.;
	drop DFSTATUS  DFVALID  DFRASTER  DFSTUDY  DFPLATE  DFSEQ DFSCREEN  DFCREATE  DFMODIFY;
 run;

 data reasons_not_elig; set reasons_not_elig;
	* break up weight elig criterion by date when we switched from screening < 1500 to < 1700, Nov 1, 2010 ;
	if screeningdate < 18567 then inweight1 = inweight; else inweight1 = 1;
	if screeningdate >= 18567 then inweight2 = inweight; else inweight2 = 1;
run;


	proc freq data = reasons_not_elig; tables InWeight1 / nocum out = inweight1; run;
	data inweight1; set inweight1; if InWeight1 = 0; format reason $60.; reason = "LBWI < 1500g*"; run;

	proc freq data = reasons_not_elig; tables InWeight2 / nocum out = inweight2; run;
	data inweight2; set inweight2; if InWeight2 = 0; format reason $60.; reason = "LBWI < 1700g^"; run;

	proc freq data = reasons_not_elig; tables InLife / nocum out = InLife; run;
	data InLife; set InLife; if InLife = 0; format reason $60.; reason = "LBWI not within first 5 days of life"; run;

	proc freq data = reasons_not_elig; tables ExLifeExpect / nocum out = ExLifeExpect; run;
	data ExLifeExpect; set ExLifeExpect; if ExLifeExpect = 1; format reason $60.; reason = "LBWI not expected to live past 7 days of life";  run;

	proc freq data = reasons_not_elig; tables ExAbnor / nocum out = ExAbnor; run;
	data ExAbnor; set ExAbnor; if ExAbnor = 1; format reason $60.; reason = "LBWI has severe congenital abnormality"; run;

	proc freq data = reasons_not_elig; tables ExTX / nocum out = ExTX; run;
	data ExTX; set ExTX; if ExTX = 1; format reason $60.; reason = "LBWI received transfusion at institution not affiliated with Emory prior to screening"; run;

	proc freq data = reasons_not_elig; tables ExMOCPrevEnrolled / nocum out = ExMOCPrevEnrolled; run;
	data ExMOCPrevEnrolled; set ExMOCPrevEnrolled; format reason $60.; reason = "Mother has previously participated in the study"; if ExMOCPrevEnrolled = 1; run;

data reasons_table; set inweight1 inweight2 InLife ExLifeExpect ExTX ExMOCPrevEnrolled; 
	label	reason = "Reason not eligible"
				count = "Total number"
				percent = "Percent of total"
	;

	format percent percent 3.0;
run;


options nodate orientation = portrait;

ods rtf file = "&output./monthly/&mon_file_reasons_not_eligible.reasons_not_eligible.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "&mon_pre_reasons_not_eligible Reasons patients ineligible at screening";

		title1 "&mon_pre_reasons_not_eligible Reasons patients ineligible at screening";
		footnote1 "*From Jan 2010 - Oct 2010, LBWI < 1500 grams were screened.";
		footnote2 "^Starting Nov 2010, LBWI < 1700 grams were screened."; 
		proc print data = reasons_table label noobs style(header) = [just=center] contents = "";

				var reason count percent;

				run;

	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;

*/
