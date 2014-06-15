options orientation=portrait ls=120 minoperator;
%let path=H:\SAS_Emory\Consulting\Mac Starr\;
filename ases "&path.RCR2005-2009clean.xls";
%include "stat_macro.sas";

proc format; 
	value LR 0="Right" 1="Left";
	value yn 0="No" 1="Yes";
	value sex 0="F" 1="M";
	value size 1=small 2=medium 3=large 4=massive;
	value tissue 1=poor 2=fair 3=good;
	value comp 0=partial 1=complete;
	value age 0="<=65" 1=">65";
	value rom 0="<90" 1=">=90";
	value pain 0="<7" 1=">=7";
	value surg 0="1" 1=">1";
	value tissue 0="fair/poor/inadequate" 1="good/adequate";
	value size 0="small/medium" 1="large/massive";
	value item  0=" "
				1="Pain"
				2="ROM FE - Active"
				3="ROM ER"
				4="ROM IR"
				5="ADL Score"
				6="ASES Score"
				;
	value idx 1="Work Comp" 
			  2="Tobacco"
			  3="Age" 
			  4="ROM FE Active"
			  5="Pain Score"
			  6="Surgeries"
              7="Capsular"
			  8="Tissue Quality"
			  9="Repair Completeness"
			 10="Tear Size"
			 ;
	value didx 1="Delta_FE"
			   2="delta_ER"
			   3="delta_IR"
			   4="delta_ADL"
			   5="delta_ASES"
 			   6="delta_Pain"
			   ;
run;

proc import out=demo0
			datafile=ases
			DBMS=EXCEL REPLACE;
			RANGE="Patient Demographics$A1:J74";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
proc contents; run;
data demo;
	set demo0;
	rename Age_at_Surgery=age Tobacco__0_no__1_yes=tobacco;
	if gender="F" then sex=0; if gender="M" then sex=1;
	if lowcase(Hand_Dominance)="right"  then hand=0; if lowcase(Hand_Dominance)="left" then hand=1; 
	poc=compress(POC__);
	drop POC__ Work_Comp__0_No__1_yes;
	comp=Work_Comp__0_No__1_yes;
	format sex sex. hand lr. comp yn.;
	ind=_n_;
	if Age_at_Surgery>=66 then age_grp=1; else if 0<Age_at_Surgery<=65 then age_grp=0;
	keep Last_Name poc ind Age_at_Surgery sex hand comp Tobacco__0_no__1_yes age_grp;
run;

proc import out=pre0
			datafile=ases
			DBMS=EXCEL REPLACE;
			RANGE="Preoperative Data$A1:AC74";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
proc contents; run;

data pre;
	set pre0;
	rename ROM_FE__active=ROM_FE0 __of_surgeries_affected_shoulder=surg pain=pain0 ROM_ER=ROM_ER0 ROM_IR__1_side__2_PSIS__15_T5_=ROM_IR0 ADL_score=ADL0 ASES=ASES0;
	poc=compress(POC__);
	ind=_n_;
	if 0<ROM_FE__active<90 then pre_rom_grp=0; else if ROM_FE__active>90 then pre_rom_grp=1;
	if 0<pain<7 then pre_pain_grp=0; else if pain>=7 then pre_pain_grp=1;
	if __of_surgeries_affected_shoulder=1 then surg_grp=0; else if __of_surgeries_affected_shoulder>1 then surg_grp=1;
	keep Last_Name poc ind Pain ROM_FE__active __of_surgeries_affected_shoulder pre_rom_grp pre_pain_grp surg_grp ROM_ER ROM_IR__1_side__2_PSIS__15_T5_ ADL_score ASES;
run;

proc import out=intra0
			datafile=ases
			DBMS=EXCEL REPLACE;
			RANGE="Intraoperative Data$A1:H74";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
proc contents; run;

data intra;
	set intra0;
	rename Tear_Size__1_small__2_medium__3_=tear_size Tissue_Quality__1_poor__2_fair__=tissue_quality;
	poc=compress(POC__);
	ind=_n_;
	if Tissue_Quality__1_poor__2_fair__ in(1,2) then tissue_grp=0; else if Tissue_Quality__1_poor__2_fair__ in(3) then tissue_grp=1;
	if Tear_Size__1_small__2_medium__3_ in(3,4) then size_grp=1; else if Tear_Size__1_small__2_medium__3_ in(1,2) then size_grp=0; 
	keep Last_Name poc ind Tear_Size__1_small__2_medium__3_ Tissue_Quality__1_poor__2_fair__ tissue_grp size_grp;
run;


proc import out=proc0
			datafile=ases
			DBMS=EXCEL REPLACE;
			RANGE="Procedures Performed$A1:L74";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
proc contents; run;

data proc;
	set proc0;
	rename Capsular_release__0_no__1_yes=capsular Repair_completeness__0_partial__=repair_comp;
	poc=compress(POC__);
	ind=_n_;
	keep Last_Name poc ind Capsular_release__0_no__1_yes Repair_completeness__0_partial__;
run;

proc import out=post0
			datafile=ases
			DBMS=EXCEL REPLACE;
			RANGE="post-op data correct$A1:M74";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
proc contents; run;

data post;
	set post0;
	rename pain=pain1 ROM_FE___active=ROM_FE1 ROM_ER=ROM_ER1 ROM_IR=ROM_IR1 ADL_score=ADL1 ASES=ASES1;
	poc=compress(POC__);
	ind=_n_;
	ASES=(10-pain)*5+5/3*ADL_score;
	keep Last_Name poc ind pain ROM_ER ROM_FE___active ROM_IR ROM_ER ADL_score ASES;
run;


data opera;
	merge demo pre intra proc post; by ind; 
	delta_FE=ROM_FE1-ROM_FE0;
	delta_ER=ROM_ER1-ROM_ER0;
	delta_IR=ROM_IR1-ROM_IR0;
	delta_ADL=ADL1-ADL0;
	delta_ASES=ASES1-ASES0;
	delta_pain=pain1-pain0;

	format sex sex. hand lr. age_grp age. comp tobacco capsular yn. tear_size size.  tissue_quality tissue. repair_comp comp.
	pre_rom_grp rom. pre_pain_grp pain. surg_grp surg. tissue_grp tissue. size_grp size.;
run;

proc print data=stat1;run;

%let varlist=comp tobacco age_grp pre_rom_grp pre_pain_grp surg_grp capsular tissue_grp repair_comp size_grp;
%let varlist=pain1 ROM_FE1 ROM_ER1 ROM_IR1 ADL1 ASES1;
ods listing close;
%stat(opera,comp, &varlist,1);
%stat(opera,tobacco, &varlist,2);
%stat(opera,age_grp, &varlist,3);
%stat(opera,pre_rom_grp, &varlist,4);
%stat(opera,pre_pain_grp, &varlist,5);
%stat(opera,surg_grp, &varlist,6);
%stat(opera,capsular, &varlist,7);
%stat(opera,tissue_grp, &varlist,8);
%stat(opera,repair_comp, &varlist,9);
%stat(opera,size_grp, &varlist,10);
ods listing;

data stat; 
	set stat1 (keep=idx item mean0 mean1 pv ) 
		stat2 (keep=idx item mean0 mean1 pv )
		stat3 (keep=idx item mean0 mean1 pv )
		stat4 (keep=idx item mean0 mean1 pv )
		stat5 (keep=idx item mean0 mean1 pv )
		stat6 (keep=idx item mean0 mean1 pv )
		stat7 (keep=idx item mean0 mean1 pv )
		stat8 (keep=idx item mean0 mean1 pv )
		stat9 (keep=idx item mean0 mean1 pv )
		stat10(keep=idx item mean0 mean1 pv );

		format idx idx. item item.;
run;

proc sort; by idx item;run;

data stat;
	set stat; by idx item;
	output;
	if last.idx then do;
	Call missing( of item mean0 mean1 pv) ; 
    output; end;
run;

ods rtf file="opera_final.rtf" style=journal bodytitle startpage=no;
proc report data=stat nowindows style=[just=center];
title "Comparsion by Groups";
column idx item mean0 mean1 pv; 
define idx/group order order=internal "Question" style=[just=left];
define item/ "Variable" style=[just=left];
define mean0/ "group=0" style=[just=center];
define mean1/"group=1" style=[just=center];
define pv/ "p value" style=[just=center];
break after idx / dol dul;
run;
ods rtf close;
