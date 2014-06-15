proc sort data = cmv.med_review out = med_review; by id dfseq; run;

***************************************;

data headcir; set med_review;
	by id;
	retain prevheadcir;
	problem = 0;

		if first.id then prevheadcir = headcircum;

		* check to see if heads are shrinking. give 3 cm measurement error forgiveness ;
		if headcircum ~= . & prevheadcir > headcircum + 3 then problem = 1;
		* check to see if heads are exploding ;
		if headcircum ~= . & headcircum - prevheadcir > 5 then problem = 1;

		if headcircum ~= . then prevheadcir = headcircum;

	keep id dfseq headcircum problem;

run;

data tokeep; set headcir; 
	by id;
	retain has_problem;
		if first.id then has_problem = problem;
		else has_problem = has_problem + problem;
		if last.id & has_problem ~= 0 then tokeep = 1; else tokeep = 0;
	if last.id;
	keep id tokeep;
run;

data headcir; merge headcir tokeep; by id; if tokeep; drop tokeep; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./qc_lineplots/headcir.rtf" style=journal;

		proc print data = headcir noobs; by id; run;

	ods rtf close;

***************************************;

data weight; set med_review;
	by id;
	retain prevweight;
	problem = 0;

		if first.id then prevweight = weight;

		if weight ~= . & prevweight > 1.40*weight then problem = 1;
		if weight ~= . & prevweight < 0.60*weight then problem = 1;

		if weight ~= . then prevweight = weight;

	keep id dfseq weight problem;

run;

data tokeep; set weight; 
	by id;
	retain has_problem;
		if first.id then has_problem = problem;
		else has_problem = has_problem + problem;
		if last.id & has_problem ~= 0 then tokeep = 1; else tokeep = 0;
	if last.id;
	keep id tokeep;
run;

data weight; merge weight tokeep; by id; if tokeep; drop tokeep; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./qc_lineplots/weight.rtf" style=journal;

		proc print data = weight noobs; by id; run;

	ods rtf close;

***************************************;

data length; set med_review;
	by id;
	retain prevlength;
	problem = 0;

		if first.id then prevlength = htlength;

		if htlength ~= . & prevlength > 1.30*htlength then problem = 1;
		if htlength ~= . & prevlength < 0.70*htlength then problem = 1;

		if htlength ~= . then prevlength = htlength;

	keep id dfseq htlength problem;

run;

data tokeep; set length; 
	by id;
	retain has_problem;
		if first.id then has_problem = problem;
		else has_problem = has_problem + problem;
		if last.id & has_problem ~= 0 then tokeep = 1; else tokeep = 0;
	if last.id;
	keep id tokeep;
run;

data length; merge length tokeep; by id; if tokeep; drop tokeep; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./qc_lineplots/length.rtf" style=journal;

		proc print data = length noobs; by id; run;

	ods rtf close;

************************;

	options nodate orientation = portrait;
	ods rtf file = "&output./qc_lineplots/hb.rtf" style=journal;

		* get outliers -- as seen on line plot ;
		data hb; set med_review; if (dfseq = 40 & hb > 25) | (dfseq = 28 & hb > 16); run;
		proc print data = hb noobs; var id dfseq hb; run;

	ods rtf close;

************************;
/*
	options nodate orientation = portrait;
	ods rtf file = "&output./qc_lineplots/hct.rtf" style=journal;

		* get outliers -- as seen on line plot ;
		data hct; set med_review; if hct ~= . & hct < 15; run;
		proc print data = hct noobs; var id dfseq hct; run;

	ods rtf close;
*/

data hct; set med_review;
	by id;
	problem = 0;

	if hct ~= . & hct < 15 then problem = 1;

	keep id dfseq hct problem;

run;

data tokeep; set hct; 
	by id;
	retain has_problem;
		if first.id then has_problem = problem;
		else has_problem = has_problem + problem;
		if last.id & has_problem ~= 0 then tokeep = 1; else tokeep = 0;
	if last.id;
	keep id tokeep;
run;

data hct; merge hct tokeep; by id; if tokeep; drop tokeep; 
	label dfseq = "Day of life*" 
				hct = "Hematocrit value*"
				problem = "Extreme value?*" 
	;
	center = floor(id/1000000);	
	format problem yn. center center.;
run;

	options nodate orientation = portrait;

	ods rtf file = "&output./qc_lineplots/hct_euhm.rtf" style=journal;
		title "Extreme values of HCT that require investigation";
		proc print data = hct noobs label split="*"; by id; where center = 1; 
			var dfseq hct problem; run;
	ods rtf close;

	ods rtf file = "&output./qc_lineplots/hct_gmh.rtf" style=journal;
		proc print data = hct noobs label split="*"; by id; where center = 2;
			var dfseq hct problem; run;
	ods rtf close;
