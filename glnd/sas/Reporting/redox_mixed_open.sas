
data blood_in;
	merge glnd_ext.redox glnd.status(keep=id in=tmp); by id;
	if tmp;
run;

proc sort data= blood_in;
by id visit replicate;
run;

data tmp;
	set blood_in;
	where visit=0 or id=42016;
	keep id visit day GSH_GSSG_redox Cys_CySS_redox GSH_concentration GSSG_concentration Cys_concentration CysSS_concentration;
run;


proc means data=blood_in mean min max noprint;
	by id visit;
	OUTPUT OUT=blood_out mean=;
run;


proc print data=blood_in;
    where id= 32064;
run;
 
data blood_plot;
	set blood_out;
	where id ~= 32006; * filter out a dropped patient whose blood was analyzed ;

		visit2= visit - .3 + .6*uniform(234);		

	log_gsh_conc = log(gsh_concentration);
	log_gssg_conc = log(gssg_concentration);

	format Cys_concentration 3.;
	
    if Cys_concentration>200 then Cys_concentration=.;

	*keep visit id visit2 GSH_CSSG Cys_CySS GSH_concentration GSSG_concentration Cys_concentration CysSS_concentration;
run;





goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
					colors = (black red) /*ftitle=Arial*/ ftext=cent  /*fby =Arial*/ hby = 3;

	/* Set up symbol for Boxplot */
	symbol2 interpol=none mode=exclude value=circle cv=blue height=1 width=1;
	/* Set up Symbol for Data Points */
	symbol1 i=j ci=red value=dot h=2 w=2;


%macro make_blood_plots; 
	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 
	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let l= 1;
  	%do %while (&l < 7);

 		%if &l = 1 %then %do; 	%let variable =GSH_GSSG_redox; %let description = f=cent 'GSH/GSSG redox (mV)';
							%let scale = /*order = (-180 to -70 by 10)*/ minor=(number=3); %let y1 = -155; %let y2= -121; %let pic= 'A)'; 
							%let description1 = f=cent 'G S H / G S S G'; %end; 

		%if &l = 2 %then %do; 	%let variable =Cys_CySS_redox; %let description = f=cent 'Cys/CySS redox (mV) '; 
							%let scale = /*order = (-110 to -20 by 10)*/ minor=(number=4); %let y1 = -98; %let y2= -62; %let pic= 'B)'; 
							%let description1 = f=cent 'C y s / C y S S';%end; 

		%if &l = 3 %then %do; 	%let variable =log_gsh_conc; %let description = f=cent 'ln[GSH concentration) ('f=greek h = 4 'm' h=3 f=cent 'M)] ';
							%let scale = /*order = (0 to 5 by 0.5)*/ minor=(number=4); %let y1 = -.105; %let y2= 1.06; %let pic= 'C)'; /* %let y1 = .9; %let y2= 2.9; %let pic= 'C)'; */
							%let description1 = f=cent 'G S H';%end; 

		%if &l = 4 %then %do; 	%let variable =log_gssg_conc; %let description = f=cent 'ln[GSSG concentration ('f=greek h = 4 'm' h=3 f=cent 'M)] ';
							%let scale = /*order = (0 to 0.2 by 0.05)*/ minor=(number=4); %let y1 = -4.61; %let y2= -2.3; %let pic= 'D)'; /*%let y1 = 0.01; %let y2= 0.1; %let pic= 'D)';*/
							%let description1 = f=cent 'G S S G';%end; 

		%if &l = 5 %then %do; 	%let variable =Cys_concentration; %let description = f=cent 'Cys concentration ('f=greek h = 4 'm' h=3 f=cent 'M) '; 
							%let scale = /*order = (0 to 17 by 1)*/ minor=(number=1); %let y1 = 4; %let y2= 16; %let pic= 'E)';
							%let description1 = f=cent 'C y s';%end; 

		%if &l = 6 %then %do; 	%let variable =CysSS_concentration; %let description = f=cent 'CysSS concentration ('f=greek h = 4 'm' h=3 f=cent 'M) ';
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 30; %let y2= 85; %let pic= 'F)';
							%let description1 = f=cent 'C y s S S';%end; 

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
		title3 h=2.5 justify=center "(mean of each patient's two replicate samples shown)";
		title4 h=2 f=triplex justify=center 'Longitudinal model (means and 95% CI)';

		axis1 	label=(f=cent h=2 'Day' ) value=(f=cent h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(f=cent h=2 a=90 &description1  ) 	value=(f=cent h=2) &scale ;


************************************************************************************************************;
************************************************************************************************************;

		proc mixed data = blood_plot empirical covtest;
			class id visit ; * &source;
		
			model &variable = visit / solution ; * &source	day*&source/ solution;
			repeated visit / subject = id type = cs;
			lsmeans visit / cl ;
			ods output lsmeans = lsmeans_&l;
		run;


		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = blood_plot out=tmp; by visit; run;
		proc sort data = lsmeans_&l; by visit; run;

		data blood_plot1 ;
			merge tmp lsmeans_&l;	by visit;
		run;
			


		DATA anno_mixed_&l; 
			set lsmeans_&l;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;;	
			

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=visit; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red';  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red';  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=visit-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red'; OUTPUT;
			  X=visit+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red'; OUTPUT;
			  X=visit;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;

	
		proc gplot data=blood_plot1 gout=glnd_rep.graphs;
			plot estimate*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2 annotate=anno_mixed_&l nolegend;
			format visit time_axis. estimate 5.0; 
		run;	


		proc print data=blood_plot1; 
		
			var id visit visit2 estimate &variable;
		run;
%let l = %eval(&l + 1);
%end;

%mend make_blood_plots;

	*ods pdf file = "S:\Eli_Rosenberg\shared GLND\Bloods\result\Yi_Ruosha\blood_july31.pdf";
		%make_blood_plots run;
	*ods pdf close;


goption reset=all;

	* spit out 3 one-page PDF files so that George's program can handle them ;


filename output 'redox1.eps';
goptions rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/redox1.ps";
	ods pdf file = "/glnd/sas/reporting/redox1.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot1;
		run;
	ods pdf close;
	ods ps close;

filename output 'redox2.eps';
goptions rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/redox2.ps";
	ods pdf file = "/glnd/sas/reporting/redox2.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot2 2:gplot3;
		run;
	ods pdf close;
	ods ps close;

filename output 'redox3.eps';
goptions rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/redox3.ps";
	ods pdf file = "/glnd/sas/reporting/redox3.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot4  2:gplot5;
		run;
	ods pdf close;
	ods ps close;
quit;

