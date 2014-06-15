options nonumber nodate nobyline;
proc format;
value group  1="Diagnosis"
				  2="Treatment"
				 99=" "
		;

value item 1="Left Eye ROP Develop?"
				2="Right Eye ROP Develop?"
				3="Left Eye Plus Disease Develop?"
				4="Right Eye Plus Disease Develop?"
				5="Left Eye Retinal Ablation Performed Using Laser?"
				6="Right Eye Retinal Ablation Performed Using Laser?"
				7="Left Eye Retinal Ablation Performed Using Cryotherapy?"
				8="Right Eye Retinal Ablation Performed Using Cryotherapy?"
				9="Left Eye Scleral Buckle Performed?"
				10="Right Eye Scleral Buckle Performed?"
				11="Left Eye Vitrectomy Performed?"
				12="Right Eye Vitrectomy Performed?"
				99=" "
		;
value code 1="Yes"
				0="No"
				9="Yes*"
				99="Unknown"
				100="Total"
		;

value stage 1="I"
				 2="II"
				 3="III"
				 4="IV"
				 100="Total"
		;

value gs  1="ROP"
				2="Plus"
				99=" "
				100="Total"
				;


value eye  0="No"
				1="Left Eye"
				2="Right Eye"
				3="Both Eyes"
				99=" "
				100="Total"
			;

run;


data rop;
	set cmv.rop;
	center=floor(id/1000000);
	format center center.;

	if LeftRetinopathy=1 and RightRetinopathy=1 then rop=3; 
	   else do; if LeftRetinopathy=1 then rop=1;  if RightRetinopathy=1 then rop=2; 
	            if LeftRetinopathy=0 and RightRetinopathy=0 then rop=0;
	        end;
	if LeftPlus=1 and  RightPlus=1 then plus=3; else if LeftPlus=1 then plus=1; else if RightPlus=1 then plus=2; else plus=0;

	keep id center LeftRetinopathy RightRetinopathy rop LeftRetinopathyStage RightRetinopathyStage LeftPlus RightPlus plus LeftLaser
	 			RightLaser LeftCryotherapy RightCryotherapy LeftScleBuckle RightScleBuckle LeftVitrectomy RightVitrectomy ;
	format rop plus eye.;

run;

proc sort data=rop out=rop_num nodupkey; by id; run;
proc means data=rop_num noprint;
    class center;
    output out=wbh n(center)=n;
run;

data _null_;
    set wbh;
    if center=1 then call symput("n1", compress(n));
    if center=2 then call symput("n2", compress(n));
    if center=3 then call symput("n3", compress(n));
    if center=. then call symput("n", compress(n));
run;

%macro rop(data,out,varlist);
data &out;
    if 1=1 then delete;
run;

%let i=1;
%let var=%scan(&varlist,&i);
%do %while (&var NE );

data tmp;
    set &data;
    if &var^=0;
run;

proc sort nodupkey; by id &var;run; 

proc freq data=tmp;
	table &var*center/norow nocol nopercent;
	ods output crosstabfreqs=diag&i(drop=table  _TYPE_  _TABLE_ Missing);
run;

data diag&i;  
    set diag&i;
    idx=&i;
    *if center=. then delete;
   	if &var=. then delete;
	rename &var=code;
run;

data &out;
    set &out diag&i;
run;

%let i=%eval(&i+1);
%let var=%scan(&varlist, &i);
%end;
proc transpose data=&out out=&out; var frequency; by idx code;run; 

data &out;
    set &out; by idx code;
    f1=col1/&n1*100;     f2=col2/&n2*100;     f3=col3/&n3*100;     f4=col4/&n*100;
    tc1=col1||"/&n1"||"("||put(f1,4.1)||"%)";
        tc2=col2||"/&n2"||"("||put(f2,4.1)||"%)";
            tc3=col3||"/&n3"||"("||put(f3,4.1)||"%)";
                tc4=col4||"/&n"||"("||put(f4,4.1)||"%)";
                
    %if &out=diag %then %do; 
        if idx=2 then do;
        f1=.;     f2=col1/&n2*100;     f3=col2/&n3*100;     f4=col3/&n*100;
        tc1="-";
            tc2=col1||"/&n2"||"("||put(f2,4.1)||"%)";
                tc3=col2||"/&n3"||"("||put(f3,4.1)||"%)";
                    tc4=col3||"/&n"||"("||put(f4,4.1)||"%)";   
        end;
    %end;
    %if &out=diag or &out=stage %then %do; if code=0 then delete; %end;
        %if &out=tab %then %do; if code=99 then delete; if idx<=4 then sec=1; else sec=2; %end;
    drop _name_ _label_;
run;

%mend rop;

%let varlist=rop plus;
%rop(rop,diag,&varlist);run;
data diag;
    length idx0 $20;
    set diag; by idx code;
    
    idx0=put(idx, gs.);
    if not first.idx then idx0=" ";
   	format idx gs. code eye.;
run;

proc print;run;


*********************************************************************************;

data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	center=floor(id/1000000);
	format center center.;
run;

proc sort data=all_pat nodupkey; by id;run;

proc means data=all_pat noprint;
	class center;
	output out=all_pat n(center)=num;
run;

data _null_;
	set all_pat;
	if center=1 then call symput("m1",compress(num));
	if center=2 then call symput("m2",compress(num));
	if center=3 then call symput("m3",compress(num));
	if center=. then call symput("m",compress(num));
run;

data rop_tab;
    f1=&n1/&m1*100;     f2=&n2/&m2*100;     f3=&n3/&m3*100;     f4=&n/&m*100;
    tc1=&n1||"/&m1"||"("||put(f1,4.1)||"%)";
        tc2=&n2||"/&m2"||"("||put(f2,4.1)||"%)";
            tc3=&n3||"/&m3"||"("||put(f3,4.1)||"%)";
                tc4=&n||"/&m"||"("||put(f4,4.1)||"%)";
run;


%let varlist=LeftRetinopathy RightRetinopathy LeftPlus RightPlus LeftLaser RightLaser LeftCryotherapy RightCryotherapy LeftScleBuckle RightScleBuckle LeftVitrectomy RightVitrectomy;
%rop(rop,tab,&varlist);run;

proc sort data=tab; by sec idx code;run;
data temp;
    do idx=7 to 12; sec=2; code=0; tc1="-"; tc2="-"; tc3="-"; tc4="-"; output; end;
run;

data tab;
    length idx0 $50 sec0 $10;
    set tab temp; by sec idx code;

    idx0=put(idx, item.);
    if not first.idx then idx0=" ";
    sec0=put(sec, group.);
    if not first.sec then sec0=" ";
    
   	format idx item. code code. sec group.;
run;

proc print;run;


*********************** This is for stage analysis **************************;
*****************************************************************************;
%let varlist=LeftRetinopathyStage RightRetinopathyStage;
%rop(rop,stage,&varlist);run;

data stage;
    length idx0 $20;
    set stage; by idx code;
      
    idx0=put(idx, eye.);
    if not first.idx then idx0=" ";   
       
   	format idx eye. code stage.;
run;

proc print;run;


*ods rtf file = "&output./rop.rtf" style=journal startpage=no bodytitle;
ods rtf file = "rop.rtf" style=journal startpage=no bodytitle;

title "Incidence of ROP";
proc print data=rop_tab noobs label style = [just=center];
var tc4 tc1-tc3;
label tc4='Overall(%)'
      tc1='EUHM(%)'
      tc2='Grady(%)'
      tc3='Northside(%)'
;

run;

title  "Incidence of ROP (Unilateral or Bilateral)";
proc print data=diag noobs label split="#";

var idx0/style(data)=[cellwidth=1.0in just=center];
var code/style(data)=[cellwidth=1.2in just=left];
var tc4 tc1 tc2  tc3/style=[cellwidth=1.25in just=center];
label  tc1="EUHM#(n=&n1)"
	   tc2="Grady#(n=&n2)"
	   tc3="Northside#(n=&n3)"
	   tc4="Overall#(n=&n)"
	   idx0="Diagnosis"
	   code="Left or Right Eye"
		;
run;


title  "Stage of ROP";
proc print data=stage noobs label split="*";
var idx0/style(data)=[cellwidth=1in just=left];
var code;
var tc4 tc1 tc2  tc3/style=[cellwidth=1.25in just=center];
label  tc1="EUHM#(n=&n1)"
	   tc2="Grady#(n=&n2)"
	   tc3="Northside#(n=&n3)"
	   tc4="Overall#(n=&n)"
		 code="Stage"
		 idx0="ROP Develop?"
		;
run;


ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=1.2in RIGHTMARGIN=1.2in}
Note: Stage I : Demarcation Line; Stage II : Ridge; Stage III : Extraretinal Fibrovascular Proliferation; Stage IV : Sub-total Retinal Detachment; Stage V : Total Retinal Detachment.';

ods rtf startpage=yes;

title  "Summary of ROP Data (n=&n)";
proc print data=tab noobs label split="#" style(data)=[just=left];
var sec0;
var idx0/style(data)=[cellwidth=2in];
var code tc4 tc1 tc2  tc3/style=[cellwidth=1in just=center];
label  tc1="EUHM#(n=&n1)"
	   tc2="Grady#(n=&n2)"
	   tc3="Northside#(n=&n3)"
	   tc4="Overall#(n=&n)"
       code="Results"
	   sec0="Section"
	   idx0="Item"
		;
run;
/*
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
*For one LBWI, both eyes are treated with retinal ablation laser.';
*/
ods rtf close;
