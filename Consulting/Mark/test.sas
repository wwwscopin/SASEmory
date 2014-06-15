options nodate pageno=1 linesize=64 pagesize=60;
data empdata;
input IdNumber $ 1-4 LastName $ 9-19 FirstName $ 20-29 
      City $ 30-42 State $ 43-44 /
      Gender $ 1 JobCode $ 9-11 Salary 20-29 @30 Birth date7.
      @43 Hired date7. HomePhone $ 54-65;
format birth hired date7.;
datalines;
1919    Adams      Gerald    Stamford     CT
M       TA2        34376     15SEP70      07JUN05    203/781-1255
1653    Alexander  Susan     Bridgeport   CT
F       ME2        35108     18OCT72      12AUG98    203/675-7715
1400    Apple      Troy      New York     NY
M       ME1        29769     08NOV85      19OCT06    212/586-0808
1350    Arthur     Barbara   New York     NY
F       FA3        32886     03SEP63      01AUG00    718/383-1549
1401    Avery      Jerry     Paterson     NJ
M       TA3        38822     16DEC68      20NOV93    201/732-8787
1499    Barefoot   Joseph    Princeton    NJ
M       ME3        43025     29APR62      10JUN95    201/812-5665
1101    Baucom     Walter    New York     NY
M       SCP        18723     09JUN80      04OCT98    212/586-8060
1333    Blair      Justin    Stamford     CT
M       PT2        88606     02APR79      13FEB03    203/781-1777
1402    Blalock    Ralph     New York     NY
M       TA2        32615     20JAN71      05DEC98    718/384-2849
1479    Bostic     Marie     New York     NY
F       TA3        38785     25DEC66      08OCT03    718/384-8816
1403    Bowden     Earl      Bridgeport   CT
M       ME1        28072     31JAN79      24DEC99    203/675-3434
1739    Boyce      Jonathan  New York     NY
M       PT1        66517     28DEC82      30JAN00    212/587-1247
1658    Bradley    Jeremy    New York     NY
M       SCP        17943     11APR65      03MAR00    212/587-3622
1428    Brady      Christine Stamford     CT
F       PT1        68767     07APR80      19NOV02    203/781-1212
1782    Brown      Jason     Stamford     CT
M       ME2        35345     07DEC73      25FEB00    203/781-0019
1244    Bryant     Leonard   New York     NY
M       ME2        36925     03SEP71      20JAN96    718/383-3334
1383    Burnette   Thomas    New York     NY
M       BCK        25823     28JAN76      23OCT00    718/384-3569
1574    Cahill     Marshall  New York     NY
M       FA2        28572     30APR74      23DEC97    718/383-2338
1789    Caraway    Davis     New York     NY
M       SCP        18326     28JAN85      14APR04    212/587-9000
1404    Carter     Donald    New York     NY
M       PT2        91376     27FEB71      04JAN98    718/384-2946
1437    Carter     Dorothy   Bridgeport   CT
F       A3         33104     23SEP68      03SEP92    203/675-4117
1639    Carter     Karen     Stamford     CT
F       A3         40260     29JUN65      31JAN92    203/781-8839
1269    Caston     Franklin  Stamford     CT
M       NA1        41690     06MAY80      01DEC00    203/781-3335
1065    Chapman    Neil      New York     NY
M       ME2        35090     29JAN72      10JAN95    718/384-5618
1876    Chin       Jack      New York     NY
M       TA3        39675     23MAY66      30APR96    212/588-5634
1037    Chow       Jane      Stamford     CT
F       TA1        28558     13APR82      16SEP04    203/781-8868
1129    Cook       Brenda    New York     NY
F       ME2        34929     11DEC79      20AUG03    718/383-2313
1988    Cooper     Anthony   New York     NY
M       FA3        32217     03DEC57      21SEP92    212/587-1228
1405    Davidson   Jason     Paterson     NJ
M       SCP        18056     08MAR54      29JAN00    201/732-2323
1430    Dean       Sandra    Bridgeport   CT
F       TA2        32925     03MAR70      30APR05    203/675-1647
1983    Dean       Sharon    New York     NY
F       FA3        33419     03MAR50      30APR85    718/384-1647
1134    Delgado    Maria     Stamford     CT
F       TA2        33462     08MAR77      24DEC04    203/781-1528
1118    Dennis     Roger     New York     NY
M       PT3        111379    19JAN57      21DEC88    718/383-1122
1438    Donaldson  Karen     Stamford     CT
F       TA3        39223     18MAR63      21NOV03    203/781-2229
1125    Dunlap     Donna     New York     NY
F       FA2        28888     11NOV76      14DEC95    718/383-2094
1475    Eaton      Alicia    New York     NY
F       FA2        27787     18DEC71      16JUL98    718/383-2828
1117    Edgerton   Joshua    New York     NY
M       TA3        39771     08JUN56      16AUG00    212/588-1239
1935    Fernandez  Katrina   Bridgeport   CT
F       NA2        51081     31MAR72      19OCT01    203/675-2962
1124    Fields     Diana     White Plains NY
F       FA1        23177     13JUL82      04OCT01    914/455-2998
1422    Fletcher   Marie     Princeton    NJ
F       FA1        22454     07JUN79      09APR99    201/812-0902
1616    Flowers    Annette   New York     NY
F       TA2        34137     04MAR68      07JUN01    718/384-3329
1406    Foster     Gerald    Bridgeport   CT
M       ME2        35185     11MAR69      20FEB95    203/675-6363
1120    Garcia     Jack      New York     NY
M       ME1        28619     14SEP80      10OCT01    718/384-4930
1094    Gomez      Alan      Bridgeport   CT
M       FA1        22268     05APR78      20APR99    203/675-7181
1389    Gordon     Levi      New York     NY
M       BCK        25028     18JUL67      21AUG03    718/384-9326
1905    Graham     Alvin     New York     NY
M       PT1        65111     19APR80      01JUN00    212/586-8815
1407    Grant      Daniel    Mt. Vernon   NY
M       PT1        68096     26MAR77      21MAR98    914/468-1616
1114    Green      Janice    New York     NY
F       TA2        32928     21SEP77      30JUN06    212/588-1092
;

proc sort data=empdata out=tempemp;
   by jobcode gender;
run;
ods listing;

ods rtf file="test.rtf" style=journal;
proc print data=tempemp split='*';
 	
   id jobcode;
   by jobcode;
   var gender salary;
 	
   sum salary;
 	
   label jobcode='Job Code*========'
         gender='Gender*======'
         salary='Annual Salary*=============';
 	
   format salary dollar11.2;
   where jobcode contains 'FA' or jobcode contains 'ME';
   title 'Salay Expenses';
run;
ods rtf close;

goptions reset=all;
ods rtf file="test2.rtf" style=journal;
proc report data=tempemp split='*' nowindows;
 	
   column jobcode gender salary;
   define jobcode/order 'Job Code*========' style(column)=[cellwidth=1in just=center];
   define gender/'Gender*======' style(column)=[cellwidth=1in just=center];
   define salary/'Annual Salary*=============' style(column)=[cellwidth=1in just=center];
   where jobcode contains 'FA' or jobcode contains 'ME';
   title 'Salay Expenses';
run;
ods rtf close;
quit;
