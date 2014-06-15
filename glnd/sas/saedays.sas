data x;
 set glnd.plate203;
 keep id sae_type dt_sae_onset;
 data y;
  set glnd.status;
  keep id dt_random treatment;
     
  data xy;
   merge x y;
    by id;
    saedays=dt_sae_onset-dt_random;
    if saedays <0 then delete;
 options ls=80 ps=53;
    proc sort; by sae_type;
 *   proc print;
    data a;
     set xy;
     if treatment=1;
    proc means noprint;
     var saedays;
     output out=sae
      median=msaedays1;
       by sae_type;
       
       data saedays1;
        set sae;
        sae=sae_type;
        keep sae msaedays1;
        run;
        
          data a;
     set xy;
     if treatment=2;
    proc means noprint;
     var saedays;
     output out=sae
      median=msaedays2;
       by sae_type;
       
       data saedays2;
        set sae;
        sae=sae_type;
        keep sae msaedays2;
        run;
        
         proc means noprint data=xy;
     var saedays;
     output out=sae
      median=msaedays;
       by sae_type;
       
       data saedays12;
        set sae;
        sae=sae_type;
        keep sae msaedays;
        run;
        
        data saedays;
         merge saedays1 saedays2 saedays12;
          by sae;
          label msaedays1='Median Days A'
                msaedays2='Median Days B'
                msaedays='Median Days'; 
          
          
      proc print;
      
 