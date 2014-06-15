*options ORIENTATION="LANDSCAPE";
options ORIENTATION="PORTRAIT";
libname wbh "/ttcmv/sas/programs";	

data hb0;
	set cmv.plate_015;
	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if HbDate=. then delete;
	if hb>25 then hb=.;
	keep id HbDate Hb DFSEQ;
run;

/*
data all_pat;
	set cmv.valid_ids;
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;
*/

data all_pat;
	set cmv.comp_pat;
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;

proc sql;
	create table hb0 as 
	select a.*
	from hb0 as a, all_pat as b
	where a.id=b.id;
quit;

proc sort data=hb0 nodupkey;by id HbDate;run;

proc sql;
create table hb as
select a.*  , LBWIDOB as DateOfBirth 
from 
hb0 as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;
quit;

data hb;
	set hb; by id HbDate;
	if DateOfBirth=. then 
	if first.id then do; base=HbDate; DateOfBirth=base; retain base; end;
	else DateOfBirth=base;
	day0=Hbdate-DateOfBirth;
	if 50<=day0 then day=60;
	else if 35<=day0<50 then day=40;
	else if 32<=day0<35 then day=28;
	else if 6<=day0<32 then day=round(day0/7)*7;
	else if day0>=2 then day=4;
	else day=0;
	drop base;
run;


data rbc;
	set cmv.plate_031;
	rbc_txt0=HMS(scan(rbc_TxStartTime,1,":"), scan(rbc_TxStartTime,2,":"), 0 ); 
	rbc_txt1=HMS(scan(rbc_TxEndTime,1,":"), scan(rbc_TxEndTime,2,":"), 0 ); 
	rbc_txt=rbc_txt1-rbc_txt0; if rbc_txt<0 then rbc_txt=rbc_txt+24*3600;
	keep id BodyWeight DateHb DateTransfusion Hb HbHctTest Hct TimeHbHct rbcVolumeTransfused rbc_TxEndTime rbc_TxStartTime rbc_txt;
run;

proc sort data=rbc; by id;run;

data hb;
	merge hb(in=ttt) rbc(keep=id DateTransfusion in=tmp);by id;
	if ttt;
	if tmp then trans=1; else trans=0;
run;

proc sort data=hb nodupkey;by id HbDate;run;
proc sort data=hb out=hb1 nodupkey; by id;run;

title "wbh";
proc print;run;

proc means data=hb1;
	class trans;
	var id;
	output out=n_id n(id)=n;
run;

data _null_;
	set n_id;
	if trans=0 then call symput("n_no", compress(put(n,3.0)));
	if trans=1 then call symput("n_yes",compress(put(n,3.0)));
run;

%let n_total=%eval(&n_yes+&n_no);

proc means data=hb;
	class day;
	var	day0;
	output out=range_day min(day0)=min_day max(day0)=max_day;
run;
proc print data=range_day;run;

data hb_plot;
   	set hb;
   	* jitter time for plotting;
   	day1= day - .3 + .6*uniform(613);	
run;

proc sort data=hb_plot nodupkey; by id day;run;

data hb_plot1;
	set hb_plot;
where day=0;
keep id;
run;

proc sql;
	create table no_hb as 
	select id
	from all_pat
	except 
	select * 
	from hb_plot1;

proc print data=no_hb;run;


data trans notrans;
	set hb_plot;
	if trans=0 then output notrans;
	if trans=1 then output trans;
run;

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
					function = 'move'; x = -0.5; y = 11.4; output;
					function = 'BAR'; x = 60.5; y = 16.1; color = 'ligr'; style = 'solid'; line= 0; output;

			
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

%anno(data=hb_plot);
%anno(data=trans);
%anno(data=notrans);



         
         goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
        
     
         %macro make_plots(data=trans); 
     
         		%let variable =hb; %let description = f=zapf "Hemoglobin(g/dL)"; %let scale=; 
					%let y1 = 11.4; %let y2= 16.1; %let pic= " "; 

          		%if &data = trans %then %do; 	 %let description = f=zapf "Hemoglobin(g/dL)- With Transfusion";
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let pic= 'A)'; %end;
          		%if &data = notrans %then %do; 	%let description = f=zapf "Hemoglobin(g/dL)- Without Transfusion";
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let pic= 'B)'; %end;
     
         
          		* get 'n' at each day;
         		proc means data=&data noprint;

         			class day;
         			var &variable;
         			output out = sizes_&data n(&variable) = num_obs;
         		run;

         	%let n_0= 0; %let n_4= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0; %let n_40= 0; %let n_60= 0; 
         
         		* populate 'n' annotation variables ;
         		%do i = 0 %to 62;
         			data _null_;
         				set sizes_&data;
         				where day = &i;
         				call symput( "n_&i",  compress(put(num_obs, 3.0)));
         			run;
         		%end;
         
         		proc format; 
         		 	value time_axis   -1=" " 1=" " 0 = "0*(&n_0)"  2=" " 3=" " 4="4*(&n_4)" 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
         			                  11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
         			                  21="21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" "
												  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
												  41=" " 40="40*(&n_40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
												  51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "
												  60="60*(&n_60)" ;
                
         		run;
         
					title1 h=3 justify=left &pic;
	
         		title2 h=3.5 justify=center &description (n=&n_total);
					%if &data=trans %then %do; title2 h=3.5 justify=center &description (n=&n_yes); %end;
					%if &data=notrans %then %do; title2 h=3.5 justify=center &description (n=&n_no); %end;
         		*title3 h=3.5 justify=center Longitudinal models (means and 95% CI);

         
         		axis1 	label=(f=zapf h=3 'Day' ) value=(f=zapf h=0.9) split="*" order= (-1 to 62 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=3 a=90 &description) order=(0 to 25 by 5) value=(f=zapf h=2) &scale ;
          
         					/* Set up Symbol for Data Points */
         					symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=500;         
             

         		*proc gplot data=&data gout=cmv.graphs;
        		proc gplot data=&data gout=wbh.graphs;
						plot  &variable*day=id/ overlay haxis = axis1 vaxis = axis2  nolegend;
         			*plot  &variable*day &variable*day1 estimate*day/ overlay annotate= anno_mixed_&data haxis = axis1 vaxis = axis2  nolegend;

         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format day time_axis. &variable 3.0;
         		run;	
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = portrait;
        	%make_plots(data=hb_plot);  
        	%make_plots(data=trans);         	
				%make_plots(data=notrans); run;
       
        	ods ps file = "hb_mixed_line.ps";
        	ods pdf file = "hb_mixed_line.pdf" startpage=no;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s /*whole*/ nofs;
						list igout;
						treplay 1:1; 
						*treplay 1:2 2:3; 
						*treplay 1:3; 
					run;

        	ods pdf close;
        	ods ps close;
  quit;
	
/*
	ods pdf file="hb_mixed_data.pdf" style=journal;

	ods pdf style=journal;
	title1	height=3 f=zapf 'Hemoglobin longitudinal model-based means';

		* now make a table of the means and 95% CI for sofa score on days 0, 7, 14;
		data hb_mixed;
				merge lsmeans_hb_plot(keep = estimate upper lower day) 
						 sizes_hb_plot(keep=day num_obs rename=(num_obs=num_all))
						 lsmeans_trans(keep = estimate upper lower day rename=(estimate=estimate_t upper=upper_t lower=lower_t))
						 sizes_trans(keep=day num_obs rename=(num_obs=num_t)) 
						 lsmeans_notrans(keep = estimate upper lower day rename=(estimate=estimate_n upper=upper_n lower=lower_n))
						 sizes_notrans(keep=day num_obs rename=(num_obs=num_n)) range_day(keep=day min_day max_day);		
			by day;
			
			*where day in (1, 7, 14);
			if day=. then delete;
			dday=strip(put(day, 3.0)) || "[" || strip(put(min_day, 3.0)) || "-" || strip(put(max_day, 3.0))|| "]";
 			hb_all = strip(put(estimate, 5.1)) || " (" || strip(put(lower, 5.1)) || ", " || strip(put(upper, 5.1))|| ")";
			hb_t = strip(put(estimate_t, 5.1)) || " (" || strip(put(lower_t, 5.1)) || ", " || strip(put(upper_t, 5.1))|| ")";
			hb_n = strip(put(estimate_n, 5.1)) || " (" || strip(put(lower_n, 5.1)) || ", " || strip(put(upper_n, 5.1))|| ")";
			
			label
				dday = "Day"
				hb_all = "Hemoglobin*mean (95% CI)"
				hb_t = "Hemoglobin With Transfusion*mean (95% CI)"
				hb_n = "Hemoglobin Without Transfusion*mean (95% CI)"
				num_all="No. of Patients"
				num_t="With Transfusion"
				num_n="Without Transfusion"
			;
		
		   keep dday num_all hb_all num_t hb_t num_n hb_n;
		run;

			proc print data = hb_mixed noobs label split="*" style(data) = [just=center];
				var dday;
				var num_all/style(data) = [cellwidth=1in just=center];
				var hb_all num_t;
			 	var hb_t/style(data) = [cellwidth=1.8in] ;
				var num_n;
	        var hb_n/style(data) = [cellwidth=1.8in] ;
			run;

ODS ESCAPECHAR='^';
ODS pdf TEXT='^S={LEFTMARGIN=0.6in RIGHTMARGIN=0.6in}
*Model-based mean:  Estimated means taking into consideration the fact that not all patients have been measured at 
all time intervals. These are maximum likelihood estimates obtained using a repeated measures model.';
	
		ods pdf close;
*/



  








