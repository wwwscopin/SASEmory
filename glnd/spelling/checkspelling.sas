	data suspected_noso_before_adj ;
		merge	glnd.plate101 (in = frozen keep = id dfseq dt_infect cult_obtain cult_positive cult_org_code_1)
				glnd.plate102 (keep = id dfseq cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5 )
				glnd.plate103 (keep = id dfseq infect_confirm site_code type_code)
				glnd.plate101 (keep = id dfseq org_spec_1)
				glnd.plate102 (keep = id dfseq org_spec_2 org_spec_3 org_spec_4 org_spec_5)
				;
		by id dfseq;
		
		if ~frozen then delete;
	run;


	data suspected_noso_before_adj;
		set suspected_noso_before_adj(keep=id dfseq cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
 			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5);
	run;
		

proc print data=glnd.plate101;run;
