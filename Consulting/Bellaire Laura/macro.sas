%macro fisher(x1, x2, x3, x4,idx);
data test;
	A=0; B=0; count=&x1; output;
	A=0; B=1; count=&x2; output;
	A=1; B=0; count=&x3; output;
	A=1; B=1; count=&x4; output;
run;

proc freq data=test order=data;
   tables A*B / chisq fisher;
   weight Count;
   output out = pv chisq exact;
run;

		data pv;
			set pv;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
			if pvalue^=. and pvalue<0.001 then pv='<0.001'; else pv=put(pvalue,5.3);
			rf=&x2*(&x3+&x4)/(&x1+&x2)/&x4;
			idx=&idx;
			keep idx pv rf;
		run;
%mend fisher;

%macro table(data, out, var1, var2);

proc freq data=&data(where=(&var2^=9));
 tables &var1*&var2;
 ods output crosstabfreqs=one;
 run;
 
 proc sort; by &var1;run;
 proc sort data=&data(where=(&var2^=9)) nodupkey out=temp(keep=&var2); by &var2;run;

 
 data _null_;
    set temp(where=(&var2^=.));
    call symput("m", compress(_n_));
 run;
 
  
 proc transpose data=one out=tmp; by &var1; 
 var &var2 frequency ColPercent rowpercent;
 run;

data _null_;
    set tmp;
    if _n_=2 then do;
        %do j=1 %to &m;
            call symput("n&j", compress(col&j));
        %end;
     end;
 run;
 
 %do j=1 %to &m;
     %let n=%eval(&n+&&n&j);
 %end;
 
 data tmp1;
    set tmp(where=(_name_='ColPercent'));
    %do j=1 %to &m;
        rename col&j=cp&j;
    %end;
 run;
 
  data tmp2;
    set tmp(where=(_name_='RowPercent'));
    %do j=1 %to &m;
        rename col&j=rp&j;
    %end;
 run;

 data _null_;
 	set tmp(where=(_name_="Frequency"));
	if &var1=. then do; 
		call symput("y1", compress(col1));
		call symput("y2", compress(col2));
	end;
run;

data rp; if 1=1 then delete; run;

%do i=1 %to 10;
	data _null_;
		set tmp(where=(_name_="Frequency" and &var1=&i));
		call symput("x1", compress(col1));
		call symput("x2", compress(col2));
	run;

	ods listing close;
    %fisher(&x1, &x2, &y1, &y2, &i);
	ods listing;

	data rp;
		set rp pv;
	run;
%end;

data &out;
    merge tmp(where=(_name_='Frequency')) 
          tmp1 
          tmp2 rp(rename=(idx=&var1)); 
          by &var1;
          col=sum(of col1-col&m);
          cp=col2/&n*100;
          drop _NAME_   _LABEL_  ;

          %do j=1 %to &m;
              c&j=col&j||"/"||compress(col)||"("||compress(put(rp&j,4.1))||"%)";
          %end;	 
		  if &var1=. then do; &var1=0;  c1=col1; c2=col2; end;
		  c=col2||"/"||compress(&n)||"("||compress(put(cp,4.1))||"%)";
run;
%mend table;




	
