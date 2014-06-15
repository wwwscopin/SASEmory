%macro rename(lib=,data=);
proc sql;
select strip(name)||'='||compress(name,'_') into :rename separated by ' '
from sashelp.vcolumn
where upcase(libname)=upcase("&lib") and upcase(memname)=upcase("&data");
quit;

data new;
set &lib..&data;
rename &rename;
run;
%mend;

PROC CONTENTS DATA=sashelp.cars noprint
OUT=OUT(KEEP=NAME TYPE);
RUN;

proc print;run;
PROC SQL NOPRINT;
SELECT NAME INTO :ALLVAR SEPARATED BY ' '
FROM OUT;
SELECT NAME INTO :NUMVAR SEPARATED BY ' ' 
FROM OUT
WHERE TYPE=1;
SELECT NAME INTO :CHRVAR SEPARATED BY ' '
FROM OUT
WHERE TYPE=2;
QUIT;
PROC FREQ DATA=sashelp.cars;
TABLE &ALLVAR/LIST MISSING NOCUM;
tables &numvar;
tables &chrvar;
*FORMAT &NUMVAR NUMFMT. &CHRVAR $CHRFMT.;
RUN;
QUIT;

%put &allvar;
