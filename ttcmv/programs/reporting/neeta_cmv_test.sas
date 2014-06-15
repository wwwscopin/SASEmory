


proc sql;
create table xx as 

select id2, max(NAT) from (
select id as id2 , max(NATTestResult)  as NAT ,"Blood" as x from cmv.Lbwi_Blood_NAT_Result where  NATTestResult In (1,2,3,4) group by id
union
select id as id2 , max(urineTestResult)  as NAT  ,"urine" as xx from cmv.Lbwi_urine_NAT_Result where  urineTestResult In (1,2,3,4)group by id
)
group by id2
;

quit;
