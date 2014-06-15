data glnd_df.emory;
   set glnd_df.submission_summary;
  if center=1;
   run;
   
      
   proc print;run;
   
  data glnd_df.mir;
 set glnd_df.submission_summary;
  if center=2;
 ;
  run;
  data glnd_df.van;
 set glnd_df.submission_summary;
  if center=3;
 
  run;
  data glnd_df.col;
 set glnd_df.submission_summary;
  if center=4;
  
  data glnd_df.wis;
 set glnd_df.submission_summary;
  if center=5;

 data e;
   set glnd_df.emory;
   emory=attended_visit_disp;
   keep form emory ;
   label emory='Emory Blood Obtained? Total(%)';
  
  
  
  
 data m;
   set glnd_df.mir;
   mir=attended_visit_disp;
   keep form mir ;
   label mir='Miriam Blood Obtained? Total(%)';
 
  
  
   
  
 data v;
   set glnd_df.van;
   van=attended_visit_disp;
   keep form van ;
   label van='Vanderbilt Blood Obtained? Total(%)';
 
  

  
  
 data c;
   set glnd_df.col;
   col=attended_visit_disp;
   keep form col ;
   label col='Colorado Blood Obtained? Total(%)';


 data w;
   set glnd_df.wis;
   wis=attended_visit_disp;
   keep form wis ;
   label wis='Wisconsin Blood Obtained? Total(%)';
  
  
  
  data glnd_df.retention;
    merge e c v w;
    if emory ne '';
  proc print label;
  run;
