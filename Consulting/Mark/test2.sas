
DATA SURVEY; 
  INFILE ‘C:\PROCREP\PROCREP.DAT’; 
  INPUT @01 FNAME    $CHAR10. 
        @12 LINIT    $CHAR1. 
        @15 SEX      $CHAR1. 
        @18 ACADYEAR $CHAR1. 
        @21 GPA      3.1 
        @27 AGE      2. 
        @31 BOOKS    4. 
        @40 FOOD     4. 
        @49 ENT      4. ; 
RUN; 
*---------------------------------------------; 
PROC FORMAT; 
  VALUE $SEXFMT  ‘M’ = ‘MALE’ 
                 ‘F’ = ‘FEMALE’ ; 
  VALUE $YEARFMT ‘1’ = ‘FRESHMAN’ 
                 ‘2’ = ‘SOPHOMORE’ 
                 ‘3’ = ‘JUNIOR’ 
                 ‘4’ = ‘SENIOR’ ; 
RUN; 
*---------------------------------------------; 

PROC REPORT DATA = SURVEY; 
RUN
