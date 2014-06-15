/*screening_thin.sas
 *
 * screening_thin - TTCMV
 *
 */



data screen_log ;
set cmv.plate_101_bu;


run;


proc transpose data=screen_log out=screen_log_temp1 (keep=DCCUnitid col1);
   by DCCUnitid;
   var lbwi_id_1-lbwi_id_20;

run;

proc transpose data=screen_log out=screen_log_temp2 (keep=DCCUnitid col2);
   by DCCUnitid;
   var lbwi_id_1-lbwi_id_20;

run;

proc sql;

create table cmv.screen_log as
select DCCUnitid, col1 as id from screen_log_temp1 where col1 is not null
union
select DCCUnitid, col2 as id from screen_log_temp2 where col2 is not null

;


quit;

