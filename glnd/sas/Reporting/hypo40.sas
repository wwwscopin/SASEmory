
data ae_temp;
	set glnd.plate201;
	
  if ae_glycemia = 2 and glucose<40 then hypo40=1;
  if glucose=. then delete;
  if hypo40=1;
  keep id glucose;
  *proc contents data=glnd.status;
  data x;
   set glnd.status;
   keep id treatment;
   
   data f;
    merge ae_temp(in=a) x;
     by id;
     if a;
  proc print;