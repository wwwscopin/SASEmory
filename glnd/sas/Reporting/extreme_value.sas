proc univariate data=glnd_ext.redox plots;
    var gsh_concentration gssg_concentration Cys_concentration CysSS_concentration;
run;

proc print data=glnd_ext.redox;
    where gsh_concentration>7 or gssg_concentration>7 or Cys_concentration>200 or CysSS_concentration>200;
    var id day gsh_concentration gssg_concentration Cys_concentration CysSS_concentration;
run;

proc univariate data=glnd_ext.cytokines plots;
    var il6 il8 ifn tnf;
run;

proc print data=glnd_ext.cytokines;
    where il6>3000 or il8>2000 or ifn>1000 or tnf>1000;
    var id day il6 il8 ifn tnf;
run;


