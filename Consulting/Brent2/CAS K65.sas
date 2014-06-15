
options ls=120 orientation=portrait fmtsearch=(library);
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
proc contents data=brent.crf;run;
proc contents data=brent.quest;run;

data quest_cas;
	set brent.quest(where=(gp=1));
run;

data crf_cas;
	set brent.crf(where=(gp=1));
run;

data k65;
	set brent.rd(where=(idx=1) keep=study_no k65 idx);
run;
