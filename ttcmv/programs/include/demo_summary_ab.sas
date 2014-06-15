/* demo_summary.sas */

%let date = 6_09_2008;
%let path = S:\Eli_Rosenberg\Allergen\reporting\;

libname allergen "&path&date\data";
libname library "&path&date\data";




/* Categorical variables */

%macro cat_vars (var= , format=, label=);

        proc freq data= demo compress noprint;
            tables &var /nocum out = &var;
        run;

        proc sort data = &var; by descending &var ; run;

        data &var; set &var;
                length variable $ 45;
                length disp $35;
                length row $ 45;

            retain n;
            n = round((count/(percent/100)), 1); * add n to each record ;

            if (&var ~= .) then do;
                disp = compress(put(count, 3.0)) || "/" || compress(put(n, 3.0)) || " (" ||  compress(put(percent, 4.1)) || "%)";
                row = put(&var , &format);
            end;
            else do;
                disp = compress(put(count, 3.0));
                row = "(missing)";
            end;

            variable = &label;
        run;

		* stack results;
		data cat_table;
			%if &var = gender %then %do;
				set &var;
			%end;
			%else %do;
				set cat_table
				&var;
			%end;
		run;
    %mend cat_vars;


%macro cont_vars (var = , label = );
	proc means data = demo fw=5 maxdec=1 nonobs n mean stddev median min max ;
		*class visit;
		var &var;
		ods output summary = &var;
	run;

	data &var;
		set &var;

		length variable $ 35;

		* fix variable names;
		n = &var._n;
		mean = &var._mean;
		std_dev = &var._stddev;
		median = &var._median;
		min = &var._min;
		max = &var._max;

		* format for display ;
		disp_mean = compress(put(mean, 4.1)) || " (" || compress(put(std_dev, 4.1)) || ")";
		disp_n = compress(put(n, 4.0));
		disp_range = "[" || compress(put(median, 4.1)) || ", " || compress(put(min, 4.1)) || " - " || compress(put(max, 4.1)) || "]";

		if (mean ~= .) then disp = trim(disp_mean || " " || disp_range) || ", " || disp_n; 
		else disp = "(no data)";

		* add row headers ;
		variable = &label;

		drop &var._n &var._mean &var._stddev &var._median &var._min &var._max;
	run;

		* stack results;
		data cont_table;
			%if &var = age %then %do;
				set &var;
			%end;
			%else %do;
				set cont_table
				&var;
			%end;
		run;

%mend cont_vars;

%macro overall_a_b;

* 1 = overall, 2 = A, 3 = B;
%do x = 1 %to 3;

proc sort data = allergen.tbl_demographic; by patientid dataentry; run;
proc sort data = allergen.treatment; by patientid; run;

	data demo;
		merge 	allergen.tbl_demographic (in = has_data)
				allergen.treatment;
		by 		patientid;

		%if &x ~= 1 %then %do;
			if trt ~= &x - 1 then delete;
		%end;

		* get rid of extra IDs in treatment dataset ;
		if ~has_data then delete;

		* keep first data entry persons data unless it is essentially blank ;
		if (first.patientid) & (race = .) & (age = .) then delete;
		else if ~first.patientid then delete;
	run;

	* get the total n for this subset ;
		proc means data = demo noprint;
			output out = n n(patientid) = n;
		run;

		data _NULL_;
			set n;			
			call symput('n', compress(put(n, 3.0)) );	
		run;

    %cat_vars(var=gender, format= gender., label= "Gender");
    %cat_vars(var=race, format= race., label= "Race");
    %cat_vars(var=maritalstatus, format= marital_status., label= "Marital Status");
    %cat_vars(var=sideaffectedbefore, format= side., label= "Dominant hand before stroke");
    %cat_vars(var=sideaffectedafter, format= side., label= "Side affected by stroke");
    %cat_vars(var=live_num, format= live., label= "Living situation");
    %cat_vars(var=cancer, format= ynu., label= "Cancer");
    %cat_vars(var=heartdisease, format= ynu., label= "Heart disease");
    %cat_vars(var=chestpains, format= ynu., label= "Chest pains");
    %cat_vars(var=highbp, format= ynu., label= "High blood pressure");
    %cat_vars(var=headaches, format= ynu., label= "Headaches");
    %cat_vars(var=dm, format= ynu., label= "Diabetes Mellitus");
    %cat_vars(var=seizures, format= ynu., label= "Seizures");
    %cat_vars(var=bladderleak, format= ynu., label= "Bladder leaking");
    %cat_vars(var=passingwater, format= ynu., label= "Difficulty passing water");
    %cat_vars(var=stroke, format= ynu., label= "Stroke");
    %cat_vars(var=strokeside_num, format= side., label= "Stroke side");
    %cat_vars(var=heartattack, format= ynu., label= "Heart attack");
    %cat_vars(var=arthritis, format= ynu., label= "Arthritis");
    %cat_vars(var=asthma, format= ynu., label= "Asthma, bronchitis, or emphysema");
    %cat_vars(var=fracture, format= ynu., label= "Fracture");
    %cat_vars(var=osteoporosis, format= ynu., label= "Osteoporosis");
    %cat_vars(var=blackouspells, format= ynu., label= "Blackout spells");
    %cat_vars(var=dizziness, format= ynu., label= "Dizziness");
    %cat_vars(var=other, format= ynu., label= "Other");
    %cat_vars(var=pacemaker, format= ynu., label= "Has a pacemaker/aneurism clip/metal implants");

	%cont_vars(var= age, label = "Age (years)");
	%cont_vars(var= weight, label = "Weight (lbs.)");
	%cont_vars(var= height, label = "Height (in.)");
	*%cont_vars(var= restingpulse, label = "Resting pulse (bpm)");
	*%cont_vars(var= systolicbp, label = "Systolic BP (mmHg)");
	*%cont_vars(var= diastolicbp, label = "Diastolic BP (mmHg)");
	%cont_vars(var= schooling, label = "Years of formal schooling");

* Stack cat. cont. variables. Add a space after each variable type ;
    data demo_tables_&x;
        set cat_table
            cont_table;
    run;

    data demo_tables_&x;
            set demo_tables_&x;

        by variable notsorted;

        output;
        if last.variable then do;
            variable = variable;
            row = " ";
            disp = " ";
            output;
        end;

		* insert a few special headers - because i have no category system in this QC table (unlike Conn outcomes)
			I need to do this here ;
		if (variable = "Living situation") & last.variable then do;
			variable = "== Medical Conditions ==";
			row = " ";
			disp = " ";
			output;
		end;

		if (variable = "Has a pacemaker/aneurism clip/metal implants") & last.variable then do;
			variable = variable;
			row = " ";
			disp = "mean (SD) [median, min - max]), n";
			output;
		end;

        label   
			variable ='00'x
	        row = '00'x
	        %if &x = 1 %then disp = "Overall*(n = &n)*total (%)";
	        %if &x = 2 %then disp = "A*(n = &n)*total (%)";
	        %if &x = 3 %then disp = "B*(n = &n)*total (%)";
		;
	run;



%end;
%mend overall_a_b;

%overall_a_b run;

	* remember the sorting order for the overall table;
	data demo_tables_1;
        set demo_tables_1;

		order = _N_;
	run;

	* sort each table then merge!;
	proc sort data = demo_tables_1; by variable row; run;	
	proc sort data = demo_tables_2; by variable row; run;
	proc sort data = demo_tables_3; by variable row; run;

	data demo_tables_overall_a_b;
		merge 
			demo_tables_1 (keep = order variable row disp rename = (disp = disp_overall))
			demo_tables_2 (keep = variable row disp rename = (disp = disp_a))
			demo_tables_3 (keep = variable row disp rename = (disp = disp_b))
			;
		by variable row;
	run;

	* re-sort in proper order;
	proc sort data = demo_tables_overall_a_b; by order; run;	

options nodate nonumber orientation = portrait;
ods pdf file = "&path&date\demo_summary_overall_ab.pdf" style=journal;
    title "Allergen Study Demographic Summary - &date ";
    proc print data = demo_tables_overall_a_b noobs label style(header) = [just=center] split = "*";
        id variable;
        by variable notsorted;
        var  row;
        var /*disp_overall*/ disp_a disp_b/style(data) = [just=center];
    run;

ods pdf close;


