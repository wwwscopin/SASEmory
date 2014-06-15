data id;
 infile 'sitevisit.dat';
 input id;

data ae;
    set glnd.plate201;
    /*
     value ae   99 = "Blank"
                 1 = "Respiratory distress"
                 2 = "Tracheostomy"
                 3 = "Significant pulmunary aspiration"
                 4 = "Pneumothorax"
                 5 = "Pulmonary emboli"
                 6 = "Wound dehiscence"
                 7 = "New onset significant hemorrhage"
                 8 = "Mechanical intestinal obstr."
                 9 = "Worsening renal function"
                 10 = "Worsening hepatic function"
                 11 = "Myocardial infarction"
                 12 = "Cerebrovascular accident"
                 13 = "Re-admission to ICU/SICU"
                 14 = "New onset significant skin rash"
                 15 = "Hyperglycemia > 250 mg/dL"
                 16 = "Non-infectious pancreatitis"
                 17 = "Encephalopathy" ;
         */;
         keep id ae_type dt_ae_onset dfseq;
         data x;
          merge id(in=a) ae;
           by id;
           if a;
           
          data ae2;
           array dtae(21) ;
           array seqae(21);
           array aetype(21);
           do i=1 to 21;
           nae=i;
                set x;
                 by id;
                 dtae(i)=dt_ae_onset;
                 seqae(i)=dfseq;
                 aetype(i)=ae_type;
                 if last.id then return;
            end;
           keep id dtae1-dtae21 seqae1-seqae21 aetype1-aetype21 nae;
           format dtae1-dtae21 mmddyy8. aetype1-aetype21 ae.;
          data ae1;
 set ae2;
       if seqae1=. then nae=0; 
           proc print;
           
