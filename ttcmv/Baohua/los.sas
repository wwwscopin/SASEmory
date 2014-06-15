%include "&include./monthly_toc.sas";
options /*orientation=landscape*/ nobyline nodate nonumber /*papersize=("7" "8")*/;


libname wbh "/ttcmv/sas/programs";

proc contents data=cmv.endofstudy;run;

data test;
    merge cmv.endofstudy(in=A) cmv.comp_pat(in=B);by id;
    if A then end=1; 
    if B then comp=1;
    if A and dob^=.;
run;

proc print;
var id StudyLeftDate dob end comp;
run;



proc sql;
 create table los as 
	select a.id, a.StudyLeftDate, b.dob, a.StudyLeftDate-b.dob as day
	from cmv.endofstudy as a, cmv.comp_pat as b
	where a.id=b.id;


proc sort; by id;run;

proc means data=los median;
var day;
output out=wbh median(day)=md;
run;

data _null_;
    set wbh;
    call symput("md", compress(md));
run;

data _null_;
	set los;
	call symput("n", compress(_n_));
run;

proc format; 
    value dd 0="1-7" 7="8-14" 14="15-21" 21="22-28" 28="29-35" 35="36-42" 42="43-49" 49="50-56" 56="57-63" 
    63="64-70" 70="71-77" 77="78-84" 84="85-91" 91="92-98" 98="99-105";
run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=all device=pslepsfc gunit=pct border /*colors=(orange green red)*/
	    htitle=3.5 htext=3 xmax=10 in  xpixels=5000  ymax=7 in ypixels=3500;
	    
	    *goptions device=png target=png xmax=10 in  xpixels=5000  ymax=7 in ypixels=3500;

 	
		%let description = Bar Chart for Length of Stay(n=&n, median=&md days);
		%let mp=(0 to 100 by 7);
		
		axis1 label=(a=90 h=3 "#Pat") order=(0 to 120 by 10) minor=none;
		axis2 label=(a=0 h=3 "Length of Stay(days)") value=(h= 2);
		
		title2 &title_los (n=&n, median=&md days);

		pattern1 color=orange;
		Proc gchart data=los gout=wbh.graphs;
			vbar day/ midpoints=&mp raxis=axis1 maxis=axis2 space=1 coutline=black width=7.5;
			format day dd.;
		run;

options orientation=landscape;
ods ps file = "los.ps";
ods pdf file = "los.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=v2s nofs; * L2R2s;
     treplay 1:1 2:2;
     *treplay 1:3 2:4;
run;
ods pdf close;
ods ps close;

ods rtf file = "/ttcmv/sas/output/monthly/&file_los.los.rtf" style=journal toc_data startpage = no bodytitle;
                ods noproctitle proclabel "";
                title "";
proc greplay igout = wbh.graphs tc=sashelp.templt template=whole nofs; * L2R2s;
     treplay 1:1;
     *treplay 1:3 2:4;
run;
                *ods rtf text = "{\sectd \pard \par \sect}"; 
ods rtf close;

