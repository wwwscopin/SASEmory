proc sort data= glnd.george; by dt_random; run;

data _null_;
    set glnd.george;
    if _n_=75 then call symput("dt", compress(month(dt_random))||"/"||compress(year(dt_random)));
run;
 
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
 
     value sub 1="First Half of Patients (Enrolled between 11/2006  and &dt)" 2="Second Half of Patients (Enrolled between &dt and 10/2012)" 3="Overall"
               4="First Half of Patients (Enrolled between 11/2006  and &dt)" 5="Second Half of Patients (Enrolled between &dt and 10/2012)" 6="Overall";
     value gp 1="by Hospital Days" 2="by SICU Days";

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
	
data _null_;
    set glnd.george(where=(treatment=1));
    call symput("na", compress(_n_));
run;
	

data _null_;
    set glnd.george(where=(treatment=2));
    call symput("nb", compress(_n_));
run;

%put &nb;

%macro sub(byday,sub);

data sub;
    merge
        glnd.george (keep = id dt_random treatment in=A) glnd.plate6(keep=id apache_total) 
        glnd.plate6b(keep=id apache_total rename=(apache_total=apache_icu))
        glnd.status (keep = id apache_2 days_hosp_post_entry days_sicu); by id;
            
        if A;      

        %if &byday=hosp %then %do; rename days_hosp_post_entry=day; %end;
        %if &byday=sicu %then %do; rename days_sicu=day; %end;
run;

proc sort; by dt_random; run;

data sub;
    set sub; by dt_random; 
        %if &sub=0 %then %do; %end;
        %if &sub=1 %then %do; if _n_<=75; %end;
        %if &sub=2 %then %do; if _n_>75; %end;
run;

proc sort; by id; run;

data _null_;
    set sub(where=(treatment=1));
    call symput("na", compress(_n_));
run;
	

data _null_;
    set sub(where=(treatment=2));
    call symput("nb", compress(_n_));
run;

%mend sub;

%let daya=0;
%let dayb=0;
%let na=0;
%let nb=0;
	
%macro grate(data,var,idx);
    %if &idx=1 %then %do; %sub(hosp, 1); %end;
    %if &idx=2 %then %do; %sub(hosp, 2); %end;
    %if &idx=3 %then %do; %sub(hosp, 0); %end;
    %if &idx=4 %then %do; %sub(sicu, 1); %end;
    %if &idx=5 %then %do; %sub(sicu, 2); %end;
    %if &idx=6 %then %do; %sub(sicu, 0); %end;

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
        ****************************************;
        * this statement is specially important!;
        if ni=. then ni=0;
        ****************************************;

        if &var=. then &var=0;
        ln_day=log(day);
        keep id &var ni treatment day ln_day tday;
        format ni;
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
            class id treatment ; 
            model ni=treatment /dist=poisson offset=ln_day type3;
            estimate "A" int 1 treatment 1 0;
            estimate "B" int 1 treatment 0 1;
        
        repeated subject=id/type=exch covb;    
        ods output Genmod.Estimates=rate_est;  
        ods output Genmod.Type3=pv;
    run;
    *ods trace off;

   
    data rate;
            merge rate_est(where=(label="A") rename=(LBetaEstimate=est1 LBetaLowerCL=lower1 LBetaUpperCL=upper1)) 
              rate_est(where=(label="B") rename=(LBetaEstimate=est0 LBetaLowerCL=lower0 LBetaUpperCL=upper0)) 
              pv(keep=probchisq rename=(probchisq=pv));

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
    	
    	na=&na; nb=&nb; daya=&daya; dayb=&dayb;
    	
		keep idx nf0 nf1 rate0 upper0_rate lower0_rate rate1 upper1_rate lower1_rate rateA rateB na nb daya dayb pv;
    run;
    
    
%mend grate;


%grate(infect,bsi,1);
%grate(infect,bsi,2);
%grate(infect,bsi,3);
%grate(infect,bsi,4);
%grate(infect,bsi,5);
%grate(infect,bsi,6);


data rate;
    length rateA rateB $15;
    set rate1 rate2 rate3 rate4 rate5 rate6;
    if idx<=3 then group=1; else group=2;
    format idx sub. group gp.;
run;


options orientation=landscape;
ods rtf file="genmod_bsi_rates_sub.rtf" style=journal bodytitle;
proc print data=rate split="*" noobs label; 
title1 "BSI Rates per 1000 Hospital Days and BSI Rates per 1000 SICU Days";
			
by group;
id group/style=[just=left];
var idx/style=[just=left];
var na daya nf1 rateA nb dayb nf0 rateB pv/style=[just=center];
label 
    group="."
    idx="Group"
    na="AG-PN*n="
    daya="AG-PN*Days"    
    nf1="AG-PN*#infec.(#pat),%"
    rateA="AG-PN*infec/1000 days[%95CI]"
    nb="STD-PN*n="
    dayb="STD-PN*Days"
    nf0="STD-PN*#infec.(#pat),%"
    rateB="STD-PN*infec/1000 days[%95CI]"
    pv="p value"
   ;
run;
ods rtf close;

%grate(infect,any,1);
%grate(infect,any,2);
%grate(infect,any,3);
%grate(infect,any,4);
%grate(infect,any,5);
%grate(infect,any,6);


data rate;
    length rateA rateB $15;
    set rate1 rate2 rate3 rate4 rate5 rate6;
    if idx<=3 then group=1; else group=2;
    format idx sub. group gp.;
run;


options orientation=landscape;
ods rtf file="genmod_any_rates_sub.rtf" style=journal bodytitle;
proc print data=rate split="*" noobs label; 
title1 "Any Infection Rates per 1000 Hospital Days and Any Infection Rates per 1000 SICU Days";
			
by group;
id group/style=[just=left];
var idx/style=[just=left];
var na daya nf1 rateA nb dayb nf0 rateB pv/style=[just=center];
label 
    group="."
    idx="Group"
    na="AG-PN*n="
    daya="AG-PN*Days"    
    nf1="AG-PN*#infec.(#pat),%"
    rateA="AG-PN*infec/1000 days[%95CI]"
    nb="STD-PN*n="
    dayb="STD-PN*Days"
    nf0="STD-PN*#infec.(#pat),%"
    rateB="STD-PN*infec/1000 days[%95CI]"
    pv="p value"
   ;
run;
ods rtf close;

