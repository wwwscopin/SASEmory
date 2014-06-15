LIBNAME new v8 'H:\SAS_Emory\Consulting\Kirk';
LIBNAME old v6 'H:\SAS_Emory\Consulting\Kirk\Data';
data new.pitaug97;
set old.pitaug97;
run;

proc print;run;
