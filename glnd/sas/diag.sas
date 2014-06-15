
ods pdf file='diag.pdf';
proc freq data=glnd.basedemo;
 tables diag;
 where dt_random < mdy(1,1,2008);
title Primary Diagnosis Pre Jan 3, 2008;
