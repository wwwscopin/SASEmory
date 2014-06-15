PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Gottschalk Michael Brandon\Stats sheet for all Surgeons.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:N1053"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F3'='CHAR(11)' 'F4'='CHAR(11)')"  ; 
RUN;
