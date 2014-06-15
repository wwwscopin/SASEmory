
%include "&include./monthly_toc.sas";




proc sql;

create table enrolled as
select a.id  , b.*
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;

quit;
data x;
 /*set cmv.lbwi_demo; */
set enrolled;


id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


proc format;

value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;

value ishispanic
0='No'
1='Yes'
;

run;

data x;
set x;

 /*
                 
 
  value race   99 = "Blank"
 			     1="Black"
                 2 = "American Indian / Alaskan Native"
                 3 = "White"               
                 4 = "Native Hawaiian or Pacific Island"
                 5 = "Asian"
					6="Other";
*/
/*
                 6 = "More than one race"
                 7 = "Other" ;
                 */
	race_new = race;

if race_new = 6 or race_new = 7 then race_new = 6;
 


   array racegender(6,2)
          aam aaf aiM aiF whM whF nam naF apM apF /*mrM mrF */
              otM otF;
          
  do race1=1 to 6;
     do gender1=1 to 2;
       if race_new=race1 and gender=gender1 then racegender(race1,gender1)=1;
     end;
  end;
  do gender1=1 to 2;
       if race_new=6 and gender=gender1 then racegender(6,gender1)=1;
  end;
      
 
 proc sort; by ishispanic center;
 options ls=121 ps=53 nodate nonumber;
proc means noprint;
  var aam aaf aiM aiF whM whF nam naF apM apF /*mrM mrF*/
              otM otF;
  output out=rc
  sum=aaM aaF aiM aiF whM whF naM naF
          apM apF  /*mrM mrF*/ otM otF;
  by ishispanic center;
  run;
  
data x;
 set rc;
 array x(12) aam aaf aiM aiF whM whF nam naF apM apF /*mrM mrF*/
              otM otF;
  do i=1 to 12;
     if x(i)=. then x(i)=0;
  end;
  
  label aim='American Indian M'
        aif='American Indian F'
        apm='Asian  M'
        apf='Asian F'
        nam='Native Hawaiian M'
        naf='Native Hawaiian F'
        aam='Black M'
        aaf='Black F'
        whm='White M'
        whf='White F'
        otm='Other M'
        otf='Other F'
		 mrM='More than one race M'
         mrF='More than one race F'
  ; 
  run;
 proc print data=x noobs label;
  by ishispanic ;
  
   var center aam aaf aiM aiF whM whF nam naF apM apF /*mrM mrF*/
              otM otF;
   title Race/Ethnic Characteristics by Site;
run;


options nodate orientation = portrait;

ods rtf file = "&output./monthly/&race_ethnic_file.LBWI race_ethnic.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "&race_ethnic_title LBWI Race/Ethnic Characteristics by Center";

		title1 "&race_ethnic_title LBWI Race/Ethnic Characteristics by Center";
		proc print data = x label noobs split = "*" style(header) = [just=center] contents = "";



				var center aam aaf  whM whF  aiM aiF nam naF apM apF /*mrM mrF*/
              otM otF  / style(data) = [just=center];				

				by ishispanic ; where ishispanic in (1,0);

				label date = "Month"
						 center = "Center"

						 aim='American * Indian *M'
        aif='American * Indian *F'
        apm='Asian  M'
        apf='Asian F'
        nam='Native Hawaiian M'
        naf='Native Hawaiian F'
        aam='Black M'
        aaf='Black F'
        whm='White M'
        whf='White F'
        otm='Other M'
        otf='Other F'
		 mrM='More than one race M'
         mrF='More than one race F'
				;
format center center.; format ishispanic ishispanic.;

				run;

	*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
