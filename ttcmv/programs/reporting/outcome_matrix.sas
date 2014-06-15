* this file creates outcomes and Tx counts, one record per observation;


%include "&include./monthly_toc.sas";
proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where IsEligible=1 ;

quit;


*  ;


data enrolled (drop=id2);
 set enrolled;


id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


proc format;

value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;

run;

%macro getoutcome(data=, cname=, group =);

proc sql;

%if &group=1 %then %do; 
create table AllOutcomes as
select a.*, b.total as &cname

from enrolled as a
left join
(select count(*) as total, id
from  &data 
group by id
) as b
on a.id =b.id;

%end;


%if &group > 1 %then %do; 
create table AllOutcomes as
select a.*, b.total as &cname

from AllOutcomes as a
left join
(select count(*) as total, id
from  &data 
group by id
) as b
on a.id =b.id;

%end;

quit;



%mend getoutcome;




%getoutcome(data=cmv.Pda, cname=PDA, group=1);
%getoutcome(data=cmv.Ivh, cname=IVH, group=2);
%getoutcome(data=cmv.bpd, cname=BPD, group=3);
%getoutcome(data=cmv.rop, cname=ROP, group=4);

%getoutcome(data=cmv.Rbctx, cname=RBC_Tx, group=5);
%getoutcome(data=cmv.Platelettx, cname=Plt_Tx, group=6);
%getoutcome(data=cmv.Ffptx, cname=FFP_Tx, group=7);


*options nodate nonumber orientation = landscape; 

ods rtf file = "&output./monthly/&outcome_tx_status_file.outcome_tx_status.rtf"  style=journal

toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&outcome_tx_status_title LBWI Outcomes and Transfusion Status Table";





*ods rtf file = "103_form_outcome_display.rtf" style = journal  toc_data startpage = yes;
*ods noproctitle  proclabel "Table 3 : Outcomes and Tx Details";
	/* Print patient details */

	
	title1  justify = center "&outcome_tx_status_title LBWI Outcomes and Tx detail   ";

   
   proc print data = AllOutcomes label noobs split = "_" style(header) = [just=center] contents = ""; 
    by center;
	var center id DateOfBirth PDA IVH BPD ROP RBC_Tx Plt_Tx FFP_Tx;
format center center.;
label center="Hospital";
run; 

ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
