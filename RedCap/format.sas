libname library "H:/SAS_Emory/RedCap";

proc format library=library; 
	value idx  0="CONTRAL" 1="CASE";
	value yn   0="No" 1="Yes";
	value drug 
		1="Abacavir (ABC)"
		2="Combivir (3TC/ZDV)"
		3="Didanosine (DDI)"
		4="Efavirenz (EFV)"
		5="Emtricitabine (FTC)"
		6="Epzicom (3TC/ABC)"
		7="Indinavir (IDV)"
		8="Lamivudine (3TC)"
		9="Lopinavir/ritonavir or Kaletra (LPV/r)"
		10="Nevirapine (NPV)"
		11="Ritonavir (RTV)"
		12="Saquinavir (SQV)"
		13="Stavudine (D4T))"
		14="Tenofovir (TDF)"
		15="Truvada (FTC/TDF)"
		16="Zidovudine (ZDV)"
		17="Other"
		;
run;
