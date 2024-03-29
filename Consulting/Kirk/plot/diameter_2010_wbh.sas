*** save.gg_sep15_2010;
*libname save '/home/keasle2/Sokoloff/';
libname save '/home/bwu2/Kirk';

options ls=132 ps=100;

/*
data one; set save.gg_sep15_2010;  if _n_ le 1893;  proc print data=one(obs=25);
proc freq; tables subject phenotype; run;

proc means; class PHENOTYPE; var diameter;

proc mixed empirical data=one;
     class SUBJECT PHENOTYPE;
    model diameter= PHENOTYPE;
    repeated /sub=SUBJECT type=cs;
    contract 'mhciia vs oths' phenotype -1 -1 -1 4 -1;
*    estimate 'linear' phenotype -2 -1 0 1 2;
*** estimate 'linear,A' phenotype -2 -1 0 1 2 region*phenotype    -2 -1 0 1 2        0 0 0 0;
*** estimate 'linear,P' phenotype -2 -1 0 1 2 region*phenotype      0 0 0 0 0      -2 -1 0 1 2;
    lsmeans PHENOTYPE /alpha=.05 cl; * pdiff;
    ods output lsmeans=save.diameter;  run;

ODS TRACE OFF;
*/

proc print data=save.diameter;   run;

data outdia; set save.diameter;
  LC=LOWER; UC=UPPER; SEM=STDERR; MEAN=ESTIMATE;
   /*
 if _n_ ge 8 and _n_ le 12 then do;  group=1; end; ** region a;
 if _n_ ge 13 and _n_ le 17 then do; group=2; end; ** region p;
     */
 if _n_=1 then do;  age=0.9; end;  **  phenotype MCHI;

 if _n_=2 then do;  age=3.9; end;  ** MCHI-IIa;

 if _n_=3 then do;  age=4.9; end;  ** MCHI-IIx;

 if _n_=4 then do;  age=1.9; end;  ** MHCIIIa;

 if _n_=5 then do;  age=2.9; end;  ** MHCIIx;
proc sort; by age;

GOPTIONS RESET=ALL htext=2;

 *Filename GSASFILE '/home/keasle2/Sokoloff/diameter.ps';
 Filename GSASFILE '/home/bwu2/Kirk/diameter.ps';
Goptions device=APPLELW htext=2 ftext=swiss ROTATE=LANDSCAPE
         GACCess=GSASFILE GSFMODE=REPLACE gsFname=GSASFILE
         GEND='0a'x gprolog='25210d0a'x;


PROC PRINT;
proc format;  VALUE group 1='Anterior' 2='Posterior' ;

 value age               0='        '
                         1='MHCI    '
                         2='MHCIIA '
                         3='MHCIIX '
                         4='MHCI-IIA  '
                         5='MHCI-IIX  '
                         6='        ';


DATA B1; SET outdia;

xsys='2'; ysys='2';
  X=age;
  y=mean;
FUNCTION='MOVE';  OUTPUT;
Y=LC;
FUNCTION='DRAW'; line=1; size=10; color='black';  OUTPUT;
LINK TIPS;
Y=UC;
FUNCTION='DRAW'; line=1; size=10; color='black';  OUTPUT;
LINK TIPS;


TIPS: *** dRAW TOP AND BOTTOM OF BARS;
  X=age-.03; FUNCTION='DRAW'; line=1; size=.2; color='black'; OUTPUT;
  X=age+.03; FUNCTION='DRAW'; line=1; size=.2; color='black'; OUTPUT;
  X=age;     FUNCTION='MOVE';                                 OUTPUT;
return;

  axis1 label=(f=swiss h=2 'Phenotype ') value=(f=swiss h=2.0) order=0 to 6 by 1;
  axis2 label=(f=swiss h=2 a=90 'Diameter') value=(f=swiss h=1) order=20 to 60 by 5;


proc gplot data=outdia gout=save.graphs;
  plot mean*age / frame haxis=axis1 vaxis=axis2
                       anno=b1;
            **         description='diameter' name='diameter';

symbol1 h=1.5 i=join value=dot color=black line=1 w=14;
** symbol2 h=1.5 i=join value=triangle color=black line=1 w=10;
symbol2 h=1.5 i=join value=circle color=black line=1; * w=5;
** label group='Group';
TITLE H=2.5 F=SWISSb '                                                                   ';
* Title 'Mean and 95% Confidence Intervals By Treatment Group for HDRS (n=62)';
format age age.; *** group group.;
  run; QUIT; RUN;
/*
 *************************************************************************;
proc means data=one; class PHENOTYPE; var PERIMETER;

proc mixed empirical data=one;
     class SUBJECT PHENOTYPE;
    model PERIMETER= PHENOTYPE;
    repeated /sub=SUBJECT type=cs;
    contract 'mhciia vs oths' phenotype -1 -1 -1 4 -1;
*    estimate 'linear' mhc_phenotype -2 -1 0 1 2;
*** estimate 'linear,A' phenotype -2 -1 0 1 2 region*phenotype    -2 -1 0 1 2        0 0 0 0;
*** estimate 'linear,P' phenotype -2 -1 0 1 2 region*phenotype      0 0 0 0 0      -2 -1 0 1 2;
    lsmeans PHENOTYPE /alpha=.05 cl; * pdiff;
    ods output lsmeans=save.perimeter;

ODS TRACE OFF;
*/
proc print data=save.perimeter;   run;



data outperi; set save.perimeter;
  LC=LOWER; UC=UPPER; SEM=STDERR; MEAN=ESTIMATE;

 if _n_=1 then do;  age=0.9; end;  **  phenotype MCHI;

 if _n_=2 then do;  age=3.9; end;  ** MCHI-IIa;

 if _n_=3 then do;  age=4.9; end;  ** MCHI-IIx;

 if _n_=4 then do;  age=1.9; end;  ** MHCIIIa;

 if _n_=5 then do;  age=2.9; end;  ** MHCIIx;
proc sort; by age;

GOPTIONS RESET=ALL htext=2;

 Filename GSASFILE '/home/bwu2/Kirk/perimeter.ps';
Goptions device=APPLELW htext=2 ftext=swiss ROTATE=LANDSCAPE
         GACCess=GSASFILE GSFMODE=REPLACE gsFname=GSASFILE
         GEND='0a'x gprolog='25210d0a'x;


PROC PRINT;


DATA B1; SET outperi;

xsys='2'; ysys='2';
  X=age;
  y=mean;
FUNCTION='MOVE';  OUTPUT;
Y=LC;
FUNCTION='DRAW'; line=1; size=10; color='black';  OUTPUT;
LINK TIPS;
Y=UC;
FUNCTION='DRAW'; line=1; size=10; color='black';  OUTPUT;
LINK TIPS;


TIPS: *** dRAW TOP AND BOTTOM OF BARS;
  X=age-.03; FUNCTION='DRAW'; line=1; size=.2; color='black'; OUTPUT;
  X=age+.03; FUNCTION='DRAW'; line=1; size=.2; color='black'; OUTPUT;
  X=age;     FUNCTION='MOVE';                                 OUTPUT;
return;

  axis1 label=(f=swiss h=2 'Phenotype ') value=(f=swiss h=2.0) order=0 to 6 by 1;
  axis2 label=(f=swiss h=2 a=90 'Perimeter') value=(f=swiss h=2.5) order=60 to 150 by 10;


proc gplot data=outperi gout=save.graphs;
  plot mean*age / frame haxis=axis1 vaxis=axis2
                       anno=b1;
***                      description='fig4a' name='fig4a';

symbol1 h=1.5 i=join value=dot color=black line=1 w=14;
** symbol2 h=1.5 i=join value=triangle color=black line=1 w=10;
symbol2 h=1.5 i=join value=circle color=black line=1; * w=5;
** label group='Group';
TITLE H=2.5 F=SWISSb '                                                                   ';
* Title 'Mean and 95% Confidence Intervals By Treatment Group for HDRS (n=62)';
format age age.; *** group group.;
  run; QUIT; RUN;

/*
proc means data=one; class PHENOTYPE; var csa;

proc mixed empirical data=one;
     class SUBJECT PHENOTYPE;
    model csa= PHENOTYPE;
    repeated /sub=SUBJECT type=cs;
    contrast 'mhciia vs oths' phenotype -1 -1 -1 4 -1;
*   estimate 'linear' phenotype -2 -1 0 1 2;
*** estimate 'linear,A' phenotype -2 -1 0 1 2 region*phenotype    -2 -1 0 1 2        0 0 0 0;
*** estimate 'linear,P' phenotype -2 -1 0 1 2 region*phenotype      0 0 0 0 0      -2 -1 0 1 2;
    lsmeans PHENOTYPE /alpha=.05 cl; * pdiff;
    ods output lsmeans=save.area;

ODS TRACE OFF;
proc print data=save.area;   run;
*/


data outcsa; set save.area;
  LC=LOWER; UC=UPPER; SEM=STDERR; MEAN=ESTIMATE;  ** if _n_ ge 8;

 if _n_=1 then do;  age=0.9; end;  **  phenotype MCHI;

 if _n_=2 then do;  age=3.9; end;  ** MCHI-IIa;

 if _n_=3 then do;  age=4.9; end;  ** MCHI-IIx;

 if _n_=4 then do;  age=1.9; end;  ** MHCIIIa;

 if _n_=5 then do;  age=2.9; end;  ** MHCIIx;
proc sort; by age;


GOPTIONS RESET=ALL htext=2;

 Filename GSASFILE '/home/bwu2/Kirk/csa.ps';
Goptions device=APPLELW htext=2 ftext=swiss ROTATE=LANDSCAPE
         GACCess=GSASFILE GSFMODE=REPLACE gsFname=GSASFILE
         GEND='0a'x gprolog='25210d0a'x;


PROC PRINT;

DATA B1; SET outcsa;

xsys='2'; ysys='2';
  X=age;
  y=mean;
FUNCTION='MOVE';  OUTPUT;
Y=LC;
FUNCTION='DRAW'; line=1; size=10; color='black';  OUTPUT;
LINK TIPS;
Y=UC;
FUNCTION='DRAW'; line=1; size=10; color='black';  OUTPUT;
LINK TIPS;


TIPS: *** dRAW TOP AND BOTTOM OF BARS;
  X=age-.03; FUNCTION='DRAW'; line=1; size=.2; color='black'; OUTPUT;
  X=age+.03; FUNCTION='DRAW'; line=1; size=.2; color='black'; OUTPUT;
  X=age;     FUNCTION='MOVE';                                 OUTPUT;
return;

  axis1 label=(f=swiss h=2 'Phenotype ') value=(f=swiss h=2.0) order=0 to 6 by 1;
  axis2 label=(f=swiss h=2 a=90 'C S A') value=(f=swiss h=2.5) order=200 to 1500 by 100;


proc gplot data=outcsa gout=save.graphs;
  plot mean*age / frame haxis=axis1 vaxis=axis2
                       anno=b1;
***                      description='fig4a' name='fig4a';

symbol1 h=1.5 i=join value=dot color=black line=1 w=14;
** symbol2 h=1.5 i=join value=triangle color=black line=1 w=10;
symbol2 h=1.5 i=join value=circle color=black line=1; * w=5;
** label group='Group';
TITLE H=2.5 F=SWISSb '                                                                   ';
* Title 'Mean and 95% Confidence Intervals By Treatment Group for HDRS (n=62)';
format age age.; *** group group.;
  run; QUIT; RUN;


filename output "fig_3panel.jpg";

goptions rotate = portrait reset=global gsfmode=replace gunit=pct border
ctext=black ftitle=swissb ftext=swiss htitle=3 htext=3
device=jpeg gsfname=output gsfmode=replace;

ods pdf file="fig_3panel.pdf";
ods ps file="fig_3panel.ps";
ods printer sas printer="PostScript EPS Color" file='fig_3panel.eps';
proc greplay nofs NOBYLINE;
igout save.graphs;
list igout;
tc template;
tdef t1 1 /llx=20   ulx=20   lrx=80  urx=80  lly=0    uly=34     lry=0      ury=34
        2 /llx=20   ulx=20   lrx=80  urx=80  lly=34   uly=68     lry=34     ury=68
        3 /llx=20   ulx=20   lrx=80  urx=80  lly=68   uly=102    lry=68     ury=102
			;
template t1;
tplay 1:2  2:3  3:1;
run; quit;
ods printer close;
ods ps close;
ods pdf close;















