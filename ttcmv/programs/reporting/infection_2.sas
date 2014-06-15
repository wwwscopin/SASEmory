%include "&include./annual_toc.sas";



proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where IsEligible=1 ;

quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data enrolled; 
set enrolled; 
output; 
center = 0; 
output; 
run; 


data infection_all; set cmv.infection_all;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data infection_all; 
set infection_all; 
output; 
center = 0; 
output; 
run; 
