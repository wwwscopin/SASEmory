

data test;
infile 'employee.txt';
input employee_name $ 1-4@;
if employee_name='ruth' then input idnum 10-11@;
else input age 7-8@;
run;

proc print;run;
