data glutamine_full;
        set glnd_ext.glutamine;
    if visit=0 then day=1;
    if visit=3 then day=2;
if visit=7 then day=3;
if visit=14 then day=4;
if visit=21 then day=5;
if visit=28 then day=6;
       keep id GlutamicAcid Glutamine visit  collectionday day;

run;
proc sort; by id visit day;
data x;
array glut(6) glut0 glut3 glut7 glut14 glut21 glut28;
  
  do i=1 to 6;
  set glutamine_full;
  by id;
    glut(day)=glutamine;
   if last.id then return;
 end;
keep glut0--glut28 id collectionday;
run;
proc sort; by id;
data z;
   merge x (in=a) 
   glnd.status (keep =id dt_random treatment)
   glnd.plate58 (keep=id dfcreate);
  by id;
   if a;
ods pdf file='glutamine.pdf';
proc print;
 var id  glut0--glut28 collectionday dfcreate dt_random treatment;
title All Glutamine Data;
