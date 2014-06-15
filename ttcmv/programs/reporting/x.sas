proc sql; create table rop_weight as
select a.* , b.id, b.id2,b.center,b.group_type,weight_group
from cmv.rop as a inner join
id_weight as b
on a.id=b.id;

quit;

title "ivh";
proc freq data=ivh_weight;
tables center*weight_group*group_type;
run;
title "bpd";
proc freq data=bpd_weight;
tables center*weight_group*group_type;
run;
title "pda";
proc freq data=pda_weight;
tables center*weight_group*group_type;
run;
title "rop";
proc freq data=rop_weight;
tables center*weight_group*group_type;
run;
