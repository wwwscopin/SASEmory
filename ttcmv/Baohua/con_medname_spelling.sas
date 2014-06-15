optiont nodate;

data all_pat;
	set cmv.comp_pat(keep=id);
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;

%let  n=0;
data _null_;
	set all_pat;
	call symput("n", compress(_n_));
run;


%macro conmed(dataset);
data tmp;
	set &dataset;
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

		keep 		DFSEQ id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
		format  StartDate EndDate mmddyy8. center center. MedCode MedCode. Indication Indication. unit unit.;
run;
%mend;

%conmed(cmv.con_meds);quit;

*ods trace on/label listing;
proc freq;
tables medcode*MedName;
ods output Freq.Table1.CrossTabFreqs=listing0;
run; 
*ods trace off;

data listing;
	set listing0;
	where frequency^=0 and medcode^=. and medname^=" ";
run;


ods rtf file="medcode_medname.rtf" style=journal;
proc print data=listing style(data)=[just=left] style(header)=[just=left];
var medcode medname frequency;
run;
ods rtf close;

data medname;
	set tmp;
	where medname^=" " and medcode^=21;
	if lowcase(medname)="gentamicin" then delete;
	if lowcase(medname)="gentamycin" then delete;
	if lowcase(medname)="ampicillin" then delete;
	if lowcase(medname)="ativan" then delete;
	if lowcase(medname)="fentanyl" then delete;
	if lowcase(medname)="methadone" then delete;
	if lowcase(medname)="morphine" then delete;
	if lowcase(medname)="morphine sulfate" then delete;
	if lowcase(medname)="nembutal" then delete;
	if lowcase(medname)="norcuron" then delete;
	if lowcase(medname)="proparacaine ophthalmic" then delete;
	if lowcase(medname)="tylenol" then delete;
	if lowcase(medname)="bicarbonate" then delete;
	if lowcase(medname)="sodium bicarbonate" then delete;
	if lowcase(medname)="caffeine" then delete;
	if lowcase(medname)="calcium gluconate" then delete;
	if lowcase(medname)="ferinsol" then delete;
	if lowcase(medname)="potassium chloride" then delete;
	if lowcase(medname)="sodium chloride" then delete;
	if lowcase(medname)="phenobarbital" then delete;
	if lowcase(medname)="furosemide" then delete;
	if lowcase(medname)="lasix" then delete;
	if lowcase(medname)="indomethacin" then delete;
	if lowcase(medname)="insulin" then delete;
	if lowcase(medname)="hydrocortisone" then delete;
	if lowcase(medname)="prelone" then delete;
	if lowcase(medname)="surfactant" then delete;
	if lowcase(medname)="survanta" then delete;
	if lowcase(medname)="vancomycin" then delete;

	if lowcase(medname)="10% dextrose" then delete;
	if lowcase(medname)="actigall" then delete;
	if lowcase(medname)="aquamephyton" then delete;

	if lowcase(medname)="multivitamin" then delete;
	if lowcase(medname)="multivitamin with iron" then delete;
	if lowcase(medname)="vitamin a" then delete;
	if lowcase(medname)="vitamin k" then delete;
run;

proc sort data=medname nodupkey; by medcode medname id DFSEQ; run;
ods rtf file="med_name.rtf" style=journal;
proc print label;
var medcode medname id DFSEQ;
label medcode="Med Code"
		medname="Medication Name"
		id="LBWI ID"
		DSSEQ="Visit Number"
		;
run;
ods rtf close;


