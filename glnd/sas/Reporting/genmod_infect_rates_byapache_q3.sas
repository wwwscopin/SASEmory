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

        keep id cult_org_code org_spec type incident;
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

%let na=0;
%let nb=0;
%let daya=0;
%let dayb=0;

proc means data =glnd.plate6b Q1 median Q3;
var apache_total;
output out=wbh Q1(apache_total)=a1 median(apache_total)=a2 Q3(apache_total)=a3;
run;

data _null_;
    set wbh;
    call symput("ap1", compress(a1));
        call symput("ap2", compress(a2));
            call symput("ap3", compress(a3));
run;
	
%macro grate(data,var,idx);
	proc means data=&data noprint;
	    class &var id;
        var incident;
        output out = sum_rate sum(incident) = ni;
	run;

	
    data rate; 
        merge sum_rate( where=(&var^=. and id^=.) in=rate) 
        glnd.george (keep = id treatment)
        glnd.plate6b(keep=id apache_total)
        glnd.status (keep = id days_hosp_post_entry days_sicu rename=(days_hosp_post_entry=day)); by id;

        if not rate then ni=0;
        ****************************************;
        * this statement is specially important!;
        if ni=. then ni=0;
        ****************************************;

        if &var=. then &var=0;
        ln_day=log(day);
        
        /*
        if 0<apache_total<=11 then apachese4=1;
            else if apache_total<=16 then apachese4=2;
            else if apache_total<=20 then apachese4=3;
            else apachese4=4;         
         */
        
         if 0<apache_total<=&ap1 then apachese4=1;
            else if &ap1<apache_total<=&ap2 then apachese4=2;
            else if &ap2<apache_total<=&ap3 then apachese4=3;
            else apachese4=4; 
        
        if apachese4=3;  
        
        keep id &var ni treatment day ln_day apache_total apachese4;
        format ni;
    run; 

   
data _null_;
    set rate(where=(treatment=1));
    call symput("na", compress(_n_));
run;
	

data _null_;
    set rate(where=(treatment=2));
    call symput("nb", compress(_n_));
run;    
    
    
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
	
	data nf;
	   merge nf(where=(treatment=1) rename=(_FREQ_=m1 nt=nt1)) 
             nf(where=(treatment=2) rename=(_FREQ_=m0 nt=nt0));
             f1=m1/&na*100;
             f0=m0/&nb*100;
             
             nf1=compress(nt1)||"("||compress(m1)||"),"||compress(put(f1,4.1))||"%";
             nf0=compress(nt0)||"("||compress(m0)||"),"||compress(put(f0,4.1))||"%";
	run;
	  
    *ods trace on/label listing;
    proc genmod data=rate;
 
        %if &var=cvs or &var=gi or &var=lri or &var=uti  %then %do; 
            class id; 
            model ni=/dist=poisson offset=ln_day wald;        
            estimate "A" int 1;
        %end;
        %else %do;
            class id treatment ; 
            model ni=treatment /dist=poisson offset=ln_day type3;
            estimate "A" int 1 treatment 1 0;
            estimate "B" int 1 treatment 0 1;
        %end;
        
        repeated subject=id/type=exch covb;    
        ods output Genmod.Estimates=rate_est;  
        ods output Genmod.Type3=pv;
    run;
    *ods trace off;

   
    data rate;

         %if &var=cvs or &var=gi or &var=uti %then %do;
                set rate_est;
                est1=LBetaEstimate; upper1=LBetaUpperCL; lower1=LBetaLowerCL;
                est0=.; upper0=.; lower0=.;
                pv=.;
         %end;
         %else %if &var=lri %then %do;
                set rate_est;
                est0=LBetaEstimate; upper0=LBetaUpperCL; lower0=LBetaLowerCL;
                est1=.; upper1=.; lower1=.;
                pv=.;
         %end;
         %else %do;
            merge rate_est(where=(label="A") rename=(LBetaEstimate=est1 LBetaLowerCL=lower1 LBetaUpperCL=upper1)) 
              rate_est(where=(label="B") rename=(LBetaEstimate=est0 LBetaLowerCL=lower0 LBetaUpperCL=upper0)) 
              pv(keep=probchisq rename=(probchisq=pv));

         %end;
         
         format pv 4.2;
    run;
    
     
    data rate&idx;
        merge rate nf;
        idx=&idx;
        rate0=put(exp(Est0)*1000,4.1);
       	upper0_rate =put(exp(Upper0)*1000,4.1);
		lower0_rate =put(exp(Lower0)*1000,4.1);

        rate1=put(exp(Est1)*1000,4.1);
       	upper1_rate =put(exp(Upper1)*1000,4.1);
		lower1_rate =put(exp(Lower1)*1000,4.1);
		rateA=compress(rate1)||"["||compress(lower1_rate)||"-"||compress(upper1_rate)||"]";
    	rateB=compress(rate0)||"["||compress(lower0_rate)||"-"||compress(upper0_rate)||"]";
    	
    	
    	if m0=. then do; rateB=" "; nf0=" "; end;
        if m1=. then do; rateA=" "; nf1=" "; end;
        if m0=. or m1=. then pv=" ";
        
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
*%grate(noso,other,14);


data rate0; idx=0; run;
data rate7; idx=7; run;
data rate10; idx=10; run;

data rate;
    length rateA rateB $15;
    set rate0 rate1 rate2 rate3 rate4 rate5 rate6 rate7 rate8 rate9 rate10 rate11 rate12 rate13;
    format idx idx.;
    /*if idx=2 then do; rateB=" "; nf0=" "; end;*/
run;

proc sort nodupkey; by idx; run;
proc print;run;

options orientation=landscape;
ods rtf file="genmod_rates_Hosp_apache3.rtf" style=journal bodytitle;
ods escapechar="^";
proc print data=rate split="*" noobs label; 
*title1 "Table 2a: Incident Infection Rates for Apache<=&ap1(First Quartile for Apache at First ICU Day):";
*title1 "Table 2b: Incident Infection Rates for Apache=&ap1~&ap2(Second Quartile for Apache at First ICU Day):";
title1 "Table 2c: Incident Infection Rates for Apache=&ap2~&ap3(Third Quartile for Apache at First ICU Day):";
*title1 "Table 2d: Incident Infection Rates for Apache>&ap3(Fourth Quartile for Apache at First ICU Day):";
title2 "AG-PN = &na patients, STD-PN = &nb patients (Patient Hospital days observed: AG-PN = &daya days, STD-PN = &dayb days)";
*title2 "AG-PN = &na patients, STD-PN = &nb patients (Patient SICU days observed: AG-PN = &daya days, STD-PN = &dayb days)";


var idx/style=[just=left];
var nf1 rateA nf0 rateB pv/style=[just=center];
label idx="."
    nf1="AG-PN*#infec.(#pat),%"
    rateA="AG-PN*infec/1000 hosp.days[%95CI]"
    nf0="STD-PN*#infec.(#pat),%"
    rateB="STD-PN*infec/1000 hosp. days[%95CI]"
    pv="p value"
   ;
run;
ods rtf text = "^S={LEFTMARGIN=1in RIGHTMARGIN=1in font_size=11pt font_style= slant}
Infection rates per 1000 hospital days were estimated and compared using Poisson 
regression analysis implemented using SAS 'Proc Genmod'.";
ods rtf close;

