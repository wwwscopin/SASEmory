



proc freq data=chemistry_plot;


where dfseq =40;
tables pO2value;
run;
