/**/
proc contents data=glnd.wbh;run;


	data glnd.plate101;
		set glnd.plate101;

		*** CLEAN UP DISPLAY IN DATASETS, REMOVE REPEAT ORGANISMS ***;
		* Set up text field to contain organism format. need to have text rather than numeric so can adjust the "other people";
			/**/
			organism_1 = put(cult_org_code_1, cult_org_code.);
			organism_2 = put(cult_org_code_2, cult_org_code.);
			organism_3 = put(cult_org_code_3, cult_org_code.);
			organism_4 = put(cult_org_code_4, cult_org_code.);
			organism_5 = put(cult_org_code_5, cult_org_code.);
			/**/
		;		
	run;




