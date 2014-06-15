data cmv.completedstudylist; set cmv.endofstudy; if reason ~= 5; 
	daysleftstudy = today() - studyleftdate;
	keep id studyleftdate daysleftstudy;
run;


