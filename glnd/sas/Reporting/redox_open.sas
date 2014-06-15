
data blood_in;
	set glnd_ext.redox;
run;

proc print data = blood_in;
	var id CysSS_concentration;
run;

proc sort data= blood_in;
by id visit replicate;
run;


proc means data=blood_in mean min max;
	by id visit;
	OUTPUT OUT=blood_out mean=;
run;

data blood_plot;
	set blood_out;
	where id ~= 32006; * filter out a dropped patient whose blood was analyzed ;

		visit2= visit - .3 + .6*uniform(234);		

	log_gsh_conc = log(gsh_concentration);
	log_gssg_conc = log(gssg_concentration);

	format Cys_concentration 3.;

	*keep visit id visit2 GSH_CSSG Cys_CySS GSH_concentration GSSG_concentration Cys_concentration CysSS_concentration;
run;



goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

					/* Set up symbol for Boxplot */
					symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=2;
					/* Set up Symbol for Data Points */
					symbol2 ci=blue value=dot h=1;


%macro make_blood_plots; 
	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 
	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let x= 1;
  	%do %while (&x < 7);

 		%if &x = 1 %then %do; 	%let variable =GSH_GSSG_redox; %let description = f=zapf 'GSH/GSSG redox (mV)';
							%let scale = /*order = (-180 to -70 by 10)*/ minor=(number=3); %let y1 = -155; %let y2= -121; %let pic= 'A)'; 
							%let description1 = f=zapf 'G S H / G S S G'; %end; 

		%if &x = 2 %then %do; 	%let variable =Cys_CySS_redox; %let description = f=zapf 'Cys/CySS redox (mV) '; 
							%let scale = /*order = (-110 to -20 by 10)*/ minor=(number=4); %let y1 = -98; %let y2= -62; %let pic= 'B)'; 
							%let description1 = f=zapf 'C y s / C y S S';%end; 

		%if &x = 3 %then %do; 	%let variable =log_gsh_conc; %let description = f=zapf 'ln[GSH concentration) ('f=greek h = 4 'm' h=3 f=zapf 'M)] ';
							%let scale = /*order = (0 to 5 by 0.5)*/ minor=(number=4); %let y1 = -.105; %let y2= 1.06; %let pic= 'C)'; /* %let y1 = .9; %let y2= 2.9; %let pic= 'C)'; */
							%let description1 = f=zapf 'G S H';%end; 

		%if &x = 4 %then %do; 	%let variable =log_gssg_conc; %let description = f=zapf 'ln[GSSG concentration ('f=greek h = 4 'm' h=3 f=zapf 'M)] ';
							%let scale = /*order = (0 to 0.2 by 0.05)*/ minor=(number=4); %let y1 = -4.61; %let y2= -2.3; %let pic= 'D)'; /*%let y1 = 0.01; %let y2= 0.1; %let pic= 'D)';*/
							%let description1 = f=zapf 'G S S G';%end; 

		%if &x = 5 %then %do; 	%let variable =Cys_concentration; %let description = f=zapf 'Cys concentration ('f=greek h = 4 'm' h=3 f=zapf 'M) '; 
							%let scale = /*order = (0 to 17 by 1)*/ minor=(number=1); %let y1 = 4; %let y2= 16; %let pic= 'E)';
							%let description1 = f=zapf 'C y s';%end; 

		%if &x = 6 %then %do; 	%let variable =CysSS_concentration; %let description = f=zapf 'CysSS concentration ('f=greek h = 4 'm' h=3 f=zapf 'M) ';
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 30; %let y2= 85; %let pic= 'F)';
							%let description1 = f=zapf 'C y s S S';%end; 

		proc sort data=blood_plot;by visit id;run;

		* get 'n' at each day;
		proc means data=blood_plot ;
			class visit;
			var &variable;
			output out = s_&variable n(&variable) = num_obs;
		run;

		* populate 'n' annotation variables ;
		%do i = 0 %to 28;
			data _null_;
				set s_&variable;
				where visit = &i;
				call symput( "n_&i",  compress(put(num_obs, 3.0)));
			run;
		%end;

		proc format; 
		 	value time_axis   -1=" " 1=" " 0 = "0*(&n_0)"  2=" " 3="3*(&n_3)" 4=" " 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
			                   11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
			                   21 = "21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" ";               
		run;

		title1 h=3 justify=left &pic;
		title2 h=3 justify=center &description;
		title3 h=2 justify=center "(mean of each patient's two replicate samples shown)";

		axis1 	label=(f=zapf h=2 'Day' ) value=(f=zapf h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(f=zapf h=2 a=90 &description1  ) 	value=(f=zapf h=2) &scale ;

		data anno;
			set blood_plot;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;;	
		run;

		proc gplot data=blood_plot gout=glnd_rep.graphs;
			plot &variable*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2 annotate=anno nolegend;
			format visit time_axis.; 
		run;	

%let x = &x + 1;
%end;

%mend make_blood_plots;

	*ods pdf file = "S:\Eli_Rosenberg\shared GLND\Bloods\result\Yi_Ruosha\blood_july31.pdf";
		%make_blood_plots run;
	*ods pdf close;


	* spit out 3 one-page PDF files so that George's program can handle them ;

	goptions rotate = portrait;

	ods ps file = "/glnd/sas/reporting/redox1.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot1;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/redox2.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot2 2:gplot3;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/redox3.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot4  2:gplot5;
		run;
	ods ps close;
quit;

