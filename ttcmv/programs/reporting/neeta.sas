proc sql;
create table xx as
select distinct donorunitid, DateDonated,DateIrradiated
from cmv.plate_001_bu
quit;
