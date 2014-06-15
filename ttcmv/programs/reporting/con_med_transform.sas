%macro conmed();
data cmv.con_meds_long;
	set cmv.con_meds;
	%do i=1 %to 9;
		center=floor(id/1000000);
		Dose=Dose&i;
		DoseNumber=DoseNumber&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		day=EndDate-StartDate;
		Indication=Indication&i;
		MedCode=MedCode&i;
		MedName=MedName&i;
		Unit=Unit&i;
		prn=prn&i;

		i=&i;

		output;
	%end;

	keep id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
	format  StartDate EndDate mmddyy8. center center. MedCode MedCode. Indication Indication. unit unit.;
run;
%mend;

%conmed(); quit;
data cmv.con_meds_long; set cmv.con_meds_long; if medcode ~= .; run;
