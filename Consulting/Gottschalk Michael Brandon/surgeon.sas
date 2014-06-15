OPTIONS orientation=portrait;
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Gottschalk Michael Brandon\Spreadsheet for Infection Calculations with Tears.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:N1054"; 
     GETNAMES=No;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F2'='CHAR(10)' 'F3'='CHAR(10)' 'F7'='CHAR(10)')"  ; 
RUN;
/*
proc contents;run;
proc freq;
	tables F1-F14;
run;
*/


proc format;
value Surgeon 1="Karas" 2="Labib" 3="Xerogeanes";
value contact 0="No" 1="Yes" 2="Not mentioned";
value sex  1="Male" 0="Female";
value ny  0="No" 1="Yes";
value infect 0="No" 1="Deep" 2="Super" ;
value Pos 0="Lithotomy" 1="Bolster";
value graft 1="tibialis anterior allo" 2="BTB" 3="HT" 4="BTB allo" 5="HT allo" 6="Achilles allo" 7="Quad" 8="Unknown allograft" 9="Double Bundle or 2 grafts used";
run;

%macro como(data, out, n);
data &out;
	if 1=1 then delete;
run;

%do j=1 %to &n;
	data _null_;
		set &data;
		if _n_=&j;
		call symput("char1",F3);
	run;

	data temp;
		set &data;
		if _n_=&j;
	
		%let i = 1;
		%let k = 1;
		%let cm1=%scan(%bquote(&char1), &i);
		%do %while(&cm1 NE );
/*
0=none		 
1=meniscectomy 	
2=PCL	
3=MCL 
4=chondroplasty 
5=loose body removal 
6=microfracture 
7=tibial plateau bone grafting 
8=osteophyte removal
9=plica removal
10=trephination
11=LCL
12=posterolateral corner
13=removal of hardware
14= meniscal repair
*/
			if &cm1=0  then graft=0;    
			if &cm1=1  then mtomy=1;  
			if &cm1=2  then pcl=1;    
			if &cm1=3  then mcl=1;  
			if &cm1=4  then chondroplasty =1;  
			if &cm1=5  then loose_body_removal=1; 
			if &cm1=6  then microfracture =1;    
			if &cm1=7  then tibial_plateau_bone_grafting =1;    
			if &cm1=8  then osteophyte=1;  
			if &cm1=9  then plica=1;  
			if &cm1=10  then trephination=1; 
			if &cm1=11  then lcl=1;    
			if &cm1=12  then posterolateral_corner=1;    
			if &cm1=13  then removal_hardware=1;  
			if &cm1=14  then meniscal_repair=1;  
	
   			%let i= %eval(&i+1);
   			%let cm1= %scan(%bquote(&char1),&i);
		%end;

	data &out;
		set &out temp;
	run;
%end;
%mend como;
%como(tmp, surgeon, 1054);


data op;
	set surgeon;
	contact=F2+0;
	Tourniquet_Time=F7+0;
	
	if F11=1 then infection=1; else infection=0;

	if 	graft=. then graft=1;
	if  mtomy=.  then mtomy=0;
	if  pcl=. then pcl=0;
	if  mcl=. then mcl=0;
	if  chondroplasty =. then chondroplasty=0;
	if  loose_body_removal=. then loose_body_removal=0;
	if  microfracture =. then microfracture =0;
	if  tibial_plateau_bone_grafting =. then tibial_plateau_bone_grafting =0;
	if  osteophyte=. then osteophyte=0;
	if  plica=. then plica=0;
	if  trephination=. then trephination=0;  
	if  lcl=. then lcl=0;
	if  posterolateral_corner=. then posterolateral_corner=0;    
	if  removal_hardware=. then  removal_hardware=0;
	if  meniscal_repair=. then meniscal_repair=0;  

		
	rename F1=surgeon F3=other_proced F4=graft_type F5=sex F6=age  F8=retear F9=ctear F10=Loa_mua F11=Infect
		F12=Hematoma F13=Reop_infect F14=pos;
	format F1 surgeon. contact contact. F5 sex. F11 infect. F14 pos. graft_type graft. 
			F8 F9 F10 infection F12 F13 mtomy pcl mcl chondroplasty loose_body_removal microfracture tibial_plateau_bone_grafting 
			osteophyte plica trephination lcl posterolateral_corner removal_hardware meniscal_repair ny.;
	*if F11 in(0,1,2);
	keep F1-F14 contact Tourniquet_Time graft_type mtomy pcl mcl chondroplasty loose_body_removal microfracture tibial_plateau_bone_grafting 
			osteophyte plica trephination lcl posterolateral_corner removal_hardware meniscal_repair infection;
run;

proc freq data=op(where=(contact in(0,1)));
	*tables pos*infection/chisq fisher;
	*tables graft_type;
	tables contact*retear/chisq fisher;
run;

proc power; 
  twosamplefreq test=fisher 
  groupproportions = (0.0114  0.0464) 
  power = .
  groupns =(859 194)
  sides = 2;
run;

proc logistic data=op descending plots(only)=roc(id=obs);;
	class pos proced sex contact LOA_MUA BTB/param=ref ref=first;
	model infection=age pos sex LOA_MUA BTB/lackfit;
run;
/*
proc logistic data=op descending;
	class sex pos proced contact retear ctear LOA_MUA Meniscectomy Hematoma graft_type/param=ref ref=first;
	model infection=age sex pos proced contact Tourniquet_Time retear ctear LOA_MUA Meniscectomy Hematoma graft_type /selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit;
run;
*/
%table(data_in=op,data_out=infect,gvar=infection,var=surgeon,type=cat, label="Primary Surgeon", first_var=1,  title="Table A: Comparison by Infection");
%table(data_in=op, where=contact^=2, data_out=infect,gvar=infection,var=contact,type=cat, label="Contact Related");
%table(data_in=op,data_out=infect,gvar=infection,var=age,type=con, label="Age");
%table(data_in=op,data_out=infect,gvar=infection,var=sex,type=cat, label="Sex");
%table(data_in=op,data_out=infect,gvar=infection,var=Tourniquet_Time,type=con, label="Tourniquet Time (mins)");
%table(data_in=op,data_out=infect,gvar=infection,var=pos,type=cat, label="Positions");
%table(data_in=op,data_out=infect,gvar=infection,var=retear,type=cat, label="Retear");
%table(data_in=op,data_out=infect,gvar=infection,var=cTear,type=cat, label="Contralateral Tear");
%table(data_in=op,data_out=infect,gvar=infection,var=LOA_MUA,type=cat, label="LOA_MUA");
%table(data_in=op,data_out=infect,gvar=infection,var=Meniscectomy ,type=cat, label="Meniscectomy");
%table(data_in=op,data_out=infect,gvar=infection,var=Hematoma ,type=cat, label="Hematoma ");
%table(data_in=op,data_out=infect,gvar=infection,var=tibialis_anterior_allo,type=cat, label="tibialis anterior allo");
%table(data_in=op,data_out=infect,gvar=infection,var=BTB,type=cat, label="BTB");
%table(data_in=op,data_out=infect,gvar=infection,var=HT,type=cat, label="HT");
%table(data_in=op,data_out=infect,gvar=infection,var=BTB_allo,type=cat, label="BTB Allo");
%table(data_in=op,data_out=infect,gvar=infection,var=HT_allo,type=cat, label="HT Allo");
%table(data_in=op,data_out=infect,gvar=infection,var=Achilles_allo,type=cat, label="Achilles_allo");
%table(data_in=op,data_out=infect,gvar=infection,var=quad,type=cat, label="Quad", last_var=1);


%table(data_in=op,data_out=graft_retear,gvar=retear,var=Age,type=con, label="Age", first_var=1,  title="Table B: Comparison by Retear");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=sex,type=cat, label="Sex");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=tibialis_anterior_allo,type=cat, label="tibialis anterior allo");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=BTB,type=cat, label="BTB");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=HT,type=cat, label="HT");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=BTB_allo,type=cat, label="BTB Allo");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=HT_allo,type=cat, label="HT Allo");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=Achilles_allo,type=cat, label="Achilles_allo");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=quad,type=cat, label="Quad");
%table(data_in=op,data_out=graft_retear,gvar=retear,var=contact,type=cat, label="Contact", last_var=1);

%table(data_in=op,data_out=sex_retear,gvar=sex,var=retear,type=cat, label="Retear", first_var=1,  title="Table C: Comparison by Sex");
%table(data_in=op,data_out=sex_retear,gvar=sex,var=CTear ,type=cat, label="Contralateral Tear", last_var=1);

%table(data_in=op,data_out=age_graft,gvar=tibialis_anterior_allo,var=Age,type=con, label="Age*tibialis_anterior_allo", first_var=1,  title="Table D: Comparison of Age by Graft");
%table(data_in=op,data_out=age_graft,gvar=BTB,var=age,type=con, label="Age*BTB");
%table(data_in=op,data_out=age_graft,gvar=HT,var=age,type=con, label="Age*HT");
%table(data_in=op,data_out=age_graft,gvar=BTB_allo,var=age,type=con, label="Age*BTB Allo");
%table(data_in=op,data_out=age_graft,var=age,gvar=HT_allo,type=con, label="Age*HT Allo");
%table(data_in=op,data_out=age_graft,var=age,gvar=Achilles_allo,type=con, label="Age*Achilles_allo");
%table(data_in=op,data_out=age_graft,var=age,gvar=quad,type=con, label="Age*Quad");
%table(data_in=op,data_out=age_graft,var=age,gvar=graft,type=con, label="Age*Any Graft", last_var=1);
