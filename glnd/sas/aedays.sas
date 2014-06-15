data x;
 set glnd.plate201;
 keep id ae_type dt_ae_onset glucose;
 if (ae_type = 15) & (ae_glycemia = 1) then ae_type=18;
 if (ae_type = 15) & (ae_glycemia = 2) then
 if (0<glucose<40) then ae_type=20; 
 else ae_type=19;

run;


 data y;
  set glnd.status;
  keep id dt_random treatment;
     
  data xy;
   merge x y;
    by id;
    aedays=dt_ae_onset-dt_random;
    if aedays <0 then delete;
 options ls=80 ps=53;
    proc sort; by ae_type;
 *   proc print;
    data a;
     set xy;
     if treatment=1;
    proc means noprint;
     var aedays;
     output out=ae
      median=maedays1;
       by ae_type;
       
       data aedays1;
        set ae;
        ae=ae_type;
        keep ae maedays1;
        run;
        
          data a;
     set xy;
     if treatment=2;
    proc means noprint;
     var aedays;
     output out=ae
      median=maedays2;
       by ae_type;
       
       data aedays2;
        set ae;
        ae=ae_type;
        keep ae maedays2;
        run;
        
         proc means noprint data=xy;
     var aedays;
     output out=ae
      median=maedays;
       by ae_type;
       
       data aedays12;
        set ae;
        ae=ae_type;
        keep ae maedays;
        run;
        
        data aedays;
         merge aedays1 aedays2 aedays12;
          by ae;
          label maedays1='Median Days A'
                maedays2='Median Days B'
                maedays='Median Days'; 
          
          
      proc print;
quit;
      
ods pdf file="median.pdf" style=journal;
proc print data=xy style(data)=[just=center];
where ae_type in(12, 20);
run;
ods pdf close;
