

proc sql;

create table cmv.plate_211_long as
select id, urinecollectdate_1 as urineDate, UrineTestResult_1 as UrineTestResult,UrineCopyNumber_1 as UrineCopyNumbber,dfseq
from cmv.plate_211 where urinecollectdate_1 is not null
union
select id, urinecollectdate_2 as urineDate, UrineTestResult_2 as UrineTestResult,UrineCopyNumber_2 as UrineCopyNumbber,dfseq
from cmv.plate_211 where urinecollectdate_2 is not null
union
select id, urinecollectdate_3 as urineDate, UrineTestResult_3 as UrineTestResult,UrineCopyNumber_3 as UrineCopyNumbber,dfseq
from cmv.plate_211 where urinecollectdate_3 is not null
union
select id, urinecollectdate_4 as urineDate, UrineTestResult_4 as UrineTestResult,UrineCopyNumber_4 as UrineCopyNumbber,dfseq
from cmv.plate_211 where urinecollectdate_4 is not null
union
select id, urinecollectdate as urineDate, UrineTestResult as UrineTestResult,UrineCopyNumber as UrineCopyNumbber,dfseq
from cmv.lbwi_urine_nat_result where urinecollectdate is not null

;
quit;

data cmv.plate_211_long; set cmv.plate_211_long;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;
