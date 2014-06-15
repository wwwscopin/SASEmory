%include "tab_stat.sas";

%let pm=%sysfunc(byte(177));


		data  indiv_pn_tables;
		set glnd_rep.indiv_pn_tables  ;
		by id;

		if last.id then delete; * remove last observation, which contains the details of a patient's hospital data termination;
	run;
	
	
	data  indiv_pn_tables;
		merge 
			indiv_pn_tables (in = from_nut)
			glnd.george (keep = id treatment)
			glnd.plate11 (keep = id bod_weight); * sorted already;
		by id;


		* Give week assignment so that we can summarize by week in PROC MEANS;
		if day < 8 then wk = 1;
		else if day < 15 then wk = 2;
		else if day < 22 then wk = 3;
		else if day < 29 then wk = 4;

		* kcal per gram body weight ;
		overall_kcal_per_kg = tot_kcal / bod_weight;
		pn_kcal_per_kg = tot_parent_kcal / bod_weight;
		en_kcal_per_kg = tot_ent_kcal / bod_weight;

			* look at PN kcal composition individually - we can't look at overall food composition since we don't have this breakdown for EN ;
			pn_aa_kcal_per_kg = pn_aa_kcal / bod_weight;
			pn_cho_per_kg = pn_cho / bod_weight;
			pn_lipid_per_kg = pn_lipid / bod_weight;

		* grams AA per kilogram body weight ;
  		overall_aa_g_per_kg = tot_aa / bod_weight;
		pn_aa_g_per_kg = pn_aa_g / bod_weight;
		en_aa_g_per_kg = tot_ent_prot / bod_weight;

     
        if id=12506 and day=26 then tot_parent_kcal=1987; 
        if pn_kcal_per_kg>overall_kcal_per_kg then delete;
           
		label 
			overall_kcal_per_kg = "Overall kcal/kg"
			pn_kcal_per_kg = "PN kcal/kg"
			en_kcal_per_kg = "EN kcal/kg"

			pn_aa_kcal_per_kg = "PN kcal/kg, from AA"
			pn_cho_per_kg = "PN kcal/kg, from CHO"
			pn_lipid_per_kg = "PN kcal/kg, from lipid"

			overall_aa_g_per_kg	= "Overall AA g/kg"
			pn_aa_g_per_kg = "PN AA g/kg"
			en_aa_g_per_kg = "EN AA g/kg"
			treatment="Treatment"

			;
	run;

proc print;
var id day tot_kcal tot_parent_kcal pn_cho pn_aa_kcal pn_lipid iv_kcal prop_kcal tot_ent_kcal tube_kcal oral_kcal;
where id in(12506,21017);
run;

data glnd.pn;
    retain id age gender bmi ap1 treatment day days_hosp days_sicu overall_kcal_per_kg pn_kcal_per_kg en_kcal_per_kg overall_aa_g_per_kg pn_aa_g_per_kg en_aa_g_per_kg;
    merge indiv_pn_tables(keep=id treatment day overall_kcal_per_kg pn_kcal_per_kg en_kcal_per_kg overall_aa_g_per_kg pn_aa_g_per_kg en_aa_g_per_kg) 
    glnd.info(keep=id age gender bmi days_hosp days_sicu days_hosp_post_entry days_sicu_post_entry ap1 ever_on_vent days_on_vent_adj 
    vent_free_days hospital_death day_28_death deceased ni_any ni_bsi ni_lri)
    glnd.followup_all_long(keep=id day sofa_tot rename=(day=day_sofa));
    by id;
    if pn_kcal_per_kg>overall_kcal_per_kg then delete;
run;

proc export data=glnd.pn outfile='glnd_pn.csv' replace label dbms=csv; run;


proc means data=indiv_pn_tables sum maxdec=2;
    class id;
    var overall_kcal_per_kg pn_kcal_per_kg en_kcal_per_kg;
    output out=sum_pn sum(overall_kcal_per_kg)=sum_tot sum(pn_kcal_per_kg)=sum_pn sum(en_kcal_per_kg)=sum_en;
run;		

data sum_pn;
    set sum_pn;
    pct_pn=sum_pn/sum_tot*100;
    format pct_pn 5.2;
    if id=. then delete;
    keep id pct_pn sum_tot sum_pn;
run;
proc print;
title "xxx";
where pct_pn>100;
run;

proc means data=sum_pn Q1 median Q3;
var pct_pn;
output out=xxx Q1(pct_pn)=Q1_pct_pn median(pct_pn)=Q2_pct_pn Q3(pct_pn)=Q3_pct_pn;
run;

data _null_;
    set xxx;
    call symput ("Q1", put(Q1_pct_pn,5.2));
        call symput ("Q2", put(Q2_pct_pn,5.2));
            call symput ("Q3", put(Q3_pct_pn,5.2));
run;

data pct_pn;
    set sum_pn;
    if 0<=pct_pn<=&Q1 then Q_pct_pn=1;
     else if pct_pn<=&Q2 then Q_pct_pn=2;
     else if pct_pn<=&Q3 then Q_pct_pn=3;
     else if pct_pn>&Q3 then Q_pct_pn=4;
run;

data pct_pn;
    merge pct_pn
    glnd.info(keep=id treatment age gender bmi days_hosp days_sicu ap1 apache_2);by id;
    log_days_hosp=log(days_hosp);
run;

proc glm data=pct_pn;
    class treatment;
    model log_days_hosp=treatment pct_pn treatment*pct_pn/solution;
run;

proc sgplot data=pct_pn;
title " ";
*loess x=pct_pn y=log_days_hosp/smooth=0.5;
reg x=pct_pn y=log_days_hosp/degree=1;
run;
    
proc sort; by treatment;run;

ods rtf file="log_hosp_on.rtf" style=journal;
proc means data=pct_pn mean std median maxdec=1;
    types () treatment treatment*Q_pct_pn;
    class treatment Q_pct_pn;
    var log_days_hosp days_hosp;
run;
ods rtf close;

proc npar1way data=pct_pn wilcoxon;
    by treatment;
    class Q_pct_pn;
    var log_days_hosp days_hosp;
run;


proc means data=indiv_pn_tables median maxdec=2;
    class id wk;
    var overall_kcal_per_kg pn_kcal_per_kg en_kcal_per_kg overall_aa_g_per_kg pn_aa_g_per_kg en_aa_g_per_kg;
    ods output summary=med(keep=id wk overall_kcal_per_kg_median pn_kcal_per_kg_median en_kcal_per_kg_median overall_aa_g_per_kg_median pn_aa_g_per_kg_median en_aa_g_per_kg_median);
run;		

data med;
    merge med glnd.george (keep = id treatment); by id; 
run;

	
%macro excel(data, var);
proc means data=&data(where=(day<=16)) n Q1 median Q3 maxdec=1;
    class treatment day;	
    var &var;
    *output out=wbh n(&var)=n Q1(&var)=Q1 Median(&var)=Median Q3(&var)=Q3;
    ods output summary=wbh0;
run;

data wbh0;
    set wbh0;
    diff_median=&var._median-&var._Q1;
    diff_Q3=&var._Q3-&var._median;
    rename &var._Q1=Q1 &var._n=n;
    format &var._Q1 diff_median diff_q3 5.2;
run;
proc sort; by day treatment;run;


proc transpose data=wbh0 out=wbh(keep=_name_ COL1-col32 rename=(_name_=name)); 
var  Q1 diff_median diff_Q3 n;
run;


ods tagsets.excelxp file="kcal_&var..xls";
ods tagsets.excelxp
options(sheet_name="sheet");
proc print data=wbh noobs label split="*";run;
ods tagsets.excelxp close;

%mend excel;

%excel(indiv_pn_tables, overall_kcal_per_kg); quit;
%excel(indiv_pn_tables, pn_kcal_per_kg); quit;
%excel(indiv_pn_tables, en_kcal_per_kg); quit;

%excel(indiv_pn_tables, overall_aa_g_per_kg); quit;
%excel(indiv_pn_tables, pn_aa_g_per_kg); quit;
%excel(indiv_pn_tables, en_aa_g_per_kg); quit;

data glnd.kcal_pn;
    set indiv_pn_tables;
run;

/*
proc mixed data=indiv_pn_tables(where=(day<=14));
    class treatment id day;
    model overall_aa_g_per_kg=treatment day treatment*day/solution;
   	repeated day / subject = id type = cs;
	lsmeans treatment*day/pdiff cl;
run;
*/
	
	
data pn;    
    set indiv_pn_tables;
    where day<15;
    
    if treatment=1 then do; 
        day1= day; 
        overall_kcal_per_kg1=overall_kcal_per_kg; 
        pn_kcal_per_kg1=pn_kcal_per_kg;
        en_kcal_per_kg1=en_kcal_per_kg;
        overall_aa_g_per_kg1=overall_aa_g_per_kg;
        pn_aa_g_per_kg1=pn_aa_g_per_kg;
        en_aa_g_per_kg1=en_aa_g_per_kg;
    end;
    if treatment=2 then do; 
        day2= day+0.25; 
        overall_kcal_per_kg2=overall_kcal_per_kg; 
        pn_kcal_per_kg2=pn_kcal_per_kg;
        en_kcal_per_kg2=en_kcal_per_kg;
        overall_aa_g_per_kg2=overall_aa_g_per_kg;
        pn_aa_g_per_kg2=pn_aa_g_per_kg;
        en_aa_g_per_kg2=en_aa_g_per_kg;
    end;
run;

%macro getn(data);
%do j = 0 %to 15;
data _null_;
    set &data;
    where day = &j;
    if treatment=1 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if treatment=2 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=all device=pslepsfc gunit=pct noborder cback=white colors = (black red)  ftext=Triplex HTEXT=3 hby = 3;

legend1 across = 1 position=(bottom left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = ("AG-PN" "STD-PN") offset=(0.2in, 0.2in) frame;

legend2 across = 1 position=(Top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = ("AG-PN" "STD-PN") offset=(0.2in, -0.2in) frame;

symbol1 i=box25f bwidth=2 cv=pink co=black;
symbol2 i=box25f bwidth=2 cv=cyan co=black;

axis1 label=(h=4 "Day") minor=none offset=(0pct,0pct) value=(h=1.25) order=(0 to 15 by 1) split="*";


%macro plot(data, var, label, ov)/minoperator;
proc means data=&data noprint;
    class treatment day;
    var &var;
	output out = num_&var n(&var) = num_obs;
run;

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0; %let m9= 0; %let m10= 0; %let m11= 0; %let m12= 0; %let m13= 0; %let m14= 0;   
%let m15= 0; %let m16= 0; %let m17= 0; %let m18= 0; %let m19= 0; %let m20=0; %let m21= 0;  
%let m22= 0; %let m23= 0; %let m24= 0; %let m25= 0; %let m26= 0; %let m27= 0; %let m28= 0;   

%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; %let n9= 0; %let n10= 0; %let n11= 0; %let n12= 0; %let n13= 0; %let n14= 0; 
%let n15= 0; %let n16= 0; %let n17= 0; %let n18= 0; %let n19= 0; %let n20=0; %let n21= 0;  
%let n22= 0; %let n23= 0; %let n24= 0; %let n25= 0; %let n26= 0; %let n27= 0; %let n28= 0; 

%getn(num_&var);


proc format;

value dd 0 = "Day*(#AG-PN)*(#STD-PN)"  1="1*(&m1)*(&n1)"  2 ="2*(&m2)*(&n2)" 3="3*(&m3)*(&n3)" 4 ="4*(&m4)*(&n4)" 5="5*(&m5)*(&n5)" 6 = "6*(&m6)*(&n6)" 
        7="7*(&m7)*(&n7)" 8 = "8*(&m8)*(&n8)" 9="9*(&m9)*(&n9)" 10 = "10*(&m10)*(&n10)" 11="11*(&m11)*(&n11) " 12 = "12*(&m12)*(&n12)" 
        13="13*(&m13)*(&n13)" 	14 = "14*(&m14)*(&n14)" 15="15*(&m15)*(&n15)" 16=" ";
        
value dt 0 = "Day*(#AG-PN)*(#STD-PN)"  1=" "  2 ="2*(&m2)*(&n2)" 3=" " 4 ="4*(&m4)*(&n4)" 5=" " 6 = "6*(&m6)*(&n6)" 
        7=" " 8 = "8*(&m8)*(&n8)" 9=" " 10 = "10*(&m10)*(&n10)" 11=" " 12 = "12*(&m12)*(&n12)" 
        13=" " 	14 = "14*(&m14)*(&n14)" 15=" " 16=" ";        
run;

axis2 label=(h=4 a=90  "&label") minor=none order=&ov;  
proc gplot data=&data gout=glnd_rep.graphs;
   %if &var # en_kcal_per_kg en_aa_g_per_kg %then %do;
       plot &var.1*day1 &var.2*day2/ overlay haxis=axis1 vaxis=axis2 autovref legend=legend2;
   %end;
   %else %do;
       plot &var.1*day1 &var.2*day2/ overlay haxis=axis1 vaxis=axis2 autovref legend=legend1;
   %end;
   format day1 dt.;
run;

/*
data temp;  
    set &data;
run;
proc sort; by treatment;run;

title "Quantile Regression";
ods graphics on;
proc quantreg data=temp ci=sparsity;
   by treatment;
   model &var =day day*day day*day*day/
                    quantile=0.5 0.75 plot=fitplot(showlimits);
run;
ods graphics off;
*/
%mend plot;

%let ov=0 to 35 by 5;
%let label=Total Energy (kcal/kg/day);
%plot(pn, overall_kcal_per_kg, &label,&ov);
%let label=Parenteral Energy (kcal/kg/day);
%plot(pn, pn_kcal_per_kg, &label, &ov);
%let label=Enteral Energy (kcal/kg/day);
%plot(pn, en_kcal_per_kg, &label, &ov);


%let ov=0 to 2 by 0.2;	
%let label=Total Protein/AA (g/kg/day);
%plot(pn, overall_aa_g_per_kg, &label, &ov);
%let label=Parenteral Protein/AA (g/kg/day);
%plot(pn, pn_aa_g_per_kg, &label, &ov);
%let label=Enteral Protein/AA (g/kg/day);
%plot(pn, en_aa_g_per_kg, &label, &ov);

/*
filename output 'nut_kcal_prot.eps';
goptions reset=all NOBORDER rotate=portrait device=pslepsfc gsfname=output gsfmode=replace ;

	ods pdf file = "nut_kcal_prot.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v3s  nofs ; * L2R2s;
            list igout;
			treplay 1:1 2:2 3:3;
			treplay 1:4 2:5 3:6;
		run;
	ods pdf close;
	quit;
*/


options orientation=landscape papersize=(11in 8.5in);

filename output 'nut_kcal_prot.eps';
goptions reset=all NOBORDER device=pslepsfc gsfname=output gsfmode=replace ;

ods pdf file = "nut_kcal_prot.pdf";
proc greplay nofs /*NOBYLINE*/;
igout glnd_rep.graphs;
list igout;
tc template;
tdef t1 4 /llx=0     ulx=0    lrx=30    urx=30   lly=10    uly=45    lry=10     ury=45
        5 /llx=35    ulx=35   lrx=65    urx=65   lly=10    uly=45    lry=10     ury=45
        6 /llx=70    ulx=70   lrx=100   urx=100  lly=10    uly=45    lry=10     ury=45
        1 /llx=0     ulx=0    lrx=30    urx=30   lly=55    uly=90    lry=55     ury=90
        2 /llx=35    ulx=35   lrx=65    urx=65   lly=55    uly=90    lry=55     ury=90
        3 /llx=70    ulx=70   lrx=100   urx=100  lly=55    uly=90    lry=55     ury=90		;
template t1;
tplay 1:1 2:2 3:3 4:4 5:5 6:6;
run; quit;
ods pdf close;

		

/*
%table(data_in=med,data_out=kcal_tab, where=wk=1, gvar=treatment,var=overall_kcal_per_kg_median,label="Total", type=con, first_var=1, title="Kcal/kg Summary");
%table(data_in=med,data_out=kcal_tab, where=wk=1, gvar=treatment,var=pn_kcal_per_kg_median,label="PN", type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=1, gvar=treatment,var=en_kcal_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=2, gvar=treatment,var=overall_kcal_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=2, gvar=treatment,var=pn_kcal_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=2, gvar=treatment,var=en_kcal_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=3, gvar=treatment,var=overall_kcal_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=3, gvar=treatment,var=pn_kcal_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=3, gvar=treatment,var=en_kcal_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=4, gvar=treatment,var=overall_kcal_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=4, gvar=treatment,var=pn_kcal_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk=4, gvar=treatment,var=en_kcal_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk in(1,2), gvar=treatment,var=overall_kcal_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk in(1,2), gvar=treatment,var=pn_kcal_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=kcal_tab, where=wk in(1,2), gvar=treatment,var=en_kcal_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=kcal_tab, gvar=treatment,var=overall_kcal_per_kg_median,label="Total",type=con );
%table(data_in=med,data_out=kcal_tab, gvar=treatment,var=pn_kcal_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=kcal_tab, gvar=treatment,var=en_kcal_per_kg_median,label="EN",type=con, last_var=1);


%table(data_in=med,data_out=prot_tab, where=wk=1, gvar=treatment,var=overall_aa_g_per_kg_median,label="Total",type=con, first_var=1, title="Protein/AA g/kg Summary");
%table(data_in=med,data_out=prot_tab, where=wk=1, gvar=treatment,var=pn_aa_g_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=1, gvar=treatment,var=en_aa_g_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=2, gvar=treatment,var=overall_aa_g_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=2, gvar=treatment,var=pn_aa_g_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=2, gvar=treatment,var=en_aa_g_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=3, gvar=treatment,var=overall_aa_g_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=3, gvar=treatment,var=pn_aa_g_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=3, gvar=treatment,var=en_aa_g_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=4, gvar=treatment,var=overall_aa_g_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=4, gvar=treatment,var=pn_aa_g_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk=4, gvar=treatment,var=en_aa_g_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk in(1,2), gvar=treatment,var=overall_aa_g_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=prot_tab, where=wk in(1,2), gvar=treatment,var=pn_aa_g_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=prot_tab, where=wk in(1,2), gvar=treatment,var=en_aa_g_per_kg_median,label="EN",type=con);
%table(data_in=med,data_out=prot_tab, gvar=treatment,var=overall_aa_g_per_kg_median,label="Total",type=con);
%table(data_in=med,data_out=prot_tab, gvar=treatment,var=pn_aa_g_per_kg_median,label="PN",type=con);
%table(data_in=med,data_out=prot_tab, gvar=treatment,var=en_aa_g_per_kg_median,label="EN",type=con, last_var=1);
*/
