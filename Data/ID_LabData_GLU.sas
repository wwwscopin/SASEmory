%let path=H:\SAS_Emory\Data\;

proc import datafile="&path.glndlab\GLU\GLND Study Group 5 - 2009_GLU.xls"
	out=glu1 dbms=excel replace; 
	sheet="zig"; 
         GETNAMES=YES;
         MIXED=YES;
run;


data lab_glu1;
	set glu1 (rename=(Reference_Number=ID0 Glutamine__uM=Glutamine Glutamic_acid__uM=Glutamic_acid lab__=Lab_num));
	id1=put(id0,10.);
	id2=substr(strip(id1),1,5);
	id=input(id2,5.);
	day=input(substr(strip(id0),6,2),2.0);
	if id=. then delete;
	drop id0 id1 id2;
run; 

proc sort data=lab_glu1 nodup; by id;run;


proc import datafile="&path.glndlab\GLU\GLN Study5 samples 1-60_GLU.xls"
	out=glu2 dbms=excel replace; 
	sheet="zig"; 
         GETNAMES=YES;
         MIXED=YES;
run;


data lab_glu2;
	set glu2 (rename=(Reference_Number=ID0 Glutamine__uM=Glutamine Glutamic_acid__uM=Glutamic_acid lab__=Lab_num));
	id1=put(id0,10.);
	id2=substr(strip(id1),1,5);
	id=input(id2,5.);
	day=input(substr(strip(id0),6,2),2.0);
	if id=. then delete;
	drop id0 id1 id2;
run; 

proc sort data=lab_glu2 nodup; by id;run;

proc import datafile="&path.glndlab\GLU\GLND Study4 results_GLU.xls"
	out=glu3 dbms=excel replace; 
	sheet="Sheet1"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_glu3;
	set glu3(rename=(F3=ID0  Glutamine__umol_L=Glutamine Glutamic_acid__umol_L=Glutamic_acid lab__=Lab_num patient= Study_Number));
	id1=substr(strip(id0),1,1)||substr(strip(id0),3,4);
	id=input(id1,5.);
	day=input(substr(strip(id0),9,2),2.0);
	if id=. then delete;
	drop id0 id1;
run;

proc sort data=lab_glu3 nodup; by id;run;

proc import datafile="&path.glndlab\GLU\GLND-3_06-17-08 (2)_GLU.xls"
	out=glu4 dbms=excel replace; 
	sheet="EMORY data"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_glu4;
	set glu4(rename=(Refer___=ID0  Glutamine__umol_L_=Glutamine  Glutamic_Acid__umol_L=Glutamic_Acid lab__=Lab_num patient= Study_Number));
	id1=substr(strip(id0),1,1)||substr(strip(id0),3,4);
	id=input(id1,5.);
	day=input(substr(strip(id0),8,2),2.0);
	if id=. then delete;
	drop id0 id1;
run;

proc sort data=lab_glu4 nodup; by id;run;


proc import datafile="&path.glndlab\GLU\Aminoacids batch 04-27-2012 final.xls"
	out=glu5A dbms=excel replace; 
	sheet="glutamine$C1:G55"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_glu5A;
	set glu5A(keep=First_name result);
	id=substr(First_name,1,5)+0;
	day=compress(substr(First_name,6),"DayBaseline")+0;
	if day=. then day=0;
	rename result=glutamine;
	drop First_name;
run;

proc sort; by id day;run;
proc import datafile="&path.glndlab\GLU\Aminoacids batch 04-27-2012 final.xls"
	out=glu5B dbms=excel replace; 
	sheet="glutamic acid$C1:G55"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_glu5B;
	set glu5B(keep=First_name result);
	id=substr(First_name,1,5)+0;
	day=compress(substr(First_name,6),"DayBaseline")+0;
	if day=. then day=0;
	rename result=Glutamic_Acid;
	drop First_name;
run;
proc sort; by id day;run;

data lab_glu5;
	merge lab_glu5a lab_glu5b; by id day;
run;

proc import datafile="&path.glndlab\GLU\Glu-gln tisa.xls"
	out=glu6 dbms=excel replace; 
	sheet="glutamic acid$C517:H624"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc print;run;

data lab_glu6;
	set glu6(keep=_1440_Day_3 _0 _04);
	id=substr(_1440_Day_3,1,5)+0;
	day=compress(substr(_1440_Day_3,7),"DdayBaseline")+0;
	if day=. then day=0;
	rename _0=Glutamic_Acid _04=glutamine;
	drop _1440_Day_3 ;
	study_number="Y2011";
run;
proc sort; by id day;run;

libname wbh "&path";
data wbh.glu_ex;
	if _n_=1 then do; id=51071; day=0; visit=0; glutamine=173; Glutamic_acid=48; output; end;
	set lab_glu1 lab_glu2 lab_glu3 lab_glu4 lab_glu5 lab_glu6; by id;
	rename 	Glutamic_acid=GlutamicAcid;
	visit=day;
	if day not in(0 3 7 14 21 28) then
	if day>7 then visit=round(day/7)*7;
	else if day>=5 then visit=7;
	else visit=3;	
	output;
run;

proc sort data=wbh.glu_ex; by id day;run;
proc print;run;
