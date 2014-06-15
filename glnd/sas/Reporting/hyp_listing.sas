
data ae_temp;
	set glnd.plate201;
	
	array ae(17);

	* mark AEs that do occur, for the patient group with AEs. will be "." for the AEs that they do not have.;
	do i=1 to 17;
 		if ae_type=i then ae(i)=1;
	end; 
	
	* handle hyper/hypoglycemia ;
                if (ae_type = 15) & (ae_glycemia = 1) then hyper = 1;
                if (ae_type = 15) & (ae_glycemia = 2) then hypo = 1;
						if (ae_type = 15) & (0<glucose <40) then hypo1 = 1; 
   where ae_type=15;
	keep id dt_ae_onset ae_code ae_glycemia ae_number ae_type glucose hyper hypo hypo1;
run;

proc sort data=ae_temp; by id; run;

data hyper;
	set ae_temp;
	drop hypo hypo1;
	where hyper=1;
run;

title "Hyperglycemia data listing";

ods pdf file="hyper.pdf" style=journal;
proc print data=hyper;
run;
ods pdf close;

data hypo;
	set ae_temp;
	drop hyper hypo1;
	where hypo=1;
run;

title "Hypoglycemia < 50 (mg/dL) data listing";

ods pdf file="hypo.pdf"style=journal;
proc print data=hypo;
run;
ods pdf close;

data hypo1;
	set ae_temp;
	drop hyper hypo;
	where hypo1=1;
run;

title "Hypoglycemia < 40 (mg/dL) data listing";

ods pdf file="hypo1.pdf" style=journal;
proc print data=hypo1;
run;
ods pdf close;
