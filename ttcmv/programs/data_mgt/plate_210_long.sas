

proc sql;

create table cmv.plate_210_long as
select id, datebloodcollected_1 as collectiondate, NATTestResult_1 as nattestresult, NATCopyNumber_1 as copynumber,dfseq
from cmv.plate_210 where datebloodcollected_1 is not null
union
select id, datebloodcollected_2 as collectiondate, NATTestResult_2 as nattestresult, NATCopyNumber_2 as copynumber,dfseq
from cmv.plate_210 where datebloodcollected_2 is not null
union
select id, datebloodcollected_3 as collectiondate, NATTestResult_3 as nattestresult, NATCopyNumber_3 as copynumber,dfseq
from cmv.plate_210 where datebloodcollected_3 is not null
union
select id, datebloodcollected_4 as collectiondate, NATTestResult_4 as nattestresult, NATCopyNumber_4 as copynumber,dfseq
from cmv.plate_210 where datebloodcollected_4 is not null

;
quit;

data cmv.plate_210_long; set cmv.plate_210_long;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;
