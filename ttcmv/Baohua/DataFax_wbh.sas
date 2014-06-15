

*options mprint mlogic;

**** export the QC notes from the dedicated datafax plate (511) for QCs to a text file ;
data _NULL_;
  command = "$DATAFAX_DIR/bin/DataFax &";	
 		
  call symput('command1', command);
run;

data _NULL_;
  x "&command1";
run;
