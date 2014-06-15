data x;
   merge glnd.younglee1 (in=a)  glnd.status(keep=id treatment);
   by id;
  if a;
data chem;
   set report.chemistries;
  keep id bun creatinine bilirubin sgot_ast sgpt_alt glucose  day ;
proc sort; by id day;


data c;
  set glnd_ext.cytokines;
  day=visit;
  keep id day il6 il8 tnf ifn;
proc sort; by id day;

data chemc;
   merge chem c;
   by id day;
 data glnd.younglee_clinical;
   merge chemc x (in=a);
    by id;
    if a;
if day >14 then delete;
ods csv file='younglee_clinical.csv';
proc print;
  var id day treatment  bun creatinine bilirubin sgot_ast sgpt_alt glucose il6 il8 tnf ifn;
run;
ods csv close;
