%let test="";
data test;
	wbh=compress(dequote(&test));
	num=length(wbh);
run;
proc contents;run;
proc print;run;
