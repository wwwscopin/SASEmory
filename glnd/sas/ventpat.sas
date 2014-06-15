data id;
 infile 'sitevisit.dat';
 input id;

data vent;
    set glnd.plate17;
	
         keep id  ;
data vent1;
merge id(in=a) vent;
by id;
if a;
vent=1;
proc print;
run;
  
