options ORIENTATION="LANDSCAPE";

data hb0;
	set cmv.plate_015;
	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	*if HbDate=. then delete;
	keep id HbDate Hb;
run;

proc print;

var id hb;
where hb>25;
run;


proc sort data=hb0 nodupkey;by id HbDate;run;

proc sql;

create table hb as
select a.*  , LBWIDOB as DateOfBirth 
from 
hb0 as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;
quit;

data hb;
	set hb; by id HbDate;
	if DateOfBirth=. then 
	if first.id then do; base=HbDate; DateOfBirth=base; retain base; end;
	else DateOfBirth=base;
	day0=Hbdate-DateOfBirth;
	if day0>=5 then day=round(day0/7)*7;
	else if day0^=0 then day=3;
	else day=0;
	drop base;
run;

