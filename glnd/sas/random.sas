

****** random.sas
       program to see if patient is eligible and apache correctly scored
       uses plate1-6
       random.dat ( id to test)
       
      ;
data x;
 merge glnd.plate1 glnd.plate2 glnd.plate3
       glnd.plate4 glnd.plate5 glnd.plate6;
 by id;
data y;
 infile 'random.dat';
 input id;
 
 keep id;
 run;
data xy;
 merge x(in=b) y(in=a);
 by id;
 if a;
 
 acheck=0;
 bcheck=0;
 gcscheck=0;
 extra=0;
 good=1;
     if validscreen=0 then good=0;
     if validplate2=0 then good=0;
 
     if apachecorrect=0 then good=2;
     
     if (aps_a=aps_total_a_check) then acheck=1;
     if aps_total_b_check=aps_b then bcheck=1;
     if (glas_eye=eye_open) and 
        (glas_verb=verb_resp) and
        (glas_motor=motor_resp) then gcscheck=1;
     if chron_health=1 then chron_health=5;
     if chron_health=3 then chron_health=0;
****** change from sas value to format;
if age_score=5 then age_score=6;
if age_score=4 then age_score=5;
if age_score=1 then age_score=0;
     if (apache_sect2=age_score) and
        (apache_sect3=chron_health) then extra=1;
        
     if acheck=0 or bcheck=0 or gcscheck=0 or extra=0 then good=3; 
     file 'random.txt';
  *put id acheck bcheck gcscheck extra good apache_sect2 age_score;
     
     correctid=0;
     if apache_score<=15 and apache_id=1 then correctid=1;
     if apache_score>15 and apache_id=2 then correctid=1;
     
  
  put;
  put;
  if b=0 then put  // '    ERROR, NO DATAFAX DATA FOR ID ' ID 
                    /  ' Rerun using command'
                    /  ' /glnd/sas/random 12 xxxxx'
                    /  ' where xxxxx is the id #';
    else do; 		
    		
  put;
  put;
  put;
  put '           GLND ID ' id '   Initials  ' ptint;
  put;
  put;
  if validscreen=0 or validplate2=0 then do;
  **** not valid;
       put ' PATIENT DOES NOT MEETS ALL REQUIREMENTS';
       PUT;
       if validscreen=0 then put ' INITIAL SCREENING FORM CRITERIA';
       if validplate2=0 then put ' ELIGIBILITY CRITERIA CONFIRMATION FORM';   
  end;    *** end not valid;
 
  else do;
  ***** patient is valid;
       put ' PATIENT DOES MEETS ALL ENTRY REQUIREMENTS';
       put;
       if good=1 then do;
  **** apache scored correctly;
          put ' Apache II was scored correctly';
          if correctid=1 then do;
  **** classified apache 2 correctly;
  		put ' All information is correct';
  		put ' Send out Envelope Notification!!!!!!!';   
  		put;
          end;  **** end  ALL correct;
 	else do;
  ***** id is incorrect!!!;
  		put ' The ID number is incorrect!!!!';
  		put ' The APACHE II WAS CLASSIFIED INCORRECTLY!!!!!';
  		put ' THIS NEEDS TO BE FIXED BEFORE PATIENT CAN BE RANDOMIZED';
  		PUT;
           end; **** apache missclass;
       end; **** apache2 score;
  	else do;
  **** error in apache 2 scoring;
  		put ' THERE IS AN ERROR IN THE APACHE II SCORE';
  		put ' THIS NEEDS TO BE FIXED BEFORE PATIENT CAN BE RANDOMIZED';
  		PUT;
  		if acheck=0 then put ' Check Part A scoring';
  		if bcheck=0 then put ' Check Part B scoring';
  		if gcscheck=0 then put ' Check GCS scoring';
  		if extra=0 then put ' Check Section 2 or Section 3 'apache_sect2 age_score
        apache_sect3 chron_health ;
  		put;
	end; **** error in apach2;
   end;
  end;	
run;	
       
     proc print;
      var id good acheck bcheck gcscheck extra good correctid;
      run;
    
    
    data xy1;
     set xy;
     center=int(id/10000);
     file 'newid.dat';
     format apache_id ;
      put id center apache_id ptint;
