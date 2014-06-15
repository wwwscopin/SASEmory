%include "&include./monthly_toc.sas";


data cmv.Med_review; set cmv.Med_review; 

total_anthro=3; total_chem=18; this_anthro_gt50=0;this_chem_gt50=0;
this_anthro=0; this_chem=0;

if HtLength <> . then this_anthro=this_anthro+1; 
if  Weight <> . then this_anthro=this_anthro+1; 
if  HeadCircum <> . then this_anthro=this_anthro+1; 

if  glucose <> . then this_chem=this_chem+1; 
if  platelet <> . then this_chem=this_chem+1; 
if  HCT <> . then this_chem=this_chem+1;   
if  Hb <> . then this_chem=this_chem+1;
if  Absneutrophil <> . then this_chem=this_chem+1;  
if  lympho <> . then this_chem=this_chem+1; 
if  ALT <> . then this_chem=this_chem+1;   
if  AST <> . then this_chem=this_chem+1; 
if  Albumin <> . then this_chem=this_chem+1; 
if  TotalBilirubin <> . then this_chem=this_chem+1;
if  DirectBilirubin <> . then this_chem=this_chem+1;
if  BUN <> . then this_chem=this_chem+1;
if  creatinine <> . then this_chem=this_chem+1;
if  potassium <> . then this_chem=this_chem+1;
if  sodium <> . then this_chem=this_chem+1;
if  chloride <> . then this_chem=this_chem+1;
if  bicarbonate <> . then this_chem=this_chem+1;
if  glucose <> . then this_chem=this_chem+1;

this_anthro_pct=this_anthro/total_anthro*100;
this_chem_pct=this_chem/total_chem*100;
pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

anthro_nonmiss=compress(this_anthro) || "/" || compress(total_anthro);
chem_nonmiss=compress(this_chem) || "/" || compress(total_chem);

if this_anthro_pct >=50 then this_anthro_gt50 =1;
if this_chem_pct >=50 then this_chem_gt50 =1;
run;
run;

/* 
uncomment this if you want a print


proc format;

value $Form
'LBWI_MRev' = 'LBWI Medical Review and Lab Results ( Longitudinal)'
'LBWI_Demo' = 'LBWI Demographics '
'SNAP' = 'LBWI SNAP on DOL 0'
'SNAP2' = 'LBWI SNAP II ( Longitudinal )'
'MOC_Demo' = 'MOC Demographics '
;


Value sigbz 
0='Red'
;


value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;

run;

proc sql;
create table med_review2 as
select * from Med_review
order by id, dfseq;
quit;

options nodate  orientation = landscape; 


ods rtf file = "&output./monthly/099_file.med_review_missing.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "Medical Review Missing Data by Site ";


	
	
	title  justify = center "Medical Review Missing Data by Site ";
footnote1 "";
footnote2 "";
   
   proc report data = Med_review2 nofs   style(header) = [just=center]  split = "_"  missing headline headskip  contents = ""; 

	column  id      dfseq HtLength Weight HeadCircum anthro_nonmiss this_anthro_pct this_anthro_gt50 pipe 
glucose platelet HCT HB Absneutrophil lympho alt ast Albumin chem_nonmiss this_chem_pct this_chem_gt50 dummy ;
by center;


define id / group Left  order=internal    "LBWI Id" ;
*define center / group   order=internal     style(column)=[cellwidth=1in just=center ]  "Site";
define dfseq /  Left     " Visit" ;
define HtLength /  Left     "HtLength" ;
define Weight /  Left     " Weight" ;
define HeadCircum /  Left     " HeadCircum" ;

define anthro_nonmiss /  Left     " #Anthro_complete" ;
define this_anthro_pct /  Left     "#Anthro_complete(%)" style(column)=[ background=sigbz.] format=5.1;
define this_anthro_gt50 /  Left     "#Anthro_complete_GT 50%%)" style(column)=[ background=sigbz.] format=5.1;


define glucose /  Left     "Glucose" ;
define platelet /  Left     "Plt" ;
define HCT /  Left     " HCT" ;
define HB /  Left     " HB" ;
define Absneutrophil /  Left     "Neutro" ;
define lympho /  Left     "Lympho" ;
define alt /  Left     " ALT" ;
define ast /  Left     "AST" ;
define Albumin /  Left     "Albumin" ;

define chem_nonmiss /  Left     " #Lab_complete" ;
define this_chem_pct /  Left     "#Lab_complete(%)" style(column)=[ background=sigbz.] format=5.1;
define this_chem_gt50 /  Left     "#Lab_complete_GT 50%%)" style(column)=[ background=sigbz.] format=5.1;
define pipe /  Left     "" ;


define dummy/ noprint;


break after id /skip;

    
	 format center center.; 
run; 


ods rtf close;
*/
