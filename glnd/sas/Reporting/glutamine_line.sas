options orientation=landscape;

data glutamine_full;
	set glnd_ext.glutamine;
	keep id GlutamicAcid Glutamine day;
run;

proc means data=glutamine_full n min max;
var glutamine glutamicacid;
run;

proc sort data=glutamine_full; by id; run;
proc sort data= glnd.george; by id; run;

 data glutamine_full;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
			;
	by id;
	center=floor(id/10000);
	if ~has_glutamine then delete; 
run;

proc print;
where id in(12115,12207);
*where glutamine>1000 and treatment=2 and center=1;
run;

goptions reset=all rotate=landscape gunit=pct device=jpeg ftitle=triplex ftext=triplex hby = 3;


%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 

* i = treatment group number. the unix macro engine cannot handle nested loops and thus you must feed it the treatment number in two separate macro calls;
%macro line_plot (data, center, trt, var); 
        %if &center=1 %then %do; %let site=Emory; %end;
        %if &center=2 %then %do; %let site=Miriam; %end;
        %if &center=3 %then %do; %let site=Vanderbilt; %end;
        %if &center=4 %then %do; %let site=Colorado; %end;
        %if &center=5 %then %do; %let site=Wisconsin; %end;
        %if &trt=1 %then %do; %let treatment=AG-PN; %end;
        %if &trt=2 %then %do; %let treatment=STD-PN; %end;
        %if &var=glutamine %then %do; %let desciption=Glutamine; %let laby='Glutamine (' f=greek 'm' f=triplex 'm)'; %let scale=(0 to 2500 by 100); %end;
        %if &var=glutamicacid %then %do; %let desciption=Glutamic Acid; %let laby='Glutamic Acid (' f=greek 'm' f=triplex 'm)'; %let scale=(0 to 2500 by 100); %end;

        data sub; 
            set &data;
            where center=&center and treatment=&trt;
        run;

		proc sort data=sub; by day id; run;
	
		proc means data= sub n min max;
			class day;
			var &var;
			output out = s_&var n(&var) = num_obs;
		run;

		* populate macro variables with sample sizes at each day;
		%do i = 0 %to 28;
				data _null_;
					set s_&var;
					where day = &i;
					call symput( "n_&i",  compress(put(num_obs, 3.0)));
				run;
		%end;

		proc format; 
		 	value dt  -1=" " 0="0*(&n_0)" 1 = " "  2=" " 3="3*(&n_3)" 4=" " 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
			                   11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
			                   21 = "21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" ";               
		run;

		title1 h=3 justify=center "&desciption -- Line Plots by Center and Treatment";
		title2 h=3 justify=center "Center=&site treatment=&treatment";
        
        symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=100; 

		axis1 	label=(h=2 'Day' ) split="*" value=(h=2)  order= (-1 to 29 by 1) minor=none ;
		axis2 	label=(h=2 a=90 &laby) value=(h=2) order=(0 to 2500 by 100) minor=(number=3);
		
		proc gplot data=sub gout=glnd_rep.graphs;
		note h=2 m=(7pct, 8.5 pct) "Age:" ;
		note h=2 m=(7pct, 6 pct) "(n)" ;
		plot &var*day=id/ overlay haxis = axis1 vaxis = axis2 nolegend; format day dt. &var 5.0;
	run;

%mend line_plot;

%line_plot (glutamine_full, 1,1, glutamine); 
%line_plot (glutamine_full, 1,2, glutamine); 

%line_plot (glutamine_full, 2,1, glutamine); 
%line_plot (glutamine_full, 2,2, glutamine); 

%line_plot (glutamine_full, 3,1, glutamine); 
%line_plot (glutamine_full, 3,2, glutamine); 

%line_plot (glutamine_full, 4,1, glutamine); 
%line_plot (glutamine_full, 4,2, glutamine); 

%line_plot (glutamine_full, 5,1, glutamine); 
%line_plot (glutamine_full, 5,2, glutamine); 

%line_plot (glutamine_full, 1,1, glutamicacid); 
%line_plot (glutamine_full, 1,2, glutamicacid); 
%line_plot (glutamine_full, 2,1, glutamicacid); 
%line_plot (glutamine_full, 2,2, glutamicacid); 
%line_plot (glutamine_full, 3,1, glutamicacid); 
%line_plot (glutamine_full, 3,2, glutamicacid);
%line_plot (glutamine_full, 4,1, glutamicacid); 
%line_plot (glutamine_full, 4,2, glutamicacid);
%line_plot (glutamine_full, 5,1, glutamicacid); 
%line_plot (glutamine_full, 5,2, glutamicacid); 


ods listing close;    
            goptions reset=all;   
           	ods pdf file = "line_plot.pdf" /*startpage=no*/;
					proc greplay igout =glnd_rep.graphs tc=sashelp.templt template=l2r2s /*whole*/ nofs;
						list igout;
						treplay 1:1  2:3  3:2  4:4; 
						treplay 1:5  2:7  3:6  4:8; 
						treplay 1:9  3:10 ; 
						treplay 1:11 2:13 3:12 4:14; 
						treplay 1:15 2:17 3:16 4:18;
						treplay 1:19 3:20;
					run;

        	ods pdf close;
  quit;



