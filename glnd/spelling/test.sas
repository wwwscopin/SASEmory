
data glnd.wbh;
		set glnd_rep.all_infections_with_adj(keep=id cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
		org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5);
		where cult_org_code_1^=. or cult_org_code_2^=. or cult_org_code_3^=. or cult_org_code_4^=. or cult_org_code_5^=.
			or org_spec_1^=" " or org_spec_2^=" " or org_spec_3^=" " or org_spec_4^=" " or org_spec_5^=" ";
			organism_1 = put(cult_org_code_1, cult_org_code.);
			organism_2 = put(cult_org_code_2, cult_org_code.);
			organism_3 = put(cult_org_code_3, cult_org_code.);
			organism_4 = put(cult_org_code_4, cult_org_code.);
			organism_5 = put(cult_org_code_5, cult_org_code.);
		drop cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5;
	run;


ods pdf file="check spelling.pdf" style = journal;
proc print;run;
ods pdf close;



