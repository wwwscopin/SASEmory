/*proc contents data=cmv.plate_035;run;*/

options orientation=landscape nobyline nodate;
libname wbh "/ttcmv/sas/data";	

data plasma;
	set cmv.plate_035;
	keep id DateTransfusion DonorUnitId  AliquotNum ffp_TxStartTime ffp_TxEndTime ffp_VolumeTransfused DatePtPTTTest TimePtPTTTest
	PT PTT inr fibrinogen;  
run;

data plasma;
	set plasma;
	x=0;
	x1=  0.2*uniform(613)-0.1;
	keep id x x1 PT PTT inr fibrinogen;  
run;



proc means n mean median min max;
	var pt ptt inr fibrinogen;
	output out=num;
run;

proc transpose data=num out=num;
 var pt ptt inr fibrinogen;
run;

data num;
	set num;
	rename _NAME_=Name Col1=N Col2=mean Col3=median col4=min col5=max;
	if _n_=1 the call symput("n1", compress(col1));
	if _n_=2 the call symput("n2", compress(col1));
	if _n_=3 the call symput("n3", compress(col1));
	if _n_=4 the call symput("n4", compress(col1));
	drop _label_;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white 
       					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

symbol1 interpol=boxt mode=exclude value=none co=black cv=black height=0.6 bwidth=12 width=1; 	 
symbol2 ci=blue value=circle h=1;         
     
%macro make_plots(data=plasma); 
 	%let x=1;          
  	%do %while (&x <5);
       %if &x = 1 %then %do; 	%let var =PT; %let pic= 'A)'; 
	  		 axis1 	label=(f=zapf h=3 "PT (n=&n1)" ) value=(f=zapf h=2.0) split="*" order= (-1 to 1 by 1) minor=none;
			 axis2 	label=(f=zapf h=3 a=90 'PT (sec)') order=(0 to 50 by 5) value=(f=zapf h=2) minor=none ;
	    %end;

       %if &x = 2 %then %do; 	%let var =PTT; %let pic= 'B)'; 
			 axis1 	label=(f=zapf h=3 "PTT (n=&n2)" ) value=(f=zapf h=2.0) split="*" order= (-1 to 1 by 1) minor=none;
			 axis2 	label=(f=zapf h=3 a=90 'PTT (sec)' ) order=(0 to 300 by 50) value=(f=zapf h=2) minor=none ;
		  %end;
 
       %if &x = 3 %then %do; 	%let var =INR; %let pic= 'C)'; 
			 axis1 	label=(f=zapf h=3  "INR (n=&n3)") value=(f=zapf h=2.0) split="*" order= (-1 to 1 by 1) minor=none;
			 axis2 	label=(f=zapf h=3 a=90 'INR') order=(0 to 4 by 0.5) value=(f=zapf h=2) minor=none;
		  %end;

       %if &x = 4 %then %do; 	%let var =fibrinogen; %let pic= 'D)'; 
			 axis1 	label=(f=zapf h=3  "Fibrinogen (n=&n4)") value=(f=zapf h=2.0) split="*" order= (-1 to 1 by 1) minor=none;
			 axis2 	label=(f=zapf h=3 a=90 'Fibrinogen (mg/dL)') order=(0 to 400 by 50) value=(f=zapf h=2) minor=none;
		  %end;
         
	
    		proc format; 
	       		value x -1=" " 0=" "  1=" ";              
     		run;

     		proc gplot data=&data gout=wbh.graphs;
       			plot   &var*x &var*x1/overlay haxis = axis1 vaxis = axis2  /*nolegend*/;
        			/*note h=2 m=(7pct, 10 pct) "Center:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;*/

       			format x x.  &var 5.0;
     		run;	

	        %let x=%eval(&x+1);
		%end;
%mend make_plots;
         
         * clear graph catalog ;
proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
%make_plots(data=plasma); quit;

 /* Reset hsize and vsize to default values */
goptions hsize=0in vsize=0in;

proc gslide gout=wbh.graphs;
   title 'Box Plots for Lab Measurements Taken Within 24 Hours Prior FFP Transfusion';
run;

ods pdf file = "plasma.pdf" startpage=no;
/*
	title h=3.5 justify=center "Fresh Frozen Plasma Tranfusion Record";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=l2r2s whole nofs;
		list igout;
		treplay 1:1 2:3 3:2 4:4; 
	run;
*/

proc greplay nofs;
	igout wbh.graphs;
	list igout;
	tc template;
	tdef t1  1/llx=5  ulx=5  lrx=50  urx=50  lly=45 uly=90 lry=45 ury=90
				 2/llx=50 ulx=50 lrx=95  urx=95  lly=45 uly=90 lry=45 ury=90
				 3/llx=5  ulx=5  lrx=50  urx=50  lly=0  uly=45  lry=0  ury=45
				 4/llx=50 ulx=50 lrx=95  urx=95  lly=0  uly=45  lry=0  ury=45
				 5/llx=0  ulx=0  lrx=100  urx=100  lly=0  uly=96 lry=0 ury=96					
			;
	template t1;
	tplay 1:1 2:2 3:3 4:4 5:5;
run; quit;


ods pdf close;
