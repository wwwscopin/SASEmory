**** mortality review form;

data mrf1;
   set glnd.plate241;
   if dfseq=361;
    rename immed_cause_desc=immed_cause_desc1;
    rename under_cause_desc=under_cause_desc1;
 keep id  immed_cause_desc under_cause_desc;
 
 data mrf2;
   set glnd.plate241;
   if dfseq=362;
    rename immed_cause_desc=immed_cause_desc2;
    rename under_cause_desc=under_cause_desc2;
 keep id  immed_cause_desc under_cause_desc;
 
data mrf3;
   set glnd.plate241;
   if dfseq=363;
    rename immed_cause_desc=immed_cause_desc3;
    rename under_cause_desc=under_cause_desc3;
 keep id  immed_cause_desc under_cause_desc;


 data glnd_rep.mrfcod;
   merge mrf1 mrf2 mrf3;
   by id;
   
   label 
    immed_cause_desc1="Immediate Cause Reviewer 1"
    under_cause_desc1="Underlying Cause Reviewer 1"
    immed_cause_desc2="Immediate Cause Reviewer 2"
    under_cause_desc2="Underlying Cause Reviewer 2"
    immed_cause_desc3="Immediate Cause Reviewer 3"
    under_cause_desc3="Underlying Cause Reviewer 3"
;

    
 proc print label noobs;
 
   var id  immed_cause_desc1  immed_cause_desc2 
   under_cause_desc1 under_cause_desc2 immed_cause_desc3 under_cause_desc3 ;
 Title Mortalty Review;  
  run;
  
 data ccod1a;
    set glnd.plate242;
    if dfseq=361;
    array ccod(9)
        cont_cause_1_desc cont_cause_2_desc cont_cause_3_desc
        cont_cause_4_desc cont_cause_5_desc cont_cause_6_desc
        cont_cause_7_desc cont_cause_8_desc cont_cause_9_desc;
    length ccause1 $ 100;
    do i=1 to 9;
        ccause1=ccod(i);
        if ccause1 ne '' then output;
    end;
	 *if ccause1 ='Decubitis' then ccause1='Decubitus' ;
    keep id i ccause1;
 run;

  data ccod1b;
    set glnd.plate243;
    if dfseq=361;
    array ccod(6)
        cont_cause_10_desc cont_cause_11_desc cont_cause_12_desc
        cont_cause_13_desc cont_cause_14_desc cont_cause_15_desc
       ;
    length ccause1 $ 100;
    do i=10 to 15;
        ccause1=ccod(i-9);
        if ccause1 ne '' then output;
    end;
    keep id i ccause1;
 run;

 data ccod1;
    set ccod1a ccod1b;
  proc sort; by id i;
  run;
  
  data ccod2a;
    set glnd.plate242;
    if dfseq=362;
    array ccod(9)
        cont_cause_1_desc cont_cause_2_desc cont_cause_3_desc
        cont_cause_4_desc cont_cause_5_desc cont_cause_6_desc
        cont_cause_7_desc cont_cause_8_desc cont_cause_9_desc;
    length ccause2 $ 100;
    do i=1 to 9;
        ccause2=ccod(i);
        if ccause2 ne '' then output;
    end;

	 *if ccause2 in('Decubiti','Doculitis') then ccause1='Decubitus' ;
    keep id i ccause2;
 run;

  data ccod2b;
    set glnd.plate243;
    if dfseq=362;
    array ccod(6)
        cont_cause_10_desc cont_cause_11_desc cont_cause_12_desc
        cont_cause_13_desc cont_cause_14_desc cont_cause_15_desc
       ;
    length ccause2 $ 100;
    do i=10 to 15;
        ccause2=ccod(i-9);
        if ccause2 ne '' then output;
    end;
    keep id i ccause2;
 run;

 data ccod2;
    set ccod2a ccod2b;
  proc sort; by id i;
  run;
 


  data ccod3a;
    set glnd.plate242;
    if dfseq=363;
    array ccod(9)
        cont_cause_1_desc cont_cause_2_desc cont_cause_3_desc
        cont_cause_4_desc cont_cause_5_desc cont_cause_6_desc
        cont_cause_7_desc cont_cause_8_desc cont_cause_9_desc;
    length ccause3 $ 100;
    do i=1 to 9;
        ccause3=ccod(i);
        if ccause3 ne '' then output;
    end;

	 *if ccause2 in('Decubiti','Doculitis') then ccause1='Decubitus' ;
    keep id i ccause3;
 run;

  data ccod3b;
    set glnd.plate243;
    if dfseq=363;
    array ccod(6)
        cont_cause_10_desc cont_cause_11_desc cont_cause_12_desc
        cont_cause_13_desc cont_cause_14_desc cont_cause_15_desc
       ;
    length ccause3 $ 100;
    do i=10 to 15;
        ccause3=ccod(i-9);
        if ccause3 ne '' then output;
    end;
    keep id i ccause3;
 run;

 data ccod3;
    set ccod3a ccod3b;
  proc sort; by id i;
  run;


     
  data glnd_rep.ccod;
    merge ccod1 ccod2 ccod3;
     by id i;
     length x1 x2 x3 $ 100;
     x1=ccause1;
     x2=ccause2;
     x2=ccause3;
     output;
     if last.id then do;
     ccause1=' - ';
     ccause2=' - ';
     ccause3=' - ';
     output;
     end;
     ccause1=x1;
     ccause2=x2;
     ccause3=x3;
     
    label ccause1='Contributing Cause of Death Reviewer 1'
          ccause2='Contributing Cause of Death Reviewer 2'
ccause3='Contributing Cause of Death Reviewer 3'
          ;
      drop x1 x2 x3;
    proc print label noobs;
    var id ccause1 ccause2 ccause3;
run;

data glnd_rep.ccod;
	set glnd_rep.ccod;
	if ccause1 in('Decubiti','Doculitis') then ccause1='Decubitus';
	if ccause2 in('Decubiti','Doculitis') then ccause2='Decubitus';
if ccause3 in('Decubiti','Doculitis') then ccause3='Decubitus';
run;

data wc1;
  set glnd.plate243;
  if dfseq=361;
  *withdraw_care="Death from withdraw care?"
        DNR_ordered="Pt have DNR ordered?"
        ;
   rename withdraw_care = withdraw_care1;
   rename DNR_ordered=dnr_ordered1;
   keep id withdraw_care dnr_ordered;
 run;
 
 data wc2;
  set glnd.plate243;
  if dfseq=362;
  
        ;
   rename withdraw_care = withdraw_care2;
   rename DNR_ordered=dnr_ordered2;
   keep id withdraw_care dnr_ordered;
 run;
 

 data wc3;
  set glnd.plate243;
  if dfseq=363;
  
        ;
   rename withdraw_care = withdraw_care3;
   rename DNR_ordered=dnr_ordered3;
   keep id withdraw_care dnr_ordered;
 run;

 data glnd_rep.wc;
   merge wc1 wc2 wc3;
   by id;
   label 
    withdraw_care1="Death from withdraw care Reviewer 1?"
    dnr_ordered1="Pt have DNR ordered Reviewer 1?"
      withdraw_care2="Death from withdraw care Reviewer 2?"
    dnr_ordered2="Pt have DNR ordered Reviewer 2?"
   withdraw_care3="Death from withdraw care Reviewer 3?"
    dnr_ordered3="Pt have DNR ordered Reviewer 3?"

    ;
 proc print label noobs;
 title Withdrawal of Care;
  var id    withdraw_care1 withdraw_care2 withdraw_care3 dnr_ordered1 dnr_ordered2 dnr_ordered3;
  
proc contents;
