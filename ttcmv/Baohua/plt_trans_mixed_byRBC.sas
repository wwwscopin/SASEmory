*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT";
libname wbh "/ttcmv/sas/data";	
data plt0;
	set cmv.plate_015;
	if Platelet=. then delete;
	if PltDate=. then PltDate=BloodCollectDate;
	*if PltDate=. then delete;
	keep id Platelet PltDate;
	rename Platelet=plt;
run;

proc sql;
	create table plt as 
	select a.*, b.dob
	from plt0 as a, cmv.comp_pat as b
	where a.id=b.id;
quit;

proc sort nodupkey; by id pltdate;run;

data rbc;
	set cmv.plate_031;
	rbc_txt0=HMS(scan(rbc_TxStartTime,1,":"), scan(rbc_TxStartTime,2,":"), 0 ); 
	rbc_txt1=HMS(scan(rbc_TxEndTime,1,":"), scan(rbc_TxEndTime,2,":"), 0 ); 
	rbc_txt=rbc_txt1-rbc_txt0; if rbc_txt<0 then rbc_txt=rbc_txt+24*3600;
	keep id BodyWeight rbc_TxStartTime DateHbHct DateTransfusion Hb HbHctTest Hct TimeHbHct rbcVolumeTransfused rbc_TxEndTime rbc_TxStartTime rbc_txt;
run;

proc sql;
	create table rbc as 
	select a.*
	from rbc as a, cmv.comp_pat as b
	where a.id=b.id;
quit;

proc sort; by id DateTransfusion; run;

data plt;
	merge plt rbc(keep=id DateTransfusion); by id;
run;

proc sql;
	create table trans as
	select a.*
	from plt as a, rbc as b
	where a.id=b.id
;

proc sort nodupkey; by id pltdate;run;
proc sort; by id DateTransfusion;run;

data trans;
	set trans; by id DateTransfusion;
	/*if first.id then day=0; else day=.;*/
run;

data trans;
	set trans; by id DateTransfusion;
	if first.id then do; base=DateTransfusion; retain base; end;
	day0=pltdate-base;
	*if day=. then do;

	if 50<=day0 then day=60;
	else if 35<=day0<50 then day=40;
	else if 32<=day0<35 then day=28;
	else if 6<=day0<32 then day=round(day0/7)*7;
	else if day0>=1 then day=4;
	else if  day0=0 then day=0;
	else if -6<day0<=-1 then day=-4;
	else if -9<day0<=-6 then day=-7;
	else if -18<day0<=-9 then day=-14;
	else if -25<day0<=-18 then day=-21;
	else if -35<day0<=-25 then day=-28;
	else if  -50<day0<=-35 then day=-40;
	else if  day0<=-50 then day=-60;
	*end;
	if plt=. or pltdate=. then delete;
	drop base;
run;

proc sort nodupkey; by id day plt;run;

ods pdf file="plt_rbc.pdf" style=journal;
title "Platelet Data Listing with RBC Transfusion Date";
proc print data=trans noobs label split="*" style(data)=[just=center];
var id pltdate plt DateTransfusion day0 day;
label DateTransfusion="Date of RBC Transfusion*"
		day="Days"
		id="TTCMV ID*"
		pltDate="Date Platelet Measured*"
		plt="Platelet Count*"
		day0="Actual Days*";
run;
ods pdf close;

proc sort data=trans out=trans1 nodupkey; by id;run;

proc means data=trans1;
	var id;
	output out=n_id n(id)=n;
run;

data _null_;
	set n_id;
	call symput("n_yes",compress(put(n,3.0)));
run;

proc means data=trans;
	class day;
	var	day0;
	output out=range_day min(day0)=min_day max(day0)=max_day;
run;

data trans;
   	set trans;
   	* jitter time for plotting;
   	day1= day - .3 + .6*uniform(613);	
run;
         
%macro anno(data=trans);
		proc mixed data = &data empirical covtest;
			class id day ; * &source;
		
			model plt = day / solution ; * &source	day*&source/ solution;
			repeated day / subject = id type = cs;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans_&data;
		run;

		proc sort data = &data; by day; run;
		proc sort data = lsmeans_&data; by day; run;

		data lsmeans_&data;
			set lsmeans_&data;
			if estimate<0 then estimate=0;
			if lower<0 then lower=0;
			if upper<0 then upper=0;
		run;

		data &data ;
			merge &data lsmeans_&data;	by day;
   	run;


		DATA anno_mixed_&data; 
			set lsmeans_&data;
			
			xsys='2'; ysys='2';

			* draw a light gray rectangle ;
					function = 'move'; x = -42; y = 150; output;
					function = 'BAR'; x = 62; y = 400; color = 'ligr'; style = 'solid'; line= 0; output;
			
			%if &data=plt_plot %then %do; %let mycolor='red'; %end;
			%if &data=trans %then %do; %let mycolor='red'; %end;
			%if &data=notrans %then %do; %let mycolor='red'; %end;

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor;  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;

%mend anno;

%anno(data=trans);


         goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
         	
         					/* Set up symbol for Boxplot */
         					symbol1 interpol=none mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8;
         
         					/* Set up Symbol for Data Points */
         					symbol2 i=none ci=black value=circle h=1 w=1;

         
         					/* Set up Symbol for Data Points */
         					symbol3 i=j ci=reddL value=dot h=1 w=4;

         
     
         %macro make_plots(data=trans); 
     
         
          		%if &data = trans %then %do; 	%let variable =plt; %let description = f=zapf "Platelet Count (1000/" f=greek 'm' f=zapf "L)- With Transfusion (n=&n_yes)";
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/;%end;
          		%if &data = notrans %then %do; 	%let variable =plt; %let description = f=zapf "Platelet Count (1000/" f=greek 'm' f=zapf "L)- Without Transfusion (n=&n_no)";
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/;%end;
   
          		* get 'n' at each day;

					proc sort data=&data out=&data._id nodupkey; by id day;run;
         		proc means data=&data._id noprint;

         			class day;
         			var &variable;
         			output out =sizes_&data n(&variable) = num_obs;
         		run;
 
         
          		* get 'n' at each day;
         	%let n_n40= 0; %let n_n28= 0; %let n_n21= 0; %let n_n14= 0; %let n_n7= 0; %let n_n4= 0; 
				%let   n_0= 0; %let   n_4= 0; %let   n_7= 0; %let  n_14= 0; %let n_21= 0; %let n_28= 0; 
				%let  n_40= 0;  %let n_60= 0; 
         
         		* populate 'n' annotation variables ;
         		%do i = -40 %to 65;
         			data _null_;
         				set sizes_&data;
							where day = &i; 
							%if &i>=0 %then %do;	
         				call symput( "n_&i",  compress(put(num_obs, 3.0))); %end;
							%if &i<0 %then %do; %let j=%eval(%sysfunc(abs(&i)));
         				call symput( "n_n&j",  compress(put(num_obs, 3.0)));%end;
         			run;
         		%end;
         
         		proc format; 
         		 	value time_axis   

		-60=" " -41=" "	-40="-40*(&n_n40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     -33=" " -32=" " -31=" " -30=" " -29=" " -28="-28*(&n_n28)" -27=" " -26=" " -25=" "
		-24=" " -23=" " -22=" "  -21="-21*(&n_n21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14*(&n_n14)" -13=" " 
		-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7*(&n_n7)" -6=" " - 5=" "  -4="-4*(&n_n4)"  -3=" "   -2=" "   -1=" "   
													1=" "   0= "0*(&n_0)"  2=" " 3=" " 4="4*(&n_4)" 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
         			                  11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
         			                  21="21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" "
												  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
												  41=" " 40="40*(&n_40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
												  51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 63=" " 61=" " 62=" "
												  60="60*(&n_60)" 80=" ";
                
         		run;

         
         		title2 h=3.5 justify=center &description;
         		title3 h=3.5 justify=center Longitudinal models (means and 95% CI);
         
					axis1 	label=(f=zapf h=3 'Days Before and After First RBC Transfusion' ) value=(f=zapf h=2.0) order= (-60 to -40 by 20 -28 to -7 by 7 -4 to 4 by 4 7 to 28 by 7 40 to 80 by 20) split="*"  minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=3 a=90 "Platelet Count (1000/" f=greek 'm' f=zapf "L)") order=(0 to 900 by 100) value=(f=zapf h=2) &scale ;
        
             
         		proc gplot data=&data gout=wbh.graphs;

         			plot  &variable*day &variable*day1 estimate*day/ overlay annotate= anno_mixed_&data haxis = axis1 vaxis = axis2  nolegend;

         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format day time_axis. &variable 3.0;
         		run;	
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = portrait;
        	%make_plots(data=trans);         	
				*%make_plots(data=notrans); run;
       
        	ods ps file = "plt_trans_mixed_rbc.ps";
        	ods pdf file = "plt_trans_mixed_rbc.pdf" startpage=no;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s nofs;
						list igout;
						treplay 1:1; 
					run;

	ods pdf startpage=no style=journal;

	title1	height=3 f=zapf 'Platelet Count longitudinal model-based means';

		* now make a table of the means and 95% CI for sofa score on days 0, 7, 14;
		data plt_trans_mixed;

					merge lsmeans_trans(keep = estimate upper lower day rename=(estimate=estimate_t upper=upper_t lower=lower_t))
					 sizes_trans(keep=day num_obs rename=(num_obs=num_t)) range_day(keep=day min_day max_day); by day;
			
			*where day in (1, 7, 14);
			if day=. then delete;
			if day=0 then do; min_day=0; max_day=0; end;
			dday=strip(put(day, 3.0)) || "[" || strip(put(min_day, 3.0)) || " to " || strip(put(max_day, 3.0))|| "]";
 			plt_t = strip(put(estimate_t, 5.1)) || " (" || strip(put(lower_t, 5.1)) || ", " || strip(put(upper_t, 5.1))|| ")";
			
			label
				dday = "Day"
				plt_t = "Platelet Count with Transfusion*mean (95% CI)"
					num_t="Sample Size"
				;
		
		   keep dday num_t plt_t;
		run;

			proc print data = plt_trans_mixed noobs label split="*" style(data) = [just=center];
				var dday num_t;
			 var plt_t/style(data) = [cellwidth=2in just=center] ;
			run;
	
		ods pdf close;      	
		ods ps close;
