/* create missing data */
data cmv.snap; set cmv.snap; 

total_snap=41;  this_snap_gt25=0;
this_snap=0; 

if MaxMeanBP eq 99 or MaxMeanBP eq 999 then  this_snap=this_snap+1;  
if MinMeanBP eq 99 or MinMeanBP eq 999 then  this_snap=this_snap+1;
if MaxHeartRate eq 99 or MaxHeartRate eq 999 then  this_snap=this_snap+1;
if MinHeartRate eq 99 or MinHeartRate eq 999 then  this_snap=this_snap+1;
if RespRate eq 99 or RespRate eq 999 then  this_snap=this_snap+1;
if Temp eq 99 or Temp eq 999 then  this_snap=this_snap+1;
if Seizures eq 99 or Seizures eq 999 then  this_snap=this_snap+1;
if Apnea eq 99 or Apnea eq 999 then  this_snap=this_snap+1;
if StoolGuaic eq 99 or StoolGuaic eq 999 then  this_snap=this_snap+1;
if po2missing eq 1  then  this_snap=this_snap+1;
if PCO2 eq 99 or PCO2 eq 999 then  this_snap=this_snap+1;
if fio2missing eq 1  then  this_snap=this_snap+1;
if OxyIndex eq 99 or OxyIndex eq 999 then  this_snap=this_snap+1;
if MaxHct eq 99 or MaxHct eq 999 then  this_snap=this_snap+1;
if MinHct eq 99 or MinHct eq 999 then  this_snap=this_snap+1;
if WBC eq 99 or WBC eq 999 then  this_snap=this_snap+1;
if WBC eq 99 or WBC eq 999 then  this_snap=this_snap+1;

if ProMyoMissing eq 1  then  this_snap=this_snap+1;
if MyelocyteMissing eq 1  then  this_snap=this_snap+1;
if MetamyeMissing eq 1  then  this_snap=this_snap+1;
if BandsMissing eq 1  then  this_snap=this_snap+1;
if TotalNeutroMissing eq 1  then  this_snap=this_snap+1;

if AbsNeutro eq 99 or AbsNeutro eq 999 then  this_snap=this_snap+1;
if Platelets eq 99 or Platelets eq 999 then  this_snap=this_snap+1;
if BUN eq 99 or BUN eq 999 then  this_snap=this_snap+1;
if Creatinine eq 99 or Creatinine eq 999 then  this_snap=this_snap+1;
if UOP eq 99 or UOP eq 999 then  this_snap=this_snap+1;

if IndirectBili eq 99 or IndirectBili eq 999 then  this_snap=this_snap+1;
if DirectBili eq 99 or DirectBili eq 999 then  this_snap=this_snap+1;
if MaxSodium eq 99 or MaxSodium eq 999 then  this_snap=this_snap+1;
if MinSodium eq 99 or MinSodium eq 999 then  this_snap=this_snap+1;
if MaxPotassium eq 99 or MaxPotassium eq 999 then  this_snap=this_snap+1;
if MinPotassium eq 99 or MinPotassium eq 999 then  this_snap=this_snap+1;

if MaxIonizedCa eq 99 or MaxIonizedCa eq 999 then  this_snap=this_snap+1;
if MinIonizedCa eq 99 or MinIonizedCa eq 999 then  this_snap=this_snap+1;

if MaxTotalCa eq 99 or MaxTotalCa eq 999 then  this_snap=this_snap+1;
if MinTotalCa eq 99 or MinTotalCa eq 999 then  this_snap=this_snap+1;

if MaxGlucose eq 99 or MaxGlucose eq 999 then  this_snap=this_snap+1;
if MinGlucose eq 99 or MinGlucose eq 999 then  this_snap=this_snap+1;

if MaxBicarbonate eq 99 or MaxBicarbonate eq 999 then  this_snap=this_snap+1;
if MinBicarbonate eq 99 or MinBicarbonate eq 999 then  this_snap=this_snap+1;

if SerumPH eq 99 or SerumPH eq 999 then  this_snap=this_snap+1;


this_snap_pct=this_snap/total_snap*100;

pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

snap_nonmiss=compress(this_snap) || "/" || compress(total_snap);


if this_snap_pct >=25 then this_snap_gt25 =1;


run;
