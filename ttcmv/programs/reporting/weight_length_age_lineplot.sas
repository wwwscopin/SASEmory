libname wbh "/ttcmv/sas/programs";	


data _null_;
	set cmv.completedstudylist;
	call symput("total", compress(_n_));
run;

data hwl;
	set cmv.plate_015;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	if hbDate=. then Hbdate=BloodCollectDate;
	if hctDate=. then HctDate=BloodCollectDate;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate Hct  HctDate  Hb  HbDate;
	rename DFSEQ=day;
run;

proc sql;
	create table hwl as 
	select a.*, dob, day - .3 + .6*uniform(613) as day1
	from hwl as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;

data qc_hwl;
	set hwl;
	dw=dif(weight); dh=dif(headcircum); dl=dif(htlength);
	keep id day Weight HeadCircum  HtLength dw dh dl;
run;

proc print; 
where day not in(1,60) and (abs(dw)>500 or abs(dh)>40 or abs(dl)>10);
run;
        
goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
				colors = (black red) ftitle="Times" ftext="Times"  fby ="Times" hby = 3;

          
/* Set up Symbol for Data Points */
symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=500;  
   
%macro make_plots(data=hwl); 

proc greplay igout= wbh.graphs nofs; delete _ALL_; run;
%let n_1= 0; %let n_4= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0; %let n_40= 0; %let n_60= 0; 

%let x=1;
%do %while (&x <6);
    %if &x = 1 %then %do; 	%let variable =Weight; %let description = 'Weight (g)'; %let pic= 'A)'; %end;
    %if &x = 3 %then %do; 	%let variable =HeadCircum; %let description = 'Head Circumference (cm)'; %let pic= 'A)'; %end;        
    %if &x = 2 %then %do; 	%let variable =HtLength; %let description = 'Length (cm)'; %let pic= 'A)'; %end;
    %if &x = 4 %then %do; 	%let variable =Hb; %let description = 'Hemoglobin (g/dL)'; %let pic= 'A)'; %end;
    %if &x = 5 %then %do; 	%let variable =Hct; %let description = 'Hematocrit (%)'; %let pic= 'A)'; %end;



	* get 'n' at each day;
		proc means data=&data noprint;
    			class day;
    			var &variable;
     			output out = sizes_&data n(&variable) = num_obs;
  		run;

	* populate 'n' annotation variables ;
   		%do i = 0 %to 62;
    			data _null_;
    				set sizes_&data;
     				where day = &i;
     				call symput( "n_&i",  compress(put(num_obs, 3.0)));
     			run;
     		%end;
         
     		proc format; 
     		 	value time_axis   
						-1=" " 0=" " 1 = "1*(&n_1)"  2=" " 3=" " 4="4*(&n_4)" 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
    			     11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
    			     21="21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" "
					  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
    					41=" " 40="40*(&n_40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
   				   51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" " 60="60*(&n_60)" ;        
        run;
         
    title h=3.5 justify=center &description (n=&total);    
    axis1 	label=(h=3 'Age of LBWI (days)' ) value=(h=1.0) split="*" order= (-1 to 62 by 1) minor=none offset=(0 in, 0 in);
    axis2 	label=(h=3 a=90 &description) value=(h=2) ;
    
    %if &x = 1 %then %do;
    axis2 	label=(h=3 a=90 &description) value=(h=2) order=(0 to 3200 by 200);
    %end;
                  
         		*proc gplot data=&data gout=cmv.graphs;
        		proc gplot data=&data gout=wbh.graphs;

         			plot   &variable*day=id/ overlay haxis = axis1 vaxis = axis2  nolegend;

         			note h=2 m=(7pct, 10 pct) "Age:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format day time_axis. &variable 5.0;
         		run;
	%let x = &x + 1;	
	%end;
%mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
 
    
        goptions rotate = portrait;
        	
		%make_plots(data=hwl); run;

%let path=/ttcmv/sas/output/qc_lineplots/;

ods listing close;       
       goptions reset=all;
        	ods ps file = "&path.hwl.ps";
        	ods pdf file = "&path.hwl.pdf";
					proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s /*whole*/ nofs;
						list igout;
						treplay 1:1; 
						treplay 1:2 2:3; 
						treplay 1:4 2:5; 
					run;

        	ods pdf close;
        	ods ps close;
  quit;
	




