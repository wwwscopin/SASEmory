ods listing;
proc sgscatter data=sashelp.cars;
	plot (horsepower enginesize)*(mpg_city mpg_highway)/markerattrs=(size=3) loess=(clm);
run;

proc sgplot data=sashelp.classfit noautolegend;
	scatter x=height y=weight;
	series x=height y=predict;
run;

proc sgplot data=sashelp.classfit noautolegend;
	scatter x=height y=weight;
	series x=height y=predict /lineattrs=GraphFit;
run;

proc sgplot data=sashelp.class;
	scatter x=height y=weight/group=sex;
run;

proc sgplot data=sashelp.classfit noautolegend;
	ellipse x=height y=weight /alpha=0.5;
	scatter x=height y=weight /group=sex;
run;

proc sgplot data=sashelp.classfit;
	ellipse x=height y=weight /alpha=0.25;
		ellipse x=height y=weight /alpha=0.5;
	scatter x=height y=weight /group=sex;
	reg x=height y=weight / clm;
run;

proc sgplot data=sashelp.stocks;
	yaxis grid;
	series x=date y=close/group=stock;
run;

proc sgpanel data=sashelp.stocks;
	panelby stock/ columns=1;
	rowaxis grid;
	series x=date y=close;
run;

title1 "Product Sales";
proc sgpanel data=sashelp.prdsale;
	panelby year quarter;
	rowaxis label="Sales";
	vbar product /response=predict transparency=0.3;
    vbar product /response=actual barwidth=0.5 transparency=0.3;
run;


title1 "Product Sales";
proc sgpanel data=sashelp.prdsale;
	by year;
	panelby quarter;
	rowaxis label="Sales";
	vbar product /response=predict transparency=0.3;
    vbar product /response=actual barwidth=0.5 transparency=0.3;
run;

