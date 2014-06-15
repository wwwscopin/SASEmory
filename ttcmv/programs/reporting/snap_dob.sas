options nodate orientation=portrait;
libname wbh "/ttcmv/sas/data";	
libname gcx "/ttcmv/sas/programs";

data wbh.snap;
	merge cmv.plate_010(keep=id DateSnapData SNAP1Score) 
   cmv.plate_011(keep=id SNAP2Score)
	cmv.plate_012(keep=id SNAP3Score SNAPTotalScore); by id;
	if SNAP1Score=. then SNAP1Score=0;
	if SNAP2Score=. then SNAP2Score=0;
	if SNAP3Score=. then SNAP3Score=0;
	if SNAPTotalScore=. then SNAPTotalScore=SNAP1Score+SNAP2Score+SNAP3Score;
	if DateSnapData=. then delete;
	center=floor(id/1000000);
	format center center.;
run;

proc print;run;


data snap;
	set wbh.snap; output;
	set wbh.snap;	center=8; output;
run;

proc sort data=snap nodupkey; by id center; run;

data snap;
	set snap;
	center1= center - .1 + .2*uniform(613);
run;

proc means data=wbh.snap;
	class center;
	var SNAPTotalScore;
	output out=snap_mean mean(SNAPTotalScore)=mean stddev(SNAPTotalScore)=std median(SNAPTotalScore)=median 
	min(SNAPTotalScore)=min max(SNAPTotalScore)=max;
run;

data snap_mean;
	set snap_mean;
	if center=. then center=8;
	drop _type_;
	rename _freq_=n;
run;

proc sort; by center;run;

 
         goptions reset=all  gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

          
         					/* Set up Symbol for Data Points */
        
       	 *symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8; 
       	 symbol1 interpol=boxt mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8; 	 
				symbol2 ci=blue value=circle h=1;         
     
         %macro make_plots(data=snap); 
     
					%let variable=SNAPTotalScore;	%let description = f=zapf "Total SNAP Score"; %let scale=; 
	     
         
          		* get 'n' at each day;
         		proc means data=&data noprint;

         			class center;
         			var &variable;
         			output out = sizes_&data n(&variable) = num_obs;
         		run;

         	   %let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_8= 0;  
         
         		* populate 'n' annotation variables ;
         		%do i = 1 %to 8;
         			data _null_;
         				set sizes_&data;
         				where center = &i;
         				call symput( "n_&i",  compress(put(num_obs, 3.0)));
         			run;
         		%end;
         
         		proc format; 
         		value site   0=" " 1="Midtown*(&n_1) " 2 = "Grady*(&n_2)" 3 = "Northside*(&n_3)"  8="Overall*(&n_8)" 9=" ";              
         		run;
         

	
         		title h=3.5 justify=center "Total SNAP Score At Birth (n=&n_8)";
			  		axis1 	label=(f=zapf h=3 'Center' ) value=(f=zapf h=2.0) split="*" order= (0 to 3 by 1 8 to 9 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=3 a=90 &description) order=(0 to 25 by 5) value=(f=zapf h=2) &scale ;
         
             
        		proc gplot data=&data gout=gcx.graphs;

         			plot   &variable*center &variable*center1/overlay haxis = axis1 vaxis = axis2  /*nolegend*/;

         			note h=2 m=(7pct, 10 pct) "Center:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format center site. &variable 5.0;
         		run;	
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout=gcx.graphs  nofs; delete _ALL_; run;
        

      	
				%make_plots(data=snap); run;
        ods listing close;        

        	ods ps file = "snap.ps";
        	ods pdf file = "snap.pdf" style=journal startpage=yes;
					proc greplay igout =gcx.graphs tc=sashelp.templt template=v2s /*whole*/ nofs;
						list igout;
						treplay 1:1; 
					run;

				*ods pdf style=journal;

         		title h=3.5 justify=center "Total SNAP Score At Birth" ;
				proc print data=snap_mean noobs label split="*" style(data)=[just=center];

					var center n mean std median min max;
					format center center.  mean std 4.1 ;
					label 
							center="Center"
							n="Num of LBWIs*"
							mean="Mean"
							median="Median"
							std="Standard Error*"
							min="Minimum"
							max="Maximum"
							;
				 run;

        	ods pdf close;
        	ods ps close;
  quit;
	




