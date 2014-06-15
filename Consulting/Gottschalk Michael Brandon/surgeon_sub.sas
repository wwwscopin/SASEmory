OPTIONS orientation=landscape;
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Gottschalk Michael Brandon\Stats sheet for all Surgeons.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:N1053"; 
     GETNAMES=No;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F3'='CHAR(20)' 'F4'='CHAR(20)')"  ; 
RUN;
/*proc contents;run;*/

proc format;
value Surgeon 1="Karas" 2="Labib" 3="Xerogeanes";
value contact 0="No" 1="Yes" 2="Not mentioned";
value sex  1="Male" 0="Female";
value ny  0="No" 1="Yes";
value infect 0="No" 1="Deep" 2="Super" 3="Dehiscence";
value Pos 0="Lithotomy" 1="Bolster";
value graft 1="tibialis anterior allo" 2="BTB" 3="HT" 4="BTB allo" 5="HT allo" 6="Achilles allo" 7="Quad" 8="other" 9="not specified";
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
		call symput("char2",F4);
	run;

	data temp;
		set &data;
		if _n_=&j;
	
		%let i = 1;
		%let k = 1;
		%let cm1=%scan(%bquote(&char1), &i);
		%let cm2=%scan(%bquote(&char2), &k);
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

		%do %while(&cm2 NE );
/*
1=tibialis anterior allo
2=BTB
3=HT
4=BTB allo
5=HT allo
6=Achilles allo
7=Quad
8=other
9=not specified
*/			if &cm2=1  then tibialis_anterior_allo=1;    
			if &cm2=2  then BTB=1;    
			if &cm2=3  then HT=1;  
			if &cm2=4  then BTB_allo=1;  
			if &cm2=5  then HT_allo=1; 
			if &cm2=6  then Achilles_allo=1;    
			if &cm2=7  then quad=1;    
			if &cm2=8  then other=1;  
			if &cm2=9  then not_specified=1; 
		
   			%let k= %eval(&k+1);
   			%let cm2= %scan(%bquote(&char2),&k);
		%end;

	run;

	data &out;
		set &out temp;
	run;
%end;
%mend como;
%como(tmp, surgeon, 1053);

/*proc print data=surgeon;run;*/

data op;
	set surgeon;
	proced=F3+0;
	graft_type=F4+0;
	/*if F11=0 then infection=0; else infection=1;*/

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
	if lcl=. then lcl=0;
	if posterolateral_corner=. then posterolateral_corner=0;    
	if removal_hardware=. then  removal_hardware=0;
	if meniscal_repair=. then meniscal_repair=0;  

			if tibialis_anterior_allo=. then  tibialis_anterior_allo=0;
			if BTB=. then BTB=0;
			if HT=. then HT=0;
			if BTB_allo=. then BTB_allo=0;  
			if HT_allo=. then HT_allo=0;
			if Achilles_allo=. then Achilles_allo=0;
			if quad=. then quad=0; 
	if graft_type=0 then graft_type=9;
	if graft_type not in (0,9) then graft=1; else graft=0;
				
	rename F1=surgeon F2=contact F5=age F6=sex F7=Tourniquet_Time F8=retear F9=ctear F10=Loa_mua F11=Infection
		F12= Meniscectomy  F13= Hematoma  F14=pos;
	format F1 surgeon. F2 contact. F6 sex. F11 infect. F14 pos. graft_type graft. graft ny.
			F8 F9 F10 infection F12 F13 mtomy pcl mcl chondroplasty loose_body_removal microfracture tibial_plateau_bone_grafting 
			osteophyte plica trephination lcl posterolateral_corner removal_hardware meniscal_repair 
			tibialis_anterior_allo 	BTB HT BTB_allo HT_allo Achilles_allo quad ny.;
	if F11 in(0,1);
run;

proc power; 
  twosamplefreq test=fisher 
  groupproportions = (0.0082  0.0054) 
  power = .
  groupns =(854 186)
  sides = 2;
run;

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
