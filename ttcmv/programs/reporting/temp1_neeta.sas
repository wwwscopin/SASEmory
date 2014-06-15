

proc sql;
create table xx as
select count(*) from tx_eos where id eq 2006311 ;

quit;
