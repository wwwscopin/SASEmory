OPTION SPOOL;
 
 proc format;
  value idx 0="== Specific Infections =="
            1="Bloodstream Infection"
            2="Cardiovascular System Infection"
            3="Gastrointestinal System Infection"
            4="Pneumonia or Lower Respiratory Tract Infection"
            5="Surgical Site Infection"
            6="Urinary Tract Infection"
            7="==================="
            8="Any non-BSI infection"
            9="Any infection"
            10="==================="
            11="Any Gram+ Bacteria"
            12="Any Gram- Bacteria"
            13="Any Fungal Species"
            14="Any Other"
            ;

 run;
 
	data noso0;
		set glnd_rep.all_infections_with_adj;

		* work backwards from oganism_5,  ... ;
		if cult_org_code_5 ~= . then do; organism = organism_5; cult_org_code = cult_org_code_5; org_spec = org_spec_5; output; end;
		if cult_org_code_4 ~= . then do; organism = organism_4; cult_org_code = cult_org_code_4; org_spec = org_spec_4; output; end;
		if cult_org_code_3 ~= . then do; organism = organism_3; cult_org_code = cult_org_code_3; org_spec = org_spec_3; output; end;
		if cult_org_code_2 ~= . then do; organism = organism_2; cult_org_code = cult_org_code_2; org_spec = org_spec_2; output; end;
		if cult_org_code_1 ~= . then do; organism = organism_1; cult_org_code = cult_org_code_1; org_spec = org_spec_1; output; end; 
		* every record has at least the first organism;
		if compress(site_code)="UTI" and compress(type_code) ^= "SUTI" then delete;

        keep id cult_org_code org_spec type_code incident;
 	run;	
 	
 	data noso;
 	  set noso0;
  		if incident^=.;
 	  	if cult_org_code in (1,2,3,4,5,6,7,11,16,21) then gpb=1;
		if cult_org_code in (8,9,10,12,13,14,15,22) then gnb=1;
		if cult_org_code in (17,18,19,20) then fungal=1;
		if cult_org_code in (23) then other=1;
 	run;
 	

	proc sort data= glnd.status; by id; run;
	proc sort data= glnd.george; by id; run;
	proc sort data= glnd_rep.all_infections_with_adj; by id; run;


	data infect;
		set	glnd_rep.all_infections_with_adj; by id;
	
		if compress(site_code)="UTI" and compress(type_code) = "ASB" then delete;
		if compress(site_code)="BSI"  then bsi=1;  
		if compress(site_code)="CVS"  then cvs=1; 
		if compress(site_code)="GI"   then gi=1;  
		if compress(site_code)="PNEU" then lri=1; 
		if compress(site_code)="SSI"  then ssi=1; 
		if compress(site_code)="UTI"  then uti=1; 

		
		if not bsi then nbsi=1;
        any=1;
	run;
	
	
data sub;
    merge
        glnd.george (keep = id dt_random treatment in=A) glnd.plate6(keep=id apache_total) 
        glnd.plate6b(keep=id apache_total rename=(apache_total=apache_icu))
        glnd.status (keep = id apache_2 days_hosp_post_entry days_sicu rename=(days_sicu=day)); by id;
            
        if A;    
        if 0<apache_total<=11 then apachese4=1;
            else if apache_total<=16 then apachese4=2;
            else if apache_total<=20 then apachese4=3;
            else apachese4=4;
            
         *if apachese4=4;   
         *if apache_icu>27;
         *if year(dt_random)=2008;
run;

data _null_;
    set sub(where=(treatment=1));
    call symput("na", compress(_n_));
run;
	

data _null_;
    set sub(where=(treatment=2));
    call symput("nb", compress(_n_));
run;



%let daya=0;
%let dayb=0;

%macro grate(data,var,idx);
	proc means data=&data noprint;
	    class &var id;
        var incident;
        output out = sum_rate sum(incident) = ni;
	run;
	
    data rate; 
        merge sum_rate( where=(&var^=. and id^=.) in=rate) 
        sub(in=A); by id;
        if A;
        if not rate then ni=0;
        if &var=. then &var=0;
        ln_day=log(day);
        if ni=. then ni=0;
        if ni>0 then infec=1; else infec=0;
        keep id &var ni treatment day ln_day infec;
        format ni;
    run;
    
    %if &var=any %then %do;
    data glnd.infect_any;
        set rate;
    run;    
    %end;
      
    proc means data=rate sum;
       class treatment;
	   var day;
	   output out=nday sum(day)=nday;
	run;
	
	data _null_;
	   set nday;
	   if treatment=1 then call symput("daya", compress(nday));
	   if treatment=2 then call symput("dayb", compress(nday));
	run;
	
         
    proc means data=rate(where=(ni>0));
       class treatment;
	   var ni;
	   output out=nf sum(ni)=nt;
	run;
	
	%if &var^=cvs %then %do;
	proc freq data=rate ;
	   tables infec*treatment/nocol norow chisq;
	   output out = pv chisq exact;
	run;


	data pv;
		set pv;
		pvalue=XP2_FISH;
		if pvalue=. then pvalue= P_PCHI;
		if pvalue^=. and pvalue<0.01 then pv='<0.01'; else pv=put(pvalue,5.2);
		keep pvalue pv;
	run;
	%end;
	%else %do;
	data pv; pv="-"; run;
	%end;
	
	
	data nf;
	   merge nf(where=(treatment=1) rename=(_FREQ_=m1 nt=nt1)) 
             nf(where=(treatment=2) rename=(_FREQ_=m0 nt=nt0))
             pv(firstobs=1 obs=1 keep=pv);
             /*
             if m0=. then do; m0=0; nt0=0; end;
             if m1=. then do; m1=0; nt1=0; end;
             */
             f1=m1/&na*100;
             f0=m0/&nb*100;
             
             nf1=compress(nt1)||"("||compress(m1)||"),"||compress(put(f1,4.1))||"%";
             nf0=compress(nt0)||"("||compress(m0)||"),"||compress(put(f0,4.1))||"%";
	   
	        
	            rate1 = ( nt1/ &daya) * 1000;
                rate0 = ( nt0/ &dayb) * 1000;
				
	
				conf_level = .95;
				
				upper_p = 1 - (1 - conf_level)/2;
				lower_p = 1 - upper_p;  
	
				* upper and lower CI bounds for the Poisson counts of incident infections ;
				upper_mu1 = .5 * cinv(upper_p, 2 * (nt1 + 1));
				lower_mu1 = .5 * cinv(lower_p, 2 * (nt1));
	

				* transform these into CI for the RATES;
				upper1_rate = (upper_mu1/&daya) * 1000;
				lower1_rate = (lower_mu1/&daya) * 1000;	
				
				* upper and lower CI bounds for the Poisson counts of incident infections ;
				upper_mu0 = .5 * cinv(upper_p, 2 * (nt0 + 1));
				lower_mu0 = .5 * cinv(lower_p, 2 * (nt0));
	

				* transform these into CI for the RATES;
				upper0_rate = (upper_mu0/&dayb) * 1000;
				lower0_rate = (lower_mu0/&dayb) * 1000;	
	run;
      
    data rate&idx;
        set nf;     idx=&idx;
        

	    rateA=compress(put(rate1,4.1))||"["||compress(put(lower1_rate,4.1))||"-"||compress(put(upper1_rate,4.1))||"]";
        rateB=compress(put(rate0,4.1))||"["||compress(put(lower0_rate,4.1))||"-"||compress(put(upper0_rate,4.1))||"]";
        
        /*if m0=. then do; rateB=" "; nf0=" "; end;
        if m1=. then do; rateA=" "; nf1=" "; end;
        if m0=. or m1=. then pv=" ";*/
  
		keep idx nf0 nf1 rate0 upper0_rate lower0_rate rate1 upper1_rate lower1_rate rateA rateB pv;
    run;
    
%mend grate;

%grate(infect,bsi,1);
%grate(infect,cvs,2); 
%grate(infect,gi,3);
%grate(infect,lri,4);
%grate(infect,ssi,5);
%grate(infect,uti,6);
%grate(infect,nbsi,8);
%grate(infect,any,9);

%grate(noso,gpb,11);
%grate(noso,gnb,12);
%grate(noso,fungal,13);

data rate0; idx=0; run;
data rate7; idx=7; run;
data rate10; idx=10; run;

data rate;
    length rateA rateB $15;
    set rate0 rate1 rate2 rate3 rate4 rate5 rate6 rate7 rate8 rate9 rate10 rate11 rate12 rate13;
    format idx idx.;
    if idx=2 then do; rateB=" "; nf0=" "; end;
run;

proc print;run;

options orientation=landscape;
ods rtf file="exact_rates_icu.rtf" style=journal bodytitle;

proc print data=rate split="*" noobs label; 
title1 "Infection Rates by Exact Method";
title2 "AG-PN = &na patients, STD-PN = &nb patients";
*title3 "(Patient hospital days observed: AG-PN = &daya days, STD-PN = &dayb days)";
title3 "(Patient SICU days observed: AG-PN = &daya days, STD-PN = &dayb days)";
			
var idx/style=[just=left];
var nf1 rateA nf0 rateB pv/style=[just=center];
label idx="."
    nf1="AG-PN*#infec.(#pat),%"
    rateA="AG-PN*infec/1000 SICU days[%95CI]"
    nf0="STD-PN*#infec.(#pat),%"
    rateB="STD-PN*infec/1000 SICU days[%95CI]"
    pv="p value"
   ;
run;
ods rtf close;
