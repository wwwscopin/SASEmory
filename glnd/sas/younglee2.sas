data x;
   merge glnd.younglee1 (in=a)  glnd.status(keep=id treatment);
   by id;
  if a;


ods pdf file='younglee2.pdf';
proc print;
  var id treatment;
title Treatment A is AG-PN, B is STD-PN;
run;
ods pdf close;

proc freq;
 tables treatment;
