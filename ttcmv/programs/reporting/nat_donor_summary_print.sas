*libname cmv "/ttcmv/sas/data/freeze2011.03.09";

%include "nat_donor_summary_include.sas";




options nodate orientation=portrait;
ods rtf   file = "&output./annual/&nat_result_summary_file.nat_result_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&nat_result_summary_title a: LBWI NAT Result (n=&total0)";

title  justify = center "&nat_result_summary_title a: LBWI NAT Result  (n=&total0) ";

footnote "LBWI id with Low positive result : &blood_pos_id";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable IN ('Blood NAT Test Result' 'Urine NAT Test Result'  )and treat=0 and category < 99;


column  variable  visitlist      category2  stat dummy ;


define variable / group order=data center   width=15   style(column)=[just=left cellwidth=1.5in] '' ;
define visitlist /  group order=data left      style(column)=[just=left cellwidth=1.5in]  'DOL ';

define category2 /group   center order=internal    style(column)=[just=center cellwidth=1.5in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;


format visitlist dfseq.;

compute after variable;
     line ' ';
  endcomp;


run;


ods noproctitle proclabel "&nat_result_summary_title b: MOC Serum CMV NAT results";

title  justify = center "&nat_result_summary_title b: MOC Serum CMV NAT results (MOC=&allmom0)";

*footnote "LBWI id with MOC missing data : &moc_pos_id";
footnote "";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='MOC NAT Test Result' and treat=0 and category < 99;

column    treat  visitlist category ,(stat) dummy ;



define treat / group order=data center      style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left      style(column)=[just=left cellwidth=1.0in]  'DOL ';


define category /across   center order=internal    style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq_MOC.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;

proc sql;
create table AllVarFreq as
select * from AllVarFreq
order by group, treat,visitlist,category;

quit;

ods noproctitle proclabel "&nat_result_summary_title c: Donor Unit Characteristics ( Donors=&donor_count)";

title  justify = center "&nat_result_summary_title c: Donor Unit Characteristics ( Donors=&donor_count) ";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable IN ('Parent Unit NAT Result' 'Parent Unit WBC Result','Blood Group' , 'RH Group' ,'Parent Unit CMV Status')and treat=0 ;

column  variable        category2  stat dummy ;


define variable / group order=data center   width=15   style(column)=[just=left cellwidth=1.5in] 'Site' ;



define category2 /group   center order=internal    style(column)=[just=center cellwidth=1.5in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;



*format visitlist BloodUnitType.;
*format treat  treat.;


compute after variable;
     line ' ';
  endcomp;


run;

title "Donor unit Residual WBC count for detectable units";
proc means data=bu_wbc1 n mean median min max p25 p75 maxdec=1;

where wbc_result1=2 and center=0;
var wbc_count1;
run;
ods rtf close;
quit;



/* **** Not required tabels *************/

/*
ods noproctitle proclabel "&nat_result_summary_title d: CMV NAT results for Donor Units for LBWI who completed study ( Donors=&donor_count)";

title  justify = center "&nat_result_summary_title d: CMV NAT results for Donor Units for LBWI who completed study ( Donors=&donor_count)";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Unit Test Result' and treat=0 ;

column      treat   category ,(stat) dummy ;

define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;



define category /across   center order=internal width=15   style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;

ods noproctitle proclabel "&nat_result_summary_title e: Residual WBC results for Donor Units ( Donors=&donor_count)";

title  justify = center "&nat_result_summary_title e: Residual WBC results for Donor Units ( Donors=&donor_count)";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable IN ('Unit WBC Result' )and treat=0 ;

column       treat  visitlist category ,(stat) dummy ;



define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=1in]  'Blood Donor Unit Type ';


define category /across   center order=internal    style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1in]  'n/N (%) ' ;;
define dummy/ noprint;


format category wbc.;
format visitlist BloodUnitType.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;


ods noproctitle proclabel "&nat_result_summary_title a: Longitudinal LBWI Serum CMV NAT results";

title  justify = center "&nat_result_summary_title a: Longitudinal LBWI Serum CMV NAT results (n=&total0)";
footnote "LBWI id with Low positive result : &blood_pos_id";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Blood NAT Test Result' and treat=0 and category < 99;

column     treat  visitlist category ,(stat) dummy ;



define treat / group order=data center      style(column)=[just=left cellwidth=.7in] 'Site' ;
define visitlist /  group order=data left      style(column)=[just=left cellwidth=1.5in]  'DOL ';


define category /across   center order=internal    style(column)=[just=left cellwidth=1.5in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;

ods noproctitle proclabel "&nat_result_summary_title b: Longitudinal LBWI Urine CMV NAT results ";

title  justify = center "&nat_result_summary_title b: Longitudinal LBWI Urine CMV NAT results";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Urine NAT Test Result' and treat=0 and category < 99;

column       treat  visitlist category ,(stat) dummy ;



define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=1.5in]  'DOL ';


define category /across   center order=internal width=15   style(column)=[just=left cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;
*/
