*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT";
libname wbh "/ttcmv/sas/data";	

data hb0;
	set cmv.plate_015;
	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;
	if hb=. then delete;
	keep id HbDate Hb;
run;

proc sort nodupkey; by id hbdate;run;

data rbc;
	set cmv.plate_031;
	rbc_txt0=HMS(scan(rbc_TxStartTime,1,":"), scan(rbc_TxStartTime,2,":"), 0 ); 
	rbc_txt1=HMS(scan(rbc_TxEndTime,1,":"), scan(rbc_TxEndTime,2,":"), 0 ); 
	rbc_txt=rbc_txt1-rbc_txt0; if rbc_txt<0 then rbc_txt=rbc_txt+24*3600;
	keep id BodyWeight rbc_TxStartTime DateHbHct DateTransfusion Hb HbHctTest Hct TimeHbHct rbcVolumeTransfused rbc_TxEndTime rbc_TxStartTime rbc_txt;
	rename DateHbHct=hbdate;
run;

proc sort nodupkey; by id DateTransfusion; run;

data rbc_tx;
	set rbc; by id DateTransfusion;
	if first.id;
run;

data hb;
	set hb0 rbc(keep=id hbdate Hb); by id;
run;

proc sort nodupkey; by id hbdate;run;

proc sql;
	create table trans0 as
	select a.*, DateTransfusion, a.Hbdate-DateTransfusion as day 
	from hb as a, rbc_tx as b
	where a.id=b.id;
;

proc sql;
	create table trans as
	select a.*
	from trans0 as a, cmv.comp_pat as b
	where a.id=b.id and -4<=day<=4 and hb^=.;
;

proc sort nodupkey; by id day hb;run;
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
	var	day;
	output out=range_day min(day)=min_day max(day)=max_day;
run;

data trans;
   	set trans;
   	* jitter time for plotting;
   	day1= day - .1 + .2*uniform(613);	
run;

proc print;run;
         
%macro anno(data=trans);
		proc mixed data = &data empirical covtest;
			class id day ; * &source;
		
			model hb = day / solution ; * &source	day*&source/ solution;
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
					function = 'move'; x = -42; y = 11.4; output;
					function = 'BAR'; x = 62; y = 16.1; color = 'ligr'; style = 'solid'; line= 0; output;
			
			%if &data=hb_plot %then %do; %let mycolor='red'; %end;
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
proc print;run;



         goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
         	
         					/* Set up symbol for Boxplot */
         					symbol1 interpol=none mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8;
         
         					/* Set up Symbol for Data Points */
         					symbol2 i=none ci=black value=circle h=1 w=1;

         
         					/* Set up Symbol for Data Points */
         					symbol3 i=j ci=red value=dot h=1 w=4;

         
     
         %macro make_plots(data=trans); 
     
         
          		%if &data = trans %then %do; 	%let variable =hb; %let description = f=zapf "Hemoglobin(g/dL)- With Transfusion (n=&n_yes)";
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/;%end;
      
          		* get 'n' at each day;

					proc sort data=&data out=&data._id nodupkey; by id day;run;
         		proc means data=&data._id noprint;

         			class day;
         			var &variable;
         			output out =sizes_&data n(&variable) = num_obs;
         		run;
 
         
          		* get 'n' at each day;
         	%let n_n4= 0; %let n_n3= 0; %let n_n2= 0; %let n_n1= 0; 
				%let n_0= 0; %let   n_1= 0; %let   n_2= 0; %let  n_3= 0; %let n_4= 0; 
         
         		* populate 'n' annotation variables ;
         		%do i = -4 %to 4;
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
									 -4="-4*(&n_n4)"  -3="-3*(&n_n3)"   -2="-2*(&n_n2)"   -1="-1*(&n_n1)" -5=" " 5=" "
										1="-1*(&n_n1)"   0= "0*(&n_0)"  2="2*(&n_n2)" 3="3*(&n_n3)" 4="4*(&n_4)" ;
                
         		run;

         
         		title2 h=3.5 justify=center &description;
         		title3 h=3.5 justify=center Longitudinal models (means and 95% CI);
         
					axis1 	label=(f=zapf h=3 'Days Before and After First RBC Transfusion' ) value=(f=zapf h=2.0) split="*"  minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=3 a=90 "Hemoglobin(g/dL)") order=(5 to 20 by 1) value=(f=zapf h=2) &scale ;
        
             
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
       
        	ods ps file = "hb_trans_mixed_local.ps";
        	ods pdf file = "hb_trans_mixed_local.pdf" startpage=no;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s nofs;
						list igout;
						treplay 1:1; 
					run;


	ods pdf startpage=no style=journal;

	title1	height=3 f=zapf 'Hemoglobin longitudinal model-based means';

		* now make a table of the means and 95% CI for sofa score on days 0, 7, 14;
		data hb_trans_mixed;

					merge lsmeans_trans(keep = estimate upper lower day rename=(estimate=estimate_t upper=upper_t lower=lower_t))
					 sizes_trans(keep=day num_obs rename=(num_obs=num_t)) range_day(keep=day min_day max_day); by day;
			
			*where day in (1, 7, 14);
			if day=. then delete;
			if day=0 then do; min_day=0; max_day=0; end;
			dday=strip(put(day, 3.0)) || "[" || strip(put(min_day, 3.0)) || " to " || strip(put(max_day, 3.0))|| "]";
 			hb_t = strip(put(estimate_t, 5.1)) || " (" || strip(put(lower_t, 5.1)) || ", " || strip(put(upper_t, 5.1))|| ")";
			
			label
				dday = "Day"
				hb_t = "Hemoglobin with Transfusion*mean (95% CI)"
					num_t="Sample Size"
				;
		
		   keep dday num_t hb_t;
		run;

			proc print data = hb_trans_mixed noobs label split="*" style(data) = [just=center];
				var dday num_t;
			 var hb_t/style(data) = [cellwidth=2in just=center] ;
			run;
	
		ods pdf close;      	
		ods ps close;
