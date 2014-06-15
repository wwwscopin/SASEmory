PROC IMPORT OUT= WORK.quad0 
            DATAFILE= "H:\SAS_Emory\Consulting\Mitchell Phillip\Quad statistics.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

proc format ;
	value gender 0="F" 1="M";
	value ht 1="A" 2="B" 3="C" 4="D";
	value idx 1="PT_remaining" 2="QT_6cm_remaining" 3="QT_8cm_remaining" 4="PT_graft_volume" 5="QT_graft_volume";
run;

data quad;
	set quad0(rename=(gender=gender0));
	if gender0="F" then gender=0; else if gender0="M" then gender=1; 
	if Height_category="A" then ht=1; else if Height_category="B" then ht=2; else if Height_category="C" then ht=3; else if Height_category="D" then ht=4;  
	rename __1_thickness=thick31 __1_thickness0=thick61 __3_thickness=thick63 _cm_sag=cm_sag;
	format gender gender. ht ht.;
run;
/**** Q1 ******************************/;

/*
proc ttest data = quad;
  paired PT_remaining*(QT_6cm_remaining QT_8cm_remaining);
  paired PT_graft_volume*(QT_graft_volume);
run;
*/

data quad1;
  set quad;
  diff6 = PT_remaining-QT_6cm_remaining;
  diff8 = PT_remaining-QT_8cm_remaining;
  diff_vol = PT_graft_volume-QT_graft_volume;
run;

%macro avg(data,var,idx);
proc means data =&data n mean median stddev clm maxdec=4;
  var &var;
  *output out=avg /autoname;
  ods output summary=avg;
run;

data avg_&var;
	idx=&idx;
	set avg;
	keep idx &var._mean &var._stddev &var._median &var._n; 
	rename &var._mean=avg &var._stddev=std &var._median=median &var._n=n;
run;

%mend avg;

%avg(quad1, PT_remaining, 1);
%avg(quad1, QT_6cm_remaining,2);
%avg(quad1, QT_8cm_remaining,3);
%avg(quad1, PT_graft_volume,4);
%avg(quad1, QT_graft_volume,5);

data avg;
	set avg_PT_remaining
		avg_QT_6cm_remaining
		avg_QT_8cm_remaining
		avg_PT_graft_volume
		avg_QT_graft_volume;
	format idx idx.;
run;
proc print;run;

proc univariate data =quad1 cibasic;
  var diff6 diff8 diff_vol;
run;


/**** Q2 ******************************/;

%macro test_corr(data, outcome, var);
proc glm data=&data;
	model &outcome=&var;
run;
%mend test_corr;
%test_corr(quad, pt_length, height);
%test_corr(quad, pt_length, weight);
%test_corr(quad, pt_length, age);
%test_corr(quad, pt_length, BMI);

%test_corr(quad, qt_length, height);
%test_corr(quad, qt_length, weight);
%test_corr(quad, qt_length, age);
%test_corr(quad, qt_length, BMI);


proc means data=quad mean median std;
class gender;
var pt_length qt_length;
run;

proc npar1way data=quad wilcoxon;
class gender;
var pt_length qt_length;
run;

proc corr data=quad spearman;
	var pt_length qt_length;
	with height weight age BMI;
run;
/*
proc sgscatter data=quad;
  title "Scatterplot for PT/QT Length";
  matrix pt_length qt_length height weight age BMI;         
run;
*/

proc sgscatter data=QUAD;
  title "Scatterplot for PT/QT Length";
  *plot (pt_length qt_length)*(height weight age BMI)/ pbspline;
   compare x=(height weight age BMI)
          y=(pt_length qt_length) /*/reg ellipse=(type=mean) spacing=4*/;
	footnote " ";
run;
/**** Q3 ******************************/;
/*
proc means data=quad mean stddev clm;
	class ht; 
	var PT_length QT_length;
run;
*/

/**** Tukey Cramer Method ******************************/;
PROC GLM DATA=quad;
  CLASS ht;
  MODEL pt_length=ht ;
  MEANS ht/ TUKEY ;
  lsmeans ht/ pdiff adjust=tukey ;
RUN;

PROC GLM DATA=quad;
  CLASS ht;
  MODEL qt_length=ht ;
  MEANS ht/ TUKEY ;
  lsmeans ht/ pdiff adjust=tukey ;
RUN;

/**** Bonfferoni Method ******************************/;
PROC multtest DATA=quad boot n = 100 s = 12345 bon notables pvals;
  CLASS ht;
  contrast 'using only a main effect' 1 -1 0 0;
  test mean(pt_length qt_length);
RUN;

/**** Q4 ******************************/;

proc glm data=quad;
	model cm_sag=qt_length;
run;
proc glm data=quad;
	model cm_sag=QT_thick_at_6;
run;
proc glm data=quad;
	model cm_sag=QT_graft_volume;
run;

proc corr data=quad spearman;
	var cm_sag;
	with qt_length QT_thick_at_6 QT_graft_volume;
run;
/*
proc sgscatter data=QUAD;
  title "Scatterplot for 3cm SAG vs (qt-length QT_thick_at_6 QT_graft_volume)";
  plot (cm_sag)*(qt_length QT_thick_at_6 QT_graft_volume);
run;
*/

proc sgscatter data=QUAD;
  title "Scatterplot for 3cm SAG vs (qt-length QT_thick_at_6 QT_graft_volume)";
  compare y=(cm_sag)
		  x=(qt_length QT_thick_at_6 QT_graft_volume);
run;

proc reg data=quad outest=regdata noprint;
   model cm_sag=QT_thick_at_6 / clm;
run;

/* Place the regression equation in a macro variable. */
data _null_;
   set regdata;
   call symput('eqn',"3cm-SAG="||Intercept||" + "||QT_thick_at_6||"*QT_thick_at_6cm");
run;

proc sgplot data=quad;
   title " ";
   reg x=QT_thick_at_6 y=cm_sag / clm;

   /* The following INSET statement can be used as */ 
   /* an alternative to the FOOTNOTE statement */
/* inset "&eqn" / position=bottomleft;  */

   footnote1 j=l "Regression Equation";
   footnote2 j=l "&eqn";
run;


proc reg data=quad outest=regdata noprint;
   model cm_sag=QT_graft_volume / clm;
run;

/* Place the regression equation in a macro variable. */
data _null_;
   set regdata;
   call symput('eqn',"3cm-SAG="||Intercept||" + "||QT_graft_volume||"*QT_graft_volume");
run;

proc sgplot data=quad;
   title " ";
   reg x=QT_graft_volume y=cm_sag / clm;

   /* The following INSET statement can be used as */ 
   /* an alternative to the FOOTNOTE statement */
/* inset "&eqn" / position=bottomleft;  */

   footnote1 j=l "Regression Equation";
   footnote2 j=l "&eqn";
run;


/**** Q5 ******************************/;
/*
proc univariate data=quad cibasic; 
	var thick31 thick61 thick63;
run;
*/
proc means data=quad n mean stddev clm; 
	var thick31 thick61 thick63;
run;

proc print;run;
