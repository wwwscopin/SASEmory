libname wbh "/ttcmv/sas/data";


data all_pat;
	set cmv.valid_ids;
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;


data dob0;
   set cmv.LBWI_Demo;
   keep id LBWIDOB;
	rename LBWIDOB=dob;
run;

proc sql;
	create table dob as 
	select a.*
	from dob0 as a, all_pat as b
	where a.id=b.id
;

data snap1;
	merge cmv.plate_010(keep=id DateSnapData SNAP1Score) 
   cmv.plate_011(keep=id SNAP2Score)
	cmv.plate_012(keep=id SNAP3Score SNAPTotalScore); by id;
	if SNAP1Score=. then SNAP1Score=0;
	if SNAP2Score=. then SNAP2Score=0;
	if SNAP3Score=. then SNAP3Score=0;
	if SNAPTotalScore=. then SNAPTotalScore=SNAP1Score+SNAP2Score+SNAP3Score;
	if DateSnapData=. then delete;
	day=0;
	keep id day SNAPTotalScore DateSnapData;
	rename SNAPTotalScore=SNAP2Score DateSnapData=DOLdate;
run;

proc sort; by id day;run;

data snap;
	set cmv.snap2;
	keep id DOLdate SNAP2Score DFSEQ;
	RENAME DFSEQ=day;
run;

proc sort; by id day;run;

data snap;
	merge snap snap1; by id day;
run;

data snap;
	merge dob(in=tmp) snap; by id;
	age=DOLdate-dob;
	if dob=. then delete;
   day1= day - .3 + .6*uniform(613);	
	if DOLdate=. then delete;
	if tmp;
	if day>60 then do;
			if 50<=age then day=60;
			else if 35<=age<50 then day=40;
			else if 25<=age<35 then day=28;
			else if 18<=age<25 then day=21;
			else if 11<=age<18 then day=14;
			else if 6<=age<11 then day=7;
			else if 1<=age<6 then day=4;
			else day=0;
	end;
run;

proc means data=snap;
	class day;
	var	age;
	output out=range_day min(age)=min_day max(age)=max_day;
run;
proc print data=range_day;run;

data snap;
	set snap;
where day^=0; 
run;

data snap_id;
	set snap;
	keep id;
run;
proc sort nodupkey; by id; run;

%let n=0;

data _null_;
	set snap_id;
	call symput("n", compress(_n_));
run;

proc sort data=snap nodupkey;by id day;run;

%macro anno(data=snap);
		proc mixed data = &data empirical covtest;
			class id day ; * &source;
		
			model SNAP2Score = day / solution ; * &source	day*&source/ solution;
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


			/* 
					draw a light gray rectangle ;
					function = 'move'; x = -0.5; y = 11.4; output;
					function = 'BAR'; x = 60.5; y = 16.1; color = 'ligr'; style = 'solid'; line= 0; output;
			*/

			
			 %let mycolor='blue'; 
	
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

%anno(data=snap);quit;




         
         goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
         	
         					/* Set up symbol for Boxplot */
         					symbol1 interpol=none mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8;
         
         					/* Set up Symbol for Data Points */
         					symbol2 i=none ci=black value=circle h=1 w=1;

         
         					/* Set up Symbol for Data Points */
         					symbol3 i=j ci=blue value=dot h=1 w=4;

         
     
         %macro make_plots(data=snap); 
     
         		%let variable =SNAP2Score; %let description = f=zapf "SNAP II Score"; %let scale=; 
	    
         
          		* get 'n' at each day;
         		proc means data=&data noprint;

         			class day;
         			var &variable;
         			output out = sizes_&data n(&variable) = num_obs;
         		run;

         	%let n_0= 0; %let n_4= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0; %let n_40= 0; %let n_60= 0; %let n_75= 0; 
         
         		* populate 'n' annotation variables ;
         		%do i = 0 %to 62;
         			data _null_;
         				set sizes_&data;
         				where day = &i;
         				call symput( "n_&i",  compress(put(num_obs, 3.0)));
         			run;
         		%end;
         
         		proc format; 
         		 	value time_axis   -1=" " 1=" " /*0 = "0*(&n_0)"*/ 0=" " 2=" " 3=" " 4="4*(&n_4)" 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 
       											10=" " 11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
         			                  21="21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" "
												  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
												  41=" " 40="40*(&n_40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
												  51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "
												  60="60*(&n_60)"; /*63=" " 64=" " 65=" " 66=" " 67=" " 68=" " 69=" " 70=" " 71=" " 72=" " 73=" " 74=" " 													75="75*(&n_75)" 76=" ";*/
                
         		run;
         

	
         		title1 h=3.5 justify=center &description (n=&n);
	       		title2 h=3.5 justify=center Longitudinal models (means and 95% CI);

         
         		axis1 	label=(f=zapf h=3 'LBWI Age (Days)' )  split="*"  value=(f=zapf h=1.0) order= (-1 to 62 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=3 a=90 &description) order=(0 to 80 by 5) value=(f=zapf h=2) &scale ;
         
             
         		*proc gplot data=&data gout=cmv.graphs;
        		proc gplot data=&data gout=wbh.graphs;

         			plot  &variable*day &variable*day1 estimate*day/ overlay annotate= anno_mixed_&data haxis = axis1 vaxis = axis2  nolegend;

         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format day time_axis. &variable 3.0;
         		run;	
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = portrait;
        	%make_plots(data=snap);  

       
        	ods ps file = "snap_mixed.ps";
        	ods pdf file = "snap_mixed.pdf" startpage=no;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s /*whole*/ nofs;
						list igout;
						treplay 1:1; 
						treplay 1:2 2:3; 
						*treplay 1:3; 
					run;

	ods pdf style=journal;
	title1	height=3 f=zapf 'SNAP II score longitudinal model-based means';

		* now make a table of the means and 95% CI for sofa score on days 0, 7, 14;
		data snap_mixed;
				merge lsmeans_snap(keep = estimate upper lower day) 
						 sizes_snap(keep=day num_obs rename=(num_obs=num_all))
							range_day(keep=day min_day max_day);
				by day;
			

			where day^=0;
			if day=. then delete;
			dday=strip(put(day, 3.0)) || "[" || strip(put(min_day, 3.0)) || "-" || strip(put(max_day, 3.0))|| "]";
 			snap = strip(put(estimate, 5.1)) || " (" || strip(put(lower, 5.1)) || ", " || strip(put(upper, 5.1))|| ")";
				
			label
				dday = "Day"
				snap = "SNAP II Score (95% CI)"
			;
		
		   keep dday num_all snap;
		run;

			proc print data = snap_mixed noobs label split="*" style(data) = [just=center];
				var dday;
				var num_all/style(data) = [cellwidth=1in just=center];
				var snap;
				label num_all="No. of Patients";
			run;

ODS ESCAPECHAR='^';
ODS pdf TEXT='^S={LEFTMARGIN=0.6in RIGHTMARGIN=0.6in}
*Model-based mean:  Estimated means taking into consideration the fact that not all patients have been measured at 
all time intervals. These are maximum likelihood estimates obtained using a repeated measures model.';
	
		ods pdf close;

