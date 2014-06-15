%macro logit(datain,dataout,var,outcome, categorical, numerical, k);

data &dataout; if 1=1 then delete; run;
data par; if 1=1 then delete; run;

%do i=1 %to &k;
data sub;
	set &datain;
	where &var=&i;
run;

proc logistic data=sub DESCENDING;
	class &categorical  /param=ref ref=first order=internal;
	model &outcome(event="1")=&categorical &numerical/noint scale=none aggregate lackfit;
	ods output  Logistic.ParameterEstimates=est;
	ods output  Logistic.OddsRatios=or;
	ods output  Logistic.Type3=pv;
run;


data par;
	merge par est(rename=(estimate=est&i stderr=stderr&i probchisq=pv&i));
	var&i=1/StdErr&i**2;
	drop df WaldChiSq;
run;
%end;

data &dataout;
	set par;
	%do i=1 %to &k;
	c&i=var&i/sum(of var1-var&k)*est&i;
	%end;
	coeff=sum(of c1-c&k);
run;
%mend logit;


/******** BootStrap Method A: From small samples *********/
/*********************************************************/
/*
%let numsamp=10000;
%let numpat=81;
data bmixed;
	do bootsamp=1 to &numsamp;
		do bootsamp_id=1 to &numpat;
		 rdx=ceil(&numpat*ranuni(1));
		 output;
		 end;
	end;
run;


proc sql;
	create table boot_mixed as 
		select distinct * from mixed inner join bmixed
		on mixed.idx=bmixed.rdx
		order by bootsamp, bootsamp_id;
		quit;

*/

/******** BootStrap Method B:  ***************************/
/*********************************************************/
/*
proc surveyselect data=YourData out=boot seed=349458478
      method=urs samprate=1 outhits
      rep=1000;
 run;

data boot_new;
  set boot;
  do i = 1 to numberhits;
    output;
  end;
  drop i;
run;
proc print data = boot_new noobs;
run;
*/
