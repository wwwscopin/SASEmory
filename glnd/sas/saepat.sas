data id;
 infile 'sitevisit.dat';
 input id;

data sae;
    set glnd.plate203;
	/*
    value sae_type   99 = "Blank"
                 1 = "Death"
                 2 = "Anaphylactic reaction"
                 3 = "Seizure"
                 4 = "Cardiopulmonary arrest"
                 5 = "Re-hospitalization w/in 30 days"
                 6 = "Re-operation w/in 30 days"
                 7 = "New cancer diagnosis"
                 8 = "Congenital anomaly/disorder" ;
         */;
         keep id sae_type dt_sae_onset dfseq;
         data x;
          merge id(in=a) sae;
           by id;
           if a;
           
          data sae2;
           array dtsae(20) ;
           array seqsae(20);
           array saetype(20);
           do i=1 to 20;
           nsae=i;
                set x;
                 by id;
                 dtsae(i)=dt_sae_onset;
                 seqsae(i)=dfseq;
                 saetype(i)=sae_type;
                 if last.id then return;
            end;
           keep id dtsae1-dtsae20 seqsae1-seqsae20 saetype1-saetype20 nsae;
           format dtsae1-dtsae20 mmddyy8. saetype1-saetype20 sae_type.;
          data sae1;
 set sae2;
       if seqsae1=. then nsae=0; 
           proc print;
           
run;
