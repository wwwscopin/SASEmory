%include "tx_all.sas";

%include "cmv_survey2_moc.sas";
%include "cmv_survey2_lbwi.sas";

%include "cmv_survey2_infection.sas";



/************************* Output *************/

options nodate orientation=portrait;
ods escapechar="\";

ods rtf file = "&output./annual/&cmv_survey_summary_file.cmv_survey2_new.rtf"  style = journal toc_data startpage = yes bodytitle;


ods noproctitle proclabel "&cmv_survey_summary_title : CMV - surveillance summary";

/****** do this for overall statistics *****/
/*title1 " Overall cohort statistics "; 

proc report data=overall_all_comp nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column  variable stat comp_stat dummy;
define variable /  group order=data   Left    " " ;
define stat/group  order=internal    Left    " Statistics_(LBWI Up to date) " ;
define comp_stat/group  order=internal    Left    " Statistics _(LBWI who Completed)" ;
define dummy/NOPRINT ;
run;

*/
/**** next two tables come from include file tx_all.sas ****/
title1  justify = center "&cmv_survey_summary_title : Parent donor unit statistics (Total donors = &tx_donor_macro / Total Tx &tx_count_macro) ";

title2 justify=center "pRBC TX= &tx_rbc_macro, Plt Tx=&tx_plt_macro, FFP Tx=&tx_ffp_macro, Cryo Tx=&tx_cryo_macro";
title3 justify=center  Number of LBWI transfused =&tx_lbwi_macro/&eos_lbwi_macro completed (&tx_pct_macro %) ;

proc report data=t_all_2 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column  variable category_txt stat dummy;
define variable /  group order=data   Left    " " ;
define category_txt/group  order=internal   Left    "  " ;
define stat/group  order=internal    Left    " " ;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after variable;
line '';
endcomp;
run;

title1 justify = center "Donor unit Residual WBC count for detectable units";
title2 "";
title3 "";
proc means data=tx_eos_wbc N mean min p25 median p75 max maxdec=1;

var wbc_count1;
run;

title1  justify = center "&cmv_survey_summary_title : CMV - surveillance if MOC/LBWI NAT positive or IgG Positive or MOC IgM Positive ( MOC=&moc LBWI=&lbwi) ";

proc report data=moc_table_output nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column  moc_id   ComboTestResult IgMTestResult moc_igg_stat bm_NAT_stat moc_nat_stat milk_culture_stat 
lbwi_count  lbwi_nat UrineTestResult FeedStatus tx_source dummy;

define moc_id /  group    Left    " MOC id " ;
define ComboTestResult/      Left    " IgG/IgM_Combo " format=igg.;
define IgMTestResult/      Left    " IgM" format=igg.;
define lbwi_count /      Left    "LBWI " format=l_count.;
define moc_igg_stat /      Left    " MOC_IgG " ;
define bm_NAT_stat /    Left    " B Milk_NAT " ;
define moc_nat_stat /      Left    " MOC_Blood_NAT " ;
define milk_culture_stat /    left    " Milk_Culture";
define lbwi_nat/  group    center    " LBWI_Blood_NAT_Positive? " format=lbwi_nat.;
define UrineTestResult/ group    center    " LBWI_Urine_NAT_Positive? " format=lbwi_nat.;
define FeedStatus/ group    center    " LBWI_Breast_Fed? " format=outcome.;
define tx_source /  group      style(column) = [just=center cellwidth=0.5in] " LBWI Tx? " format=outcome.;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after moc_id;
line '';
endcomp;

run;


title1  justify = center "&cmv_survey_summary_title : CMV - surveillance resuts if LBWI / MOC CMV NAT Positive or IgG Positive or MOC IgM Positive ( MOC=&moc LBWI=&lbwi)";

proc report data=lbwi_table_output nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  id age_wt_gender_stat death_stat lbwi_blood_NAT_stat lbwi_urine_nat_stat FeedStatus tx_stat cmv_disease nec pda_stat rop bpd IVH_stat  dummy;

define id / group  order=data  style(column) = [just=center cellwidth=0.9in]    " LBWI_id " ;
define age_wt_gender_stat / group    style(column) = [just=center cellwidth=0.8in]    "Gender_BirthWeight_Gest Age" ;

define death_stat /  group    style(column) = [just=center cellwidth=0.5in]   "Death" ;


define lbwi_blood_NAT_stat /      style(column) = [just=center cellwidth=1in font_size=8pt]   " LBWI_Blood_NAT " ;
define lbwi_urine_nat_stat /     style(column) = [just=center cellwidth=.8in font_size=8pt]   " LBWI_Urine_NAT " ;


define FeedStatus / group        style(column) = [just=center cellwidth=0.5in font_size=8pt] " LBWI_Breast_Fed?" format=outcome.;
define tx_stat / group        style(column) = [just=center cellwidth=0.5in font_size=8pt] " LBWI_Tx?_Total " ;
define cmv_disease /group     style(column) = [just=center cellwidth=0.5in font_size=8pt]    " CMV_dis_confirmed? " ;
define NEC / group        " NEC " style(column) = [just=center cellwidth=0.4in font_size=8pt] format=outcome.;

define PDA_stat / group         " PDA " style(column) = [just=center cellwidth=0.4in font_size=8pt] ;
define ROP / group         " ROP " style(column) = [just=center cellwidth=0.4in font_size=8pt] format=outcome.;
define BPD / group        " BPD " style(column) = [just=center cellwidth=0.4in] format=outcome.;
define IVH_stat / group       " IVH " style(column) = [just=center cellwidth=0.5in] ;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after id;
line '';
endcomp;
run;

ods rtf close;
quit;
