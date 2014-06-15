/* ACR_summary_ab.sas */


ods escapechar = "^";

* one macro to process binary variables and continuous variables using proc means - specify with parameter "type= ";
	%macro binary_cont_vars (data_in=, data_out=, var= , row=, format=, type=);

	proc means data = local.acr fw=5 maxdec=1 nonobs n mean stddev median min max ;
			%if (&x < 3) %then %do; * this is valid since we are inside of a loop already;
				where treatment = &x;
			%end;

		class visit;
		var &var;
		output out = &var sum(&var) = &var._sum n(&var) = &var._n median(&var) = &var._median q1(&var) = &var._q1	q3(&var) = &var._q3;
	run;

	data &var;
		set &var;
		
		where _TYPE_ = 1;

        length variable $ 45;
        length disp $85;
        length row $ 45;

		* fix variable names;
		n = &var._n;
		sum = &var._sum;
		median = &var._median;
		q1 = &var._q1;
		q3 = &var._q3;

		* add row headers ;
		row = &row;
		disp_visit = compress(put(visit, visit.)); * make a text field of visit so that it can be made blank;

		* set up columns for display ;
		* if binary ;
			if ("&type" = "binary") then do;
				disp = compress(put(sum, 4.0)) || "/" || compress(put(n, 4.0)) || " (" || compress(put((sum/n) * 100, 4.1)) || ")";
			end;
		* if continuous ;
			else if ("&type" = "continuous") then do;
				disp = compress(put(median, 4.1)) || " (" || compress(put(q1, 4.1)) || ", " || compress(put(q3, 4.1)) || "), " || compress(put(n, 4.0));
			end;
		drop &var._sum &var._n &var._median &var._q1 &var._q3;
	run;

  		* stack results;
		data binary_cont_table;
			%if &var = acr_20 %then %do;
				set &var;
			%end;
			%else %do;
				set binary_cont_table
				&var;
			%end;
		run;
    %mend binary_cont_vars;

* build a separate table for each treatment group ;
%macro outcome_table;
%let x = 1;

%do %while (&x < 4);
	%if (&x = 1) %then %let trt = A;
	%else %if (&x = 2) %then %let trt = B;
	%else %if (&x = 3) %then %let trt = Overall;

	* make rows for binary and continuous variables ;
    %binary_cont_vars(var=acr_20, row= "ACR-20", type = binary);
    %binary_cont_vars(var=acr_50, row= "ACR-50", type = binary);
    %binary_cont_vars(var=acr_70, row= "ACR-70", type = binary);
    %binary_cont_vars(var=acr_n, row= "ACR-N", type = continuous);
    %binary_cont_vars(var=hybrid_acr, row= "Hybrid ACR", type = continuous);


	* process for printing ;
		data binary_cont_table_&trt;
				set binary_cont_table;

			by row notsorted;
			
			* add line with title at beginning of category;
			*** see "outcome_summary_ab.sas" for details on having categories of outcomes ;
			output;

			* add blank line at end of category;
			if last.row then do;
				row = row;
				disp_visit = '00'x;
				disp = '00'x;
				output;
				
				* add headers for continuous variables on last row of categorical ;
				if row = "ACR-70" then do;
					row = row;
					disp_visit = '00'x;
					disp = "^S={fontstyle= slant fontweight = bold}median (Q1, Q3), n"; * ^S={textdecoration = underline}; 
					output;
				end;
			end;

			label 	row ='00'x
					disp_visit = '00'x
					
					%if &x = 1 %then %do; disp = "A*^S={fontweight = bold}total (%)" %end;
					%if &x = 2 %then %do; disp = "B*^S={fontweight = bold}total (%)" %end;
					%if &x = 3 %then %do; disp = "Overall*^S={fontweight = bold}total (%)" %end;
					;
		run;
		%let x = &x + 1;
	%end;
%mend outcome_table;

%outcome_table run;

** Post-process ** ;
	* remember the sorting order for the overall table;
	data binary_cont_table_overall;
        set binary_cont_table_overall;

		order = _N_;
	run;

	* sort each table then merge!;
	proc sort data = binary_cont_table_A; by row disp_visit; run;	
	proc sort data = binary_cont_table_B; by row disp_visit; run;
	proc sort data = binary_cont_table_Overall; by row disp_visit; run;

	data binary_cont_table;
		merge 
			binary_cont_table_A (keep = row disp_visit disp rename = (disp = disp_a ))
			binary_cont_table_B(keep = row disp_visit disp rename = (disp = disp_b))
			binary_cont_table_Overall (keep = order row disp_visit disp rename = (disp = disp_overall))
			;
		by row disp_visit;

	run;

	* get everything back into the correct sorting order; 
	proc sort data = binary_cont_table;	by order;	run;



* output table to PDF;
options nodate nonumber orientation = portrait;
ods rtf file = "&path&date\acr_summary_ab.rtf" style=journal;
	title1 "GRAC" ;
	title2 "ACR Endpoint Summary - &date "; 
	proc print data = binary_cont_table label noobs split = "*" style(header) = [just=center];
		id  row;
		by  row notsorted;

		var disp_visit ;
		var disp_A disp_b disp_overall /style(data) = [just=center];;
	run;
ods rtf close;
