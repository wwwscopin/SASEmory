
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

  
	keep id dt_ae_onset ae_code ae_glycemia ae_number ae_type glucose hyper hypo hypo1;
run;

proc sort data=ae_temp nodup; by id; run;

data hyper;
	set ae_temp;
where hyper=1;
run;


title "hyper id listing";
ods pdf file="hyper.pdf" style=journal;
proc print data=hyper label style(data)=[just=center]; 
var id dt_ae_onset ae_code ae_glycemia ae_number ae_type glucose hyper;
run;

ods pdf close;






