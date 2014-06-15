
	proc sort data=glnd_rep.last_contact_closed;
		 by id;
	run;
data apa;
 set glnd.status;
 keep id apache_2 ;
proc sort; by id;

data xy;
 merge glnd_rep.last_contact_closed apa;
 by id;
 if id=32156 then apache_2=2;
ods ps file='survival.ps';
 proc lifetest plot=(s) nocensplot ;
        time days*deceased(0);
        run;

ods ps close;

ods ps file='survival_closed.ps' ;
	*ods graphics on;
	*ods select survival;
	proc lifetest plot=(s) nocensplot notable;
	time days*deceased(0);
   strata treatment;
   format treatment trt.;
	run;
ods ps closed;
endsas;

proc sort;
 by apache_2;
proc lifetest plot=(s) nocensplot notable;
	time days*deceased(0);
   strata treatment;
   format treatment trt.;
 by apache_2;
	run;
	*ods graphics off;
	*ods ps close;
	
