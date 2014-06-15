* add 4 categorical variables; 
options nocenter;
libname hw 'p:\bio113\hw';
data hw.ivh1;
set hw.ivh1;

if .<bw<750 then bwcat=1;
else if 750<=bw<1000 then bwcat=2;
else if 1000<=bw<1250 then bwcat=3;
else if bw>=1250 then bwcat=4;

if labor=0 then labcat=1;
else if 0<labor<=12 then labcat=2;
else if labor>12 then labcat=3;

if .<rom<1 then romcat=1;
else if rom>=1 then romcat=2;

if .<bw<=1000 and .<ga<26 then gabwcat=1;
if .<bw<=1000 and 26<=ga<=28 then gabwcat=2;
if .<bw<=1000 and ga>28 then gabwcat=3;
if bw>1000 and .<ga<26 then gabwcat=4;
if bw>1000 and 26<=ga<=28 then gabwcat=5;
if bw>1000 and ga>28 then gabwcat=6;
run;

*use PROC FREQ to display 1-way and 2-way tables of 4 categorical variables;
proc freq data=hw.ivh1;
tables bwcat labcat romcat gabwcat;
tables romcat*bwcat;
tables romcat*labcat;
tables romcat*gabwcat;
run;

* use SAS ARRAY/functions to create 15 new variables;
data hw.ivh1;
set hw.ivh1;
drop i;
array cc(4) cc1-cc4;
array col(4) col1-col4; 
array cry(4) cry1-cry4;
array wt(4) wt1-wt4;
array pctwt(4) pctwt1-pctwt4;
do i=1 to 4;
  cc(i)=sum(col(i),cry(i))/(wt(i)/1000);
  pctwt(i)=round(100*(bw-wt(i))/bw, .1);
end;

* we can use the following codes also;
/*
array vara(5,4) col1-col4 cry1-cry4 wt1-wt4 cc1-cc4 pctwt1-pctwt4;
do i=1 to 4;
  vara(4,i)=sum(vara(1,i),vara(2,i))/(vara(3,i)/1000);
  vara(5,i)=round(100*(bw-vara(3,i))/bw, .1);
end;
*/

* use SAS functions to calculate;
mmap=mean(of map1-map4);
mpco=mean(of pco2_1-pco2_4);
lpco=min(of pco2_1-pco2_4);
hpco=max(of pco2_1-pco2_4);

mmap1=(map1+map2+map3+map4)/4;
mpco1=(pco2_1+pco2_2+pco2_3+pco2_4)/4;

apgrat=round(apg1/apg5,.001);
run;


* use PROC MEANS to display 15 new variables;
proc means data=hw.ivh1 maxdec=3 mean min max n nmiss;
var cc1-cc4 pctwt1-pctwt4 mmap mmap1 mpco mpco1 lpco hpco apgrat;
run;

* use SAS ARRAY/function to count number of adverse events;
data hw.ivh1;
set hw.ivh1;
drop i apg5c;
if .<apg5<5 then apg5c=1;
else  if apg5>=5 then apg5c=0;
array event(15) apg5c ivh dead dopa1-dopa4 pda1-pda4 ptx1-ptx4;
count=0;
do i=1 to 15;
  if event(i)=1 then count=count+1;
end;
count1=sum(of apg5c ivh  dead  dopa1-dopa4  pda1-pda4  ptx1-ptx4);
run;

* use PROC FREQ to see the values taken on by these two variables;
proc freq data=hw.ivh1;
tables count count1;
run;