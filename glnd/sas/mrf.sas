**** mortality review form;

data mrf1;
   set glnd.plate241;
   if dfseq=361;
    rename immed_cause_desc=immed_cause_desc1;
    rename under_cause_code=under_cause_code1;
 keep id  immed_cause_desc under_cause_code;
 proc print;
 
   
   