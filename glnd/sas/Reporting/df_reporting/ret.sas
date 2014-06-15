data x;
  set glnd_df.submission_summary;
  if attended_visit_disp ne '';  
  n=index(attended_visit_disp," ");
  r=substr(attended_visit_disp,1,n-1)+0;
  per=r*100/count;
day=3;
 if substr(form,1,1)='B' then day=0;
 if substr(form,5,1)='7' then day=7;
 if substr(form,6,1)='4' then day=14;
 if substr(form,6,1)='1' then day=21;
 if substr(form,6,1)='8' then day=28;
  keep form attended_visit_disp count r per day;
proc sort; by day;
proc means noprint sum;
 by day;
 var count r;
 output out=new sum=count r;
run;
data final;
  set new;
  per=round(r*100/count, .1);
 label day='Blood Collection Day'
       r='# Obtained'
       per='Percent';
options ls=80 ;
title GLND Retention;
ods pdf file='ret.pdf';
proc print noobs label;
 var day r per;
run;
ods pdf close;
