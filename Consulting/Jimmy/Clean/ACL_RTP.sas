options orientation=landscape;
%include "tab_pct_stat.sas";

PROC IMPORT OUT= WORK.ACC 
            DATAFILE= "H:\SAS_Emory\Consulting\Jimmy\Clean\Complete ACL Data Cleaned and Coded.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="ACC$A1:V50"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.SEC 
            DATAFILE= "H:\SAS_Emory\Consulting\Jimmy\Clean\Complete ACL Data Cleaned and Coded.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="SEC$A1:V58"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.PAC 
            DATAFILE= "H:\SAS_Emory\Consulting\Jimmy\Clean\Complete ACL Data Cleaned and Coded.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="PAC-12$A1:V79"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc contents;run;

proc format;
value group 1="ACC" 2="SEC" 3="PAC-12";
value YE	0 ="redshirt freshman" 1 = "freshman" 2 ="sophomore" 3 = "junior" 4 = "senior" 5 ="5th year senior";
value YN	1 ="Yes" 0 = "No";
value Depth	1 ="Starter" 2 = "Utilized Player" 3 = "Rarely Played";
Value ACL_Type	1 ="Transtibial" 2 = "Anteromedial" 3 = "Two incision";
value Graft_Type	0 = "Allograft" 1 = "Patella autograft" 2 = "Hamstring autograft" 3 = "Quad autograft";
Value Tib_Fix	1 = "Screw fixation" 2 = "Washerloc fixation" 3 = "Tie over post fixation";
Value Fem_Fix	1= "Rigidfix/interfix fixation" 2 = "Screw fixation" 3 = "Endoloc/toggleloc fixation";
run;


data ACL;
	set ACC(in=A) SEC(in=B) PAC;
	if A then group=1; else if B then group=2; else group=3;
	if  graft_type in(1,2,3) then autograft=1; else autograft=0;
	if MM|LM|LR|MR|Micro|Chondro|MCL|LCL|PCL then concom=1; else concom=0;
	if MM|LM then menisectomy=1; else menisectomy=0;
	if MM&LM then MM_LM=1; else MM_LM=0;
	if LR|MR then meniscal_repair=1; else meniscal_repair=0;
	if LR&MR then LR_MR=1; else LR_MR=0;

	day=RTP_date-Surg_date;
	if day<0 then day=.;

	format group group. 
		scholarship MM LM LR MR Micro Chondro MCL LCL PCL RTP Grad NFL autograft concom menisectomy meniscal_repair MM_LM LR_MR YN. 
		Surg_date RTP_date mmddyy10.
		year yE. depth_pre depth_post depth. ACL_type ACL_type. Graft_type Graft_type. Tib_fix Tib_fix. Fem_fix Fem_fix.;
	label group="Group"
		  year="Years of experience"
		  Scholarship="Was played on a scholarship?"
		  Depth_Pre="Player's depth chart position before surgery"
		  Surg_date="Date of surgery"
		  ACL_type="ACL Reconstriction technique"
		  Graft_type="Type of graft used"
		  Tib_Fix="Type of tibial fixation used"
		  Fem_Fix="Type of femoral fixation used"
		  MM="Did player have a medial menisectomy?"
		  LM="Did player have a lateral menisectomy?"
		  LR="Did player have a lateral meniscal repair?"
		  MR="Did player have a medial meniscal repair?"
		  Micro="Did player have a microgfracture?"
		  Chondro="Did player have a chondroplasty?"
		  MCL="Did player have a MCL repair?"
		  LCL="Did player have a LCL repair?"
		  PCL="Did player have a PCL repair?"
		  RTP="Did player return to play?"
		  RTP_date="Date of return to play"
		  Grad="Did player graduate?"
		  NFL="Did player go on to play in the NFL?"
		  Depth_Post="Player's depth chart position after surgery"

		  autograft="Autograft of any kind?"
		  concom="Had a concomitant procedure of any kind?"
		  menisectomy="Players with menisectomy?"
		  MM_LM="Medial and Lateral Menisectomy?"
		  meniscal_repair="Players with meniscal repair?"
		  LR_MR="Medial and Lateral Meniscal Repair?"
		  day="Days from Surgery to Return to Play"
	;
run;

proc print data=ACL;
var group surg_date rtp_date day;
where .<day<0;
run;

proc means data=acl mean std min Q1 median Q3 max maxdec=1;
	type () group;
	class group;
	var day;
run;

%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=group,type=cat, first_var=1, title="Table Summary by RTP");
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=depth_pre,type=cat);
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=depth_post,type=cat);
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=Scholarship,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=year,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=NFL,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=Grad,type=cat)

%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var= autograft,type=cat)
%table(data_in=ACL,where=(autograft=1),data_out=ACL_RTP,gvar=RTP,var= graft_type,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=concom,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=menisectomy,type=cat)
%table(data_in=ACL,where=(menisectomy=1),data_out=ACL_RTP,gvar=RTP,var=MM,type=cat)
%table(data_in=ACL,where=(menisectomy=1),data_out=ACL_RTP,gvar=RTP,var=LM,type=cat)
%table(data_in=ACL,where=(menisectomy=1),data_out=ACL_RTP,gvar=RTP,var=MM_LM,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=meniscal_repair,type=cat)
%table(data_in=ACL,where=(meniscal_repair=1),data_out=ACL_RTP,gvar=RTP,var=LR,type=cat)
%table(data_in=ACL,where=(meniscal_repair=1),data_out=ACL_RTP,gvar=RTP,var=MR,type=cat)
%table(data_in=ACL,where=(meniscal_repair=1),data_out=ACL_RTP,gvar=RTP,var=LR_MR,type=cat)

%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=Micro,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=Chondro,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=MCL,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=LCL,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=PCL,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=ACL_type,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=Tib_fix,type=cat)
%table(data_in=ACL,data_out=ACL_RTP,gvar=RTP,var=Fem_fix,type=cat,last_var=1);quit;
