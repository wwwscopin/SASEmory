PROC IMPORT OUT= WORK.stiff 
            DATAFILE= "H:\SAS_Emory\Consulting\Desai Mihir\Ex-Fix.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents data=stiff;run;

proc format; 
	value type
		1="11mm-1"
		2="11mm-2"
		3="11mm-X"
		4="8mm-1"
		5="8mm-2"
		6="8mm-X";
run;

data type0; 
	set stiff; 
	if _n_=4 then delete;
	if _n_=1 then type=1;
	if _n_=2 then type=2;
	if _n_=3 then type=3;
	if _n_=5 then type=4;
	if _n_=6 then type=5;
	if _n_=7 then type=6;

	*stiff=mean(of Stiffness_1, Stiffness_2, Stiffness_3, Stiffness_4);
	rename Force_to_10_mm__N_=F10 Force_to_20_mm__N_=F20;
	drop Std__Dev____ Average_Stiffness__N_mm_;
	format type type.;
run;

proc print;run;

proc glm data = type0;
  model Stiffness_1 Stiffness_2 Stiffness_3 Stiffness_4 = ;
  repeated d ;
run;
quit;


data type; 
	set type0(keep=type Stiffness_1 rename=(Stiffness_1=stiff))
		type0(keep=type Stiffness_2 rename=(Stiffness_2=stiff))
		type0(keep=type Stiffness_3 rename=(Stiffness_3=stiff))
		type0(keep=type Stiffness_4 rename=(Stiffness_4=stiff));
run;

proc sort; by type; run;

proc glm data =type;
  class type;
  model stiff = type;
  means type;
run;
quit;

%macro type(data, i, j);
*ods trace on/label listing;
proc npar1way data = type(where=(type in(&i, &j))) wilcoxon;
  class type;
  var stiff;
  exact wilcoxon;
  ods output WilcoxonTest=wp&i&j;
run;
*ods trace off;

	data wp&i&j;
		length pv $6;
		set wp&i&j;
		if _n_=14;
		item="Compare between "|| put(&i, type.)||" and " || put(&j,type.);
		pv=put(nvalue1, 7.4);
		if nvalue1<0.001 then pv='<0.001';
		keep item  pv nvalue1;
	run;

%mend type;

%type(type, 1, 2);
%type(type, 1, 3);
%type(type, 1, 4);
%type(type, 1, 5);
%type(type, 1, 6);
%type(type, 2, 3);
%type(type, 2, 4);
%type(type, 2, 5);
%type(type, 2, 6);
%type(type, 3, 4);
%type(type, 3, 5);
%type(type, 3, 6);
%type(type, 4, 5);
%type(type, 4, 6);
%type(type, 5, 6);

data comp; 
	set wp12 wp13 wp14 wp15 wp16 wp23 wp24 wp25 wp26 wp34 wp35 wp36 wp45 wp46 wp56;
run;


proc print;
var item pv;
run;




