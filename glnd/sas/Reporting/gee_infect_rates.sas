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
   value gp 1="by Hospital Days" 2="by SICU Days";
   value idx 1="Treatment" 2="Period" 3="Interaction between treatment and period";
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

        keep id cult_org_code org_spec incident;
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
	
/*	
	proc print;
	var id any dt_infect incident;
	run;
*/
	
data _null_;
    set glnd.george(where=(treatment=1));
    call symput("na", compress(_n_));
run;
	

data _null_;
    set glnd.george(where=(treatment=2));
    call symput("nb", compress(_n_));
run;

%put &nb;

proc sort data= glnd.george; by dt_random; run;

data half_cut;;
    set glnd.george; by dt_random;
    if _n_=75 then call symput("dt", compress(month(dt_random))||"/"||compress(year(dt_random)));
    if _n_<=75 then half=1; else half=2;
    keep id half;
run;		
proc sort; by id; run;

proc sort data= glnd.george; by id; run;

	
%macro grate(data,var,idx);

	data sub;
	   merge &data(keep=id incident bsi cvs gi lri ssi uti nbsi any dt_infect in=A) 
	         glnd.george(keep=id dt_random);  by id;
       if A and incident=1 and &var=1;
       iday= dt_infect-dt_random;
	   if iday<=14 then wk1=1;
	   if 14<iday<=28 then wk2=1;
	   	          
	   drop dt_random;
	run;
	
	proc sort; by id dt_infect;run;
	
	proc means data=sub noprint;
	    class id;
        var wk1 wk2;
        output out = sum_rate sum(wk1) = nwk1 sum(wk2)=nwk2;
	run;
	

	data sum_rate;
	   set sum_rate;
	   if id=. then delete;

	   wk=1; ni=nwk1; output;
	   wk=2; ni=nwk2; output;

   	   drop nwk1 nwk2  _TYPE_    _FREQ_;
	run;
    
    data rate;
        merge sum_rate(in=A) half_cut
            glnd.george (keep = id treatment)
            glnd.status (keep = id days_hosp_post_entry days_sicu); by id;
        if A;
        %if &idx=1 %then %do;
        if 14<days_hosp_post_entry and ni=. then ni=0;
        if days_hosp_post_entry<14 and wk=1 then ln_day=log(days_hosp_post_entry);
        else if 14<=days_hosp_post_entry<28 then do; if  wk=1 then ln_day=log(14); if wk=2 then ln_day=log(days_hosp_post_entry-14); end;
        else if days_hosp_post_entry>=28 then ln_day=log(14);
        %end;
        
        %if &idx=2 %then %do;
        if 14<days_sicu and ni=. then ni=0;
        if days_sicu<14 and wk=1 then ln_day=log(days_sicu);
        else if 14<=days_sicu<28 then do; if  wk=1 then ln_day=log(14); if wk=2 then ln_day=log(days_sicu-14); end;
        else if days_sicu>=28 then ln_day=log(14);
        %end;
        
        tday=exp(ln_day);
   run;
   
 
   proc means data=rate;
        class treatment wk;
        var ni tday;
        output out=sum_ni sum(ni) =sum_ni sum(tday)=sum_day;
        output out=temp n(ni)=n;
   run;
   
 
    data _null_;
        set temp;
        if treatment=1 and wk=1 then call symput("n1", compress(n));
        if treatment=1 and wk=2 then call symput("n2", compress(n));
        if treatment=2 and wk=1 then call symput("n3", compress(n));        
        if treatment=2 and wk=2 then call symput("n4", compress(n));        
    run; 

    data _null_;
        set sum_ni;
        if treatment=1 and wk=1 then do; call symput("m1", compress(sum_ni)); call symput("day1", compress(sum_day)); end;
        if treatment=1 and wk=2 then do; call symput("m2", compress(sum_ni)); call symput("day2", compress(sum_day)); end;
        if treatment=2 and wk=1 then do; call symput("m3", compress(sum_ni)); call symput("day3", compress(sum_day)); end;       
        if treatment=2 and wk=2 then do; call symput("m4", compress(sum_ni)); call symput("day4", compress(sum_day)); end;       
    run;  
   
    *ods trace on/label listing;
    proc genmod data=rate;     
        class id treatment wk; 
        model ni=treatment wk treatment*wk /dist=poisson offset=ln_day type3;
        repeated subject=id/type=exch covb;               
    
        Estimate 'AG-PN and Week 1~2'  int 1 treatment 1 0 wk 1 0 treatment*wk 1 0 0 0/exp;
        Estimate 'AG-PN and Week 2~4'  int 1 treatment 1 0 wk 0 1 treatment*wk 0 1 0 0/exp;
        Estimate 'STD-PN and Week 1~2' int 1 treatment 0 1 wk 1 0 treatment*wk 0 0 1 0/exp;       
        Estimate 'STD-PN and Week 2~4' int 1 treatment 0 1 wk 0 1 treatment*wk 0 0 0 1/exp;       
 
        ods output Genmod.Estimates=rate_est;  
        ods output Genmod.Type3=pv;
    run;
    *ods trace off;

   
    data rate;
        merge 
            rate_est(where=(label="AG-PN and Week 1~2") rename=(LBetaEstimate=est1 LBetaLowerCL=lower1 LBetaUpperCL=upper1)) 
            rate_est(where=(label="AG-PN and Week 2~4") rename=(LBetaEstimate=est2 LBetaLowerCL=lower2 LBetaUpperCL=upper2)) 
            rate_est(where=(label="STD-PN and Week 1~2") rename=(LBetaEstimate=est3 LBetaLowerCL=lower3 LBetaUpperCL=upper3)) 
            rate_est(where=(label="STD-PN and Week 2~4") rename=(LBetaEstimate=est4 LBetaLowerCL=lower4 LBetaUpperCL=upper4)) 
              /*pv(keep=probchisq rename=(probchisq=pv))*/;
         format pv 4.2;
    run;
    
    proc contents data=pv;run;
    
    data pv&idx;
        set pv;
        index=_n_;
        keep source probchisq index;
        format index idx.;
    run;
    

      
    data rate&idx;
        length rateA  rateB  rateC rateD $50 nf1-nf4 $20;
        set rate;
        idx=&idx;
        f1=&n1/75*100;         f2=&n2/75*100;         f3=&n3/75*100;         f4=&n4/75*100;
        nf1=compress(&m1)||"("||compress(&n1)||"), "||compress(put(f1,4.1))||"%";
        nf2=compress(&m2)||"("||compress(&n2)||"), "||compress(put(f2,4.1))||"%";
        nf3=compress(&m3)||"("||compress(&n3)||"), "||compress(put(f3,4.1))||"%";
        nf4=compress(&m4)||"("||compress(&n4)||"), "||compress(put(f4,4.1))||"%";
        
        nday1=&day1;         nday2=&day2;         nday3=&day3;         nday4=&day4;
        
        rate1=exp(Est1)*1000;
       	upper_rate1 =exp(Upper1)*1000;
		lower_rate1 =exp(Lower1)*1000;

        rate2=exp(Est2)*1000;
       	upper_rate2 =exp(Upper2)*1000;
		lower_rate2 =exp(Lower2)*1000;
		
		rate3=exp(Est3)*1000;
       	upper_rate3 =exp(Upper3)*1000;
		lower_rate3 =exp(Lower3)*1000;
		
		rate4=exp(Est4)*1000;
       	upper_rate4 =exp(Upper4)*1000;
		lower_rate4 =exp(Lower4)*1000;
		
		
		rateA=compress(put(rate1,4.1))||"["||compress(put(lower_rate1,4.1))||"-"||compress(put(upper_rate1,4.1))||"]";
    	rateB=compress(put(rate2,4.1))||"["||compress(put(lower_rate2,4.1))||"-"||compress(put(upper_rate2,4.1))||"]";
    	rateC=compress(put(rate3,4.1))||"["||compress(put(lower_rate3,4.1))||"-"||compress(put(upper_rate3,4.1))||"]";
    	rateD=compress(put(rate4,4.1))||"["||compress(put(lower_rate4,4.1))||"-"||compress(put(upper_rate4,4.1))||"]";
    	
		keep idx nf1-nf4 nday1-nday4 rate1-rate4 upper_rate1-upper_rate4 lower_rate1-lower_rate4 rateA rateB rateC rateD;
    run;
    
    data rate_&idx;
        set rate&idx(keep=idx nf1 nf2 nday1 nday2 rateA rateB in=A)
            rate&idx(keep=idx nf3 nf4 nday3 nday4 rateC rateD rename=(nf3=nf1 nf4=nf2  nday3=nday1 nday4=nday2 rateC=rateA rateD=rateB) in=B);
            if A then trt=1;
            if B then trt=2;
    run;

%mend grate;


%grate(infect,any, 1);
%grate(infect,any, 2);quit;

data rate;
    set rate_1 rate_2 ;
    format idx gp.;
run;


options orientation=landscape;
ods rtf file="gee_rates.rtf" style=journal bodytitle startpage=never;
proc print data=rate split="*" noobs label; 
title "Table 6: Any Infection Rates per 1000 Hospital Days and Any Infection Rates per 1000 SICU Days in the First 4 Weeks";
by idx;
id idx/style=[just=left];
var trt nf1  nday1 rateA nf2 nday2 rateB/style=[just=center width=1in];
label idx="."
    trt="Treatment"
    nf1="Week 1~2*#infect.(#pat)%"
    nf2="Week 3~4*#infect.(#pat)%"
    nday1="Week 1~2*Total Days"
    nday2="Week 3~4*Total Days"
    rateA="Week 1~2*infec/1000 days[%95CI]"
    rateB="Week 3~4*infec/1000 days[%95CI]"
   ;
format trt treatment.;
run;

proc print data=pv1 noobs label;
title1 "Any Infection Rates per 1000 Hospital Days in the First 4 Weeks";
title2 "P value for Repeated Measurements Analysis";
var index/style=[just=left];
var  probchisq/style=[width=1in];
label index="Effect" probchisq="p value";
run;

proc print data=pv2 noobs label;
title1 "Any Infection Rates per 1000 SICU Days in the First 4 Weeks";
title2 "P value for Repeated Measurements Analysis";
var index/style=[just=left];
var  probchisq/style=[width=1in];
label index="Effect" probchisq="p value";
run;
ods rtf close;

proc format; 
    value group 0=" " 1="AG-PN" 2="STD-PN" 3=" ";
    value index 1="Week 1~2" 2="Week 3~4";
run;

data rate;
    set rate1(in=A keep=rate1 lower_rate1 upper_rate1 rename=(rate1=rate lower_rate1=lower_rate upper_rate1=upper_rate)) 
        rate1(in=B keep=rate2 lower_rate2 upper_rate2 rename=(rate2=rate lower_rate2=lower_rate upper_rate2=upper_rate)) 
        rate1(in=C keep=rate3 lower_rate3 upper_rate3 rename=(rate3=rate lower_rate3=lower_rate upper_rate3=upper_rate)) 
        rate1(in=D keep=rate4 lower_rate4 upper_rate4 rename=(rate4=rate lower_rate4=lower_rate upper_rate4=upper_rate)) ;
    if  A or C then index=1;
    if  B or D then index=2;
    if A or B then group=1;
    if C or D then group=2;
    if group=2 then index=index+0.05;
    if group=1 then do; rateA=rate; lower_rateA=lower_rate;  upper_rateA=upper_rate; end;
    if group=2 then do; rateB=rate; lower_rateB=lower_rate;  upper_rateB=upper_rate; end;
    format group group. index index.;
run;

ODS PDF FILE ="infect_rates.pdf";  
proc sgplot data=rate ;
title "Any Infection Rates by Treatment and Period";

SCATTER X = index Y = rateA / yerrorlower=lower_rateA yerrorupper=upper_rateA ERRORBARATTRS=(color=red)  LEGENDLABEL = 'AG-PN' MARKERATTRS=(size=8 SYMBOL=circlefilled color=red);
SCATTER X = index Y = rateB / yerrorlower=lower_rateB yerrorupper=upper_rateB ERRORBARATTRS=(color=blue) LEGENDLABEL = 'STD-PN' MARKERATTRS=(size=8 SYMBOL=circle color=blue);

keylegend/position=topright across=1 location=inside;

series x=index y=rateA / lineattrs=(pattern=dash THICKNESS = 0.5 color=red);
series x=index y=rateB / lineattrs=(pattern=dash THICKNESS = 0.5 color=blue);

xaxis integer values=(1 to 2 by 1) label=" " offsetmin=0.25 offsetmax=0.25;
yaxis integer values=(0 to 100 by 10)label="Any Infection Rates per 1000 Hospital Days" offsetmin=0.1 offsetmax=0.1;

run;
ods pdf close;
