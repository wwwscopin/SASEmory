***** convert ae_type with 17 levels into 17 variables that have 
      # of patient with that ae
      later add info on # of events, # of patients with event
      ;
      
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
 array ae(17);
  do i=1 to 17;
   if ae_type=i then ae(i)=1;
  end;
  keep id ae1-ae17 ;
  proc sort; by id;
  proc means noprint;
   by id;
    var ae1-ae17;
    output out=new max=ae1-ae17;
    data r;
     set glnd.plate8;
      keep id;
      
      
data trt;
 set glnd.george;
keep treatment id;
label treatment='Treatment';
format treatment trt.;
      
    data glnd.ae;
       merge r new trt;
        by id;
        array ae(17);
        do i=1 to 17;
           if ae(i)=. then ae(i)=0;
        end;
      keep id ae1-ae17 treatment;
      format ae1-ae17 yn.;
      label ae1 = "Respiratory distress"
                 ae2 = "Tracheostomy"
                 ae3 = "Significant pulmonary aspiration"
                 ae4 = "Pneumothorax"
                 ae5 = "Pulmonary emboli"
                 ae6 = "Wound dehiscence"
                 ae7 = "New onset significant hemorrhage"
                ae8 = "Mechanical intestinal obstr."
                 ae9 = "Worsening renal function"
                 ae10 = "Worsening hepatic function"
                 ae11 = "Myocardial infarction"
                 ae12 = "Cerebrovascular accident"
                 ae13 = "Re-admission to ICU/SICU"
                 ae14 = "New onset significant skin rash"
                 ae15 = "Hyperglycemia > 250 mg/dL"
                 ae16 = "Non-infectious pancreatitis"
                 ae17 = "Encephalopathy" ;
            proc freq;
             tables ae1-ae17;
