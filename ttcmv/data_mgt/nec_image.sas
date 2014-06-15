/* NEC image.sas
 *
 * NEC images form - TTCMV
 *
 */

proc sql;

create table cmv.nec_image as
select * from  cmv.nec_image_case1
union
select * from  cmv.nec_image_case2
union
select * from  cmv.nec_image_case3;

quit;


proc print;
run;
	
