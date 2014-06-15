PROC IMPORT OUT= WORK.ACC0 
            DATAFILE= "H:\SAS_Emory\Consulting\Jimmy\20130507\Complete ACL Data .xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="ACC$A3:S53"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents data=ACC0;run;
proc contents data=PAC;run;
proc contents data=acc0 short varnum;run;
*/
data ACC;
	set ACC0(rename=(Year_in_School__0_5_=year_school Depth_Chart_Position=DP_Position F1=player
		Type_of_ACL_Reconstruction=ACL Type_of_Graft_Utilized=Graft Graft_Fixation_Method=Tibial F11=Femoral
		Concomitant_Procedures_Performed=concom Date_of_Clearance_to_Return_to_P=Date_return
		Depth_Chart_Position1=DP_position1 Did_Player_Graduate_=Graduate Did_Player_Play_After_College_=play_after));
	if _n_=1 then delete;
run;

PROC IMPORT OUT= WORK.SEC0 
            DATAFILE= "H:\SAS_Emory\Consulting\Jimmy\20130507\Complete ACL Data .xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="SEC$A3:S61"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data SEC;
	set SEC0(rename=(Year_in_School__1_5_=year_school Depth_Chart_Position=DP_Position F1=player
		Type_of_ACL_Reconstruction=ACL Type_of_Graft_Utilized=Graft Graft_Fixation_Method=Tibial F11=Femoral
		Concomitant_Procedures_Performed=concom Date_of_Clearance_to_Return_to_P=Date_return
		Depth_Chart_Position1=DP_position1 Did_Player_Play_After_College_=play_after));
	if _n_=1 then delete;
	graduate=Did_Player_Graduate_+0;
run;


PROC IMPORT OUT= WORK.PAC0 
            DATAFILE= "H:\SAS_Emory\Consulting\Jimmy\20130507\Complete ACL Data .xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="PAC-12$A3:S82"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data PAC;
	set PAC0(rename=(Year_in_School__1_5_=year_school Scholarship=Scholarship0 Concomitant_Procedures_Performed=concom
		Date_of_Clearance_to_Return_to_P=Date_return Return_to_Play=Return_to_Play0 F1=player
		Depth_Chart_Position1=DP_position1 Did_Player_Graduate_=Graduate Did_Player_Play_After_College_=play_after));
	if _n_=1 then delete;
	Scholarship=Scholarship0+0;
	DP_Position=Depth_Chart_Position+0;
	ACL=Type_of_ACL_Reconstruction+0;
	Graft=Type_of_Graft_Utilized+0;
	Tibial=Graft_Fixation_Method+0;
	Femoral=F11+0;
	Return_to_Play=Return_to_Play0+0;
run;
proc format;
	value group 1="ACC" 2="SEC" 3="PAC";
	value pos 1="Starters" 2="Utilized players" 3="Rarely playing players";
	value yn 0="No" 1="yes";
	value graft 1="Patella Autograft" 2="Hamstring Autograft" 3="Quad Autograft" 0="Allograft";
	value concom 1="Partial medial menisectomy"
			     2="Partial lateral menisectomy"
				 3="Lateral meniscal repair"
				 4="Medial meniscal repair"
				 5="Microfracture"
				 6="Chondroplasty"
				 7="MCL repair"
				 8="LCL reconstruction"
				 9="PCL reconstruction"
				 ;
	value ACL 1="Transtibial ACL" 2="Anteromedial ACL" 3="2 incision ACL";
	value tibia 1="Screw tibial fixation" 2="Washerloc tibial fixation" 3="Tie over post tibial fixation";
	value femor 1="Rigidfix/interfix femoral fixation" 2="Screw femoral fixation" 3="Endo/toggleloc femoral fixation";
run;

data ACL;
	retain player age year_school scholarship dp_position Date_of_Surgery ACL Graft Tibial Femoral concom Return_to_Play Date_return 
		Did_Player_Play_Through_Eligibil Position1 DP_position1 graduate play_after;
	length position concom player $12;
	set ACC(in=A) SEC(in=B) PAC;
	if A then group=1; 
	else if B then group=2;
	else group=3;
	format group group. scholarship graduate play_after Return_to_Play yn. dp_position dp_position1 pos. 
		ACL ACL. Graft Graft. Tibial Tibia. Femoral Femor.;

	drop Did_Player_Graduate_ Scholarship0 Depth_Chart_Position Type_of_ACL_Reconstruction Type_of_Graft_Utilized Graft_Fixation_Method F11 Return_to_Play0;
run;


%macro como(data, out, varlist);

data _null_;
	set &data;
	call symput("n", _n_);
run;

data &out;
	if 1=1 then delete;
run;

%do j=1 %to &n;
	data _null_;
		set &data;
		if _n_=&j;
		call symput("char",&varlist);
	run;

	data temp;
		set &data;
		if _n_=&j;
	
		%let i = 1;
		%let cm=%scan(%bquote(&char), &i);
		%do %while(&cm NE );
			*value type 1="IM Nail"	2="ExFix Pins"	3="Plate"	4="Screws"	5="Bone Graft"	N="none";
			if &cm=0  then pro0=1;    
			if &cm=1  then pro1=1; 
			if &cm=2  then pro2=1;    
			if &cm=3  then pro3=1;  
			if &cm=4  then pro4=1;  
			if &cm=5  then pro5=1; 
			if &cm=6  then pro6=1;    
			if &cm=7  then pro7=1;    
			if &cm=8  then pro8=1;  
			if &cm=9  then pro9=1;  

  			%let i= %eval(&i+1);
   			%let cm= %scan(%bquote(&char),&i);
		%end;
	run;

	data &out;
		set &out temp;
		drop N;
	label pro0="No concomitant procedure"
		  pro1="Partial medial menisectomy"
		  pro2="Partial lateral menisectomy"
		  pro3="Lateral meniscal repair"
		  pro4="Medial meniscal repair"
		  pro5="Microfracture"
		  pro6="Chondroplasty"
		  pro7="MCL repair"
		  pro8="LCL reconstruction"
		  pro9="PCL reconstruction";
	run;
%end;
%mend como;
%como(ACL, tab_new, concom);

