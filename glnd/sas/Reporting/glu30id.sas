options orientation=landscape nodate nonumber;

%let mu=%sysfunc(byte(181));

proc format;
    value trt 1="AG-PN" 2="STD-PN";
    value died   0="No" 1="Yes";
run;

data glu;
    merge glnd_ext.glutamine(keep=id GlutamicAcid Glutamine visit rename=(visit=day)) 
  		  glnd_ext.chemistries(keep=id day bun creatinine bilirubin); by id day;
run;

data glu30;
    merge glnd.glu(in=A) glnd.ae_patients(keep=id ae9 ae10) 
          glnd.george (keep = id treatment)
          glnd.plate205 (in =B keep=id)
  		  glnd.status (keep = id dt_random dt_discharge)
  		  glu; by id;
  		  
    if B then died=1; else died=0;
    days_on_study=dt_discharge-dt_random;

    label  
        ae9 = "Worsening renal function"
        ae10 = "Worsening hepatic function"
        ;
    
    format treatment trt. died died.;
run;

proc sort; by id day;run;

ods  rtf  file="GLNGLND_All.rtf" style=journal bodytitle startpage=yes;
	proc report data=glu30 nowindows split="*" style(column)=[just=center] missing;
	    title "Data for IDs with High Glutamine";
    	column id treatment ae9 ae10 died days_on_study day glutamine glutamicacid bun creatinine bilirubin;
    	define id/"ID" group order=internal;
    	define treatment/"Treatment" group;
    	define ae9/"Worsening*renal function" group style(column)=[width=1in];
    	define ae10/"Worsening*hepatic function" group style(column)=[width=1.25in];
    	define died/"Death?" group;
    	define days_on_study/"Days on Study" group style(column)=[width=1in];
    	define day/"Day" order;
    	define glutamine/"Glutamine*(&mu M)" format=4.0 style(colum)=[width=0.75in];
    	define glutamicacid/"Glutamic Acid*(&mu M)" format=4.0 style(column)=[width=1in];
    	define bun/"BUN*(mg/dL)";
    	define creatinine/"Creatinine*(mg/dL)";
	    define bilirubin/"Total Bilirubin*(mg/dL)" style(column)=[width=1in];
	run;
ods rtf close;
	
