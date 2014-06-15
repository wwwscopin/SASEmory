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
           proc print;