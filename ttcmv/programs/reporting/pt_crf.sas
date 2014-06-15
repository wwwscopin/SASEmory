* DataFax QC query to obtain the number of pages  ***;


data _NULL_;
  		
  command = "/usr/local/apps/datafax/reports/DF_QCupdate 20 ";	
  
  call symput('command1', command);
  
  put command;
run;

data _NULL_;
   x "&command1";
   x "chmod -f g+rw /ttcmv/DataFax/work/*";
   x "chgrp -f studies *";
run;

data _NULL_;
  filename = "pt_missing_current.txt"; 		
  command = "/usr/local/apps/datafax/reports/DF_PTmissing 20  > /ttcmv/sas/data/pt_missing_current.txt";	
  call symput('filename', filename);	
  call symput('command1', command);
  put filename;
  put command;
run;

data _NULL_;
   x "&command1";
   x "chmod -f g+rw /ttcmv/DataFax/work/*";
   x "chgrp -f studies *";
run;
		 
* read first half of the columns (the first table);
data ptcrf;
 infile "/ttcmv/sas/data/pt_missing_current.txt"  missover firstobs=8  ; * when importing a file from the cumulative QC report: firstobs= 12 obs=18 ;
		input id   visit  problem $  ;
 if id =. then delete;
run;	


proc sql;

create table ptcrf2 as
select distinct(id) as id , 1 as missingflag from ptcrf;

create table MissedCRF as
select a.* , b.id as Missingid, missingflag
from cmv.Endofstudy as a left join
ptcrf2 as b
on a.id=b.id;

drop table ptcrf; drop table ptcrf2;
quit;


data MissedCRF; set MissedCRF;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
if missingflag=. then missingflag=0;
run;



proc sql;
create table summary1 as
select count(*) as count,  center  from MissedCRF where missingflag=1 group by center
union

select count(*) as count, 0 as center  from MissedCRF where missingflag=1
;

create table summary2 as
select count(*) as total, center  from MissedCRF where missingflag In (1,0) group by center
union

select count(*) as total, 0 as  center   from MissedCRF where missingflag In (1,0);


create table summary as
select a.*,b.*
from summary1 as a, summary2 as b
where a.center=b.center ;

drop table summary1; drop table summary2;
quit;


data summary (keep =center  stat  pipe) ; set summary;
stat = Trim(Left(total-count)) || "/" || Trim(Left(total)) || " ( " || Trim(Left(put(((total-count)/total)*100,10.))) || " )";
*stat =  Trim(Left(put((count/total)*100,10.))) ;
pipe="|";
run; 
