options byline spool nodate nonumber /*mprint mlogic*/;
%let pm=%sysfunc(byte(177));  

/*
libname wbh "H:\SAS_Emory\Macro";  
proc format; 
	value female 0="Male" 1="Female";
	value type 1="Type A" 2="Type B";
	value prog 1="ProgA" 2="ProgB" 3="ProgC";
run;

data hsb;
	set wbh.hsb2;
	format female female. schtyp type. prog prog.;
	label female="Gender" read="Reading Score" prog="Program";
run; 
*/

%macro tab(data=, gvar=, var=, nonparm=1, decmax=1);
data &var; if 1=1 then delete; run;
proc freq data=&data;
 	%if &nonparm=1 %then %do;
		tables &var*&gvar/chisq fisher cmh;
		output out = pv chisq exact cmh;
	%end;
	%else %do;
		tables &var*&gvar/chisq cmh;
		output out = pv chisq cmh;
	%end;
	ods output crosstabfreqs=one;
run;

	   data pv;
    		length pv psig $8;
			set pv;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
			if pvalue^=. then do;
				if pvalue>=0.10 then pv=put(pvalue,4.2);
				else if 0.01<=pvalue<0.10 then pv=put(pvalue, 5.3);
				else if 0.0001<=pvalue<0.01 then pv=put(pvalue, 6.4);
				else if pv<0.0001 then pv="<0.0001";
			end;
		
			if 0<pvalue<0.10 then psig="*"; else psig=" ";
			pv=compress(pv||psig);

			or=_LGOR_+0;
			orange=put(L_LGOR,4.2)||"--"||compress(put(U_LGOR,4.2));
			if or=. then orange=" ";
			keep pvalue pv or orange;
			format or pvalue 5.2;
		run;


proc sort data=one; by &var;run;
  
proc transpose data=one out=tmp; by &var; 
	var &gvar frequency ColPercent rowpercent;
run;

data _null_;
	set tmp;
	if _n_=2;
	%do j=1 %to &m;
		call symput("k&j", col&j);
	%end;
run;

data _null_;
    set tmp;
    if _n_=2 then do;
        %do j=1 %to &m;
            call symput("n&j", compress(col&j));
        %end;
     end;
run;
 
 %let n=0;
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
 
data &var;
	length c c1-c&m $60 row variable $200;

    merge tmp(where=(_name_='Frequency')) 
          tmp1 
          tmp2; 
          by &var;
          col=sum(of col1-col&m);
          cp=col/&n*100;
		  c=col||"/"||compress(&n)||"("||compress(put(cp,4.&decmax))||"%)";
          drop _NAME_   _LABEL_  ;
          %do j=1 %to &m;
		  	  c&j=col&j||"/"||compress(&&k&j)||"("||compress(put(cp&j,4.&decmax))||"%)";
          %end;
          if &var=" " then delete;
		  variable = varlabel(open("&data_in", "i"), varnum(open("&data_in"), "&var"));
		  row = putn(&var , varfmt(open("&data_in"), varnum(open("&data_in"), "&var"))); 
		  keep &var variable row c c1-c&m ;
run;
proc sort; by descending &var; run;

data &var;
	merge  &var(rename=(c=col1) drop=&var) pv;
    %do j=1 %to &m;
		%let g=%eval(&j+1);
		rename c&j=col&g;
    %end;
run;

%mend tab;

%macro stat(data=, gvar=, var=, decmax=1);
	data &var; if 1=1 then delete; run;
	data stat;
		if 1=1 then delete;
	run;

	proc means data=&data /*noprint*/;
		class &gvar;
		var &var;
		output out=&var n(&var)=m mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3 min(&var)=min max(&var)=max;
	run;
	
	data &var;
		set &var;

		mean0=compress(put(mean,5.&decmax))||" &pm "||compress(put(std,5.&decmax))||"("||compress(m)||")";
 	
		range=compress(put(median, 5.&decmax))||"["||compress(put(Q1,5.&decmax))||" - "||compress(put(Q3,5.&decmax))||"]";
		minmax="["||compress(put(min,5.&decmax))||" - "||compress(put(max,5.&decmax))||"]";

		keep &gvar mean0 median range minmax ;
	run;
	
*ods trace on/label listing;
	proc npar1way data = &data wilcoxon;
  		class &gvar;
  		var &var;
  		ods output KruskalWallisTest=wp;
	run;
*ods trace off;

	data wp;
		length pv psig $8;
		set wp(rename=(nvalue1=pvalue));
		if _n_=3;

		if pvalue^=. then do;
				if pvalue>=0.10 then pv=put(pvalue,4.2);
				else if 0.01<=pvalue<0.10 then pv=put(pvalue, 5.3);
				else if 0.0001<=pvalue<0.01 then pv=put(pvalue, 6.4);
				else if pv<0.0001 then pv="<0.0001";
		end;

		if 0<pvalue<0.10 then psig="*"; else psig=" ";
		pv=compress(pv||psig);
		keep pvalue pv;
	run;

	proc transpose data=&var out=&var;
		var mean0 range minmax;
	run;

	
	data &var;
		length col1-col&h $60 row variable $200;
		merge &var wp;

		if compress(_name_)="mean0" then row="Mean &pm SD (N)";
		else if compress(_name_)="range" then row="Median[Q1-Q3]";
		else if compress(_name_)="minmax" then row="[Min-Max]";

		drop _name_;
		variable = varlabel(open("&data_in", "i"), varnum(open("&data_in"), "&var"));
	run;
%mend stat;	

ods escapechar = "^";
%macro table(data_in=, where=, data_out=, gvar=, var= , type=, nonparm=1, first_var=0, last_var=0, decmax=1 , label=, title=, footnote=, prn=1);

	%global fnote footnote1 footnote2 footnote3 footnote4 footnote5 til title1 title2 title3;

	%if &first_var=1 %then %do; 
		%let footnote1=; %let footnote2=; %let footnote3=; %let footnote4=; %let footnote5=;
		data &data_out; if 1=1 then delete; run; 
		%if &title NE %str() %then %do; %let til=1; %let title1=%str(&title); %end; %else %let til=0;
		%if &footnote NE %str() %then %do; %let fnote=1; %let footnote1=%str(%sysfunc(dequote(&footnote))); %end; %else %let fnote=0; %end;
	%else %do;
		%if &title NE %str() %then %do; %let til=%eval(&til+1); %let title&til=%str(&title); %end;
		%if &footnote NE %str() %then %do; %let fnote=%eval(&fnote+1); %let footnote&fnote=%str(%sysfunc(dequote(&footnote))); %end;
	%end;

	* subset data according to where input;
	data x;	
		set &data_in;
		where &where;
	run;

proc sort data=x nodupkey out=xx(keep=&gvar); by &gvar;run;
data _null_; set xx(where=(&gvar^=.)); call symput("m", compress(_n_));run;

proc freq data=x compress;
	tables &gvar/nocum;
	ods output onewayfreqs=&gvar;
run;

%let num_total=0;
%do i=1 %to &m;
	data _null_;
		set &gvar;
		if _n_=&i then do;
			call symput("num&i", compress(frequency));
			call symput("colname&i", strip(putn(&gvar , varfmt(open("&data_in"), varnum(open("&data_in"), "&gvar")))));
		end;
	run;
	%let num_total=%eval(&num_total+&&num&i);
%end;

%let h=%eval(&m+1);

	* for CONTINUOUS or BINARY types;
	%if &type=con %then %do;	%stat(data=x, gvar=&gvar, var=&var, decmax=&decmax); %end;
	* for CATEGORICAL types;	
	%if &type= cat %then %do;	%tab(data=x, gvar=&gvar, var=&var, nonparm=&nonparm, decmax=&decmax); %end;
	
	data first_line;
		length row variable $200;
		* assign descriptive label to each row:;
		%if  &label EQ %str() %then %do; 		
			variable = varlabel(open("&data_in", "i"), varnum(open("&data_in"), "&var"));
		%end;
		%else %do; variable = dequote(&label); %end;
		row = "^S={font_weight = bold}" ||strip(variable);
	run;

	data &var; 
		set first_line &var(in=A);       
		if A then row="  "||strip(row);
	run;

  	* stack results - if first variable, then start our growing results table;
	
	data &data_out;
		length col1-col&h $60 row variable $200;
		%if (&first_var = 1) %then %do;
			set &var;
		%end;
		%else %do;
			set &data_out
			&var;
		%end;
	run;

%if &last_var=1 and &prn=1 %then %do;
	ods rtf file = "&data_out..rtf"  style=journal toc_data startpage =no bodytitle ;
		%do nn=1 %to &til;	 title&nn h=%sysevalf(4-&nn*0.5) &&title&nn; %end;
	proc report data =&data_out nowd headskip missing split = "*" style(header) = {just=center};
		column  row col1-col&h pv;
		define row/ "Characteristic" style={asis=on just=left vjust=middle width=3in};
		define col1 /"Overall*(n=&num_total)" style(column) = [just=center font_size=1.75] ;
		%do i=2 %to &h;
			%let j=%eval(&i-1);
			define col&i /"&&colname&j*(n=&&num&j)" style(column) = [just=center font_size=1.75];
		%end;
		define pv /"p value" style(column) = [just=center font_size=1.5];
	run;	

	ods escapechar='^';
	%do mm=1 %to &fnote;
	ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt} Note &mm: &&footnote&mm";
	%end;
	ods rtf close;
%end;

%mend table;

/*
%table(data_in=hsb,data_out=test,gvar=prog,var=read,type=con, first_var=1, title="TableA Summary");
%table(data_in=hsb,data_out=test,gvar=prog,var=female,type=cat, last_var=1);quit;
*/
