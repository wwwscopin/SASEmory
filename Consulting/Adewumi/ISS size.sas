options orientation=landscape SPOOL;

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Adewumi\November Radiation_ISS list.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet2$B1:B338"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*proc contents;run;*/

proc means data=temp n mean std median Q1 Q3 min max maxdec=1;
	var iss;
run;
