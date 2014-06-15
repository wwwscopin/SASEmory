%let path=H:\SAS_Emory\Data\;
libname wbh "&path";

proc import datafile="&path.glndlab\GLU\HighGLNGLND.xls"
	out=glu0 dbms=excel replace; 
	sheet="sheet1$B1:B30"; 
         GETNAMES=No;
         MIXED=YES;
run;

proc contents;run;

data wbh.glu;
	set glu0;
	id=f1+0;
	drop f1;
run; 

proc print;run;
