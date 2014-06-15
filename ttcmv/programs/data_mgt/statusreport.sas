%inc'patientreportinc.sas';

proc contents;
run;
options orientation=landscape ls=135 ps=54;
;

      ods pdf file='statusreport.pdf' style=journal;
       ods ps file='statusreport.ps' style=journal;    
      ods rtf file='statusreport.rtf' sasdate;
      
data report;
   set cmv.status;
   length sd $ 8;
   sd='';
   if leftstudy=1 then sd=put(studyleftdate, mmddyy8.);
   label sd='Date Left Study';
   length tdate $ 8;
   
   if trans=1 then Tdate=put(TransferDate, mmddyy8.);
   label tdate='Transfer Date';
   
   length rbcf $ 3;
   if rbc>=1 then rbcf='Yes';
   label rbcf='RBC Forms?'
         rbc='# RBC Forms';
   
 title TTCMV Forms Status Report; 
proc print noobs label uniform;
 var id mocinit enrollmentdate lbwidob p3 p4 f4 f7 f14 f21 f28 f40 f60 f90 rbc fdays leftstudy sd tdate;
     run;
  ods rtf close;
  ods ps close;
  ods pdf close;
