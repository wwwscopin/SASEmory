/* create missing data */

%include "&include./monthly_toc.sas";
%include "&include./nurses_toc.sas";


data cmv.snap; set cmv.snap; 

total_snap=39;  this_snap_gt25=0;
this_snap=0; 

v1=0; v2=0; v3=0; v4=0; v5=0; v6=0;v7=0;v8=0; v9=0; v10=0;
v11=0; v12=0; v13=0; v14=0; v15=0; v16=0;v17=0;v18=0;v19=0;v20=0;
v21=0;v22=0;v23=0;v24=0;v25=0;v26=0;v27=0;v28=0;v29=0;v30=0;v31=0;
v32=0;v33=0;v34=0;v35=0;v36=0;v37=0;v38=0;v39=0;



if MaxMeanBP eq 99 or MaxMeanBP eq 999 then  do; this_snap=this_snap+1; v1=1; end; 
if MinMeanBP eq 99 or MinMeanBP eq 999 then  do; this_snap=this_snap+1;v2=1; end; 
if MaxHeartRate eq 99 or MaxHeartRate eq 999  then do; this_snap=this_snap+1; v31=1; end; 
if MinHeartRate eq 99 or MinHeartRate eq 999  then do; this_snap=this_snap+1;v4=1; end; 
if RespRate eq 99 or RespRate eq 999 then  do; this_snap=this_snap+1;v5=1; end; 
if Temp eq 99 or Temp eq 999 then  do; this_snap=this_snap+1; v6=1; end; 
if Seizures eq 99 or Seizures eq 999  then do; this_snap=this_snap+1; v7=1; end; 
if Apnea eq 99 or Apnea eq 999 then  do; this_snap=this_snap+1; v8=1; end; 
if StoolGuaic eq 99 or StoolGuaic eq 999 then do; this_snap=this_snap+1;  v9=1; end; 
if po2missing eq 1  then  do; this_snap=this_snap+1;  po2_udf=99; v9=1; end;
if PCO2 eq 99 or PCO2 eq 999 then do; this_snap=this_snap+1;  v11=1; end;
if fio2missing eq 1  then  do; this_snap=this_snap+1;fio2_udf=99;v12=1; end;
if OxyIndex eq 99 or OxyIndex eq 999 then do; this_snap=this_snap+1;v13=1; end;
if MaxHct eq 99 or MaxHct eq 999 then do; this_snap=this_snap+1;v14=1; end;
if MinHct eq 99 or MinHct eq 999 then do; this_snap=this_snap+1; v15=1; end;
if WBC eq 99 or WBC eq 999 then do; this_snap=this_snap+1; v16=1; end;


if ProMyoMissing eq 1  then do; this_snap=this_snap+1; v17=1; v17_udf=99;end;
if MyelocyteMissing eq 1  then do; this_snap=this_snap+1; v18=1;v18_udf=99 ;end;
if MetamyeMissing eq 1  then do; this_snap=this_snap+1; v19=1; v19_udf=99;  end;
if BandsMissing eq 1  then do; this_snap=this_snap+1; v20=1; v20_udf=99;  end;
if TotalNeutroMissing eq 1  then do; this_snap=this_snap+1; v21=1;v21_udf=99 ; end;

if AbsNeutro eq 99 or AbsNeutro eq 999 then do; this_snap=this_snap+1; v22=1; end;
if Platelets eq 99 or Platelets eq 999 then do; this_snap=this_snap+1; v23=1; end;
if BUN eq 99 or BUN eq 999 then do; this_snap=this_snap+1;v24=1; end;
if Creatinine eq 99 or Creatinine eq 999 then do; this_snap=this_snap+1; v25=1; end;
if UOP eq 99 or UOP eq 999 then do; this_snap=this_snap+1;v26=1; end;

if IndirectBili eq 99 or IndirectBili eq 999 then do; this_snap=this_snap+1;v27=1; end;
if DirectBili eq 99 or DirectBili eq 999 then do; this_snap=this_snap+1;v28=1; end;
if MaxSodium eq 99 or MaxSodium eq 999 then do; this_snap=this_snap+1; v29=1; end;
if MinSodium eq 99 or MinSodium eq 999 then do; this_snap=this_snap+1; v30=1; end;
if MaxPotassium eq 99 or MaxPotassium eq 999  then do; this_snap=this_snap+1; v31=1; end;
if MinPotassium eq 99 or MinPotassium eq 999 then  do; this_snap=this_snap+1; v32=1; end;


var33 = Min( MaxIonizedCa ,MaxTotalCa);
var34 = Min( MinIonizedCa ,MinTotalCa);
if (MaxIonizedCa eq 99 or MaxIonizedCa eq 999) and (MaxTotalCa eq 99 or MaxTotalCa eq 999) then  do; this_snap=this_snap+1;  var33=99; end;
if (MinIonizedCa eq 99 or MinIonizedCa eq 999) and (MinTotalCa eq 99 or MinTotalCa eq 999)  then do; this_snap=this_snap+1;var34=99; end;

/*if MaxTotalCa eq 99 or MaxTotalCa eq 999 then do;  this_snap=this_snap+1;v35=1; end;
if MinTotalCa eq 99 or MinTotalCa eq 999 then do; this_snap=this_snap+1;v36=1; end;
*/
if MaxGlucose eq 99 or MaxGlucose eq 999 then do; this_snap=this_snap+1;v35=1; end;
if MinGlucose eq 99 or MinGlucose eq 999 then do; this_snap=this_snap+1; v36=1; end;

if MaxBicarbonate eq 99 or MaxBicarbonate eq 999 then do; this_snap=this_snap+1;v37=1; end;
if MinBicarbonate eq 99 or MinBicarbonate eq 999 then do; this_snap=this_snap+1; v38=1; end;

if SerumPH eq 99 or SerumPH eq 999 then do; this_snap=this_snap+1; v39=1; end;


this_snap_pct=this_snap/total_snap*100;

pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

snap_nonmiss=compress(this_snap) || "/" || compress(total_snap);


if this_snap_pct >=25 then this_snap_gt25 =1;


run;


data snap; 
set cmv.snap;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;



proc format ;

value display
99="M"
999="M";


run;

proc sql;

select compress(put(count(*),3.0)) into: sample_all from  snap where dfseq <= 63;
select compress(put(count(*),3.0)) into: sample_partial from  snap where this_snap_pct >25 ;



quit;


data temp; t=(&sample_partial/&sample_all)*100; run;

proc sql;

select compress(put(t,2.0)) into: ratio from temp; drop table temp;

quit;

ods escapechar = '~';
options nodate orientation = landscape;
ods rtf file = "&output./nurses/&snap_missing_file.snap_missing.rtf"  style=journal

toc_data startpage = yes bodytitle;

ods noproctitle proclabel "&snap_missing_title : List of LBWI with more than 25% SNAP components missing ( M : Missing ) ";


	title  justify = center "&snap_missing_title : List of LBWI with more than 25% SNAP components missing ( M : Missing ) 
 [&sample_partial/&sample_all(&ratio.%) ]";
footnote1 "1: MaxMeanBP 2:MinMeanBP  3:MaxHeartRate  4:MinHeartRate  5:RespRate 6:Temp 7:Seizures 8:Apnea 9:StoolGuaic 10:po2";
footnote2 "11:PCO2 12:fio2 13:OxyIndex 14:MaxHct 15:MinHct 16:WBC 17: ProMyelocyte 18:Myelocyte 19:Metamyocyte 20:Bands";
footnote3 "21:TotalNeutro 22:AbsNeutro 23:Platelets 24:BUN 25:Creatinine 26:UOP 27:IndirectBili 28:DirectBili 29:MaxSodium 30:MinSodium";
footnote4 "31:MaxPotassium 32:MinPotassium  33:MaxIonizedCa/MaxTotalCa  34:MinIonizedCa/MinTotalCa   
  35:MaxGlucose 36:MinGlucose 37:MaxBicarbonate 38:MinBicarbonate 39:SerumPH";

proc report  data=snap  nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

 where this_snap_pct >25; ;

column id  MaxMeanBP  MinMeanBP MaxHeartRate MinHeartRate RespRate Temp Seizures Apnea StoolGuaic po2_udf PCO2 fio2_udf OxyIndex 
MaxHct MinHct WBC /*ProMyoMissing MyelocyteMissing MetamyeMissing BandsMissing TotalNeutroMissing */
v17_udf v18_udf v19_udf v20_udf v21_udf AbsNeutro Platelets BUN 
Creatinine UOP IndirectBili DirectBili MaxSodium MinSodium MaxPotassium MinPotassium 
var33  var34 /*MaxTotalCa MinTotalCa*/ MaxGlucose MinGlucose MaxBicarbonate MinBicarbonate SerumPH dummy ;

define id / center group        style(column)=[cellwidth=0.75in just=center]  "LBWI Id";


define MaxMeanBP/ center    "1"  format=display.;
define MinMeanBP/ center    "2"  format=display.;

define MaxHeartRate/ center    "3"  format=display.;

define MinHeartRate/ center    "4"  format=display.;
define RespRate/ center    "5"  format=display.;
define Temp/ center    "6"  format=display.;
define Seizures/ center    "7"  format=display.;
define Apnea/ center    "8"  format=display.;
define StoolGuaic/ center    "9"  format=display.;
define po2_udf/ center    "10"  format=display.;
define PCO2/ center    "11"  format=display.;
define fio2_udf/ center    "12"  format=display.;
define OxyIndex/ center    "13"  format=display.;
define MaxHct/ center    "14"  format=display.;
define MinHct/ center    "15"  format=display.;
define WBC/ center    "16"  format=display.;

/*define ProMyoMissing/ center    "17"  format=display.;
define MyelocyteMissing/ center    "18"  format=display.;
define MetamyeMissing/ center    "19"  format=display.;
define BandsMissing/ center    "20"  format=display.;
define TotalNeutroMissing/ center    "21"  format=display.;
*/

define v17_udf/ center    "17"  format=display.;
define v18_udf/ center    "18"  format=display.;
define v19_udf/ center    "19"  format=display.;
define v20_udf/ center    "20"  format=display.;
define v21_udf/ center    "21"  format=display.;

define AbsNeutro/ center    "22"  format=display.;
define Platelets/ center    "23"  format=display.;
define BUN/ center    "24"  format=display.;
define Creatinine/ center    "25"  format=display.;
define UOP/ center    "26"  format=display.;

define IndirectBili/ center    "27"  format=display.;
define DirectBili/ center    "28"  format=display.;
define MaxSodium/ center    "29"  format=display.;
define MinSodium/ center    "30"  format=display.;
define MaxPotassium/ center    "31"  format=display.;
define MinPotassium/ center    "32"  format=display.;

define var33/ center    "33"  format=display.;
define var34/ center    "34"  format=display.;



define MaxGlucose/ center    "35"  format=display.;
define MinGlucose/ center    "36"  format=display.;


define MaxBicarbonate/ center    "37"  format=display.;
define MinBicarbonate/ center    "38"  format=display.;
define SerumPH/ center    "39"  format=display.;

define dummy/ noprint;
format center center.;

run;


ods noproctitle proclabel "&snap_missing_title : List of LBWI with <= 25% SNAP components missing ( M : Missing ) ";


	title  justify = center "&snap_missing_title : List of LBWI with <= 25% SNAP components missing ( M : Missing ) ";
footnote1 "1: MaxMeanBP 2:MinMeanBP  3:MaxHeartRate  4:MinHeartRate  5:RespRate 6:Temp 7:Seizures 8:Apnea 9:StoolGuaic 10:po2";
footnote2 "11:PCO2 12:fio2 13:OxyIndex 14:MaxHct 15:MinHct 16:WBC 17: ProMyelocyte 18:Myelocyte 19:Metamyocyte 20:Bands";
footnote3 "21:TotalNeutro 22:AbsNeutro 23:Platelets 24:BUN 25:Creatinine 26:UOP 27:IndirectBili 28:DirectBili 29:MaxSodium 30:MinSodium";
footnote4 "31:MaxPotassium 32:MinPotassium  33:MaxIonizedCa/MaxTotalCa  34:MinIonizedCa/MinTotalCa   
35:MaxGlucose 36:MinGlucose 37:MaxBicarbonate 38:MinBicarbonate 39:SerumPH";

proc report  data=snap  nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

 where this_snap_pct <=25; ;

column id  MaxMeanBP  MinMeanBP MaxHeartRate MinHeartRate RespRate Temp Seizures Apnea StoolGuaic po2_udf PCO2 fio2_udf OxyIndex 
MaxHct MinHct WBC /*ProMyoMissing MyelocyteMissing MetamyeMissing BandsMissing TotalNeutroMissing */
v17_udf v18_udf v19_udf v20_udf v21_udf AbsNeutro Platelets BUN 
Creatinine UOP IndirectBili DirectBili MaxSodium MinSodium MaxPotassium MinPotassium 
var33  var34 /*MaxTotalCa MinTotalCa*/ MaxGlucose MinGlucose MaxBicarbonate MinBicarbonate SerumPH dummy ;

define id / center group        style(column)=[cellwidth=0.75in just=center]  "LBWI Id";


define MaxMeanBP/ center    "1"  format=display.;
define MinMeanBP/ center    "2"  format=display.;

define MaxHeartRate/ center    "3"  format=display.;

define MinHeartRate/ center    "4"  format=display.;
define RespRate/ center    "5"  format=display.;
define Temp/ center    "6"  format=display.;
define Seizures/ center    "7"  format=display.;
define Apnea/ center    "8"  format=display.;
define StoolGuaic/ center    "9"  format=display.;
define po2_udf/ center    "10"  format=display.;
define PCO2/ center    "11"  format=display.;
define fio2_udf/ center    "12"  format=display.;
define OxyIndex/ center    "13"  format=display.;
define MaxHct/ center    "14"  format=display.;
define MinHct/ center    "15"  format=display.;
define WBC/ center    "16"  format=display.;

/*define ProMyoMissing/ center    "17"  format=display.;
define MyelocyteMissing/ center    "18"  format=display.;
define MetamyeMissing/ center    "19"  format=display.;
define BandsMissing/ center    "20"  format=display.;
define TotalNeutroMissing/ center    "21"  format=display.;
*/

define v17_udf/ center    "17"  format=display.;
define v18_udf/ center    "18"  format=display.;
define v19_udf/ center    "19"  format=display.;
define v20_udf/ center    "20"  format=display.;
define v21_udf/ center    "21"  format=display.;

define AbsNeutro/ center    "22"  format=display.;
define Platelets/ center    "23"  format=display.;
define BUN/ center    "24"  format=display.;
define Creatinine/ center    "25"  format=display.;
define UOP/ center    "26"  format=display.;

define IndirectBili/ center    "27"  format=display.;
define DirectBili/ center    "28"  format=display.;
define MaxSodium/ center    "29"  format=display.;
define MinSodium/ center    "30"  format=display.;
define MaxPotassium/ center    "31"  format=display.;
define MinPotassium/ center    "32"  format=display.;

define var33/ center    "33"  format=display.;
define var34/ center    "34"  format=display.;



define MaxGlucose/ center    "35"  format=display.;
define MinGlucose/ center    "36"  format=display.;


define MaxBicarbonate/ center    "37"  format=display.;
define MinBicarbonate/ center    "38"  format=display.;
define SerumPH/ center    "39"  format=display.;

define dummy/ noprint;
format center center.;

run;
ods rtf close;
quit;











