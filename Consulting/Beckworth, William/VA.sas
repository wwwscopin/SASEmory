PROC IMPORT OUT= WORK.va0 
            DATAFILE= "H:\SAS_Emory\Consulting\Beckworth, William\VAData 7-8-12.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

proc freq; 
tables C3_4Disc_Height;
run;

proc format;
	value cdh   0="Normal" 1="Mild" 2="Moderate" 3="Severe" 4="Fused Congentially";
	value amp   0="Anterior" 1="Posterior" 2="Mid";
	value pyn   0="Not Posterior" 1="Posterior";
	value dyn   0=">=2mm" 1="<2mm";
	value yn    0="No" 1="Yes";
	value domin 0="L" 1="R" 2="C";
	value sex   0="Female" 1="Male";
	value group 1="C2-3" 2="C3-4" 3="C4-5" 4="C5-6" 5="C6-7";
run;

data va;
	set va0(rename=(R_distance4=rd4 ));
	if _n_<188;
	r_distance4=rd4+0;

	if sex="F" then gender=0; else gender=1;
	if dominance="L" then domin=0; else if dominance="R" then domin=1; else domin=2;
	if lowcase(C2_3_Disc_Height)="normal" then c23dh=0;  else if  lowcase(C2_3_Disc_Height)="mild" then c23dh=1;  else if lowcase(C2_3_Disc_Height)="moderate" then c23dh=2; 
		else if  lowcase(C2_3_Disc_Height)="severe" then c23dh=3; else if  lowcase(C2_3_Disc_Height)="fused congenitally" then c23dh=4; 

	if lowcase(C3_4Disc_Height)="normal" then c34dh=0;  else if  lowcase(C3_4Disc_Height)="mild" then c34dh=1;  else if lowcase(C3_4Disc_Height)="moderate" then c34dh=2; 
		else if  lowcase(C3_4Disc_Height)="severe" then c34dh=3; else if  lowcase(C3_4Disc_Height)="fused congenitally" then c34dh=4; 

	if lowcase(C4_5_Disc_Height)="normal" then c45dh=0;  else if  lowcase(C4_5_Disc_Height)="mild" then c45dh=1;  else if lowcase(C4_5_Disc_Height)="moderate" then c45dh=2; 
		else if  lowcase(C4_5_Disc_Height)="severe" then c45dh=3; else if  lowcase(C4_5_Disc_Height)="fused congenitally" then c45dh=4; 

	if lowcase(C5_6_Disc_Height)="normal" then c56dh=0;  else if  lowcase(C5_6_Disc_Height)="mild" then c56dh=1;  else if lowcase(C5_6_Disc_Height)="moderate" then c56dh=2; 
		else if  lowcase(C5_6_Disc_Height)="severe" then c56dh=3; else if  lowcase(C5_6_Disc_Height)="fused congenitally" then c56dh=4; 

	if lowcase(C6_7_Disc_Height)="normal" then c67dh=0;  else if  lowcase(C6_7_Disc_Height)="mild" then c67dh=1;  else if lowcase(C6_7_Disc_Height)="moderate" then c67dh=2; 
		else if  lowcase(C6_7_Disc_Height)="severe" then c67dh=3; else if  lowcase(C6_7_Disc_Height)="fused congenitally" then c67dh=4; 
		

	if L_Location="Anterior" then ll=0;  else if L_Location="Posterior" then ll=1;  else ll=2;
	if R_Location="Anterior" then rl=0;  else if r_Location="Posterior" then rl=1;  else rl=2;

	if L_Location1="Anterior" then ll1=0;  else if L_Location1="Posterior" then ll1=1;  else ll1=2;
	if R_Location1="Anterior" then rl1=0;  else if r_Location1="Posterior" then rl1=1;  else rl1=2;

	if L_Location2="Anterior" then ll2=0;  else if L_Location2="Posterior" then ll2=1;  else ll2=2;
	if R_Location2="Anterior" then rl2=0;  else if r_Location2="Posterior" then rl2=1;  else rl2=2;

	if L_Location3="Anterior" then ll3=0;  else if L_Location3="Posterior" then ll3=1;  else ll3=2;
	if R_Location3="Anterior" then rl3=0;  else if r_Location3="Posterior" then rl3=1;  else rl3=2;

	if L_Locatoion="Anterior" then ll4=0;  else if L_Locatoion="Posterior" then ll4=1;  else ll4=2;
	if R_Location4="Anterior" then rl4=0;  else if r_Location4="Posterior" then rl4=1;  else rl4=2;

	if L_Distance<2 then ldgrp=1; else ldgrp=0;
	if R_Distance<2 then rdgrp=1; else rdgrp=0;

	if L_Distance1<2 then ld1grp=1; else ld1grp=0;
	if R_Distance1<2 then rd1grp=1; else rd1grp=0;

	if L_Distance2<2 then ld2grp=1; else ld2grp=0;
	if R_Distance2<2 then rd2grp=1; else rd2grp=0;

	if L_Distance3<2 then ld3grp=1; else ld3grp=0;
	if R_Distance3<2 then rd3grp=1; else rd3grp=0;

	if L_Distance4<2 then ld4grp=1; else ld4grp=0;
	if R_Distance4<2 then rd4grp=1; else rd4grp=0;

	level=sum(of posterior posterior1-posterior9);
	dsum=sum(of ldgrp rdgrp  ld1grp rd1grp ld2grp rd2grp ld3grp rd3grp ld4grp rd4grp);
	
	if level>=1 then post=1; else post=0;
	if dsum>=1 then d2mm=1; else d2mm=0;

	id=_n_;
	
	pyear=Pack_Years+0;
	dc47yn=__2_mm_from_C4_7_Y_N+0;

	post2mm_any=((posterior*ldgrp)|(posterior1*rdgrp))|((posterior2*ld1grp)|(posterior3*rd1grp))|((posterior4*ld2grp)|(posterior5*rd2grp))|((posterior6*ld3grp)|(posterior7*rd3grp))|((posterior8*ld4grp)|(posterior9*rd4grp));
	post2mm_c47=((posterior4*ld2grp)|(posterior5*rd2grp))|((posterior6*ld3grp)|(posterior7*rd3grp))|((posterior8*ld4grp)|(posterior9*rd4grp));

	rename  Loop__Y_N_=LYN F13=lfs F19=rfs posterior=llp posterior1=rlp F26=lfs1 F32=rfs1 posterior2=llp1 posterior3=rlp1
			F39=lfs2 F45=rfs2 posterior4=llp2 posterior5=rlp2 F52=lfs3 F58=rfs3 posterior6=llp3 posterior7=rlp3
			F65=lfs4 F71=rfs4 posterior8=llp4 posterior9=rlp4 _2mm_from_C2_7=dc27yn 
			Posterior_VA_Y_N=pva Posterior_VA__C4_7__Y_N=pva47 __2_mm_from_C4_7_Y_N=dc47 Culmlative_DDD=ddd Smoker_Y_N=smoke;
	format  c23dh c34dh c45dh c56dh c67dh F13 F19 F26 F32 F39 F45 F52 F58 F65 F71 cdh. ll rl ll1 rl1 ll2 rl2 ll3 rl3 ll4 rl4 amp. 
			ldgrp rdgrp ld1grp rd1grp ld2grp rd2grp ld3grp rd3grp ld4grp rd4grp dyn.
			Loop__Y_N_ Smoker_Y_N Posterior_VA_Y_N Posterior_VA__C4_7__Y_N dc47yn DM HTN Dyslipidemia VascularDisease  yn.
			domin domin. gender sex. posterior posterior1-posterior9 pyn.;
run;

proc contents data=va;run;

proc freq data=va;
tables post2mm_any;
tables post2mm_c47;
run;


data wbh;
	set va(keep=id c23dh llp  rlp  L_Distance  R_Distance  lfs  rfs rename=(c23dh=cdh) in=A)
		va(keep=id c34dh llp1 rlp1 L_Distance1 R_Distance1 lfs1 rfs1 rename=(c34dh=cdh llp1=llp rlp1=rlp L_Distance1=L_Distance R_Distance1=R_Distance lfs1=lfs rfs1=rfs) in=B)
		va(keep=id c45dh llp2 rlp2 L_Distance2 R_Distance2 lfs2 rfs2 rename=(c45dh=cdh llp2=llp rlp2=rlp L_Distance2=L_Distance R_Distance2=R_Distance lfs2=lfs rfs2=rfs) in=C)
		va(keep=id c56dh llp3 rlp3 L_Distance3 R_Distance3 lfs3 rfs3 rename=(c56dh=cdh llp3=llp rlp3=rlp L_Distance3=L_Distance R_Distance3=R_Distance lfs3=lfs rfs3=rfs) in=D)
		va(keep=id c67dh llp4 rlp4 L_Distance4 R_Distance4 lfs4 rfs4 rename=(c67dh=cdh llp4=llp rlp4=rlp L_Distance4=L_Distance R_Distance4=R_Distance lfs4=lfs rfs4=rfs) in=E); 
	if L_Distance<2 then ld2mm=1; else ld2mm=0;   
	if R_Distance<2 then rd2mm=1; else rd2mm=0;

	if A then sub=1;
	if B then sub=2;
	if C then sub=3;
	if D then sub=4;
	if E then sub=5;

	if ld2mm or rd2mm then d2mm=1; else d2mm=0; 
	if llp or rlp then lp=1; else lp=0;
run;

proc freq data=wbh(where=(cdh^=4)) order=internal; 
tables cdh*(lp d2mm)/chisq fisher nopercent nocol;
run;

proc freq data=wbh(where=(cdh^=4)) order=internal; 
by sub;
tables cdh*(lp d2mm)/chisq fisher nopercent nocol;
run;

/*
proc freq data=wbh order=data; 
by sub;
tables lp*d2mm/chisq fisher norow nocol;
run;

proc npar1way data =wbh wilcoxon;
  class lfs;
  var L_Distance;
run;
proc npar1way data =wbh wilcoxon;
  class rfs;
  var r_Distance;
run;

proc freq data = wbh;
  tables lfs*llp / chisq fisher;
  tables rfs*rlp / chisq fisher;
  tables lfs*ld2mm / chisq fisher;
  tables rfs*rd2mm / chisq fisher;
run;
*/

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Beckworth, William\VAData 12-18-11.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet2$A1:F1871"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data dva;
	set tmp(rename=(level=level0));
	retain level;
	if level0^=" " then level=level0;

	if level="C2-3" then group=1;
		if level="C3-4" then group=2;
			if level="C4-5" then group=3;
				if level="C5-6" then group=4;
					if level="C6-7" then group=5;

	if L_Location="Anterior" then location=0;  else if L_Location="Posterior" then location=1;  else location=2;

	rename Foraminal_Sten_0_normal__1_mild_=stenosis L_Distance=ld;
	format Foraminal_Sten_0_normal__1_mild_ cdh. location amp. posterior pyn. group group.;
	drop level0;
	if Foraminal_Sten_0_normal__1_mild_=0 then norm=0; else norm=1;
	if L_Distance<2 then d2mm=1; else d2mm=0;
run;



/*
proc freq data=va;
	tables pva47*dc47/chisq;
	tables post*d2mm/chisq;
run;


proc univariate data=va plot;
	var L_Distance R_Distance;
	qqplot;
run;


proc glm data = dva;
  class stenosis;
  model ld = stenosis;
  means stenosis;
run;


proc freq data=va;
	tables llp*ldgrp;
	tables rlp*rdgrp;
	tables llp1*ld1grp;
	tables rlp1*rd1grp;
	tables llp2*ld2grp;
	tables rlp2*rd2grp;
	tables llp3*ld3grp;
	tables rlp3*rd3grp;
	tables llp4*ld4grp;
	tables rlp4*rd4grp;
run;


proc means data = dva mean stderr median Q1 Q3 min max;
  class norm;
  var ld;
run;


* For Q1;
*ods trace on/label listing;
proc npar1way data =dva wilcoxon;
  class norm;
  var ld;
  ods output   WilcoxonScores=wc1;
    ods output   KruskalWallisTest=wp1;
run;

proc freq data = dva;
  tables norm*posterior / chisq fisher;
  ods output crosstabfreqs=tab1;
  ods output chisq=tabp1;
run;
*/

* For Q1;
*ods trace on/label listing;

proc means data = dva mean stddev median Q1 Q3 min max maxdec=1;
  class stenosis;
  var ld;
run;

proc npar1way data =dva wilcoxon;
  class stenosis;
  var ld;
  ods output   WilcoxonScores=wc1;
    ods output   KruskalWallisTest=wp1;
run;
ods trace off;

data wcp1;
	merge wc1(keep=class N Meanscore) wp1(firstobs=3 keep=cvalue1);
run;

proc freq data = dva;
  tables stenosis*posterior / chisq fisher trend;
  tables stenosis*d2mm / chisq fisher trend;
run;

proc freq data = dva;
	by group;
  	tables posterior*d2mm / chisq fisher;
run;


* For Q2-Q3;

proc freq data = va;
  tables pva47*dc47 / chisq;
  tables pva*dc27yn / chisq;
run;

proc freq data = va;
  tables pva47*(smoke dm htn Dyslipidemia VascularDisease) / chisq;
  tables dc47*(smoke dm htn Dyslipidemia VascularDisease) / chisq;
run;

proc npar1way data =va wilcoxon;
  class pva47;
  var ddd pyear BMI;
run;

proc means data=va mean stddev median Q1 Q3 min max maxdec=1;
  class pva47;
  var ddd pyear BMI;
run;


proc npar1way data =va wilcoxon;
  class dc47;
  var ddd pyear BMI;
run;

proc means data=va mean stddev median Q1 Q3 min max maxdec=1;
  class dc47;
  var ddd pyear BMI;
run;



* For Q4;

proc npar1way data=va wilcoxon;
	class domin;
	var l_distance r_distance l_distance1 r_distance1 l_distance2 r_distance2 l_distance3 r_distance3 l_distance4 r_distance4;
run;

proc means data=va mean stderr median Q1 Q3 min max maxdec=1;
	class domin;
	var l_distance r_distance l_distance1 r_distance1 l_distance2 r_distance2 l_distance3 r_distance3 l_distance4 r_distance4;
run;
