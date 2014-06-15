/*
proc contents data=cmv.plate_015 short varnum;run;
proc contents data=cmv.plate_016 short varnum;run;
*/

libname wbh "/ttcmv/sas/programs";

%let tri=%sysfunc(byte(179)); 

data lab_015;
	set cmv.plate_015;
	keep AnthroMeasureDate HeightDate WeightDate HeadDate BloodCollectDate WBCDate PltDate HctDate HbDate          
NeutroDate LymphoDate ALTDate ASTDate AlbuminDate TBiliDate DBiliDate id HtLength Weight HeadCircum WBC Platelet Hct Hb AbsNeutrophil Lympho ALT AST Albumin TotalBilirubin  DirectBilirubin DFSEQ;
	rename DFSEQ=day;
run;
proc sort; by id day; run;

data lab_016;
	set cmv.plate_016;
	keep BUNDate CreatDate PotassiumDate SodiumDate ChlorideDate BicarbDate GlucoseDate id BUN Creatinine    
Potassium Sodium Chloride Bicarbonate Glucose DFSEQ;
	rename DFSEQ=day;
run;

proc sort; by id day; run;


data lab0;
	merge lab_015 lab_016; by id day;

	if HtLength^=. and HeightDate=. then HeightDate=AnthroMeasureDate;
	if Weight^=. and WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadCircum^=. and HeadDate=. then HeadDate=AnthroMeasureDate;
	if WBC^=. and WBCDate=. then WBCDate=BloodCollectDate;
	if Platelet^=. and PltDate=. then PltDate=BloodCollectDate;
	if Hct^=. and HctDate=. then HctDate=BloodCollectDate;
	if Hb^=.  and HbDate=.  then HbDate=BloodCollectDate;
	if AbsNeutrophil^=. and NeutroDate=. then NeutroDate=BloodCollectDate;
	if Lympho^=. and LymphoDate=. then LymphoDate=BloodCollectDate;
	if ALT^=. and ALTDate=. then ALTDate=BloodCollectDate;
	if AST^=. and ASTDate=. then ASTDate=BloodCollectDate;
	if Albumin^=. and AlbuminDate=. then AlbuminDate=BloodCollectDate;
	if TotalBilirubin^=. and TBiliDate=. then TBiliDate=BloodCollectDate;
	if DirectBilirubin^=. and DBiliDate=. then DBiliDate=BloodCollectDate;

	if BUN^=. and BunDate=. then BunDate=BloodCollectDate;
	if Creatinine^=. and CreatDate=. then CreatDate=BloodCollectDate;
	if Potassium^=. and PotassiumDate=. then PotassiumDate=BloodCollectDate;
	if Sodium^=. and SodiumDate=. then SodiumDate=BloodCollectDate;
	if Chloride^=. and ChlorideDate=. then ChlorideDate=BloodCollectDate;
	if Bicarbonate^=. and BicarbDate=. then BicarbDate=BloodCollectDate;
	if Glucose^=. and GlucoseDate=. then GlucoseDate=BloodCollectDate;
run;

/*
data dob;
	set cmv.plate_005(keep=id LBWIDOB rename=(LBWIDOB=dob));
run;

proc sort; by id; run;

data lab0;
	merge lab0 dob; by id;

	DHeight=HeightDate-dob;
	DWeight=WeightDate-dob;
	DHead=HeadDate-dob;
	DWBC=WBCDate-dob;
	DPlt=PltDate-dob;
	DHct=HctDate-dob;
	DHb=HbDate-dob;
	DNeu=NeutroDate-dob;
	DLym=LymphoDate-dob;
	DALT=ALTDate-dob;
	DAST=ASTDate-dob;
	DAl=AlbuminDate-dob;
	DTB=TbiliDate-dob;
	DDB=DBiliDate-dob;
	DBUN=BUNDate-dob;
	DCreat=CreatDate-dob;
	DK=PotassiumDate-dob;
	DNa=SodiumDate-dob;
	DCl=ChlorideDate-dob;
	DBC=BicarbDate-dob;
	DGlu=GlucoseDate-dob;	
run;

proc contents;run;
proc print;run;
*/

data valid_id;
	set cmv.valid_ids;
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;

proc means data=valid_id noprint;
 	class center;
	var id;
	output out=n_id n(id)=n;
run;

data _null_;
	set n_id;
	if center=1 then call symput("n1", compress(n));
	if center=2 then call symput("n2", compress(n));
	if center=3 then call symput("n3", compress(n));
	if center=. then call symput("n", compress(n));
run;

proc sql;
	create table lab as 
	select a.*, center
	from lab0 as a, valid_id as b
	where a.id=b.id
	;

data lab;
	set lab;
	keep id center day HtLength Weight HeadCircum WBC Platelet Hct Hb AbsNeutrophil Lympho ALT AST Albumin TotalBilirubin  DirectBilirubin
			BUN Creatinine Potassium Sodium Chloride Bicarbonate Glucose;
run;


proc print;
	where Creatinine>5 or ALT>100 or AST>200 or WBC>50 or Hb>25 or AbsNeutrophil>20000 or DirectBilirubin>5;
	var id day Creatinine ALT AST WBC Hb AbsNeutrophil DirectBilirubin;
run;


options ORIENTATION = LANDSCAPE nodate;
goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
				colors = (black red) ftitle="Times" ftext="Times"  fby ="Times" hby = 3;

          
/* Set up Symbol for Data Points */
symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=200;  
   
%macro make_plots(data=lab); 

proc greplay igout= wbh.graphs nofs; delete _ALL_; run;
%let m_1= 0; %let m_4= 0; %let m_7= 0; %let m_14= 0; %let m_21= 0; %let m_28= 0; %let m_40= 0; %let m_60= 0; 
%let g_1= 0; %let g_4= 0; %let g_7= 0; %let g_14= 0; %let g_21= 0; %let g_28= 0; %let g_40= 0; %let g_60= 0; 
%let n_1= 0; %let n_4= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0; %let n_40= 0; %let n_60= 0; 

%let x=1;
%do %while (&x <22);
	
    %if &x = 1  %then %do; 	%let variable =Weight;         %let description = 'Weight (g)';  %let order=(0 to 3000 by 200);	%end;     
    %if &x = 2  %then %do; 	%let variable =HtLength;       %let description = 'Length (cm)'; %let order=(20 to 50 by 2); %end;
    %if &x = 3  %then %do; 	%let variable =HeadCircum;     %let description = 'Head Circumference (cm)';%let order=(16 to 48 by 2); %end;
	 

	%if &x = 4  %then %do; 	%let variable =WBC;   	 		%let description = 'WBC (1000/' f=greek "m" f=zapf 'l)'; 
																			 		%let order=(0 to 70 by 5);	  %end;     
	%if &x = 5  %then %do; 	%let variable =Platelet; 		%let description = 'Platelet count (1000/' f=greek "m" f=zapf 'l)';
																			 		%let order=(0 to 1000 by 100); %end;
	%if &x = 6  %then %do; 	%let variable =Hct;   			%let description = 'Hematocrit (%)'; 
																					%let order=(5 to 70 by 5);	  %end;  
	%if &x = 7  %then %do; 	%let variable =Hb;    	        %let description =  'Hemoglobin (g/dL)'; 
																					%let order=(0 to 40 by 5);	  %end;     
	%if &x = 8  %then %do; 	%let variable =AbsNeutrophil;   
  										/*%let description = m=(0, +0.3) "3"; */
										%let description = "Absolute neutrophil count (mm&tri)"; 
																					   %let order=(0 to 32000 by 5000);	%end;
	%if &x = 9  %then %do; 	%let variable =Lympho;          %let description = 'Lymphocytes (%)';	
																						%let order=(0 to 90 by 10); 	%end;  
	%if &x = 10 %then %do; 	%let variable =ALT;             %let description = 'ALT (units/L)';  
																					   %let order=(0 to 250 by 50);		%end;     
	%if &x = 11 %then %do; 	%let variable =AST;          		%let description = 'AST (units/L)'; 	
																						%let order=(0 to 260 by 20);	%end;
	%if &x = 12 %then %do; 	%let variable =Albumin;  			%let description = 'Albumin(g/dL)';
																						%let order=(1 to 5 by 1);       %end;  
	%if &x = 13 %then %do; 	%let variable =TotalBilirubin;  %let description = 'Total bilirubin (mg/dL)'; 
																					   %let order=(0 to 12 by 2);       %end;    
	%if &x = 14 %then %do; 	%let variable =DirectBilirubin; %let description = 'Direct bilirubin (mg/dL)';
																					   %let order=(0 to 8 by 1);        %end;
	%if &x = 15 %then %do; 	%let variable =BUN;             %let description = 'BUN (mg/dL)'; 
																					   %let order=(0 to 60 by 5);	    %end;  
	%if &x = 16 %then %do; 	%let variable =Creatinine;      %let description = 'Creatinine (mg/dL)';  
																					   %let order=(0 to 7 by 1);        %end;     
	%if &x = 17 %then %do; 	%let variable =Potassium;       %let description = 'Potassium (mEq/L)';
																					   %let order=(2 to 9 by 1);        %end;
	%if &x = 18 %then %do; 	%let variable =Sodium;          %let description = 'Sodium (mEq/L)';  
																					   %let order=(120 to 155 by 5);    %end;  
   %if &x = 19 %then %do; 	%let variable =Chloride;        %let description = 'Chloride (mEq/L)';
																					   %let order=(85 to 125 by 5);     %end;     
	%if &x = 20 %then %do; 	%let variable =Bicarbonate;     %let description = 'Bicarbonate (mEq/L)';   
																					   %let order=(10 to 35 by 5);   	%end;
	%if &x = 21 %then %do; 	%let variable =Glucose;         %let description = 'Glucose (mg/dL)';    
																					   %let order=(0 to 250 by 50);	    %end;  

	* get 'n' at each day;
		proc means data=&data noprint;
				by center;
    			class day;
    			var &variable;
     			output out = sizes_&data n(&variable) = n;
  		run;
		
		data sizes_&data;
			set sizes_&data;	
			if day=. then delete;
		run;

	* populate 'n' annotation variables ;
   		%do i = 0 %to 62;
    			data _null_;
    				set sizes_&data;
     				where day = &i;
     				if center=1 then call symput( "m_&i",  compress(n));
     				if center=2 then call symput( "g_&i",  compress(n));
     				if center=3 then call symput( "n_&i",  compress(n));
     			run;
     		%end;
         
     		proc format; 
     		
    		 	value dd   
						-1=" " 0=" " 1 = "1"  2=" " 3=" " 4="4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
    			     11=" " 12=" " 13=" " 14="14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
    			     21="21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28"  29=" " 30=" "
					  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
    					41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
   				   51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" " 60="60" ;
   				   
   			  value dt   
						-1=" " 0=" " 1 = " "  2=" " 3=" " 4=" " 5=" " 6=" " 7=" " 8=" " 9=" " 10=" " 
    			     11=" " 12=" " 13=" " 14=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
    			     21=" "  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28=" "  29=" " 30=" "
					  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
    					41=" " 40=" " 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
   				   51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" " 60=" " ;
   				   
     		 	value m_axis   
						-1=" " 0=" " 1 = "&m_1"  2=" " 3=" " 4="&m_4" 5=" " 6=" " 7="&m_7" 8=" " 9=" " 10=" " 
    			     11=" " 12=" " 13=" " 14="&m_14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
    			     21="&m_21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="&m_28"  29=" " 30=" "
					  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
    					41=" " 40="&m_40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
   				   51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" " 60="&m_60" ;   
     		 	value g_axis   
						-1=" " 0=" " 1 = "&g_1"  2=" " 3=" " 4="&g_4" 5=" " 6=" " 7="&g_7" 8=" " 9=" " 10=" " 
    			     11=" " 12=" " 13=" " 14="&g_14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
    			     21="&g_21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="&g_28"  29=" " 30=" "
					  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
    					41=" " 40="&g_40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
   				   51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" " 60="&g_60" ; 

     		 	value n_axis   
						-1=" " 0=" " 1 = "&n_1"  2=" " 3=" " 4="&n_4" 5=" " 6=" " 7="&n_7" 8=" " 9=" " 10=" " 
    			     11=" " 12=" " 13=" " 14="&n_14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
    			     21="&n_21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="&n_28"  29=" " 30=" "
					  31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
    					41=" " 40="&n_40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
   				   51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" " 60="&n_60" ;        
        run;
         
         
         
    data annom annog annon;
	   length function $8;
	   retain xsys '2' ysys '3' color 'black' when 'a';
    	set sizes_&data;
    	function='move'; x=day; y=15; output;
    	function='draw'; x=day; y=13.5; output;
    	function='label'; x=day; y=11; size=0.75; output;
    	if center=1 then do; text=left(put(day,dd.)); output annom; end;
    	    	if center=2 then do; text=left(put(day,dd.)); output annog;  end;
    	    	    	if center=3 then do; text=left(put(day, dd.)); output annon; end;

    run;
    

    
  
    axis1 	label=(h=3 'Age of LBWI (days)' ) value=(h=2) origin=(,15) split="*" order= (-1 to 62 by 1) minor=none offset=(0 in, 0 in);
    axis2 	label=(h=3 a=90 &description) value=(h=2) order=&order ;

                  
	proc gplot data=&data gout=wbh.graphs;
		title h=3.5 justify=center &description, "Center=EUHM (n=&n1)";  
		*note h=2 m=(7pct, 10 pct) "Age:" ;
		*note h=2 m=(7pct, 7.5 pct) "(n)" ;
		where center=1; 
		plot &variable*day=id/ overlay haxis = axis1 vaxis = axis2 annotate= annom  nolegend; format day dt. &variable 5.0;
	run;

	proc gplot data=&data gout=wbh.graphs;
		title h=3.5 justify=center &description, "Center=Grady (n=&n2)";  
		*note h=2 m=(7pct, 10 pct) "Age:" ;
		*note h=2 m=(7pct, 7.5 pct) "(n)" ;
		where center=2; 
		plot &variable*day=id/ overlay haxis = axis1 vaxis = axis2 annotate= annog nolegend; format day dt. &variable 5.0;
	run;

	proc gplot data=&data gout=wbh.graphs;
		title h=3.5 justify=center &description, "Center=Northside (n=&n3)";  
		*note h=2 m=(7pct, 10 pct) "Age:" ;
		*note h=2 m=(7pct, 7.5 pct) "(n)" ;
		where center=3;  
		plot &variable*day=id/ overlay haxis = axis1 vaxis = axis2 annotate= annon nolegend; format day dt. &variable 5.0;
	run;

	%let x = &x + 1;	
	%end;
%mend make_plots;

			        
         * clear graph catalog ;
         proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
        
        *goptions rotate = portrait;
        	
				%make_plots(data=lab); run;

%let path=/ttcmv/sas/output/qc_lineplots/;
 
ods listing close;    
            goptions reset=all;   
           	ods pdf file = "&path.lab_test.pdf" /*startpage=no*/;
					proc greplay igout =wbh.graphs tc=sashelp.templt template=l2r2 /*whole*/ nofs;
						list igout;
						treplay 1:1  2:2  3:3; 
						treplay 1:4  2:5  3:6; 
						treplay 1:7  2:8  3:9; 
						treplay 1:10 2:11 3:12; 
						treplay 1:13 2:14 3:15; 
						treplay 1:16 2:17 3:18; 
						treplay 1:19 2:20 3:21; 
						treplay 1:22 2:23 3:24; 
						treplay 1:25 2:26 3:27; 
						treplay 1:28 2:29 3:30; 
						treplay 1:31 2:32 3:33; 
						treplay 1:34 2:35 3:36; 
						treplay 1:37 2:38 3:39; 
						treplay 1:40 2:41 3:42; 
						treplay 1:43 2:44 3:45; 
						treplay 1:46 2:47 3:48; 
						treplay 1:49 2:50 3:51; 
						treplay 1:52 2:53 3:54; 
						/*
						treplay 1:55 2:56 3:57; 
						treplay 1:58 2:59 3:60; 
						treplay 1:61 2:62 3:63; 
						*/
					run;

        	ods pdf close;
  quit;



