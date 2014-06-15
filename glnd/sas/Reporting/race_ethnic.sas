data x;
 set glnd.basedemo;
 /*
                 
 
  value race   99 = "Blank"
                 1 = "American Indian / Alaskan Native"
                 2 = "Asian"
                 3 = "Black or African American"
                 4 = "Native Hawaiian or Pacific Islan"
                 5 = "White"
                 6 = "More than one race"
                 7 = "Other" ;
                 */
 
   array racegender(6,2)
          aiM aiF apM apF aaM aaF
          nam naF whM whF otM otF;
          
  do race1=1 to 6;
     do gender1=1 to 2;
       if race=race1 and gender=gender1 then racegender(race1,gender1)=1;
     end;
  end;
  do gender1=1 to 2;
       if race=7 and gender=gender1 then racegender(6,gender1)=1;
  end;
      
 
 proc sort; by hispanic center;
 options ls=80 ps=60 nodate nonumber;
proc means noprint;
  var aiM aiF apM apF naM naF
      aaM aaF whM whF otM otF;
  output out=rc
  sum=aiM aiF apM apF naM naF
          aaM aaF whM whF otM otF;
  by hispanic center;
  run;
  
data glnd_rep.race;
 set rc;
 array x(12) aiM aiF apM apF naM naF
          aaM aaF whM whF otM otF;
  do i=1 to 12;
     if x(i)=. then x(i)=0;
  end;
  
  label aim='American Indian M'
        aif='American Indian F'
        apm='Asian Pacific M'
        apf='Asian Pacific F'
        nam='Native Hawaiian M'
        naf='Native Hawaiian F'
        aam='Black M'
        aaf='Black F'
        whm='White M'
        whf='White F'
        otm='Other M'
        otf='Other F'
  ; 
  
  options orientation =portrait leftmargin= .1 rightmargin = .1 nodate nonumber;

ods pdf file = "/glnd/sas/reporting/race_ethnic.pdf" style=journal;
ods ps file = "/glnd/sas/reporting/race_ethnic.ps" style=journal;
       
 proc print noobs label;
  by hispanic ;
  
   var center aiM aiF apM apF naM naF
          aaM aaF whM whF otM otF;
   title Race/Ethnic Characteristics by Site;
        
        run;
ods ps close;
ods pdf close;

  
