
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait;

%let mu=%sysfunc(byte(181));

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
        *if incident=1;
run;

proc sort; by id dt_infect; run;

data infect_any;
    set  infect; by id dt_infect;
    if first.id;
    keep id bsi cvs gi lri ssi uti any dt_infect;
    rename dt_infect=dt_any;
run;

data infect_bsi;
    set  infect(keep=id dt_infect bsi where=(bsi=1));
run;

proc sort; by id dt_infect; run;

data infect_bsi; 
    set infect_bsi; by id dt_infect;
    if first.id;
    rename dt_infect=dt_bsi;
    drop bsi;
run;

data infect_lri;
    set  infect(keep=id dt_infect lri where=(lri=1));
run;

proc sort; by id dt_infect; run;

data infect_lri; 
    set infect_lri; by id dt_infect;
    if first.id;
    rename dt_infect=dt_lri;
    drop lri;
run;

proc means data=infect noprint;
	    class any id;
        var incident;
        output out = sum_any(where=(any=1 and id^=.)) sum(incident) = ni_any;
run;

proc means data=infect noprint;
	    class bsi id;
        var incident;
        output out = sum_bsi(where=(bsi=1 and id^=.)) sum(incident) = ni_bsi;     
run;

proc means data=infect noprint;
	    class lri id;
        var incident;
        output out = sum_lri(where=(lri=1 and id^=.)) sum(incident) = ni_lri;     
run;

proc format;
    value trt 1="AG-PN" 2="STD-PN";
run;

proc contents data=glnd.mech_vent;run;

data info;
  merge glnd.george (keep = id dt_random treatment in=comp)
        glnd.basedemo(keep=id age gender bmi race  surg)
        glnd.status (keep = id deceased apache_2 dt_death dt_discharge days_hosp days_sicu days_hosp_post_entry days_sicu_post_entry followup_days)
        glnd.plate6(keep=id apache_total rename=(apache_total=ap0))
        glnd.plate6b(keep=id apache_total rename=(apache_total=ap1))
        glnd.mech_vent(keep=id ever_on_vent days_on_vent_adj vent_free_days)
        infect_bsi
        infect_lri
        infect_any(keep=id dt_any)
        sum_any(keep=id ni_any)
        sum_bsi(keep=id ni_bsi)
        sum_lri(keep=id ni_lri); by id;
        
        if comp;
        
  if deceased & (dt_death <= dt_discharge) then hospital_death = 1 ; else hospital_death = 0;
  if deceased & ((dt_death - dt_random) <= 28) then day_28_death = 1; else day_28_death = 0;	  
  if (id = 32175) then hospital_death = 1; ** correction on 3/06/09 because we do not yet have hospital release date **;
  if 0<dt_bsi<=dt_discharge then bsi_hosp=1; else bsi_hosp=0;
  if 0<dt_lri<=dt_discharge then pneu_hosp=1; else pneu_hosp=0;
  if ni_any=. then ni_any=0;
  if ni_bsi=. then ni_bsi=0;
  
  format ni_any ni_bsi ni_lri;
  format treatment trt. day_28_death hospital_death deceased bsi_hosp pneu_hosp yn. race race.;
  label day_28_death="28 day mortality"
    hospital_death="in-hospital mortality"
    deceased="6 month mortality"
    ni_any="total number of incident nosocomial infections per patient"
    ni_bsi="total number of incident BSI per patient"
    ni_lri="total number of incident Pneumonia or Lower Respiratory Tract Infection per patient"
    bsi_hosp="did patient have incident BSI while in hospital?"
    pneu_hosp="did patient have incident pneumonia while in hospital?"
    days_sicu="Total number of days in ICU"
    days_hosp="Total number of days in hospital"
    days_sicu_post_entry="number of days in ICU"
    days_hosp_post_entry="number of days in hospital"
    followup_days="Follow-up Days"
    ap0="APACHE at Entry"
    ap1="APACHE at SICU"
    dt_bsi="Date of BSI onset" 
    dt_lri="Date of LRI(pneumonia) onset" 
    dt_death="Date of death"
    dt_random="Date Randomized"
    id="GLND ID"
    race="Race"
    treatment="Treatment"
    ;
run;

data glnd.info;
    set info;
run;
proc contents;run;

proc export data=info outfile='glnd_info.csv' replace label dbms=csv replace; run;

data infect;
    set info; by id dt_bsi;
    keep id ni_bsi dt_bsi;
run;
proc sort nodupkey;by _all_;run;
proc print;run;
