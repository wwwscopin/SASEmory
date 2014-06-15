PROC IMPORT OUT= tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Fitting\data-ex-14-8 (Aircraft Damage).xls" 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc print;run;
proc genmod;
model y=x1 x2/dist=poisson type1 type3;
run;
