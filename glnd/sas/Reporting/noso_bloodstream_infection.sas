data tmp;
		length organism_1 $ 100;
		length organism_2 $ 100;
		length organism_3 $ 100;
		length organism_4 $ 100;
		length organism_5 $ 100;

		set glnd_rep.all_infections_with_adj;

		*** CLEAN UP DISPLAY IN DATASETS, REMOVE REPEAT ORGANISMS ***;
		* Set up text field to contain organism format. need to have text rather than numeric so can adjust the "other people";
			/**/
			organism_1 = put(cult_org_code_1, cult_org_code.);
			organism_2 = put(cult_org_code_2, cult_org_code.);
			organism_3 = put(cult_org_code_3, cult_org_code.);
			organism_4 = put(cult_org_code_4, cult_org_code.);
			organism_5 = put(cult_org_code_5, cult_org_code.);
			/**/

		* Adjust "other" categories to include the name of the organism;
			if (cult_org_code_1 in (9, 20, 21,22,23)) then organism_1= trim(put(organism_1, $30.)) || " - " || trim(put(org_spec_1, $50.)) ;
			if (cult_org_code_2 in (9, 20, 21,22,23)) then organism_2= trim(put(organism_2, $30.)) || " - " || trim(put(org_spec_2, $50.)) ;
			if (cult_org_code_3 in (9, 20, 21,22,23)) then organism_3= trim(put(organism_3, $30.)) || " - " || trim(put(org_spec_3, $50.)) ;
			if (cult_org_code_4 in (9, 20, 21,22,23)) then organism_4= trim(put(organism_4, $30.)) || " - " || trim(put(org_spec_4, $50.)) ;
			if (cult_org_code_5 in (9, 20, 21,22,23)) then organism_5= trim(put(organism_5, $30.)) || " - " || trim(put(org_spec_5, $50.)) ;


		* remove repeat organisms from the same infection report, comparing the text labels, working backwards from the 5th organism ;
			if (organism_5 = organism_4) then do; organism_5 = .; cult_org_code_5 = .; org_spec_5 = .; end;
			if (organism_4 = organism_3) then do; organism_4 = .; cult_org_code_4 = .; org_spec_4 = .; end;
			if (organism_3 = organism_2) then do; organism_3 = .; cult_org_code_3 = .; org_spec_3 = .; end;
			if (organism_2 = organism_1) then do; organism_2 = .; cult_org_code_2 = .; org_spec_2 = .; end;
			
		label	
			organism_1 ="1st cult. org."
			organism_2 ="2nd cult. org."
			organism_3 ="3rd cult. org."
			organism_4 ="4th cult. org."
			organism_5 ="5th cult. org."
		;		
	
	run;


/**  PRODUCE BY SITE AND TYPE TABLE, with organism listing **/

	* first, we need the data arranged two way - by number of unique infection episodes and by cultured organisms;

	* number of unique episodes is straight-forward - simply take noso, filter out non-confirmed infections ;
	data by_episode;
		set tmp; 

		where (infect_confirm in (1,2)); * only look at positive infections with positive cultures ; 


		site_code_label = trim(put(site_code, site_code.));
		type_code_label = trim(put(type_code, type_code.));

		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;



	* now list by organism ... ; 
	* unlike the previous by_organism, this dataset has records for those infections w/o a listed organism ;
	data by_organism_all_infec;
		set tmp;

		where (infect_confirm in (1,2)); * only look at positive infections with positive cultures ; 

		/*organism= " 													";
		* work backwards from oganism_5,  ... ;
		if cult_org_code_5 ~= . then do; organism = trim(organism) || ", " || organism_5; end;
		if cult_org_code_4 ~= . then do; organism = trim(organism) || ", " || organism_4; end;
		if cult_org_code_3 ~= . then do; organism = trim(organism) || ", " || organism_3; end;
		if cult_org_code_2 ~= . then do; organism = trim(organism) || ", " || organism_2; end;

		if cult_org_code_1 ~= . then do; organism = trim(organism) || ", " || organism_1; end;
		*/
		if cult_org_code_5 ~= . then do; organism = organism_5; cult_org_code = cult_org_code_5; org_spec = org_spec_5; output; end;
		if cult_org_code_4 ~= . then do; organism = organism_4; cult_org_code = cult_org_code_4; org_spec = org_spec_4; output; end;
		if cult_org_code_3 ~= . then do; organism = organism_3; cult_org_code = cult_org_code_3; org_spec = org_spec_3; output; end;
		if cult_org_code_2 ~= . then do; organism = organism_2; cult_org_code = cult_org_code_2; org_spec = org_spec_2; output; end;

		if cult_org_code_1 ~= . then do; organism = organism_1; cult_org_code = cult_org_code_1; org_spec = org_spec_1; output; end; * every record has at least the first organism;
		else output;
		
		
		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;		

	* add labels to those infections w/o a confirmed organism;
	data by_organism_all_infec;
		set  by_organism_all_infec;

		if  (organism = "") & ~cult_obtain then organism = "(no culture obtained)";
		else if (organism = "") & (cult_obtain) & (~cult_positive) then organism = "(negative culture)";

		* also add indicator for whether this is a prevalent or incident culture ;
		if incident then organism = trim(organism) || " - [inc.]";
		if ~incident then organism = trim(organism) || " - [prev.]";

	run;

title "wbh";
proc contents data=by_organism_all_infec;run;
data bsi;
	set by_organism_all_infec;
	where site_code='BSI' and type_code='LCBI';
run;

ods pdf file="bsi.pdf" style=journal;
proc print data=bsi style(data)=[just=left];
var id site_code organism;
run;

ods pdf close;
