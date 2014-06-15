options orientation=landscape ls=120 minoperator;
%let path=H:\SAS_Emory\Consulting\Mac Starr\;
filename ases "&path.27.xls";

proc import out=ases
			datafile=ases
			DBMS=EXCEL REPLACE;
			RANGE="sheet1$V1:W28";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
data ases1;
	set ases;
	if ases_post=. then delete;
	pre=ases_pre+0;
	rename ases_post=post;
	diff=ases_post-pre;
run;

proc print label;
var pre post diff;
label pre="ASES-pre"
	  post="ASES-post"
	  Diff="Difference";
run;

proc univariate data = ases1;
  var diff;
run;
