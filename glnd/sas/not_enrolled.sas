*libname glnd '/glnd/sas/dsmc/20100219';
 data reason2;
  set glnd.screened;
  length reason $ 60;
  if reas_no_consent=1 then  reason='Patient Death' ;
   if reas_no_consent=2 then  reason='Patient did not wish to participate' ;
 if reas_no_consent=3 then  reason=reas_no_consent_spec ; 
 
 
 if study_proc=1 then reason='Unable or Unwilling to Participate' ;
     
 if reason='' then delete;
  
 keep id reason;

 proc sort; by id;
 data x;

  set reason2;
   by id;
   length affil $ 12;
  
   if first.id then do;
    center=int(id/10000);
    affil='Emory';
    if center=2 then affil='Miriam';;  
    if center=3 then affil='Vanderbilt';
    if center=4 then affil='Colorado';
    if center=5 then affil='Wisconsin';

    glndid=put(id,6.);
   end;
  
   format center center.;
   label center='Clinical Center'
    glndid='GLND ID No.'
	reason='Reason Not Enrolled'
	affil='Clinical Center';
	*drop center;
	if center=. then affil=' ';
data  glnd.not_enrolled;
 set x;
 drop id center;
 proc print label;
 run;
data  glnd.not_enrolled1;
 set x;
if center <3;
 drop id center;
 *proc print label;
	where center^=2;
 run;
data  glnd.not_enrolled2;
 set x;
if center >2;
 drop id center;
 *proc print label;
 run;
