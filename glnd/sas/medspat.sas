data id;
 infile 'sitevisit.dat';
 input id;

data meds;
    set glnd.plate18;
	
         keep id  ;
data meds1;
merge id(in=a) meds;
by id;
if a;
meds=1;
proc print;
run;
  
