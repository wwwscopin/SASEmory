data x;
 set glnd.plate203;
  center=int(id/10000);
  format center center.;
  keep id center sae_type dt_sae_onset related_treat;
  if dt_sae_onset > mdy(4,11,2007);
  ods rtf file='sae_070412.rtf';
  proc print label;
   var center id dt_sae_onset sae_type related_treat;
   title Possible SAE since April 12, 2007;
   run;
   ods rtf close;