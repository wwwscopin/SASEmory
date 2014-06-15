libname wbh "/ttcmv/sas/data";	

proc format;
		value tx 
		0="No"
		1="Yes"
		;
run;

data hwl;
	set cmv.plate_015;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate;
	rename DFSEQ=day;
run;

proc sql;
	create table hwl as 
	select a.*, dob, day - .3 + .6*uniform(613) as day1
	from hwl as a, cmv.comp_pat as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;

data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0; 
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	/*if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */
	if A;

	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
		;
run;

proc sort nodupkey; by id dt; run;

data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	daytx0=WeightDate-dt;

	if 50<=daytx0 then daytx=60;
	else if 35<=daytx0<50 then daytx=40;
	else if 32<=daytx0<35 then daytx=28;
	else if 6<=daytx0<32 then daytx=round(daytx0/7)*7;
	else if daytx0>1 then daytx=4;
	else if  -1<=daytx0<=1 then daytx=0;
	else if -6<daytx0<-1 then daytx=-4;
	else if -9<daytx0<=-6 then daytx=-7;
	else if -18<daytx0<=-9 then daytx=-14;
	else if -25<daytx0<=-18 then daytx=-21;
	else if -35<daytx0<=-25 then daytx=-28;
	else if  -50<daytx0<=-35 then daytx=-40;
	else if  daytx0<=-50 then daytx=-60;

	daytx1= daytx - .3 + .6*uniform(613);	

	if tx then output hwl_tx;
	if not tx then output hwl_no_tx;
	output hwl;
run;

data hwl_id;
	set hwl; 
	keep id tx;
run;

proc sort nodupkey; by id;run;
	
proc freq data=hwl_id;
	tables tx;
	ods output onewayfreqs=tab;
run;

data _null_;
	set tab;
	if tx=0 then call symput("no", compress(frequency));
	if tx=1 then call symput("yes",compress(frequency));
run;

%let total=%eval(&yes+&no);

%macro anno(data=, var=);
	%if &data=hwl_tx %then %do; %let t=daytx; %end;
	%if &data=hwl_no_tx %then %do; %let t=day; %end;

		proc mixed data = &data empirical covtest;
			class id &t ; * &source;
		
			model &var = &t / solution ; * &source	day*&source/ solution;
			repeated &t / subject = id type = cs;
			lsmeans &t / cl ;
			ods output lsmeans = lsmeans;
		run;

		proc sort data = &data; by &t; run;
		proc sort data = lsmeans; by &t; run;

		data lsmeans;
			set lsmeans;
			if estimate<0 then estimate=0;
			if lower<0 then lower=0;
			if upper<0 then upper=0;
		run;

		data &data._&var ;
			merge &data lsmeans;	by &t;
   	run;


		DATA anno_mixed_&data._&var; 
			set lsmeans;
			
			xsys='2'; ysys='2';


			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			x=&t; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='red';  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='red';  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  x=&t-.2; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='red'; OUTPUT;
			  x=&t+.2; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='red'; OUTPUT;
			  x=&t;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;

%mend anno;

%anno(data=hwl_tx, var=weight);
%anno(data=hwl_no_tx, var=weight);

%anno(data=hwl_tx, var=HeadCircum);
%anno(data=hwl_no_tx, var=HeadCircum);

%anno(data=hwl_tx, var=HtLength);
%anno(data=hwl_no_tx, var=HtLength);

proc print data=hwl_tx_weight;run;
       

         goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
         	
         					/* Set up symbol for Boxplot */
         					symbol1 interpol=none mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=0.8;
         
         					/* Set up Symbol for Data Points */
         					symbol2 i=none ci=blue value=circle h=1 w=1;

         
         					/* Set up Symbol for Data Points */
         					symbol3 i=j ci=red value=dot h=1.5 w=2;

  
%macro make_plots(data); 

proc greplay igout= wbh.graphs nofs; delete _ALL_; run;
          		* get 'n' at each day;
         	%let n_n60=0; %let n_n40= 0; %let n_n28= 0; %let n_n21= 0; %let n_n14= 0; %let n_n7= 0; %let n_n4= 0; 
				%let   n_0= 0; %let   n_4= 0; %let   n_7= 0; %let  n_14= 0; %let n_21= 0; %let n_28= 0; 
				%let  n_40= 0;  %let n_60= 0; 


				%let  m_1= 0; %let   m_4= 0; %let   m_7= 0; %let  m_14= 0; %let m_21= 0; %let m_28= 0; 
				%let  m_40= 0;  %let m_60= 0; 

%let x=1;
%do %while (&x <4);
    %if &x = 1 %then %do; 	%let var =Weight; %let description = f=zapf 'Weight (g)'; %let pic= 'A)'; 
		%let order= (0 to 3000 by 500); %end;
    %if &x = 3 %then %do; 	%let var =HeadCircum; %let description = f=zapf 'Head Circumference (cm)'; %let pic= 'C)'; 
			%let order= (15 to 40 by 5); %end;        
    %if &x = 2 %then %do; 	%let var =HtLength; %let description = f=zapf 'Length (cm)'; %let pic= 'B)'; 
		%let order= (10 to 50 by 5); %end;


	proc sort data=&data(where=(tx=1)) out=&data._tx_id nodupkey; by id daytx;run;
	proc sort data=&data(where=(tx=0)) out=&data._no_tx_id nodupkey; by id day;run;

	* get 'n' at each day;
		proc means data=&data._tx_id noprint;
    			class daytx;
    			var &var;
     			output out = sizes_&var._tx n(&var) = num_obs;
  		run;

	* get 'n' at each day;
		proc means data=&data._no_tx_id noprint;
    			class day;
    			var &var;
     			output out = sizes_&var._no_tx n(&var) = num_obs;
  		run;

	* populate 'n' annotation variables ;
         		* populate 'n' annotation variables ;
         		%do i = -60 %to 65;
         			data _null_;
         				set sizes_&var._tx;
							where daytx = &i; 
							%if &i>=0 %then %do;	
         				call symput( "n_&i",  compress(put(num_obs, 3.0))); %end;
							%if &i<0 %then %do; %let j=%eval(%sysfunc(abs(&i)));
         				call symput( "n_n&j",  compress(put(num_obs, 3.0)));%end;
         			run;
         		%end;

         		* populate 'n' annotation variables ;
         		%do i = 0 %to 62;
         			data _null_;
         				set sizes_&var._no_tx;
         				where day = &i;
         				call symput( "m_&i",  compress(put(num_obs, 3.0)));
         			run;
         		%end;
         
          
	proc format; 
      value t_axis_tx   
			-60="-60*(&n_n60) " -41=" "	-40="-40*(&n_n40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28*(&n_n28)" -27=" " -26=" " -25=" "
			-24=" " -23=" " -22=" "  -21="-21*(&n_n21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14*(&n_n14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7*(&n_n7)" -6=" " - 5=" "  -4="-4*(&n_n4)"  -3=" "   -2=" "   -1=" "   
													1=" "   0= "0*(&n_0)"  2=" " 3=" " 4="4*(&n_4)" 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
         			                  11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
         			                  21="21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" "
												  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
												  41=" " 40="40*(&n_40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
												  51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 63=" " 61=" " 62=" "
												  60="60*(&n_60)" 80=" " -62=" ";

         		 	value t_axis_no_tx   -1=" " 0=" " 1 = "1*(&m_1)"  2=" " 3=" " 4="4*(&m_4)" 5=" " 6=" " 7="7*(&m_7)" 8=" " 9=" " 10=" " 
         			                  11=" " 12=" " 13=" " 14="14*(&m_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
         			                  21="21*(&m_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&m_28)"  29=" " 30=" "
												  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
												  41=" " 40="40*(&m_40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
												  51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "
												  60="60*(&m_60)" ;
                
         		run;

         

					axis1 	label=(f=zapf h=3 'Days Before and After Transfusion' ) value=(f=zapf h=2.0) order= (-62 -60 to -40 by 20 -28 to -7 by 7 -4 to 4 by 4 7 to 28 by 7 40 to 80 by 20) split="*"  minor=none offset=(0 in, 0 in);
				   axis10 	label=(f=zapf h=3 'Age of LBWI (days)' ) value=(f=zapf h=1.0) split="*" order= (-1 to 62 by 1) minor=none offset=(0 in, 0 in);

   				axis2 	label=(f=zapf h=3 a=90 &description) value=(f=zapf h=2) order=&order;
            
        		proc gplot data=&data._no_tx_&var gout=wbh.graphs;
         			title2 h=3.5 justify=center &description -LBWI without transfustion (n=&no);
         			title3 h=3.5 justify=center Longitudinal models (means and 95% CI);
						
	         		plot  &var*day &var*day1 estimate*day/ overlay annotate= anno_mixed_&data._no_tx_&var haxis = axis10 vaxis = axis2  nolegend;

         			note h=2 m=(7pct, 10 pct) "Age:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format day t_axis_no_tx. &var 5.0;
         		run;

        		proc gplot data=&data._tx_&var gout=wbh.graphs;
         			title2 h=3.5 justify=center &description -LBWI with transfustion (n=&yes);
         			title3 h=3.5 justify=center Longitudinal models (means and 95% CI);
					
	         	plot  &var*daytx &var*daytx1 estimate*daytx/ overlay annotate= anno_mixed_&data._tx_&var haxis = axis1 vaxis = axis2  nolegend;

         			note h=2 m=(7pct, 10 pct) "Days:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format daytx t_axis_tx. &var 5.0;
         		run;
	%let x = &x + 1;	
	%end;
%mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = portrait;
        	
				%make_plots(data=hwl); run;

       
        	ods ps file = "hwl_tx.ps";
        	ods pdf file = "hwl_tx.pdf" startpage=no;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s /*whole*/ nofs;
						list igout;
						treplay 1:1 2:2;
						treplay 1:3 2:4;
						treplay 1:5 2:6;
					run;

        	ods pdf close;
        	ods ps close;
  quit;
	




