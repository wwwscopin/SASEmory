

proc sql;

create table cmv.plate_216_long as
select id, milk_date_1 as milk_date, rapid_test_1 as rapid_test, conv_test_1 as conv_test
from cmv.plate_216 where milk_date_1 is not null
union
select id, milk_date_2 as milk_date, rapid_test_2 as rapid_test, conv_test_2 as conv_test
from cmv.plate_216 where milk_date_2 is not null
union
select id, milk_date_3 as milk_date, rapid_test_3 as rapid_test, conv_test_3 as conv_test
from cmv.plate_216 where milk_date_3 is not null

union
select id, milk_date_4 as milk_date, rapid_test_4 as rapid_test, conv_test_4 as conv_test
from cmv.plate_216 where milk_date_4 is not null

;
quit;
