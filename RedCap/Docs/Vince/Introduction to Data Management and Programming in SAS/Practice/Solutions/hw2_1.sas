* summarize the continuous variables;
options nocenter;
proc  means data='p:\bio113\hw\ivh';
var id ga bw labor rom mage apg1 apg5 los wt1-wt4 map1-map4 pco2_1-pco2_4 fluid1-fluid4 cry1-cry4 col1-col4 t4 t4age;
run;

* summarize the discrete variables;
proc freq data='p:\bio113\hw\ivh';
tables hosp sex race ivh medu single cs pih acs vent dead pda1-pda4 dopa1-dopa4 ptx1-ptx4;
run;

* assign to the missing value code(.);
libname hw 'p:\bio113\hw';
data hw.ivh1;
set 'p:\bio113\hw\ivh';
if t4=99.99 then t4=.;
drop i j k l m;
array missa (6) race medu single pda4 dopa4 ptx4;
array missb (17) ga mage apg1 apg5 map1-map4 pco2_1-pco2_4 col1-col4 t4age; 
array missc (8) fluid1-fluid4 cry1-cry4; 
array missd (5) bw wt1-wt4; 
array misse (2) labor rom;
do i=1 to 6;
   if missa(i)=9 then missa(i)=.;
end;
do j=1 to 17;
   if missb(j)=99 then missb(j)=.;
end;
do k=1 to 8;
   if missc(k)=999 then missc(k)=.;
end;
do l=1 to 5;
   if missd(l)=9999 then missd(l)=.;
end;
do m=1 to 2;
   if misse(m)=9999.9 then misse(m)=.;
end;
run;

* repeat to check whether missing value code assignment worked;
proc  means data='p:\bio113\hw\ivh1';
var id ga bw labor rom mage apg1 apg5 los wt1-wt4 map1-map4 pco2_1-pco2_4 fluid1-fluid4 cry1-cry4 col1-col4 t4 t4age;
run;
proc freq data='p:\bio113\hw\ivh1';
tables hosp sex race ivh medu single cs pih acs vent dead pda1-pda4 dopa1-dopa4 ptx1-ptx4;
run;



